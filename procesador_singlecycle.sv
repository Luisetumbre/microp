module procesador_singlecycle (CLK,RESET_N,idata,ddata_r,iaddr,daddr,ddata_w,d_rw);
//comentario
parameter n=32;

//Definicion de los puertos de la interfaz
input CLK,RESET_N;
input [n-1:0] idata; //Instruccion de datos
input [n-1:0] ddata_r; //Bus de datos

output [n-1:0] iaddr, daddr; //siguiente posicion de memoria de la instruccion
//daddr es posicion de memoria del dato
output  [n-1:0] ddata_w; //bus de datos de escritura
output d_rw; //lectura-escritura

wire [31:0] Imm;
wire [31:0] Imm_desplazado;
wire w_Branch;
wire w_RegWrite;
wire w_MemRead;
wire w_MemtoReg;
wire branch_zero;

wire [31:0] w_Readdata1;
wire [31:0] w_Writedata; //Cable que une salida mux 2a1 con puerto Write_data del banco de registros 
wire [3:0] ALUOp;
//Instanciacion control-path
control control (.Instruction(idata[6:0]),
					  .Branch(w_Branch),
					  .MemRead(d_rw),
					  .MemtoReg(w_MemtoReg),
					  .ALUOp(ALUOp),
					  .MemWrite(1'b1), //senyal de escritura en memoria
					  .ALUSrc(ALUSrc),
					  .RegWrite(w_RegWrite));

wire [31:0] w_ALU_result;
wire [31:0] w_B;
wire [3:0] operacionALU;
wire w_zero;
wire ALUSrc;
wire [31:0] salida_sumador_instrucciones;
assign w_B=ALUSrc ? Imm : w_Readdata2; //Multiplexor 2 a 1

ALU ALU (.A(w_Readdata1),
			.B(w_B),
			.zero(w_zero),
			.ALU_result(w_ALU_result),
			.ALU_operation(operacionALU));
			
ALUcontrol ALUCONTROL (.instruction({idata[30],idata[14:12]}),
							  .ALUOp(ALUOp),
							  .ALUoperation(operacionALU));

wire [31:0] w_Readdata2;
		
Register Register (.CLK(CLK),
						 .RESET_N(RESET_N),
						 .RegWrite(w_RegWrite),
						 .RegRead_1(idata[19:15]),
						 .RegRead_2(idata[24:20]),
						 .w_reg(idata[11:7]),
						 .w_data(w_Writedata), //cable salida mux
						 .r_data1(w_Readdata1),
						 .r_data2(w_Readdata2));

assign w_Writedata=w_MemtoReg? ddata_r : w_ALU_result; //Multiplexor 2 a 1

//Generador del inmediato
generador_inmediato gen_Imm (.instruction(idata),
									  .Imm(Imm));

assign branch_zero=w_Branch & w_zero; //Variable de seleccion para mux al salida sumador
assign Imm_desplazado={Imm[30:0],Imm[31]};

assign ddata_w=w_Readdata2; //Bus de datos de escritura	 
assign salida_sumador_instrucciones=Imm_desplazado+idata;

assign iaddr=branch_zero?salida_sumador_instrucciones:(idata+4); //Bus de direcciones
assign daddr=w_ALU_result; //Bus de direcciones de datos

endmodule 
