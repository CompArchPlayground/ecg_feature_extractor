`timescale 1 ps/1 ps

// `define FPGA
// // `define SIM_DEBUG

// `ifdef 	FPGA
	// `define ALTERA
	// // `define DEBUG_ENABLED
// `endif

module fifo_mem #(  parameter DATA_W 		 = 16,
					parameter ADDR_W		 = 8,
					parameter NUM_OF_MEM 	 = 8,	
					parameter MEM_DEPTH 	 = 256,	
					parameter LOG2_MEM_DEPTH = 8,
					parameter NUM_OF_FLAGS	 = 8
					)
				 (	input		  					 		clk, reset_n,	
					input signed [DATA_W-1:0]				data_i,
					input  [ADDR_W-1:0]				 		w_addr,
					input  [(ADDR_W*NUM_OF_MEM)-1:0]	 	r_addr,
					input  [NUM_OF_MEM-1:0]		 	 		w_en, r_en, 
					output signed [(DATA_W*NUM_OF_MEM)-1:0] data_o
					);
// `ifdef SIM_DEBUG
// wire signed [ADDR_W-1:0] addr_0, addr_1, addr_2, addr_3, 
						 // addr_4, addr_5, addr_6, addr_7; 

// assign addr_0 = r_addr[ADDR_W-1:0]; 
// assign addr_1 = r_addr[2*ADDR_W-1:1*ADDR_W]; 
// assign addr_2 = r_addr[3*ADDR_W-1:2*ADDR_W]; 
// assign addr_3 = r_addr[4*ADDR_W-1:3*ADDR_W];
// assign addr_4 = r_addr[5*ADDR_W-1:4*ADDR_W];
// assign addr_5 = r_addr[6*ADDR_W-1:5*ADDR_W];
// assign addr_6 = r_addr[7*ADDR_W-1:6*ADDR_W];
// assign addr_7 = r_addr[8*ADDR_W-1:7*ADDR_W];

// `endif 

generate
genvar n;						
for (n = 0; n < NUM_OF_MEM; n = n +1) 
	begin
		// `ifdef FPGA
			// `ifdef ALTERA
			 :MEM dp_mem_256x16 i_fifo_mem (.aclr 		( ~reset_n ),
											.clock 		( clk ),
											.data		( data_i ),
											.rdaddress 	( r_addr[ADDR_W*(n+1)-1:n*ADDR_W] ),
											.rden		( r_en[n] ),
											.wraddress	( w_addr[ADDR_W-1:0] ),
											.wren		( w_en[n] ),
											.q			( data_o[DATA_W*(n+1)-1:n*DATA_W] )
											);
			// `endif
		// `endif	
	end 
endgenerate

endmodule 