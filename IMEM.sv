module IMEM(clk,iaddr,idata);
`include "MathFun.vh"
parameter length=1024;
localparam n=CLogB2(length);
input clk; 
input [n-1:0] iaddr; 
output reg [31:0] idata;


reg [31:0] rom [0:length-1];

initial
begin

$redmemh("memoryrom.list",rom);
end 
  
assign idata=rom[iaddr];

endmodule