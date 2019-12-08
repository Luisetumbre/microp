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
interface Interfaz (
  input  bit        reloj  , 
  input   bit      rst);
  logic [N-1:0] insdat, busdata_r, next_mem, pos_mem, busdata_w;
  logic rw;

clocking cb_dut @(posedge reloj);
  default input #2ns output #2ns;
    input insdat;
    input busdata_r;
    output next_mem;
    output pos_mem;
    output busdata_w;
    output rw;
  endclocking

clocking cb_tb @(posedge reloj);
  default input #2ns output #2ns;
    output insdat;
    output busdata_r;
    input next_mem;
    input pos_mem;
    input busdata_w;
    input rw;
  endclocking
  // from tb, input data output enable
  modport tb_p (clocking cb_tb);
  //from dut, output data input enable
  modport dut_p (clocking cb_dut);
endinterface


////////////////COVERGROUPS/////////////

covergroup valores;  //Definicion del covergroup   
  
  valores_ALUOp:coverpoint  monitorizar.md.
  R_W:coverpoint  monitorizar.md.rw;
  inst_code:coverpoint monitorizar.codigo_instruccion;
  fuente1: coverpoint {monitorizar.codigo_instruccion[19:15]}
  fuente2: coverpoint {monitorizar.codigo_instruccion[24:20]}
  destino: coverpoint {monitorizar.codigo_instruccion[11:7]}
  //inmediatos: coverpoint
endgroup;   
////////////////////TASKS///////////
task automatic separaBus(input [N-1] instruccion); //variables dinamicas con automatic
  
endtask : separaBus

////////////////////////////////////

module testBench();
  bit clk;
  bit rst_n;

  Interfaz intf1(clk, rst_n);

  procesador_singlecycle DUT (intf1.dut_p);

  //reloj
  always #10 clk = ~clk;

endmodule : testBench



