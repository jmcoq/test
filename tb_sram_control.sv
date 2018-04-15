// $Id: $
// File name:   tb_sram_control.sv
// Created:     4/3/2018
// Author:      Joseph Coq
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: 

`timescale 1ns / 100ps

module tb_sram_control ();
	localparam TB_CLK_PERIOD = 6.0;

	//ON_CHIP_SRAM
	integer unsigned tb_init_file_number;	// Can't be larger than a value of (2^31 - 1) due to how VHDL stores unsigned ints/natural data types
	integer unsigned tb_dump_file_number;	// Can't be larger than a value of (2^31 - 1) due to how VHDL stores unsigned ints/natural data types
	integer unsigned tb_start_address;	// The first address to start dumping memory contents from
	integer unsigned tb_last_address;		// The last address to dump memory contents from
	
	reg tb_mem_clr;		// Active high strobe for at least 1 simulation timestep to zero memory contents
	reg tb_mem_init;	// Active high strobe for at least 1 simulation timestep to set the values for address in
										// currently selected init file to their corresonding values prescribed in the file
	reg tb_mem_dump;	// Active high strobe for at least 1 simulation timestep to dump all values modified since most recent mem_clr activation to
										// the currently chosen dump file. 
										// Only the locations between the "tb_start_address" and "tb_last_address" (inclusive) will be dumped
	reg tb_verbose;		// Active high enable for more verbose debuging information	
	reg [7:0]	tb_read_data;		// The data read from the SRAM


	//SRAM_CONTROL
	reg [2:0] tb_state;
	reg [15:0] tb_sym_addr;
	reg tb_sym_read;
	reg tb_sym_write;
	reg [7:0] tb_sym_data;
	reg [15:0] tb_bus_addr;
	reg tb_bus_read;
	reg tb_bus_write;
	reg [7:0] tb_bus_data;
	reg [15:0] tb_node_addr;
	reg tb_node_read;
	reg tb_node_write;
	reg [7:0] tb_node_data;
	reg [15:0] tb_mc_addr;
	reg tb_mc_read;
	reg tb_mc_write;
	reg [7:0] tb_mc_data;
	reg tb_sram_read;
	reg tb_sram_write;
	reg [15:0] tb_sram_addr;
	reg [7:0] tb_sram_data;
	//reg [7:0] tb_data_read;

	sram_control mycon (
		.state(tb_state),
		.sym_addr(tb_sym_addr),
		.sym_read(tb_sym_read),
		.sym_write(tb_sym_write),
		.sym_data(tb_sym_data),
		.bus_addr(tb_bus_addr),
		.bus_read(tb_bus_read),
		.bus_write(tb_bus_write),
		.bus_data(tb_bus_data),
		.node_addr(tb_node_addr),
		.node_read(tb_node_read),
		.node_write(tb_node_write),
		.node_data(tb_node_data),
		.mc_addr(tb_mc_addr),
		.mc_read(tb_mc_read),
		.mc_write(tb_mc_write),
		.mc_data(tb_mc_data),
		.sram_read(tb_sram_read),
		.sram_write(tb_sram_write),
		.sram_addr(tb_sram_addr),
		.sram_data(tb_sram_data)
		//.data_read(tb_data_read)
	);

	on_chip_sram_wrapper DUT
	(
		// Test bench control signals
		.mem_clr(tb_mem_clr),
		.mem_init(tb_mem_init),
		.mem_dump(tb_mem_dump),
		.verbose(tb_verbose),
		.init_file_number(tb_init_file_number),
		.dump_file_number(tb_dump_file_number),
		.start_address(tb_start_address),
		.last_address(tb_last_address),
		// Memory interface signals
		.read_enable(tb_sram_read),
		.write_enable(tb_sram_write),
		.address(tb_sram_addr),
		.read_data(tb_read_data),
		.write_data(tb_sram_data)
	);	

	initial begin
		//Initialize ON_CHIP_SRAM signals
		tb_mem_clr					<= 0;
		tb_mem_init					<= 0;
		tb_mem_dump					<= 0;
		tb_verbose					<= 0;
		tb_init_file_number	<= 0;
		tb_dump_file_number	<= 0;
		tb_start_address		<= 0;
		tb_last_address			<= 100;
	

		// Initialize SRAM_CONTROL Signals
		tb_state 	<= 3'b0;
		tb_sym_addr	<= 16'b0;
		tb_sym_read	<= 1'b0;
		tb_sym_write	<= 1'b0;
		tb_sym_data	<= 8'b0;
		tb_bus_addr	<= 16'b0;
		tb_bus_read	<= 1'b0;
		tb_bus_write	<= 1'b0;
		tb_bus_data	<= 8'b0;
		tb_node_addr	<= 16'b0;
		tb_node_read	<= 1'b0;
		tb_node_write	<= 1'b0;
		tb_node_data	<= 8'b0;
		tb_mc_addr	<= 16'b0;
		tb_mc_read	<= 1'b0;
		tb_mc_write	<= 1'b0;
		tb_mc_data	<= 8'b0;
		//tb_data_read	<= 8'b0;
		#TB_CLK_PERIOD;

		//begin testing
		tb_state <= 3'b001;
		tb_sym_addr	<= 16'b0;
		tb_sym_read	<= 1'b0;
		tb_sym_write	<= 1'b1;
		tb_sym_data	<= 8'b0;
		tb_bus_addr	<= 16'b0;
		tb_bus_read	<= 1'b0;
		tb_bus_write 	<= 1'b1;
		tb_bus_data 	<= 8'hFF;
		tb_node_addr	<= 16'b0;
		tb_node_read	<= 1'b0;
		tb_node_write	<= 1'b1;
		tb_node_data	<= 8'b0;
		tb_mc_addr	<= 16'b0;
		tb_mc_read	<= 1'b0;
		tb_mc_write	<= 1'b1;
		tb_mc_data	<= 8'b0;
		#TB_CLK_PERIOD;

		tb_sym_addr	<= 16'b0;
		tb_sym_read	<= 1'b1;
		tb_sym_write	<= 1'b0;
		tb_sym_data	<= 8'b0;
		tb_bus_addr	<= 16'b0;
		tb_bus_read	<= 1'b1;
		tb_bus_write	<= 1'b0;
		tb_bus_data	<= 8'b0;
		tb_node_addr	<= 16'b0;
		tb_node_read	<= 1'b1;
		tb_node_write	<= 1'b0;
		tb_node_data	<= 8'b0;
		tb_mc_addr	<= 16'b0;
		tb_mc_read	<= 1'b1;
		tb_mc_write	<= 1'b0;
		tb_mc_data	<= 8'b0;
		#TB_CLK_PERIOD;


		tb_mem_dump					<= 1;
		tb_dump_file_number	<=	2;
		tb_start_address		<= 0;
		tb_last_address			<= 100;
		#TB_CLK_PERIOD;
		
	end
endmodule
