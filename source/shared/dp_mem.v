`timescale 1ns / 10ps

module dp_mem #(parameter MEM_DEPTH =16, parameter LOG2_MEM_DEPTH=4, parameter DATA_WIDTH=16) 
(  input clk,
   input aclr,
	input [DATA_WIDTH-1:0] data_in,
	input [LOG2_MEM_DEPTH-1:0] r_addr, w_addr,
	input w_en, r_en, 
	output reg [DATA_WIDTH-1:0] data_out
);

reg [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0]; 

// Write
	always @(posedge clk)
	begin
		if (w_en)
			mem[w_addr]<= data_in;
	end

// Read 
	always @(posedge clk)
	begin
		if (r_en)
			data_out <= mem[r_addr];
	end

endmodule
