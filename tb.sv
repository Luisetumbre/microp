class Bus;
  parameter N=32;
  randc logic [N-1:0] inst_i;
  randc logic [N-1:0] inst_r;
  randc logic [N-1:0] inst_s;
  randc logic [N-1:0] inst_b;
  constraint op_code_I {inst_i[6:0]==7'b0010011;};
  constraint op_code_R {inst_r[6:0]==7'b0110011;};
  constraint op_code_S {inst_s[6:0]==7'b0100011;};
  constraint op_code_B {inst_b[6:0]==7'b1100011;};
endclass

`timescale 1ns/1ps

/////////INTERFAZ///////////
//señales:
//CLK,RESET_N,idata,ddata_r,iaddr,daddr,ddata_w,d_rw
interface test_if (
  input  bit        reloj  , 
  input   bit      rst);
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
  
  valores_ALUOp:coverpoint  monitorizar.md.
  R_W:coverpoint  monitorizar.md.rw;
  inst_code:coverpoint monitorizar.codigo_instruccion;
  fuente1: coverpoint {monitorizar.codigo_instruccion[19:15]}
  fuente2: coverpoint {monitorizar.codigo_instruccion[24:20]}
  destino: coverpoint {monitorizar.codigo_instruccion[11:7]}
  inmediatos: coverpoint
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

task separarBus()
begin
end
endtask



endmodule