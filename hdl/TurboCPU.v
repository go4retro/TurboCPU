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
                input _reset_cpu,
                input clock_cpu, 
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
                output reg [18:0]address_mem,
                inout [7:0]data_mem,
                output reg _we_mem,
                output reg _ce_ram,
                output _ce_dat,
                output clock_cocpu,
                output _reset_cocpu,
                output _abort_cocpu,
                output _ready_cocpu,
                output _irq_cocpu,
                output _nmi_cocpu,
                output _be_cocpu,
                input r_w_cocpu,
                inout [7:0]data_cocpu
               );

wire ce_dffx;
wire ce_dffe;
wire ce_dfff;
wire [18:8]address_mem_bank;
wire [18:16]address_cocpu_bank;

assign ce_dffx =           !_io[2] & (address_cpu[7:2] == 6'b111111);
assign ce_dffc =           ce_dffx & (address_cpu[1:0] == 0);
assign ce_dffd =           ce_dffx & (address_cpu[1:0] == 1);
assign ce_dffe =           ce_dffx & (address_cpu[1:0] == 2);
assign ce_dfff =           ce_dffx & (address_cpu[1:0] == 3);
reg [7:0]data_cpu_out;
reg [7:0]data_mem_out;
reg [7:0]data_cocpu_out;
 
assign _ce_dat =           1;
assign _abort_cocpu =      1;
assign _ready_cocpu =      1;
assign _irq_cocpu =        1;
assign _nmi_cocpu =        1;
assign _be_cocpu =         1;
assign clock_cocpu =       !clock_cpu;

assign data_cpu =          data_cpu_out;
assign data_mem =          data_mem_out;
assign data_cocpu =        data_cocpu_out;
assign _enbus =            clock_cpu;

register #(.WIDTH(8))      reg_dffe(
                                    clock_cpu, 
                                    !_reset_cpu, 
                                    ce_dffe & !r_w_cpu, 
                                    data_cpu[7:0], 
                                    address_mem_bank[15:8]
                                   );

register #(.WIDTH(3))      reg_dfff(
                                    clock_cpu, 
                                    !_reset_cpu, 
                                    ce_dfff & !r_w_cpu, 
                                    data_cpu[2:0], 
                                    address_mem_bank[18:16]
                                   );
register #(.WIDTH(1))      reg_cocpu(
                                     clock_cpu, 
                                     !_reset_cpu, 
                                     ce_dffc & !r_w_cpu, 
                                     data_cpu[0], 
                                     _reset_cocpu
                                   );
                                   register #(.WIDTH(3))      reg_bank(
                                    clock_cpu, 
                                    !_reset_cpu, 
                                    1, 
                                    data_cocpu[2:0], 
                                    address_cocpu_bank
                                   );
always @(*)
begin
   if(clock_cpu & !_io[1]) // cpu access
   begin
      address_mem = {address_mem_bank, address_cpu[7:0]};
      _we_mem = r_w_cpu; // main cpu cycle
      _ce_ram = 0;
   end
   else
   begin
      address_mem = {address_cocpu_bank, 16'bz}; // cocpu access
      _we_mem = r_w_cocpu;
      _ce_ram = 0;
   end
end

always @(*)
begin
   if(clock_cpu)
      if(_we_mem & !_io[1])
      begin
         data_cpu_out = data_mem;
         data_cocpu_out = 8'bz;
         data_mem_out = 8'bz;
      end
      else
      begin
         data_cpu_out = 8'bz;
         data_cocpu_out = 8'bz;
         data_mem_out = data_cpu;
      end
   else
      if(_we_mem)
      begin
         data_cpu_out = 8'bz;
         data_cocpu_out = data_mem;
         data_mem_out = 8'bz;
      end
      else
      begin
         data_cpu_out = 8'bz;
         data_cocpu_out = 8'bz;
         data_mem_out = data_cocpu;
      end
end

endmodule
