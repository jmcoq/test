// $Id: $
// File name:   sram_control.sv
// Created:     4/3/2018
// Author:      Joseph Coq
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: 

module sram_control (
	//control logic signals
	/*input wire clk,
	input wire n_rst,
	input wire freq_enable,
	input wire huff_start,
	input wire enc_start,
	input wire EOT_flag,
	input wire start_det,	
	output wire freq_done,
	output wire huff_done,
	output wire enc_done,
	output wire load_enable,*/

	//old sram signals
	input wire [2:0] state,
	input wire [15:0] sym_addr,
	input wire sym_read,
	input wire sym_write,
	input wire [7:0] sym_data,
	input wire [15:0] bus_addr,
	input wire bus_read,
	input wire bus_write,
	input wire [7:0] bus_data,
	input wire [15:0] node_addr,
	input wire node_read,
	input wire node_write,
	input wire [7:0] node_data,
	input wire [15:0] mc_addr,
	input wire mc_read,
	input wire mc_write,
	input wire [7:0] mc_data,
	output wire sram_read,
	output wire sram_write,
	output wire [15:0] sram_addr,
	output wire [7:0] sram_data
	//output wire [7:0] data_read
);
	reg [15:0] addr;
	reg read;
	reg write;
	reg [7:0] data;

	assign sram_addr = addr;
	assign sram_read = read;
	assign sram_write = write;
	assign sram_data = data;

	always_comb
	begin
		//IDLE values (check numbers for state later)
		addr = 16'b0;
		read = 1'b0;
		write = 1'b0;
		data = 1'b0;
		
		case(state)
			3'b001:
			begin
				addr = bus_addr;
				read = bus_read;
				write = bus_write;
				data = bus_data;
			end
			3'b010:
			begin
				addr = sym_addr;
				read = sym_read;
				write = sym_write;
				data = sym_data;
			end
			3'b011:
			begin
				addr = node_addr;
				read = node_read;
				write = node_write;
				data = node_data;
			end
			3'b100:
			begin
				addr = mc_addr;
				read = mc_read;
				write = mc_write;
				data = mc_data;
			end			
		endcase	
	end

endmodule
