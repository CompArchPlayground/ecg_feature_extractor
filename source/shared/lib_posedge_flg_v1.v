`timescale 1ns/10ps

module lib_posedge_flg_v1 ( input      clk,
							input      reset_n,
							input	   data_i,
							output reg pos_edge_flg
							);

reg neg_edge_flg; 
reg	seen_neg_edge_flg;

// posedge detector
always @(posedge clk or negedge reset_n)
if (!reset_n)
	pos_edge_flg <= 1'b0;
else
	pos_edge_flg <= ~pos_edge_flg & data_i & seen_neg_edge_flg;

// negedge detector
always @(posedge clk or negedge reset_n)
if (!reset_n)
	neg_edge_flg <= 1'b0;
else
	neg_edge_flg <= ~(neg_edge_flg | data_i);

// seen negedge
always @(posedge clk or negedge reset_n)
if (!reset_n)
	seen_neg_edge_flg <= 1'b1; // must be '1' otherwise no posedge would be detected
else if (neg_edge_flg)
	seen_neg_edge_flg <= 1'b1;
else if (pos_edge_flg)
	seen_neg_edge_flg <= 1'b0;
	
endmodule 