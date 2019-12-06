module generador_inmediato (instruction,Imm);
input [31:0] instruction;
output [31:0] Imm;

always @ (*) begin
	case (instruction[6:0])
		7'b00x0011: //Inmediato para instrucciones tipo I
			Imm={{20{instruction[31]}},instruction[30:25],instruction[24:21],instruction[20]};
			
		7'b0100011: //Inmediato instrucciones tipo B
			Imm={{20{instruction[31]}},instruction[30:25],instruction[11:8],instruction[7]};
			
		7'b1100011: //Instrucciones tipo B
			Imm={{19{instruction[31]}},instruction[7],instruction[30:25],instruction[11:8],1'b0};
		default:
			Imm=0;
	endcase
		end	

endmodule
