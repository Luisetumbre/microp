module ALUcontrol (instruction,ALUOp,ALUoperation);
input [3:0] instruction; // bit 30 y 14:12 de el codigo de instruccion
input [3:0] ALUOp; //Viene del  controlpath

output reg [3:0] ALUoperation; //Codigo de operacion que mandaremos a la ALU

always @* //Sintetiza Latch!!!!!
begin
	case (ALUOp)
	1: //Instrucciones de tipo I (inmediato)
		case (instruction[2:0])
			3'b0xx:
				if(instruction[3]==0)
					ALUoperation=0; //ADD, ADDI
				else
					ALUoperation=1; //SUB
			
			3'b111:
				ALUoperation=2;
			3'b110:
				ALUoperation=3;
			3'b100:
				ALUoperation=4;
		default:
			ALUoperation=0;
		endcase
	
	2: //Instrucciones de tipo SB (BNE,BEQ)
		ALUoperation=1;
	
	3:
		ALUoperation=0;
	
default:
				ALUoperation=0;
			
	endcase
end

endmodule
