class Bus;
  randc logic [7:0] valor;
  constraint impares    {valor[0] == 1'b1;}
  constraint pares {valor[0] == 1'b0;}
endclass

`timescale 1ns/1ps

/////////INTERFAZ///////////
//señales:
//CLK,RESET_N,idata,ddata_r,iaddr,daddr,ddata_w,d_rw
interface test_if (
  input  bit        reloj  , 
  input   bit      rst);
  parameter N=32;
  logic [N-1:0] insdat, busdata, next_mem, pos_mem;
  logic rw;


  clocking md @(posedge reloj);
	input #1ns insdat;
	input #1ns busdata;
	output #1ns next_mem;
	output #1ns pos_mem;
  output #1ns rw;
   endclocking:md;

  clocking sd @(posedge reloj);
  output #1ns insdat;
  output #1ns busdata;
  input #1ns next_mem;
  input #1ns pos_mem;
  input #1ns rw;
  endclocking:sd;


  	modport monitor (clocking md);
    modport test (clocking sd);
    modport duv (
  		input reloj,
      input rst,
      input insdat,
      input busdata,
      output next_mem,
      output pos_mem,
      output rw
		);
endinterface


////////////////COVERGROUPS/////////////

covergroup valores;  //Definicion del covergroup   
  
  valores_A:coverpoint  monitorizar.md.data_in_A; //valores que consigue A (aleatorios)
  valores_B:coverpoint  monitorizar.md.data_in_B; //valores que consigue B (aleatorios)
  par_impar: coverpoint {monitorizar.md.data_in_A[0],monitorizar.md.data_in_B[0]}
  {
    bins par_par ={0};
    bins par_impar={1};
    bins impar_par={2};
    bins impar_impar={3};
  }
  
  signo_operandos: coverpoint {monitorizar.md.data_in_A[7], monitorizar.md.data_in_B[7]} //Coverpoint como el signo de los operandos
    {
    bins positivopositivo ={0};
  bins positivonegativo ={1};
  bins negativopositivo ={2};
  bins negativonegativo ={3}; //distintos bins dependiendo de las combinaciones
  }
  cross par_impar, signo_operandos;
  //cross valores_A, valores_B; esto hay que quitarlo porque es imposible conseguir el maximo
endgroup;   


////////////////////////////////////

module prueba_radicador();
// constants                                           
// general purpose registers
reg CLK;
reg RESET;
reg START;
reg [7:0] X;
// wires                                               
wire [3:0] COUNT, target;
wire FIN;


event comprobar; 
covergroup valores_X;    
  coverpoint  X;
endgroup;                       
//declaraciones de dos objetos
  Bus busInst;
  valores_X veamos;
// assign statements (if any)                          
sed i1 (
// port map - connection between master ports and signals/registers   
	.CLK(CLK),
	.COUNT(COUNT),
	.FIN(FIN),
	.RESET(RESET),
	.START(START),
	.X(X)
);
  assign target=$floor($sqrt(integer'(X)));
// CLK
always
begin
	CLK = 1'b0;
	#50;
	CLK =  1'b1;
    #50;
end 

// RESET
initial
begin
  RESET=1'b1;
  # 1  RESET=1'b0;
	#99 RESET = 1'b1;
end 

// START
initial
begin
     
  busInst = new;//construimos la case de valores random
  veamos=new;//construimos el covergroup
	START <= 1'b0;
	X = 8'd25;
	repeat (3) @(posedge CLK);
	START <= 1'b1;
	@(posedge CLK);
	START <= 1'b0;
	@(posedge FIN);
	-> comprobar;
	@(negedge FIN);
  while ( veamos.get_coverage()<40)
	begin
	   busInst.pares.constraint_mode(0);
	   $display("pruebo con impares");
	   assert (busInst.randomize()) else    $fatal("randomization failed");
    	X = busInst.valor;	
    	veamos.sample();
    	@(posedge CLK);
	   START <= 1'b1;
	   @(posedge CLK);
	   START <= 1'b0;
	   @(posedge FIN);
	   -> comprobar;
	   @(negedge FIN);
   end
  while ( veamos.get_coverage()<90)
	begin
 	   busInst.impares.constraint_mode(0);
	   busInst.pares.constraint_mode(1);
	   $display("pruebo con pares");
	   assert (busInst.randomize()) else    $fatal("randomization failed");
    	X = busInst.valor;	
    	veamos.sample();  
    	@(posedge CLK);  	
	   START <= 1'b1;
	   @(posedge CLK);
	   START <= 1'b0;
	   @(posedge FIN);
	   -> comprobar;
	   @(negedge FIN);
   end
   $stop;
end 
always @(comprobar)
begin
	@(posedge CLK);
	assert (COUNT==target) else $error("operacion mal realizada: la raiz cuadrada de %d es %d y tu diste %d",X,target,COUNT);
	end


 
initial begin
  $dumpfile("radicador.vcd");
  $dumpvars(1,prueba_radicador);
end 


endmodule
