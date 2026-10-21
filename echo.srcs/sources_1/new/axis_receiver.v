


module axis_receiver
#(
    parameter WIDTH = 16
    
)
(


    input wire                      s_axis_aclk,
    input wire                      s_axis_resetn,
    input wire signed [WIDTH-1:0]   s_axis_tdata,
    input wire                      s_axis_tvalid,

    
    output wire                     s_axis_tready,
    output reg signed [WIDTH-1:0]   last_sample

);
 
 assign s_axis_tready = 1'b1;

 always@(posedge s_axis_aclk or negedge s_axis_resetn)begin
    if(!s_axis_resetn)begin
        last_sample <= 0;
    end else if(s_axis_tready && s_axis_tvalid) begin
        last_sample <= s_axis_tdata;
    end  
 end
 
endmodule
