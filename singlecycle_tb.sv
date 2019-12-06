`timescale 1ns/1ps

module singlecycle_tb;
	
	parameter n=32;
		
	reg	CLK;
	reg RESET_N;
	
	wire[31:0] idata; //Bus de direcciones
	wire [31:0] ddata_r; //Bus de datos
	
	wire [n-1:0] iaddr, daddr;
	wire  [31:0] ddata_w;
	wire d_rw;
	
	always //RESET_N
		begin
			CLK = 1'b0;
			CLK = #50 1'b1;
			#50;
		end 
	
	
	initial
		begin
			RESET_N=1'b1;
			# 1  RESET_N=1'b0;
			#99 RESET_N = 1'b1;
		end 

//   **** CORE ****
	procesador_singlecycle CORE
	(
		.CLK(CLK) ,	// input  CLK_sig
		.RESET_N(RESET_N) ,	// input  RESET_N_sig
		.idata(idata) ,	// input [31:0] idata_sig
		.ddata_r(ddata) ,	// input [31:0] ddata_r_sig
		.iaddr(iaddr) ,	// output [n-1:0] iaddr_sig
		.daddr(daddr) ,	// output [n-1:0] daddr_sig
		.ddata_w(ddata_w) ,	// output [31:0] ddata_w_sig
		.d_rw(d_rw) 	// output  d_rw_sig
	);
	
// ***** Memoria de DATOS *****	
	DMEM DATOS
(
	.clk(CLK) ,	// input  clk_sig
	.memO_dw(ddata_w) ,	// input [31:0] memO_dw_sig
	.memO_ena(1'b1) ,	// input  memO_ena_sig
	.memO_rw(d_rw) ,	// input  memO_rw_sig
	.out(daddr) 	// output [31:0] out_sig
);

defparam DMEM_inst.N = 1024;

// ***** Memoria de INSTRUCCIONES *****
IMEM INSTRUCCIONES
(
	.clk(CLK) ,	// input  clk_sig
	.idata(idata),
	.iaddr(iaddr)// output [31:0] idata_sig
);

defparam IMEM_inst.length = 1024;




endmodule 

