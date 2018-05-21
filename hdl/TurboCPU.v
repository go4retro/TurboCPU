`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:58:09 05/19/2018 
// Design Name: 
// Module Name:    TurboCPU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module TurboCPU(
                //input _reset_cpu,
                //input clock_cpu, 
                //input clock_dot,
                //input clock_mult
                input r_w_cpu, 
                input[2:1] _io,
                //input _roml,
                //input _romh,
                //output _exrom,
                //output _game,
                //output _irq,
                //output _nmi,
                input [15:0]address_cpu, 
                inout [7:0]data_cpu,
                output _enbus,
                output [18:0]address_mem,
                inout [7:0]data_mem,
                output _we_mem,
                output _ce_ram
               );


assign _we_mem =                 r_w_cpu;
assign address_mem[18:8] =       0;
assign address_mem[7:0] =        address_cpu[7:0];
assign _ce_ram =                 _io[1];
assign data_cpu =                (!_io[1] & r_w_cpu ? data_mem : 8'bz);
assign data_mem =                (!_io[1] & !r_w_cpu ? data_cpu : 8'bz);
assign _enbus =                  1; // disable cpu address drivers


endmodule
