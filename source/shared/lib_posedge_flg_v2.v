`timescale 1ns/10ps

module lib_posedge_flg_v2 ( input      clk,
							input      reset_n,
							input	   data_i,
							output reg pos_edge_flg
							);

assign seen_pos_edge = ~pos_edge_flg & data_i;

// seen posedge and hold	
always @(posedge clk or negedge reset_n)
if (!reset_n)
	pos_edge_flg <= 1'b0;
else if (pos_edge_flg)
	pos_edge_flg <= 1'b1;
else if (seen_pos_edge)
	pos_edge_flg <= 1'b1;
	
endmodule 