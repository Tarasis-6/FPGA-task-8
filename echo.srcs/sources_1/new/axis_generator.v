module axis_generator
 #(
    parameter WIDTH  = 16,
    parameter PERIOD = 32
    
)
(
    
  input  m_axis_aclk,
  input  m_axis_resetn,
  
  output  signed [WIDTH-1:0] m_axis_tdata,
  output reg                 m_axis_tvalid,
  input                      m_axis_tready
  
);
 reg [$clog2(PERIOD)-1:0] cnt;
 
 always@(posedge m_axis_aclk or negedge m_axis_resetn)begin
    if(!m_axis_resetn)begin
        cnt <= 0;
        m_axis_tvalid <= 0;
    end else if(m_axis_tvalid && m_axis_tready) begin
        cnt <= cnt + 1;
    end else begin
        m_axis_tvalid <= 1;
    end   
 end
 
 assign m_axis_tdata   = (cnt == PERIOD-1) ? 16'd10000 : 16'd0;

 
 
 
endmodule