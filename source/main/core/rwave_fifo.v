`timescale 1ps/1ps

module rwave_fifo #(parameter DATA_W 		  = 16,
					parameter NUM_OF_MEM 	  = 8,
					parameter LOG2_NUM_OF_MEM = 3,
					parameter MEM_DEPTH 	  = 128,	
					parameter LOG2_MEM_DEPTH  = 7
					)
				  (	input		  					 clk,
													 reset_n,
					input 							 w_en,
					input							 r_en,
					input [LOG2_MEM_DEPTH-1:0]		 addr,
					input  signed [(DATA_W*NUM_OF_MEM)-1:0] data_i,
					output signed [DATA_W-1:0]				data_o,
					output							 r_inc
					);

reg [NUM_OF_MEM-1:0] 			r_en_v;					
wire [(DATA_W*NUM_OF_MEM)-1:0] 	data_v;	

//r_inc

assign r_inc = r_en_v[NUM_OF_MEM-1];

// out mux
assign data_o =     !r_en ? {DATA_W{1'b0}}  : 
				r_en_v[0] ? data_v[8*DATA_W-1:7*DATA_W] :
			    r_en_v[1] ? data_v[1*DATA_W-1:0*DATA_W] :
			    r_en_v[2] ? data_v[2*DATA_W-1:1*DATA_W] :
			    r_en_v[3] ? data_v[3*DATA_W-1:2*DATA_W] :
			    r_en_v[4] ? data_v[4*DATA_W-1:3*DATA_W] :
			    r_en_v[5] ? data_v[5*DATA_W-1:4*DATA_W] :
			    r_en_v[6] ? data_v[6*DATA_W-1:5*DATA_W] :
			    r_en_v[7] ? data_v[7*DATA_W-1:6*DATA_W] : {DATA_W{1'b0}};

// one-hot counter
always @(posedge clk or negedge reset_n)
if (!reset_n)
	r_en_v <= 8'b0000_0001;
else if (r_en)
	r_en_v <= {r_en_v[NUM_OF_MEM-2:0], r_en_v[NUM_OF_MEM-1]};
else 
	r_en_v <= 8'b0000_0001;
	
generate
genvar n;

for (n = 0; n < NUM_OF_MEM; n = n + 1) 
begin
	:FIFO	dp_mem_128x16	i_dp_fifo (.aclr  ( ~reset_n ),
									   .clock ( clk ),
									   .data  ( data_i[((n+1)*DATA_W)-1:n*(DATA_W)] ),
									   .rdaddress ( addr ),
									   .rden ( r_en_v[n] & r_en ),
									   .wraddress ( addr ),
									   .wren ( w_en ),
									   .q     ( data_v[((n+1)*DATA_W)-1:n*(DATA_W)] )
									  ); 
end
endgenerate
	
endmodule 