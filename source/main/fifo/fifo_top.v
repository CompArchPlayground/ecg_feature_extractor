`timescale 1 ps/1 ps
module fifo_top #(  parameter DATA_W 		  = 16,
					parameter ADDR_W		  = 8,
					parameter NUM_OF_MEM 	  = 8,
					parameter LOG2_NUM_OF_MEM = 3,
					parameter MEM_DEPTH 	  = 256,	
					parameter LOG2_MEM_DEPTH  = 8,
					parameter TX_WIN_TRIGGER  = 800,
					parameter R_PTR_INC_VAL	  = 8,
					parameter NUM_OF_FSM_STATE= 4,
					parameter NUM_OF_REG_BYTE = 1
					)
				 (	input		  			clk, reset_n,	
					// <= sync
					input 					sync_offset_en,
					input  [DATA_W-1:0]		sync_offset_i,
					// <= hybrid
					input 					hybd_done,
					input 					hybd_r_pk_en,
					input  [DATA_W-1:0]	hybd_r_pk_i,	
					// <= rtu_slv
					input 					w_en,					
					input  [DATA_W-1:0]		data_i,
					// => hybrid
					output					r_en_o,
					output [(DATA_W*NUM_OF_MEM)-1:0] data_o,
					output [(NUM_OF_REG_BYTE*8)-1:0] fifo_status_reg_o		
					);

wire loop_offset_en, r_en, w_ovrflw, r_ovrflw, r_undflw;					
					
wire 		[LOG2_MEM_DEPTH+LOG2_NUM_OF_MEM-1:0] w_addr, r_addr;					
wire 		[DATA_W-1:0] 						 mem_data_i; 
wire        [(NUM_OF_MEM*DATA_W)-1:0] 			 mem_data_o;
wire 		[DATA_W-1:0] 						 r_offset;
wire 		[LOG2_MEM_DEPTH+LOG2_NUM_OF_MEM-1:0] loop_offset;
wire 		[(NUM_OF_MEM*ADDR_W)-1:0]			 r_addr_v;
wire 		[NUM_OF_FSM_STATE-1:0]				 fsm_state;
wire 		[NUM_OF_MEM-1:0]					 w_en_v;
wire 											 toggle_en;

reg			r_en_dly_2, r_en_dly, sync_offset_en_dly, loop_offset_en_dly;
reg 		r_dir, w_dir;
reg [7:0]	fifo_status_reg; 

assign r_en_o	  		 = r_en; //_dly;
assign mem_data_i 		 = data_i;
assign fifo_status_reg_o = fifo_status_reg; 

// flags

assign r_lags_w   = r_dir^w_dir;

assign r_offset   = (loop_offset_en)? {5'b0,loop_offset} : (sync_offset_en)? sync_offset_i : 0;

assign tx_w_done  = (!fsm_state[0]) ? 1'b0 : (r_lags_w  && (w_addr - r_addr > TX_WIN_TRIGGER)) ? 1'b1 :
				    (!r_lags_w && ((NUM_OF_MEM*MEM_DEPTH-1) - r_addr + w_addr + 1) > TX_WIN_TRIGGER) ? 1'b1 : 1'b0;
assign fifo_empty =	(!fsm_state[1]) ? 1'b0 : r_lags_w ? ((w_addr - r_addr <  R_PTR_INC_VAL) ? 1'b1 : 1'b0) : 
					((w_addr + 1 + (NUM_OF_MEM*MEM_DEPTH-1) - r_addr + 1 <= R_PTR_INC_VAL) ? 1'b1 : 1'b0);			   
assign fifo_full  = (!fsm_state[1]) ? (r_lags_w ? 1'b0 : (w_addr >= r_addr ) ? 1'b1 : 1'b0) : 1'b0; 

// w_en vector
assign w_en_v =  w_addr[LOG2_NUM_OF_MEM-1:0] == 0 ?	      {7'b0, w_en} :		
				 w_addr[LOG2_NUM_OF_MEM-1:0] == 1 ? {6'b0, w_en, 1'b0} :
				 w_addr[LOG2_NUM_OF_MEM-1:0] == 2 ? {5'b0, w_en, 2'b0} :
				 w_addr[LOG2_NUM_OF_MEM-1:0] == 3 ? {4'b0, w_en, 3'b0} :
				 w_addr[LOG2_NUM_OF_MEM-1:0] == 4 ? {3'b0, w_en, 4'b0} :
				 w_addr[LOG2_NUM_OF_MEM-1:0] == 5 ? {2'b0, w_en, 5'b0} :
				 w_addr[LOG2_NUM_OF_MEM-1:0] == 6 ? {1'b0, w_en, 6'b0} :
				 w_addr[LOG2_NUM_OF_MEM-1:0] == 7 ? 	  {w_en, 7'b0} : 8'b0;

always@(posedge clk or negedge reset_n)
if (!reset_n) fifo_status_reg <= 0;
else 		  fifo_status_reg <= {fsm_state,r_lags_w,tx_w_done,fifo_full,fifo_empty};

always@(posedge clk or negedge reset_n)
if (!reset_n) sync_offset_en_dly <= 0;
else 		  sync_offset_en_dly <= sync_offset_en;

always@(posedge clk or negedge reset_n)
if (!reset_n) loop_offset_en_dly <= 0;
else 		  loop_offset_en_dly <= loop_offset_en;

always@(posedge clk or negedge reset_n)
if (!reset_n)
	w_dir <= 1'b0;
else if (w_ovrflw)
	w_dir <= ~w_dir;
	
always@(posedge clk or negedge reset_n)
if (!reset_n)
	r_dir <= 1'b0;
else if (r_ovrflw || r_undflw)
	r_dir <= ~r_dir;

generate 
genvar n;
for (n = 0; n < NUM_OF_MEM; n = n +1)  
begin
	:R_ADDR_VEC assign r_addr_v[(n+1)*ADDR_W-1:n*ADDR_W] = !(fsm_state[1]) ? 0 : (r_addr[LOG2_NUM_OF_MEM-1:0] <= n ) ? r_addr[LOG2_MEM_DEPTH+LOG2_NUM_OF_MEM-1:LOG2_NUM_OF_MEM]: 
																								 r_addr[LOG2_MEM_DEPTH+LOG2_NUM_OF_MEM-1:LOG2_NUM_OF_MEM] +1; 
end
endgenerate

fifo_ctrl_fsm  #(16, 8, 3, 256, 8)
i_fifo_fsm(.clk 		( clk ), 
		   .reset_n		( reset_n ), 
		   .hybd_done	( hybd_done), 
		   .loop_done 	( loop_offset_en_dly),
		   .tx_w_done	( tx_w_done),
		   .sync_done	( sync_offset_en_dly),
		   .r_en		( r_en ),
		   .toggle      ( toggle_en),
		   .fsm_state_o ( fsm_state)
		);	

fifo_loop  #(16, 8, 3, 800)
i_fifo_loop	(.clk 				( clk ), 
			 .reset_n 			( reset_n ),  
			 .hybd_r_pk_en 		( hybd_r_pk_en ), 
			 .hybd_r_pk_pos_ref ( hybd_r_pk_i[LOG2_NUM_OF_MEM+LOG2_MEM_DEPTH-1:0] ),
			 .loop_offset_en_o	( loop_offset_en ),
			 .loop_offset_o		( loop_offset )					
			);		
			
fifo_mem #(16, 8, 8, 256, 8, 0)
i_fifo_mem  (.clk		( clk ), 
			 .reset_n	( reset_n ),
			 .data_i	( mem_data_i ),
			 .w_addr	( w_addr[ADDR_W+LOG2_NUM_OF_MEM-1:LOG2_NUM_OF_MEM] ),
			 .r_addr	( r_addr_v ),
			 .w_en		( w_en_v ), 
			 .r_en		( {NUM_OF_MEM{(fsm_state[1] & ~toggle_en)}} ),
			 .data_o	( mem_data_o )
			);
					
lib_ptr_v0 #(2047, 11, 0, 1)
i_fifo_w_ptr(.clk 	 	   ( clk     ), 
			.reset_n 	   ( reset_n ), 
			.reset_s 	   ( 1'b0    ),		
			.ptr_inc_en    ( w_en    ),
			.ptr_off_en	   ( 1'b0    ),
			.ptr_rst_val_i ( {ADDR_W+LOG2_NUM_OF_MEM{1'b0}} ),
			.ptr_off_val_i ( {ADDR_W+LOG2_NUM_OF_MEM{1'b0}} ),
			.ptr_val_o	   ( w_addr  ),		
			.ptr_ovrflw_flg( w_ovrflw),
			.ptr_undflw_flg(         )
			);
										
lib_ptr_v0 #(2047, 11, 0, 8)
i_fifo_r_ptr(.clk 	 	   ( clk     ), 
			.reset_n 	   ( reset_n ), 
			.reset_s 	   ( 1'b0    ),		
			.ptr_inc_en    ( fsm_state[1] & ~toggle_en ),
			.ptr_off_en	   ( sync_offset_en | loop_offset_en ),
			.ptr_rst_val_i ( {ADDR_W+LOG2_NUM_OF_MEM{1'b0}} ),
			.ptr_off_val_i ( r_offset[LOG2_MEM_DEPTH+LOG2_NUM_OF_MEM-1:0] ),
			.ptr_val_o	   ( r_addr   ),		
			.ptr_ovrflw_flg( r_ovrflw ),
			.ptr_undflw_flg( r_undflw )
			);

fifo_out_mux #(16, 11, 8, 3)
i_fifo_out_mux(.data_i ( mem_data_o ),
			   .addr_i ( r_addr ),
			   .data_o ( data_o )  
			  );			
					
endmodule 