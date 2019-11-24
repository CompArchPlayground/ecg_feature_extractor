`timescale 1 ps/1 ps
module fifo_loop #( parameter DATA_W 		  = 16,
					parameter LOG2_MEM_DEPTH  = 8,
					parameter LOG2_NUM_OF_MEM = 3,
					parameter ECG_WINDOW	  = 800
					)
				  ( input 						clk, 
												reset_n,  
												hybd_r_pk_en,
					input   	[LOG2_MEM_DEPTH+LOG2_NUM_OF_MEM-1:0]	hybd_r_pk_pos_ref,
					output reg											loop_offset_en_o,
					output  	[LOG2_MEM_DEPTH+LOG2_NUM_OF_MEM-1:0]	loop_offset_o					
					);

reg [LOG2_MEM_DEPTH+LOG2_NUM_OF_MEM-1:0]  hybd_r_pk_cntr, 
										 loop_offset_start,
										 loop_offset_end,
										 loop_delta;	
										 
reg seen_first_r_pk;

assign loop_offset_o   = loop_offset_start; 

//delayed en
always@(posedge clk or negedge reset_n)
if (!reset_n)
	loop_offset_en_o <= 1'b0;
else 
	loop_offset_en_o <= hybd_r_pk_en;

// main loop
always@(posedge clk or negedge reset_n)
if (!reset_n) begin
	loop_offset_start <= 0;
	loop_delta 		  <= 0; 
	seen_first_r_pk   <= 1'b0; end 
else if (hybd_r_pk_en && !seen_first_r_pk) begin
	loop_offset_start <= 0;
	loop_delta 		  <= ECG_WINDOW - hybd_r_pk_pos_ref; 
	seen_first_r_pk   <= 1'b1; end
else if (hybd_r_pk_en && seen_first_r_pk)
	loop_offset_start <= (ECG_WINDOW - hybd_r_pk_pos_ref != loop_delta) ? hybd_r_pk_pos_ref + loop_delta - ECG_WINDOW : 0;

endmodule 
