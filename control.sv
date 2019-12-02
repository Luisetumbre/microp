module control (Instruction,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite);
input [6:0] Instruction;
output reg Branch,MemRead,MemtoReg,MemWrite,ALUSrc,RegWrite;
output reg [3:0] AlUOp; 

//Decodificacion del tipo de instruccion:
always @(Instruction)
begin
	Branch=1'b0;
	MemRead=1'b0;
	MemtoReg=1'b0;
	MemWrite=1'b0;
	ALUSrc=1'b0;
	RegWrite=1'b0;
	ALUOp=4'h0;
	case (Instruction)
		7'b0000011: //LW
		begin
		
			Branch=1'b0;
			MemRead=1'b1;
			MemtoReg=1'b1;
			MemWrite=1'b1;
			ALUSrc=1'b0;
			RegWrite=1'b1;
			ALUOp=4'h0; //Suma
		end
		
		7'b0010011:   //Instrucciones tipo I
		begin
			Branch=1'b0;
			MemRead=1'b1;
			MemtoReg=1'b1;
			MemWrite=1'b1;
			ALUSrc=1'b1; 
			RegWrite=1'b1;
			ALUOp=4'h0;
		end
		
		7'b0110011: //Instrucciones tipo R
		begin
			Branch=1'b0;
			MemRead=1'b1;
			MemtoReg=1'b1;
			MemWrite=1'b1;
			ALUSrc=1'b0;
			RegWrite=1'b1;
			ALUOp=4'h0;
		end
		
		7'b0100011: //Instrucciones tipo S
		begin
			Branch=1'b0;
			MemRead=1'b1;
			MemtoReg=1'b1;
			MemWrite=1'b1;
			ALUSrc=1'b0;
			RegWrite=1'b1;
			ALUOp=4'h0;
		end
		
		7'b1100011: //Instrucciones tipo SB (LOS BRANCHES)
		begin
			Branch=1'b1;
			MemRead=1'b1;
			MemtoReg=1'b1;
			MemWrite=1'b1;
			ALUSrc=1'b0;
			RegWrite=1'b1;
			ALUOp=4'h0;
		end
	endcase
	end
endmodule
		
		
		
		
			
		
			