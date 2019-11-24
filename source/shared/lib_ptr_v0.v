`timescale 1ns/10ps

module lib_ptr_v0 #(parameter PTR_MAX = 15, parameter PTR_W = 4, parameter RST_VAL = 0, parameter INC_VAL = 1)
				   (// global
					input					   clk, 
					input					   reset_n, 
					input					   reset_s,		
					// enable
					input					   ptr_inc_en,			
					input					   ptr_off_en,
					// dynamic parameters
					input		 [PTR_W - 1:0] ptr_rst_val_i,
					input signed [PTR_W - 1:0] ptr_off_val_i,
					// ptr_val_o 
					output reg	 [PTR_W - 1:0] ptr_val_o,		
					// flag
					output					   ptr_ovrflw_flg,
					output					   ptr_undflw_flg
					);
					
assign ptr_ovrflw_flg = ptr_off_en ? ((ptr_val_o + ptr_off_val_i > PTR_MAX) ? 1'b1:1'b0) : 
						ptr_inc_en ? ((ptr_val_o + INC_VAL 		 > PTR_MAX) ? 1'b1:1'b0) : 1'b0;
						
assign ptr_undflw_flg = ptr_off_en ? ((ptr_val_o + ptr_off_val_i < 0) ? 1'b1:1'b0) : 
						ptr_inc_en ? ((ptr_val_o + INC_VAL 		 < 0) ? 1'b1:1'b0) : 1'b0;
																					
always @(posedge clk or negedge reset_n)
if (!reset_n)									ptr_val_o 	 <= RST_VAL;
else if (reset_s)								ptr_val_o 	 <= ptr_rst_val_i;
else if (ptr_off_en)
	 if (ptr_val_o + ptr_off_val_i > PTR_MAX)	ptr_val_o 	 <= ptr_val_o + ptr_off_val_i - PTR_MAX - 1;
	 else if (ptr_val_o + ptr_off_val_i < 0) 	ptr_val_o 	 <= ptr_val_o + ptr_off_val_i + PTR_MAX + 1;	
	 else 										ptr_val_o 	 <= ptr_val_o + ptr_off_val_i;	
else if (ptr_inc_en)
     if (ptr_val_o + INC_VAL > PTR_MAX)			ptr_val_o 	 <= ptr_val_o + INC_VAL - PTR_MAX - 1;	 
	 else if (ptr_val_o + INC_VAL < 0)			ptr_val_o 	 <= ptr_val_o + INC_VAL + PTR_MAX + 1;
	 else										ptr_val_o 	 <= ptr_val_o + INC_VAL;
	
endmodule 