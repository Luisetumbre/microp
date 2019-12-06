module control (Instruction,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite);
input [6:0] Instruction;
output reg Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite;
output reg [3:0] ALUOp; 




//ALUSrc : si es 1 el operando es INMEDIATO y si es 0 esta en memoria
//Decodificacion del tipo de instruccion:
always @(*)
begin
	case (Instruction)
		7'b0000011: //LW
		begin
	   	Branch=1'b0;
			MemRead=1'b1;
			MemtoReg=1'b1;
			MemWrite=1'b0;
			ALUSrc=1'b0;
			RegWrite=1'b1;
			ALUOp=3; //Solo suma
		end
		
		7'b0010011:   //Instrucciones tipo I
		begin
			Branch=1'b0;
			MemRead=1'b1;
			MemtoReg=1'b1;
			MemWrite=1'b0;
			ALUSrc=1'b1; 
			RegWrite=1'b1;
			ALUOp=4'h1; //Operandos inmediato
		end
		
		7'b0110011: //Instrucciones tipo R
		begin
			Branch=1'b0;
			MemRead=1'b1;
			MemtoReg=1'b1;
			MemWrite=1'b0;
			ALUSrc=1'b0;
			RegWrite=1'b1;
			ALUOp=4'h1; //Los bits de funct3 coinciden con las instrucciones de tipo I
		end
		
		7'b0100011: //Instruccion SW
		begin
			Branch=1'b0;
			MemRead=1'b0;
			MemtoReg=1'b0;
			MemWrite=1'b1;
			ALUSrc=1'b0;
			RegWrite=1'b0;
			ALUOp=3; //SOLO SUMA
		end
		
		7'b1100011: //Instrucciones BEQ,BNE
		begin
			Branch=1'b1;
			MemRead=1'b0;
			MemtoReg=1'b0;
			MemWrite=1'b0;
			ALUSrc=1'b0;
			RegWrite=1'b1;
			ALUOp=4'h2; //Haremos una resta
		end		
		
		default:
			begin
			Branch=1'b0;
			MemRead=1'b0;
			MemtoReg=1'b0;
			MemWrite=1'b0;
			ALUSrc=1'b0;
			RegWrite=1'b1;
			ALUOp=4'h0;
			end
	endcase
	end
endmodule
		
		
		
		
			
		
			