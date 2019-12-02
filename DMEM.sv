module DMEM(clk,mem0_dw,mem0_dr,mem0_ena,mem0_rw,out);
`include "MathFun.vh"
parameter N=1024;
localparam n=CLogB2(N);
input clk,mem0_ena,mem0_rw;

input [n-1:0] mem0_dr;
input [31:0] mem0_dw; 
 
output reg [31:0] out;


reg [31:0] ram [0:N-1];

initial
begin

$redmemh("memoryram.list",ram);
end

always @ (posedge clk) 
  begin
  
   if(mem0_ena && mem0_rw)
	  ram[mem0_dr]<=mem0_dw; 
  end  

assign out=ram[mem0_dr];   

endmodule