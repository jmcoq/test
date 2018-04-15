// $Id: $
// File name:   huffman_heap.sv
// Created:     4/3/2018
// Author:      Joseph Coq
// Lab Section: 337-03
// Version:     1.0  Initial Design Entry
// Description: 

module huffman_heap (
	input wire clk,
	input wire n_rst,
	input wire huff_start,
	input wire [7:0] data_read,
	output wire huff_done,
	output wire read,
	output wire write,
	output wire [15:0] addr,
	output wire [7:0] data
);

	typedef enum bit [5:0] {IDLE, read_freq1, read_freq2, check_0_1, write_node, not_first, read_insert, dec_insert, greater, read_to_shift, check_shift, inc_shift, wrote_node, check_char, inc_char, check_naddr, child1, dec_naddr, child2, freq_sum, at_left, go_left, find_left, write_bits, write_byte1, write_byte2, find_par, back, go_right, find_right, at_right, DONE} stateType;
	stateType state;
	stateType nxt_state;
	reg read_out;
	reg write_out;
	reg [15:0] addr_out;
	reg [7:0] data_out;
	reg huff_done_out;
	reg [90:0][55:0] nodes;
	/*mapping a node's contents:
	[character:freq1:freq2:nodenumber:parent:leftchild:rightchild]
	*/

	reg [44:0][7:0] charlist;
	

	//variables to handle (fix the size of these wires) 
	reg firstchar; //is 1 when dealing with the firstchar
	reg [15:0] curr_freq; //frequency of currently character
	reg [15:0] read_freq; //frequency read in to try to insert
	reg [6:0] shift_addr; //address being shifted
	reg [55:0] shift_node; //node to shift
	reg [6:0] last_node; //address of the final node currently in existence
	reg [15:0] char_addr; //address of previously read character
	//reg char_addr_b2; //address of second byte
	//reg char_addr_b2; //address of third byte
	reg [15:0] last_char = 88; //final character to be read
	reg [6:0] naddr; //node number of the node on top of the stack
	reg [6:0] inaddr; //node number of the insert location 
	reg [6:0] first_node = 7'b0000001; //address of the first node
	reg [6:0] curr_node; //node number of currently being created node
	reg [15:0] path; //the path to the current position
	reg [7:0] curr_bit; //the bit we will write to next
	//reg [4:0]higher_bit; //one bit higher than curr_bit
	reg [7:0] nullval = 8'h00; //null value
	reg [6:0] look_for; //node number we are looking for
	reg [55:0] curr_shift;
	reg [7:0] left_child;
	reg [7:0] right_child;

	//next state of internal variables (fix the size of these wires)
	reg [90:0][55:0] next_nodes;
	reg next_firstchar; 
	reg [15:0] next_curr_freq; 
	reg [15:0] next_read_freq; 
	reg [6:0] next_shift_addr;
	reg [55:0] next_shift_node; 
	reg [6:0] next_last_node; 
	reg [15:0] next_char_addr; 
	//reg next_char_addr_b2; 
	//reg next_char_addr_b3;
	//reg next_last_char; 
	reg [6:0] next_naddr; 
	reg [6:0] next_inaddr;
	//reg next_first_node; 
	reg [6:0] next_curr_node;
	reg [15:0] next_path; 
	reg [7:0] next_curr_bit; 
	//reg next_higher_bit; 
	//reg next_null; 
	reg [6:0] next_look_for; 
	reg [55:0] next_curr_shift;
	reg [7:0] next_left_child;
	reg [7:0] next_right_child;

	//create always_ff for internal variables
	always_ff @ (negedge n_rst, posedge clk)
	begin 
		if(1'b0 == n_rst)
		begin			
			//create IDLE values
			nodes <= 0;
			firstchar <= 1; 
			curr_freq <= 16'b0; 
			read_freq <= 16'b0; 
			shift_addr <= 7'b0000001; 
			shift_node <= 56'b0;
			last_node <= 7'b0; 
			char_addr <= 16'b0; 
			//char_addr_b2 <= ; 
			//char_addr_b3 <= ;
			//last_char <= ; 
			naddr <= 7'b0000001; 
			inaddr <= 7'b0;
			//first_node <= ; 
			curr_node <= 7'b0000001;
			path <= 16'b0; 
			curr_bit <= 0; 
			//higher_bit <= 1; 
			//null <= ; 
			look_for <= 7'b0; 
			curr_shift <= 56'b0;
			left_child <= 8'b0;
			right_child <= 8'b0;		
		end	
		else begin
			nodes <= next_nodes;
			firstchar <= next_firstchar; 
			curr_freq <= next_curr_freq; 
			read_freq <= next_read_freq; 
			shift_addr <= next_shift_addr; 
			shift_node <= next_shift_node;
			last_node <= next_last_node; 
			char_addr <= next_char_addr; 
			//char_addr_b2 <= next_char_addr_b2; 
			//char_addr_b3 <= next_char_addr_b3;
			//last_char <= next_last_char; 
			naddr <= next_naddr; 
			inaddr <= next_inaddr;
			//first_node <= next_first_node; 
			curr_node <= next_curr_node;
			path <= next_path; 
			curr_bit <= next_curr_bit; 
			//higher_bit <= next_higher_bit; 
			//null <= next_null; 
			look_for <= next_look_for; 
			curr_shift <= next_curr_shift;
			left_child <= next_left_child;
			right_child <= next_right_child;
		end 
	end

	//create always_comb for internal variable transitions
	always @(nodes,firstchar,curr_freq,read_freq,shift_addr,last_node,char_addr,naddr,inaddr,curr_node,path,curr_bit,look_for,curr_shift,left_child,right_child,state)
	begin: Internal_Variable_Transitions
		charlist[0] = 97; //a
		charlist[1] = 98;
		charlist[2] = 99;
		charlist[3] = 100;
		charlist[4] = 101;
		charlist[5] = 102;
		charlist[6] = 103;
		charlist[7] = 104;
		charlist[8] = 105;
		charlist[9] = 106;
		charlist[10] = 107;
		charlist[11] = 108;
		charlist[12] = 109;
		charlist[13] = 110;
		charlist[14] = 111;
		charlist[15] = 112;
		charlist[16] = 113;
		charlist[17] = 114;
		charlist[18] = 115;
		charlist[19] = 116;
		charlist[20] = 117;
		charlist[21] = 118;
		charlist[22] = 119;
		charlist[23] = 120;
		charlist[24] = 121;
		charlist[25] = 122; //z
		charlist[26] = 48; //0
		charlist[27] = 49;
		charlist[28] = 50;
		charlist[29] = 51;
		charlist[30] = 52;
		charlist[31] = 53;
		charlist[32] = 54;
		charlist[33] = 55;
		charlist[34] = 56;
		charlist[35] = 57; //9
		charlist[36] = 32; //space
		charlist[37] = 46; //.
		charlist[38] = 44; //,
		charlist[39] = 63; //?
		charlist[40] = 33; //!
		charlist[41] = 59; //;
		charlist[42] = 58; //:
		charlist[43] = 39; //'
		charlist[44] = 4; //EOT


		//next_state
		next_nodes = nodes;
		next_firstchar = firstchar; 
		next_curr_freq = curr_freq; 
		next_read_freq = read_freq; 
		next_shift_addr = shift_addr; 
		next_last_node = last_node; 
		next_char_addr = char_addr; 
		//next_char_addr_b2 = char_addr_b2; 
		//next_char_addr_b3 = char_addr_b3;
		//next_last_char = last_char; 
		next_naddr = naddr;
		next_inaddr = inaddr; 
		//next_first_node = first_node; 
		next_curr_node = curr_node;
		next_path = path; 
		next_curr_bit = curr_bit; 
		//next_higher_bit = higher_bit; 
		//next_null = null; 
		next_look_for = look_for; 
		next_curr_shift = curr_shift;
		next_left_child = left_child;
		next_right_child = right_child;

		//unused: 
		case(state)
			IDLE:
			begin
				//nothing
			end
			read_freq1:
			begin
				//nothing
			end
			read_freq2:
			begin
				next_curr_freq[15:8] = data_read;
			end
			check_0_1:
			begin
				next_curr_freq[7:0] = data_read;
				next_inaddr = naddr+1;
				next_last_node = naddr+1;
				next_curr_shift[47:40] = curr_freq[15:8];
				next_curr_shift[39:32] = data_read;
				next_curr_shift[55:48] = charlist[char_addr/2];
				next_curr_shift[31:24] = curr_node;
				next_curr_shift[23:0] = 24'b0;
			end
			write_node:
			begin
				//next_nodes[shift_addr][47:32] = curr_freq;
				next_nodes[shift_addr] = curr_shift;				
			end
			not_first:
			begin
				next_firstchar = 1'b0;
				next_curr_node = curr_node+1;
				next_char_addr = char_addr + 2;
			end
			read_insert:
			begin
				next_read_freq = nodes[inaddr-1][47:32];				
			end
			greater:
			begin
				next_shift_addr = inaddr;				
			end
			dec_insert:
			begin
				next_inaddr = inaddr-1;
			end
			read_to_shift:
			begin
				next_shift_node = nodes[shift_addr];
			end
			check_shift:
			begin
				//nothing				
			end
			inc_shift:
			begin
				next_shift_addr = shift_addr + 1;
				next_curr_shift = shift_node;
			end
			wrote_node:
			begin
				next_naddr = naddr+1;
				next_curr_node = curr_node+1;
			end
			check_char:
			begin
				//nothing				
			end
			inc_char:
			begin
				next_char_addr = char_addr + 2;				
			end
			check_naddr:
			begin
				//nothing				
			end
			child1:
			begin
				next_nodes[naddr][23:16] = curr_node;
				next_curr_freq = nodes[naddr][47:32];
				next_left_child = nodes[naddr][31:24];
			end
			dec_naddr:
			begin
				next_naddr = naddr-1;
			end
			child2:
			begin
				next_nodes[naddr][23:16] = curr_node;
				next_curr_freq = curr_freq + nodes[naddr][47:32];
				next_right_child = nodes[naddr][31:24];
			end
			freq_sum:
			begin
				next_naddr = naddr-1;
				next_curr_shift[47:32] = curr_freq;
				next_curr_shift[55:48] = nullval;
				next_curr_shift[31:24] = curr_node;
				next_curr_shift[23:16] = 8'b0;
				next_curr_shift[15:0] = {left_child, right_child};
				next_last_node = last_node+1;
			end
			at_left:
			begin
				next_look_for = nodes[naddr][15:8];				
			end
			go_left:
			begin
				next_curr_bit = curr_bit + 1;
				next_path[curr_bit] = 1'b1;
			end
			find_left:
			begin
				next_naddr = (naddr + 1) % 90;
			end
			write_bits:
			begin
				next_look_for = nodes[naddr][23:16];
			end
			write_byte1:
			begin
				//nothing
			end
			write_byte2:
			begin
				//nothing
			end
			find_par:
			begin
				next_naddr = (naddr - 1) % 90;				
			end
			back:
			begin
				next_curr_bit = curr_bit - 1;
				next_look_for = nodes[naddr][23:16];	
			end
			go_right:
			begin
				next_curr_bit = curr_bit + 1;
				next_path[curr_bit] = 1'b0;
				next_look_for = nodes[naddr][7:0];
			end
			find_right:
			begin
				next_naddr = (naddr + 1) % 90;				
			end
			at_right:
			begin
				next_look_for = nodes[naddr][15:8];
			end
			DONE:
			begin
				//nothing
			end
		endcase		
	end





	assign read = read_out;
	assign write = write_out;
	assign addr = addr_out;
	assign data = data_out;
	assign huff_done = huff_done_out;

	always_comb
	begin : Next_State_Logic
		//next_state
		nxt_state = state;
		case(state)
			IDLE:
			begin
				if (huff_start==1'b1) begin
					nxt_state = read_freq1;
				end
				else begin
					nxt_state = IDLE;
				end
			end
			read_freq1:
			begin
				nxt_state = read_freq2;
			end
			read_freq2:
			begin
				nxt_state = check_0_1;
			end
			check_0_1:
			begin
				if ({curr_freq[15:8],data_read}==16'b0) begin
					nxt_state = check_char;
				end
				else begin
					if (firstchar == 1'b1) begin
						nxt_state = write_node;
					end
					else begin
						nxt_state = read_insert;
					end
				end
			end
			write_node:
			begin
				if (firstchar==1'b1) begin
					nxt_state = not_first;
				end
				else begin
					nxt_state = check_shift;
				end
			end
			not_first:
			begin
				nxt_state = read_freq1;
			end
			read_insert:
			begin
				nxt_state = greater;
			end
			greater:
			begin
				if (curr_freq > read_freq) begin
					if(inaddr > 1) begin
						nxt_state = dec_insert;
					end
					else begin
						nxt_state = read_to_shift;
					end
					//fix transition here
				end
				else begin
					nxt_state = read_to_shift;
				end
			end
			dec_insert:
			begin
				nxt_state = read_insert;
			end
			read_to_shift:
			begin
				nxt_state = write_node;
			end
			check_shift:
			begin
				if (shift_addr==last_node) begin
					nxt_state = wrote_node;
				end
				else begin
					nxt_state = inc_shift;
				end
			end
			inc_shift:
			begin
				nxt_state = read_to_shift;
			end
			wrote_node:
			begin
				nxt_state = check_char;
			end
			check_char:
			begin
				if (char_addr==last_char) begin
					nxt_state = check_naddr;
				end
				else begin
					nxt_state = inc_char;
				end
			end
			inc_char:
			begin
				nxt_state = read_freq1;
			end
			check_naddr:
			begin
				if (naddr==first_node) begin
					nxt_state = at_left;
				end
				else begin
					nxt_state = child1;
				end
			end
			child1:
			begin
				nxt_state = dec_naddr;
			end
			dec_naddr:
			begin
				nxt_state = child2;
			end
			child2:
			begin
				nxt_state = freq_sum;
			end
			freq_sum:
			begin
				nxt_state = read_insert;
			end
			at_left:
			begin
				if (nodes[naddr][15:8]==nullval) begin
					nxt_state = write_bits;
				end
				else begin
					nxt_state = go_left;
				end
			end
			go_left:
			begin
				nxt_state = find_left;
			end
			find_left:
			begin
				if (nodes[naddr+1][31:24]==look_for) begin
					nxt_state = at_left;
				end
				else begin
					nxt_state = find_left;
				end
			end
			write_bits:
			begin
				nxt_state = write_byte1;
			end
			write_byte1:
			begin
				nxt_state = write_byte2;
			end
			write_byte2:
			begin
				nxt_state = find_par;
			end
			find_par:
			begin
				if (nodes[naddr-1][31:24]==look_for) begin
					nxt_state = back;
				end
				else begin
					nxt_state = find_par;
				end
			end
			back:
			begin
				/*if (curr_bit==0) begin
					nxt_state = DONE;
				end
				else begin
					if (path[curr_bit-1]==1'b1) begin
						nxt_state = go_right;
					end
					else begin
						nxt_state = find_par;
					end
				end */
				if (path[curr_bit-1]==1'b1) begin
					nxt_state = go_right;
				end
				else begin
					if (curr_bit==1) begin
						nxt_state = DONE;
					end
					else begin
						nxt_state = find_par;
					end
				end 
			end
			go_right:
			begin
				nxt_state = find_right;
			end
			find_right:
			begin
				if (nodes[naddr+1][31:24]==look_for) begin
					nxt_state = at_right;
				end
				else begin
					nxt_state = find_right;
				end
			end
			at_right:
			begin
				if (nodes[naddr][15:8]==nullval) begin
					nxt_state = write_bits;
				end
				else begin
					nxt_state = go_left;
				end
			end
			DONE:
			begin
				nxt_state = DONE;
			end
		endcase		
	end

	always_ff @ (negedge n_rst, posedge clk)
	begin 
		if(1'b0 == n_rst)
		begin			
			state <= IDLE;			
		end	
		else begin
			state <= nxt_state;
		end 
	end


	//create output values
	always_comb
	begin : Output_Logic
		//IDLE values
		read_out = 1'b0;
		write_out = 1'b0;
		addr_out = 16'b0;
		data_out = 8'b0;
		huff_done_out = 1'b0;
		
		//unused: IDLE, check_0_1, write_node, not_first, read_insert, dec_insert, greater, read_to_shift, check_shift, inc_shift, wrote_node, check_char, inc_char, check_naddr, child1, dec_naddr, child2, freq_sum, at_left, go_left, find_left, find_par, back, go_right, find_right, at_right
		case(state)
			read_freq1:
			begin
				read_out = 1'b1;
				addr_out = char_addr;
			end
			read_freq2:
			begin
				read_out = 1'b1;
				addr_out = char_addr + 1;
			end
			
			write_bits:
			begin
				write_out = 1'b1;
				addr_out = 3 * (nodes[naddr][31:24]-1) + 90;
				data_out = curr_bit;
			end
			write_byte1:
			begin
				write_out = 1'b1;
				addr_out = 3 * (nodes[naddr][31:24]-1) + 91;
				data_out = path[15:8];
			end
			write_byte2:
			begin
				write_out = 1'b1;
				addr_out = 3 * (nodes[naddr][31:24]-1) + 92;
				data_out = path[7:0];
			end
			DONE:
			begin
				huff_done_out = 1'b1;
			end
		endcase		
	end

endmodule
