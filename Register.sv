module Register (CLK, RESET_N, RegWrite, RegRead_1, RegRead_2, w_reg, w_data, r_data1,r_data2);
	
input CLK, RESET_N, RegWrite;
input [4:0] RegRead_1, RegRead_2, w_reg; //[size-1:0]
input [31:0]  w_data;
output   reg [31:0] r_data1, r_data2; //[width-1:0]

reg[31:0] reg_file[0:31]; //[width-1 :0] en ambos casos 

always @(posedge CLK or negedge RESET_N) 
 begin
    
	if(!RESET_N)
		for(int i=0;i<32;i=i+1)
			begin
				reg_file[i]<=32'b0;
			end
	else
	 
	if (RegWrite) //Si queremos escribir en el banco de registros 
			if(w_reg != 0) //si el registro en el que queremos escribir NO ES el x0
			reg_file[w_reg] <=  w_data;
 end

	assign r_data1= reg_file[RegRead_1];
	assign r_data2= reg_file[RegRead_2];
	
endmodule
