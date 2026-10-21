module echo
#(
    parameter WIDTH = 16,
    parameter DEL   = 8

)
(

    input wire                      s_axis_aclk,
    input wire                      s_axis_resetn,
    input wire signed [WIDTH-1:0]   s_axis_tdata,
    input wire                      s_axis_tvalid,
    input wire                      m_axis_tready,

    input wire  clear,
    

    input wire [$clog2(DEL):0]      delay,
    input wire [$clog2(3)-1:0]      shift,
    
    output wire [WIDTH-1:0]         m_axis_tdata,
    output wire                     m_axis_tvalid,
    output wire                     s_axis_tready

);
       
    
   reg signed [WIDTH-1:0] echo_reg_del [DEL-1:0];
   reg signed [WIDTH:0]   adder;
   reg signed [WIDTH-1:0] adder_reg;
      
   wire step = s_axis_tvalid && s_axis_tready;
   
   
   integer i;
    
   always @(posedge s_axis_aclk or negedge s_axis_resetn) begin
        if(~ s_axis_resetn)begin
            for (i = 0; i < DEL; i = i+1)begin
                echo_reg_del[i] <= 0;
            end    
        end else if(clear)begin
            for (i = 0; i < DEL; i = i+1)begin
                echo_reg_del[i] <= 0;
            end  
        end else if (step)begin
            echo_reg_del[0] <= adder;
            for (i = 1; i < DEL; i = i+1)begin
                echo_reg_del[i] <= echo_reg_del[i-1];
            end

        end        
    end
   
    reg signed [WIDTH:0] mux_out;

    always @(*) begin
             case (delay)
                  4'd1 : begin
                             mux_out = echo_reg_del[0];
                           end
                  4'd2 : begin
                             mux_out = echo_reg_del[1];
                           end
                  4'd3 : begin
                              mux_out = echo_reg_del[2];
                           end
                  4'd4 : begin
                              mux_out = echo_reg_del[3];
                           end
                  4'd5 : begin
                              mux_out = echo_reg_del[4];
                           end
                  4'd6 : begin
                              mux_out = echo_reg_del[5];
                           end
                  4'd7 : begin
                             mux_out = echo_reg_del[6];
                           end
                  4'd8 : begin
                             mux_out = echo_reg_del[7];
                           end
                  default: begin
                            mux_out  = echo_reg_del[0];
                           end
               endcase         
    end
    
    
    
    
    always @(*) begin
        adder = s_axis_tdata + (mux_out >>> shift);
        if(adder > 32767)begin
            adder = 32767;
        end else if (adder < -32768)begin
            adder = -32768;
        end    
    end




    always @(posedge s_axis_aclk or negedge s_axis_resetn) begin
        if(~ s_axis_resetn)begin
            adder_reg <= 0;
        end else if (clear)begin
            adder_reg <= 0;
        end else if (step)begin
            adder_reg <= adder;
        end        
    end
    
    reg out_valid;

    always @(posedge s_axis_aclk or negedge s_axis_resetn) begin
        if(~ s_axis_resetn)begin
            out_valid <= 0;
        end else if (clear)begin
            out_valid <= 0;
        end else if(s_axis_tready) begin
            out_valid <= s_axis_tvalid;
        end             
    end

    
    
    assign s_axis_tready = ~out_valid | m_axis_tready;
    
    assign m_axis_tvalid =  out_valid;
    assign m_axis_tdata  =  adder_reg;
    
endmodule
