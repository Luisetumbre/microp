module try;

//declaracion de funcion
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

//probamos la funcion
reg [31:0] instruccion = 32'h00050513;
reg [6:0] opcode;
reg [1:0] tipoInstruccion;
reg [9:0] groupR;
reg [6:0] funct7;
reg [2:0] funct3;
string format;
string mnemonico;

initial 
	begin
		opcode = getOpcode(instruccion);
		$display("OpCode =%d",opcode);
		tipoInstruccion = getInstType(opcode);
		$display("Formato de Instruccion =%d",tipoInstruccion);
	end

initial
	begin
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
	$display("formato = %d",format);
	funct3 = getFunct3(instruccion);
	//Ahora nos separamos por formatos
	//R-format
	if(format=="R-format")
	begin
		funct7 = getFunct7(instruccion);
		groupR = {funct7,funct3}; //agrupamos funct7 y funct3 para diferenciar ahora el tipo de instruccion que tenemos
		case (groupR)
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
		endcase
	end
	else if(format=="I-format")
		
	
	end
endmodule