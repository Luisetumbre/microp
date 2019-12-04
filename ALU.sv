module ALU(A,B,ALU_operation,ALU_result,zero);
input [31:0] A,B;
input [3:0] ALU_operation;
output reg [31:0] ALU_result;
output reg  zero;

always @(A,B,ALU_operation)
	begin
	if (A==B)
		zero = 1'b1;
		else
			zero=1'b0;
	case (ALU_operation)
			4'h0:
				ALU_result= A+B; //ADD, ADDI, LW,SW,
			4'h1: 
				ALU_result= A-B; //SLTI, SLTIU, SUB, BEQ, BNE, SLT, SLTU            					
			4'h2: 
				ALU_result= A & B; //ANDI, AND
			4'h3: 
				ALU_result= A | B; //ORI, OR
			4'h4: 
				ALU_result= A ^ B; //XORI, XOR		
							
		default: ALU_result=A+B;
		endcase
	end
	
endmodule
	
	

			