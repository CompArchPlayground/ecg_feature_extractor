`timescale 1ns/1ps

module lib_posedge_flg_v0 ( input      clk,
							input      reset_n,
							input	   data_i,
							output reg pos_edge_flg
							);

// posedge detector
always @(posedge clk or negedge reset_n)
if (!reset_n)
	pos_edge_flg <= 1'b0;
else
	pos_edge_flg <= ~pos_edge_flg & data_i;

endmodule 