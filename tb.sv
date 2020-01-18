class Rands;
  parameter N=32;
  randc logic [N-1:0] inst;
  
  constraint op_code_I {inst[6:0] dist {7'b0010011:=6, 7'b0000011:=1};} 
  constraint op_code_R {inst[6:0]==7'b0110011;}
  constraint op_code_S {inst[6:0]==7'b0100011;}
  constraint op_code_B {inst[6:0]==7'b1100011;}
 
  constraint funct_3_RI{soft inst[14:12] != 3'b001; soft inst[14:12] != 3'b101;}
  constraint funct_3_S{inst[14:12] == 3'b010;}
  constraint funct_3_B{inst[14:12] < 3'b10;}
  
  constraint funct_7{inst[31:25] dist{7'h0:=6, 7'h20:=1};}
  
endclass

`timescale 1ns/1ps

/////////INTERFAZ///////////
//señales:
//CLK,RESET_N,idata,ddata_r,iaddr,daddr,ddata_w,d_rw
interface Interfaz (
  input  bit        reloj  , 
  input   bit      rst);
  logic [31:0] idata, iaddr, ddadr, ddata_r, ddata_w;
  logic rw;

clocking cb_dut @(posedge reloj);
  default input #1ns output #1ns;
    input idata;
    input ddata_r;
    output iaddr;
    output ddata_w;
    output ddadr;
    output rw;
  endclocking

clocking cb_tb @(posedge reloj);
  default input #1ns output #1ns;
    output idata;
    output ddata_r;
    input iaddr;
    input ddata_w;
    input ddadr;
    input rw;
  endclocking
  
clocking monit @(posedge reloj);
  default input #1ns output #1ns;
    input idata;
    input ddata_r;
    input iaddr;
    input ddata_w;
    input ddadr;
    input rw;
  endclocking
 
  //from dut, output data input enable
  modport dut_p (clocking cb_dut);
  // from tb, input data output enable
  modport tb_p (clocking cb_tb);
  //monitor 
  modport monitor (clocking monit);

  //hacer modport para el dut!
  modport duv (
  	input reloj,
  	input rst,
  	input idata,
  	input ddata_r,
  	output ddadr,
  	output iaddr,
  	output ddata_w,
  	output rw
  	);

  
endinterface


////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////

class Scoreboard; //Scoreboard receive's the sampled packet from monitor
  parameter N=32;
  //used to count the number of transactions
	int no_transactions;
	reg [N-1:0] target, result, aux1, aux2;
	reg [4:0] rd;
	reg [11:0] imm;
	reg [4:0] rs1, rs2;
	reg [31:0] pc;
	
	virtual Interfaz.monit puertos;
	
  //constructor
  function new(virtual Interfaz.monit ports); //como es el constructor?, instanciando interfaz y monitor?
  begin
  this.puertos = ports;
  end
  endfunction
   
	task modoI;
	input [31:0] instruccion;
	string nombre;
	nombre = mnemonico(instruccion);
	case (nombre)
		"addi":
			target = aux1 + imm;
		"slti":
		begin
			if(aux1<imm) target=1'b1;
			else target 1'b0;
		end
		"sltiu":
		begin
			if(aux1<imm) target=1'b1;
			else target 1'b0;
		end
		"xori":
			target = aux1 ^ imm;
		"ori":
			target = aux1 | imm;
		"andi":
			target = aux1 & imm;
		default:
	endcase
	
	endtask
	
	
	task modoR;
	input [31:0] instruccion;
	string nombre;
	nombre = mnemonico(instruccion);
	case (nombre)
		"add":
			target = aux1 & aux2;
		"sub":
			target = aux1 - aux2;
		"slt":
			if(aux1<rs2) target=1'b1;
			else target = 1'b0;
		"sltu":
		begin
			if(aux1<rs2) target=1'b1;
			else target = 1'b0;
		end
		"xor":
			target = aux1 ^ aux2;
		"or":
			target = aux1 | aux2;
		"and":
			target = aux1 & aux2;
		default:
	endcase
	
	endtask
	
	
	task modoS;
	input [31:0] instruccion;
	string nombre;
	nombre = mnemonico(instruccion);
	case (nombre)
		"beq":
		begin
			if (aux1 == aux2)
			pc = pc + {imm,1'b0};
			else 
			pc = pc;
	end
		"bne":
		begin
			if (aux1 != aux2)
			pc = pc + {imm,1'b0};
			else 
			pc = pc;
		end
	endcase // nombre
	endtask
	
	
//	task modoSB;
//	input [31:0] instruccion;
//	string nombre;
//	nombre = mnemonico(instruccion); //sólo está Sw
//	mem [aux1 + imm] = aux2
	
	
	task checkResult;
	assert (target == result) else $info("No concuerda el resultado del micro con el correcto");
	endtask

	task setGlobals;
		input [31:0] instruction;
		case(getInstType(instruction))
			2'b00: //R
			begin
				rs1=getRs1(instruction);
				rs2=getRs2(instruction);
			end
			2'b01: //I
			begin
				rs1=getRs1(instruction);
				imm=getImm(instruction,getInstType(instruction));
			end
			2'b10: //S
			begin
				rs1=getRs1(instruction);
				rs2=getRs2(instruction);
				imm=getImm(instruction,getInstType(instruction));
			end
			2'b11: //B
			begin
				rs1=getRs1(instruction);
				rs2=getRs2(instruction);
				imm=getImm(instruction,getInstType(instruction));
			end
		endcase
	endtask
	
	
	function bit [6:0] getOpcode;
  input [31:0] instruction;
  getOpcode = instruction [6:0];
endfunction : getOpcode

function bit [2:0] getFunct3;
  input [31:0] instruction;
  getFunct3 = instruction [14:12];
endfunction : getFunct3

function bit [6:0] getFunct7;
  input [31:0] instruction;
  getFunct7 = instruction [31:25];
endfunction : getFunct7

function bit [11:0] getImm;
  input [31:0] instruction;
  input [1:0] inst_type;
  case (inst_type)
  //R-format No hay inmediato
  2'b01: //I-format
  getImm = instruction [31:20];
  2'b10: //S-format
  getImm = {instruction[31:25], instruction[11:7]};
  2'b11: //SB-format
  getImm = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
  default:
  getImm = 0;
  endcase
endfunction : getImm

function bit [4:0] getRs1;
  input [31:0] instruction;
  getRs1 = instruction [19:15];
endfunction : getRs1

function bit [4:0] getRs2;
  input [31:0] instruction;
  getRs2 = instruction [24:20];
endfunction : getRs2

function bit [4:0] getRd;
  input [31:0] instruction;
  getRd = instruction [11:7];
endfunction : getRd

function bit [1:0] getInstType;
  input [6:0] opCode; //entra opCode
  case (opCode)
  //R-format
  7'b0110011:
  getInstType = 2'b00;
  7'b0111011:
  getInstType = 2'b00;
  //I-format
  7'b0000011: 
  getInstType = 2'b01;
  7'b0010011:
  getInstType = 2'b01;
  7'b0011011:
  getInstType = 2'b01;
  7'b1100111:
  getInstType = 2'b01;
  7'b1110011:
  getInstType = 2'b01;
  //S-format
  7'b0100011:
  getInstType = 2'b10;
  //SB-format
  7'b1100011:
  getInstType = 2'b11;
  endcase
  
endfunction : getInstType



function string mnemonico;
input [31:0] instruccion;
	reg [6:0] opcode;
	reg [1:0] tipoInstruccion;
	reg [9:0] group;
	reg [6:0] funct7;
	reg [2:0] funct3;
	string format;
	//primero sacamos el opcode y el formato de la instruccion
	opcode = getOpcode(instruccion);
	tipoInstruccion = getInstType(opcode);
	case (tipoInstruccion)
		2'b00:
		format = "R-format";
		2'b01:
		format = "I-format";
		2'b10:
		format = "S-format";
		2'b11:
		format = "SB-format";
	endcase
	//$display("formato = %d",format);
	funct3 = getFunct3(instruccion);
	//Ahora nos separamos por formatos
	//R-format
	
	if(format=="R-format")
	begin
		funct7 = getFunct7(instruccion);
		group = {funct7,funct3}; //agrupamos funct7 y funct3 para diferenciar ahora el tipo de instruccion que tenemos
		case (group)
		10'h000:
		mnemonico = "add";
		10'h100:
		mnemonico = "sub";
		10'h002:
		mnemonico = "slt";
		10'h003:
		mnemonico = "sltu";
		10'h004:
		mnemonico = "xor";
		10'h006: 
		mnemonico = "or";
		10'h007:
		mnemonico = "and";
		default:
		mnemonico = "unknown or not implemented";
		endcase
	end
	
	else if(format=="I-format")
	begin
		group = {funct3,opcode}; //agrupamos funct3 con opcode para diferenciar el tipo de instruccion como antes
		case (group)
		10'h013:
		mnemonico = "addi";
		10'h113:
		mnemonico = "slti";
		10'h193:
		mnemonico = "sltiu";
		10'h213:
		mnemonico = "xori";
		10'h313:
		mnemonico = "ori";
		10'h393: 
		mnemonico = "andi";
		10'h103:
		mnemonico = "lw";
		default:
		mnemonico = "unknown or not implemented";
		endcase
	end
	
	else if(format=="S-format")
	begin
		group = {funct3,opcode};
		case (group)
		10'h123:
		mnemonico = "sw";
		default:
		mnemonico = "unknown or not implemented";
		endcase
	end
	
	else if(format == "SB-format")//SB-format
	begin
		group = {funct3,opcode};
		case (group)
		10'h063:
		mnemonico = "beq";
		10'h0E3:
		mnemonico = "bne";
		default:
		mnemonico = "unknown or not implemented";
		endcase
	end
	$display("Instruccion:%d",mnemonico);
	endfunction: mnemonico

endclass : Scoreboard

////probamos la funcion
//reg [31:0] instruccion = 32'h01DF0F33;
//reg [6:0] opcode;
//reg [1:0] tipoInstruccion;
//reg [9:0] group;
//reg [6:0] funct7;
//reg [2:0] funct3;
//string format;
//string nombre;
//
//initial 
//	begin
//		opcode = getOpcode(instruccion);
//		$display("OpCode =%b",opcode);
//		tipoInstruccion = getInstType(opcode);
//		nombre = mnemonico(instruccion);
//		newInst(instruccion);
//	end




/////////////////////////////////////////////




program estimulos
	(Interfaz.tb_p testar,
	Interfaz.monitor monitor
	);

covergroup Rcover;
	AluOP:coverpoint testar.cb_tb.idata[6:0] {
	bins OpR = {51};//7'h33
	}
	fun7:coverpoint testar.cb_tb.idata[31:25]{
	bins funct7[2] = {0,32}; //2 bins, b[0]=0 and b[1]=32
  	}
  	fun3:coverpoint  testar.cb_tb.idata[14:12]{
  	bins funct3 [8] = {[0:7]};
 	}
 	fuente1: coverpoint testar.cb_tb.idata[19:15];
  	fuente2: coverpoint testar.cb_tb.idata[24:20];
  	destino: coverpoint testar.cb_tb.idata[11:7];
endgroup

covergroup Icover;
	AluOp:coverpoint testar.cb_tb.idata[6:0]{
	bins OpI [2]= {3,19}; //2 bins, b[0]=3 and b[1]=19
	}
	fun3:coverpoint  testar.cb_tb.idata[14:12]{
  	bins funct3 [8] = {[0:7]};
 	}
 	fuente1: coverpoint testar.cb_tb.idata[19:15];
  	destino: coverpoint testar.cb_tb.idata[11:7];
  	//inmediatos:coverpoint {monitor.monit.idata[31:20]}{
  	//bins positivo = {1:8191};
  	//bins negativo = {8192:16383};
//}
endgroup

covergroup Scover;
   	AluOp:coverpoint monitor.monit.idata[6:0]{
	bins OpS = {35}; //7'h23
	}
	fun3:coverpoint  monitor.monit.idata[14:12]{
  	bins funct3 [8] = {[0:7]};
 	}
 	fuente1: coverpoint monitor.monit.idata[19:15];
  	fuente2: coverpoint monitor.monit.idata[24:20];
  	//inmediatos:coverpoint {monitor.monit.idata[31:25],monitor.monit.idata[11,7]}{
  	//bins positivo = {1:8191};
  	//bins negativo = {8192:16383};
  	//}

endgroup

covergroup Bcover;  //Definicion del covergroup   
 	AluOp:coverpoint  monitor.monit.idata[6:0]
  	{
  	bins OpB = {99};//7'h63
  	}
 	fun3:coverpoint  monitor.monit.idata[14:12]
  	{
 	bins funct3 [8] = {[0:7]};
 	}
 	fuente1: coverpoint monitor.monit.idata[19:15];
 	fuente2: coverpoint monitor.monit.idata[24:20];
 	//inmediatos:coverpoint {monitor.monit.idata[31],monitor.monit.idata[7],monitor.monit.idata[30:25],monitor.monit.idata[11,8]}{
  	//bins positivo = {1:8191};
  	//bins negativo = {8192:16383};
  	//}
endgroup; 

//Declaracion Scoreboard
Scoreboard sb;
//Declaracion aleatorios
Rands randsInst;
//Declaracion covergroups
Rcover rcov;
Icover icov;
Scover scov;
Bcover bcov;
string nombre;

initial
begin
	randsInst = new; //creamos el objeto de los aleatorios
	sb = new(monitor); //creamos el scoreboard
	icov = new; //creamos el covergroup de las instrucciones R
	
	//rellenar el banco de registros
	duv.DUT.Register.reg_file[1] = 32'h3;
	duv.DUT.Register.reg_file[24] = 32'h9;
	duv.DUT.Register.reg_file[3] = 32'h8;
	duv.DUT.Register.reg_file[6] = 32'h7;
	duv.DUT.Register.reg_file[21] = 32'h30;
	
	@(testar.cb_tb);
	$display("Probamos instrucciones I");
	while (icov.get_coverage()<90) begin
	randsInst.op_code_R.constraint_mode(0);
	randsInst.funct_7.constraint_mode(0);
	randsInst.op_code_I.constraint_mode(1);
	randsInst.funct_3_RI.constraint_mode(1);
	randsInst.op_code_S.constraint_mode(0);
	randsInst.op_code_B.constraint_mode(0);
	randsInst.funct_3_S.constraint_mode(0);
	randsInst.funct_3_B.constraint_mode(0);
	
	assert (randsInst.randomize()) else    $info("Fallo en la aleatorizacion");
	if (randsInst.inst[6:0]==7'h3)
	randsInst.inst[14:12]=3'b010;

	$display("IDATA:%h",randsInst.inst);
	//nombre = sb.mnemonico(randsInst.inst);
	sb.setGlobals(randsInst);
	//sb.modoI(randsInst.inst);
	testar.cb_tb.idata <= randsInst.inst;
	@(testar.cb_tb);
	sb.result <= monitor.monit.ddadr;
	$display("Target: %d",sb.result);
	modoI(randsInst.inst);
	checkResult();
	icov.sample();
	end
	
	rcov = new();
	$display ("Probamos instrucciones R");
	//while (rcov.get_coverage()<90) begin
	repeat (20) begin
	randsInst.op_code_R.constraint_mode(1);
	randsInst.funct_7.constraint_mode(1);
	randsInst.op_code_I.constraint_mode(0);
	randsInst.funct_3_RI.constraint_mode(1);
	randsInst.op_code_S.constraint_mode(0);
	randsInst.op_code_B.constraint_mode(0);
	randsInst.funct_3_S.constraint_mode(0);
	randsInst.funct_3_B.constraint_mode(0);
	assert (randsInst.randomize()) else    $info("Fallo en la aleatorizacion");
	$display("IDATA:%h",randsInst.inst);
	testar.cb_tb.idata <= randsInst.inst;
	sb.target <= monitor.monit.ddadr;
	@(testar.cb_tb);
	rcov.sample();
	end
	@(testar.cb_tb);
end

endprogram






module top_duv(Interfaz.duv bus);
 	bit clk;
 	bit rst_n;

	Interfaz intf1(clk, rst_n);

	procesador_singlecycle DUT (
  		.CLK(bus.reloj),
  		.RESET_N(bus.rst),
  		.idata(bus.idata),
  		.ddata_r(bus.ddata_r),
  		.iaddr(bus.iaddr), 
  		.daddr(bus.ddadr),
  		.ddata_w(bus.ddata_w),
  		.d_rw(bus.rw) 
  		);

endmodule : top_duv

////////////////////////////////////////////////////////////////////////

module tb();                                         
// general purpose registers
reg CLK;
reg RESET;

//interfaz
Interfaz interfaz(.reloj(CLK),.rst(RESET));

 //diseño rtl top               
top_duv duv (.bus(interfaz));
            
//program  
estimulos estim1 (.testar(interfaz),.monitor(interfaz));  

// CLK
always
begin
  CLK = 1'b0;
  CLK = #50 1'b1;
  #50;
end 

// RESET
initial
begin
  RESET=1'b0;
  # 3 RESET = 1'b1;
end 
  
initial begin
  $dumpfile("singlecycle_test.vcd");
  $dumpvars(0,tb);  
end  
endmodule