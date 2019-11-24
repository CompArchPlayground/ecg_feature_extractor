`timescale 1 ps/1 ps

module sync_top 	#(  parameter DATA_W 		    = 16,
						parameter DIFF_MEM_DEPTH    = 32,
						parameter TMP_MEM_DEPTH     = 64,
						parameter LOG2_DIFF_DEPTH   = 5,
						parameter LOG2_TMP_DEPTH    = 6,
						parameter TMP_WINDOW_LENGTH = 800,
						parameter DIFF_RESOLUTION   = 50,
						parameter OBS_WINDOW_FACTOR = 2,
						parameter TMP_PTR_RST_VAL	= 0,
						parameter TMP_PTR_INC_VAL	= 1
						)
					 (	input 					  clk, 
												  reset_n,
						//						  
						input 					  sync_cfg_en,
						input 					  sync_diff_en,
						input signed [DATA_W-1:0] data_i,
						//
						output 					  sync_offset_done,
						output [DATA_W-1:0] 	  sync_offset_o
						);

localparam NUM_OF_MEM      = (TMP_WINDOW_LENGTH / DIFF_RESOLUTION);
localparam DIFF_ITER_LIMIT = ((OBS_WINDOW_FACTOR -1)*TMP_WINDOW_LENGTH)/DIFF_RESOLUTION + 1; 						

reg diff_r_dly_1, 
	diff_r_dly_2;
reg [(DATA_W*2)-1:0] 	  sync_diff_sum_min; 
reg	[LOG2_DIFF_DEPTH-1:0] sync_diff_sum_num; 
reg [LOG2_DIFF_DEPTH-1:0] sync_diff_sum_reg; 
reg					 	  sync_diff_cmp_flg;

wire 	   		  [2*DATA_W-1:0] sync_diff_buffer;						
wire            [NUM_OF_MEM-1:0] sync_diff_done_vect;
wire 		[(NUM_OF_MEM+1)-1:0] sync_cfg_w_vect; 
wire 		[(NUM_OF_MEM+1)-1:0] sync_diff_r_vect;
wire [(NUM_OF_MEM*2*DATA_W)-1:0] sync_diff_data;

assign sync_offset_o       = sync_diff_sum_reg*DIFF_RESOLUTION;
assign sync_diff_r_mem_en  = sync_diff_done_vect[NUM_OF_MEM-1] & ~sync_diff_cmp_flg;
assign sync_cfg_w_vect[0]  = 1'b1;
assign sync_diff_r_vect[0] = 1'b1;

assign sync_diff_buffer = !sync_diff_cmp_flg ? sync_diff_data[(32*1)-1:0]        + sync_diff_data[(32*2)-1:(32*1)]   + 
											   sync_diff_data[(32*3)-1:(32*2)]   + sync_diff_data[(32*4)-1:(32*3)]   + 
											   sync_diff_data[(32*5)-1:(32*4)]   + sync_diff_data[(32*6)-1:(32*5)]   + 
											   sync_diff_data[(32*7)-1:(32*6)]   + sync_diff_data[(32*8)-1:(32*7)]   +
											   sync_diff_data[(32*9)-1:(32*8)]   + sync_diff_data[(32*10)-1:(32*9)]  + 
											   sync_diff_data[(32*11)-1:(32*10)] + sync_diff_data[(32*12)-1:(32*11)] + 	
											   sync_diff_data[(32*13)-1:(32*12)] + sync_diff_data[(32*14)-1:(32*13)] + 
											   sync_diff_data[(32*15)-1:(32*14)] + sync_diff_data[(32*16)-1:(32*15)] : 0;

// cyc_dly #2
always @(posedge clk or negedge reset_n)
begin : diff_r_dly_x2
if (!reset_n) begin
	diff_r_dly_1 <= 0;
	diff_r_dly_2 <= 0; end
else begin
	diff_r_dly_1 <= sync_diff_r_mem_en;
	diff_r_dly_2 <= diff_r_dly_1; end 
end

always @(posedge clk or negedge reset_n)
begin : find_min
if (!reset_n) begin 
	sync_diff_sum_min <= {DATA_W*2{1'b1}}; 
	sync_diff_sum_num <= 0; 
	sync_diff_sum_reg <= 0; 
	sync_diff_cmp_flg <= 1'b0; end
else if (diff_r_dly_2)
	 if (sync_diff_sum_num == DIFF_ITER_LIMIT-1)
		sync_diff_cmp_flg <= 1'b1;
	 else 
		 if (sync_diff_buffer < sync_diff_sum_min) begin
			sync_diff_sum_min <= sync_diff_buffer; 
			sync_diff_sum_num <= sync_diff_sum_num+1; 
			sync_diff_sum_reg <= sync_diff_sum_num; end
		 else 
			sync_diff_sum_num <= sync_diff_sum_num+1; 
end 						  

lib_posedge_flg_v2 i_sync_done (.clk 		  ( clk ),
							    .reset_n	  ( reset_n ),
							    .data_i       ( sync_diff_cmp_flg ),
							    .pos_edge_flg ( sync_offset_done )
							   );

generate 				  	
genvar n;
for (n = 0; n < NUM_OF_MEM; n = n + 1) 
begin : SYNC_TMP							
	sync_tmp_inst #(DATA_W, DIFF_MEM_DEPTH, TMP_MEM_DEPTH, LOG2_DIFF_DEPTH, LOG2_TMP_DEPTH, TMP_WINDOW_LENGTH,
					DIFF_RESOLUTION, OBS_WINDOW_FACTOR, TMP_PTR_RST_VAL, TMP_PTR_INC_VAL, DIFF_ITER_LIMIT)
	i_sync_tmp_inst(.clk		( clk ), 
					.reset_n	( reset_n ),		
					//
					.cfg_w_en	( sync_cfg_en & sync_cfg_w_vect[n] ),	
					.data_i		( data_i ),
					//
					.diff_r_en	   ( sync_diff_en & sync_diff_r_vect[n] ),
					.diff_r_mem_en ( sync_diff_r_mem_en ),
					//
					.cfg_done	   ( sync_cfg_w_vect[n+1] ),
					.diff_done     ( sync_diff_done_vect[n] ),
					.diff_init_done( sync_diff_r_vect[n+1] ),
					.diff_data_o   ( sync_diff_data[((n+1)*2*DATA_W)-1:n*2*DATA_W] )
					);						
end
endgenerate

endmodule 