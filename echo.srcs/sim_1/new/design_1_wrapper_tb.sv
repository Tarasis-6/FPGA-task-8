`timescale 1ns / 1ps

module design_1_wrapper_tb();


  reg          clk_100MHz;
  reg          reset_rtl_0;        
  wire [15:0]  last_sample;



   initial begin
       clk_100MHz  = 0;
       reset_rtl_0 = 0;
   end

  always #5 clk_100MHz = ~clk_100MHz;


   initial begin
    repeat(200) @(negedge clk_100MHz);
    reset_rtl_0 = 1;        
       
    repeat(20000) @(negedge clk_100MHz);
                       
    $finish;
   end


design_1_wrapper dut(.*);


endmodule