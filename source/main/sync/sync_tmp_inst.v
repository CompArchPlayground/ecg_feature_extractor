`timescale 1 ps/1 ps

module sync_tmp_inst #( parameter DATA_W 		    = 16,
						parameter DIFF_MEM_DEPTH    = 32,
						parameter TMP_MEM_DEPTH     = 64,
						parameter LOG2_DIFF_DEPTH   = 5,
						parameter LOG2_TMP_DEPTH    = 6,
						parameter TMP_WINDOW_LENGTH = 800,
						parameter DIFF_RESOLUTION   = 50,
						parameter OBS_WINDOW_FACTOR = 2,
						parameter TMP_PTR_RST_VAL	= 0,
						parameter TMP_PTR_INC_VAL	= 1,
						parameter DIFF_ITER_LIMIT   = 17
						)
					 (	input clk, reset_n,		
						//
						input cfg_w_en,	
						input signed [DATA_W-1:0] data_i,
						//
						input diff_r_en,
						input diff_r_mem_en,
						//
						output cfg_done,
						output diff_done,
						output diff_init_done,
						output [(DATA_W*2)-1:0] diff_data_o
						);

//localparam DIFF_ITER_LIMIT = ((OBS_WINDOW_FACTOR -1)*TMP_WINDOW_LENGTH)/DIFF_RESOLUTION + 1; 						
									
reg signed [DATA_W-1:0]		data_i_buffer;							
reg signed [(DATA_W*2)-1:0] diff_abs; 
reg signed [(2*DATA_W)-1:0]	abs_diff_raw, abs_diff_2C;

reg [LOG2_DIFF_DEPTH-1:0]   diff_w_mem_addr;
reg [LOG2_DIFF_DEPTH-1:0]   diff_r_mem_addr;	
reg 					    diff_r_done_dly;
reg 					    diff_r_done_dly_2;
reg 					    diff_r_en_dly;

wire [LOG2_TMP_DEPTH-1:0]  cfg_w_addr; 
wire [LOG2_TMP_DEPTH-1:0] diff_r_addr;

wire signed [DATA_W-1:0] 		tmp_r_data;
					  
wire  cfg_w_done; 
wire diff_r_done;

assign diff_done = (diff_w_mem_addr == DIFF_ITER_LIMIT);
assign diff_mem_w_en = diff_r_done_dly_2 & ~diff_done; 

// abs diff comb
always@(*)
begin
	abs_diff_raw = diff_done ? 0 :  (diff_r_en_dly) ? (tmp_r_data - data_i_buffer) : 0;
	abs_diff_2C  = diff_done ? 0 : (!diff_r_en_dly) ? 0 : (abs_diff_raw[(DATA_W*2)-1]) ? (~abs_diff_raw) + 32'b1 : abs_diff_raw;
end

// ecg data buffer
always @(posedge clk or negedge reset_n)
if (!reset_n)
	data_i_buffer <= 0;
else if (!diff_done)
	data_i_buffer <= data_i;

// diff_r_en_dly gen
always @(posedge clk or negedge reset_n)
if (!reset_n)
	diff_r_en_dly <= 1'b0;
else 
	diff_r_en_dly <= diff_r_en;	
	
// absolute diff 
always @(posedge clk or negedge reset_n)
if (!reset_n)
	diff_abs <= 0;
else 
	diff_abs <= (cfg_w_en) ? 0 : (diff_done) ? 0 : (diff_r_addr == 1) ? abs_diff_2C : abs_diff_2C + diff_abs;
						 
// delayed diff_r_done 
always @(posedge clk or negedge reset_n)
if (!reset_n) begin
	diff_r_done_dly   <= 1'b0;
	diff_r_done_dly_2 <= 1'b0; end
else begin
	diff_r_done_dly   <= diff_r_done;
	diff_r_done_dly_2 <= diff_r_done_dly; end

// diff_w_mem_addr
always @(posedge clk or negedge reset_n)
if (!reset_n)
	diff_w_mem_addr <= 0;
else if (diff_r_done_dly_2 & diff_w_mem_addr != DIFF_ITER_LIMIT)
	diff_w_mem_addr <= diff_w_mem_addr + 1;

// diff_r_mem_addr
always @(posedge clk or negedge reset_n)
if (!reset_n)
	diff_r_mem_addr <= 0;
else if (diff_r_mem_en)
	diff_r_mem_addr <= diff_r_mem_addr + 1;	

// diff memory
dp_mem_32x32 i_diff_mem (.aclr 		( ~reset_n ),
						 .clock 	( clk ),
						 .data 		( diff_abs ),
						 .rdaddress ( diff_r_mem_addr ),
						 .rden 		( diff_r_mem_en ),
						 .wraddress ( diff_w_mem_addr ),
						 .wren 		( diff_mem_w_en ),
						 .q 		( diff_data_o )
						 );	

//
// cfg_write_pointer increments till cfg_w_addr = 49 
// and raises done flag to indicate end of cfg. 
//
lib_ptr_v0 #(DIFF_RESOLUTION-1, LOG2_TMP_DEPTH, TMP_PTR_RST_VAL, TMP_PTR_INC_VAL)
i_cfg_w_ptr(.clk 	 	     ( clk     ), 
			 .reset_n 	     ( reset_n ), 
			 .reset_s 	     ( 1'b0    ),		
			 .ptr_inc_en     ( cfg_w_en & ~cfg_done),
			 .ptr_off_en	 ( 1'b0    ),
			 .ptr_rst_val_i  ( {LOG2_TMP_DEPTH{1'b0}} ),
			 .ptr_off_val_i  ( {LOG2_TMP_DEPTH{1'b0}} ),
			 .ptr_val_o	     ( cfg_w_addr ),		
			 .ptr_ovrflw_flg ( cfg_w_done ),
			 .ptr_undflw_flg (  )
			 );

//
// diff_read_pointer increments till diff_r_addr = 49,
// repeats the process till diff_w_mem_addr = 17
//
lib_ptr_v0 #(DIFF_RESOLUTION-1, LOG2_TMP_DEPTH, TMP_PTR_RST_VAL, TMP_PTR_INC_VAL)
i_diff_r_ptr(.clk 	 	     ( clk     ), 
			 .reset_n 	     ( reset_n ), 
			 .reset_s 	     ( 1'b0    ),		
			 .ptr_inc_en     ( diff_r_en & ~diff_done ),
			 .ptr_off_en	 ( 1'b0    ),
			 .ptr_rst_val_i  ( {LOG2_TMP_DEPTH{1'b0}} ),
			 .ptr_off_val_i  ( {LOG2_TMP_DEPTH{1'b0}} ),
			 .ptr_val_o	     ( diff_r_addr ),		
			 .ptr_ovrflw_flg ( diff_r_done ),
			 .ptr_undflw_flg (  )
			 );			 

//			 
// seen cfg_r_done and hold, sampled 
// and held 'high' after the completion 
// of first diff read loop. 
//
lib_posedge_flg_v2 i_r_cfg_done(.clk 		    ( clk ),
							    .reset_n	    ( reset_n ),
							    .data_i       ( diff_r_done ),
							    .pos_edge_flg ( diff_init_done )
							    );			 

//			 
// seen cfg_w_done and hold, sampled 
// and held 'high' after the completion 
// of template mem write. 
//
lib_posedge_flg_v2 i_w_cfg_done(.clk 		    ( clk ),
							    .reset_n	    ( reset_n ),
							    .data_i       ( cfg_w_done ),
							    .pos_edge_flg ( cfg_done )
							  );
			 
// template memory
dp_mem_64x16 i_cfg_mem (.aclr 	   ( ~reset_n ),
						.clock 	   ( clk      ),
						.data 	   ( data_i   ),
						.rdaddress ( diff_r_addr ),
						.rden 	   ( diff_r_en & ~diff_done),
						.wraddress ( cfg_w_addr),
						.wren 	   ( cfg_w_en & ~cfg_done ),
						.q 		   ( tmp_r_data )
					    );
						
endmodule 