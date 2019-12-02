module Register (clk, reset, RegWrite, RegRead_1, RegRead_2, w_reg, w_data, r_data1,r_data2);
	
	//parameter nreg=32;
	//parameter width= 32;
	//parameter size= clog2(width);
		
	input clk, reset, RegWrite;
	input [4:0] RegRead_1, RegRead_2, w_reg; //[size-1:0]
	input [31:0]  w_data;
	output reg  [31:0] r_data1, r_data2; //[width-1:0]

	reg[31:0] reg_file[0:31]; //[width-1 :0] en ambos casos 

	// Se podria colocar un for para inicializarlos todos  pero da latches.
	


always @(posedge clk) 
 begin
	  
	if (RegWrite) 
			if(w_reg != 0)
			reg_file[w_reg] <=  w_data;
 end

	assign r_data1= reg_file[RegRead_1];
	assign r_data2= reg_file[RegRead_2];


endmodule
