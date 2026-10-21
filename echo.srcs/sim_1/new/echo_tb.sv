`timescale 1ns / 1ps


module echo_tb();


  parameter WIDTH = 16;
  parameter DEL   = 8;

  reg   s_axis_aclk;
  reg   s_axis_resetn;
  reg   s_axis_tvalid;
  reg   m_axis_tready; 
  reg   clear;
  
  reg  signed [WIDTH-1:0]       s_axis_tdata;

  reg         [$clog2(DEL):0]   delay;
  reg         [$clog2(3)-1:0]   shift;


  wire signed [WIDTH-1:0] m_axis_tdata;
  wire                    m_axis_tvalid, s_axis_tready;

  integer errors = 0, beats = 0;
  integer test_num = 0, test_err0;


   initial begin

       s_axis_aclk      = 0;
       s_axis_resetn    = 0;
       s_axis_tvalid    = 0;
       m_axis_tready    = 0;
       clear            = 0;
       s_axis_tdata     = 0;

       delay = 0;
       shift = 0;

   end

  always #5 s_axis_aclk = ~s_axis_aclk;


  task send;
    input signed [WIDTH-1:0] d;
    begin
      @(negedge s_axis_aclk);
      s_axis_tdata  <= d;
      s_axis_tvalid <= 1;
      @(posedge s_axis_aclk);
      while (!s_axis_tready) @(posedge s_axis_aclk);   // held until accepted
    end
  endtask

  task idle;
    begin
      @(negedge s_axis_aclk);
      s_axis_tvalid <= 0;
      s_axis_tdata  <= 0;
    end
  endtask

  task expect_out;
    input signed [WIDTH-1:0] exp;
    integer t;
    begin
      t = 0;
      @(posedge s_axis_aclk);
      while (!(m_axis_tvalid && m_axis_tready) && t < 50) begin
        @(posedge s_axis_aclk);
        t = t + 1;
      end
      if (t == 50) begin
        $display("[%0t] FAIL beat %0d: no output within 50 cycles (exp %0d)", $time, beats, exp);
        errors = errors + 1;
      end else if (m_axis_tdata === exp)
        $display("[%0t] PASS beat %0d: got %0d", $time, beats, m_axis_tdata);
      else begin
        $display("[%0t] FAIL beat %0d: exp %0d got %0d", $time, beats, exp, m_axis_tdata);
        errors = errors + 1;
      end
      beats = beats + 1;
    end
  endtask


  // --- start a test: name, new delay/shift, delay line cleared ---
  task test_begin;
    input [(8*32)-1:0] name;
    input integer d;
    input integer s;
    begin
      test_num  = test_num + 1;
      test_err0 = errors;
      @(negedge s_axis_aclk); clear = 1;
      @(negedge s_axis_aclk); clear = 0;
      delay = d;
      shift = s;
      $display("---- test %0d: %0s  (delay=%0d, shift=%0d)", test_num, name, d, s);
    end
  endtask

  task test_end;
    begin
      if (errors == test_err0) $display("     test %0d PASS", test_num);
      else                     $display("     test %0d FAIL (%0d errors)", test_num, errors - test_err0);
    end
  endtask


   initial begin

    repeat(5)@(negedge s_axis_aclk);
    s_axis_resetn = 1;
    @(negedge s_axis_aclk);
    @(negedge s_axis_aclk); m_axis_tready = 1;
    
    test_begin("impulse response",1, 1);
    fork
      begin                               
        send(10000);
        send(0); send(0); send(0); send(0); send(0); send(0);
        idle;
      end
      begin                                
        expect_out(10000);
        expect_out(5000);
        expect_out(2500);
        expect_out(1250);
        expect_out(625);
        expect_out(312);
        expect_out(156);

      end
    join
    test_end;

    test_begin("clear", 3, 2);
    fork
      begin
        send(20000);
        send(0);
        send(0);
        send(0);
        send(0);
        send(0);
        send(0);
        idle;
      end
      begin
        expect_out(20000);
        expect_out(0);
        expect_out(0);
        expect_out(5000);
        expect_out(0);
        expect_out(0);
        expect_out(1250);
      end
    join
    test_end;


    test_begin("saturation", 1, 0);
    fork
      begin
        send(20000);
        send(20000);
        send(-30000);
        send(-30000);
        send(-30000);
        idle;
      end
      begin
        expect_out(20000);
        expect_out(32767);                          
        expect_out(2767);
        expect_out(-27233);
        expect_out(-32768);                       
      end
    join
    test_end;

    $display("==========================================");
    if (errors == 0) $display("RESULT: PASS  (%0d beats checked)", beats);
    else             $display("RESULT: FAIL  (%0d errors in %0d beats)", errors, beats);
    $display("==========================================");

    $finish;

   end


echo  dut(.*);


endmodule