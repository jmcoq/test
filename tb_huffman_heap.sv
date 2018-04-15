// $Id: $
// File name:   tb_huffman_heap.sv
// Created:     4/3/2018
// Author:      Joseph Coq
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: 


`timescale 1ns / 100ps

module tb_huffman_heap ();
	localparam TB_CLK_PERIOD = 6.06;

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


	//HUFF
	reg tb_clk;
	reg tb_n_rst;
	reg tb_huff_start;
	reg [7:0] tb_data_read;
	reg tb_read;
	reg tb_write;
	reg [15:0] tb_addr;
	reg [7:0] tb_data;
	reg tb_huff_done;

	huffman_heap myhuff (
		.clk(tb_clk),
		.n_rst(tb_n_rst),
		.huff_start(tb_huff_start),
		.data_read(tb_data_read),
		.huff_done(tb_huff_done),	
		.read(tb_read),
		.write(tb_write),
		.addr(tb_addr),
		.data(tb_data)
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
		.read_enable(tb_read),
		.write_enable(tb_write),
		.address(tb_addr),
		.read_data(tb_data_read),
		.write_data(tb_data)
	);	


    	always begin
        	tb_clk = 1'b1;
        	#(TB_CLK_PERIOD / 2);
        	tb_clk = 1'b0;
        	#(TB_CLK_PERIOD / 2);
    	end


	initial begin
		//Initialize ON_CHIP_SRAM signals
		tb_mem_clr					<= 0;
		tb_mem_init					<= 1;
		tb_mem_dump					<= 0;
		tb_verbose					<= 0;
		tb_init_file_number	<= 0;
		tb_dump_file_number	<= 0;
		tb_start_address		<= 0;
		tb_last_address			<= 300;
	

		// Initialize HUFF Input Signals
		tb_clk 	<= 3'b0;
		tb_n_rst	<= 1'b1;
		tb_huff_start	<= 1'b0;
		//tb_data_read	<= 8'b0; can't initialize because it is the output of the sram block
		 @(posedge tb_clk);

		//begin testing
		 @(posedge tb_clk);
		tb_mem_init <= 0;
		 @(posedge tb_clk);
		tb_n_rst <= 1'b0;
		 @(posedge tb_clk);
		tb_n_rst <= 1'b1;
		 @(posedge tb_clk);
		tb_huff_start <= 1'b1;
		 @(posedge tb_clk);
		while(tb_huff_done != 1'b1) begin
			 @(posedge tb_clk);
		end

		 @(posedge tb_clk);
		tb_mem_dump		<= 1;
		tb_dump_file_number	<=	2;
		 @(posedge tb_clk);
	end
endmodule
