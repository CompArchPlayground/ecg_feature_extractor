`timescale 1 ps/1 ps

module hybd_top   #(parameter UART_ADDR_W			 = 16, 	
					parameter UART_DATA_W			 = 8,
					parameter UART_NUM_OF_SLV		 = 6,
					//
					parameter FIFO_LIMIT			 = 2048,
					parameter LOG2_FIFO_LIMIT		 = 11,
					parameter FIFO_WRAP_W		     = 16,
					//
					parameter SYNC_LIMIT			 = 800,
					parameter LOG2_SYNC_LIMIT		 = 10,
					//
					parameter SYNC_DATA_W 		     = 16,
					parameter SYNC_DIFF_MEM_DEPTH    = 32,
					parameter SYNC_TMP_MEM_DEPTH     = 64,
					parameter SYNC_LOG2_DIFF_DEPTH   = 5,
					parameter SYNC_LOG2_TMP_DEPTH    = 6,
					parameter SYNC_TMP_WINDOW_LENGTH = 800,
					parameter SYNC_DIFF_RESOLUTION   = 50,
					parameter SYNC_OBS_WINDOW_FACTOR = 2,
					parameter SYNC_TMP_PTR_RST_VAL	 = 0,
					parameter SYNC_TMP_PTR_INC_VAL	 = 1,
					//
					parameter FIFO_DATA_W 		  	 = 16,
					parameter FIFO_ADDR_W		  	 = 8,
					parameter FIFO_NUM_OF_MEM 	  	 = 8,
					parameter FIFO_LOG2_NUM_OF_MEM 	 = 3,
					parameter FIFO_MEM_DEPTH 	 	 = 256,	
					parameter FIFO_LOG2_MEM_DEPTH  	 = 8,
					parameter FIFO_TX_WIN_TRIGGER  	 = 800,
					parameter FIFO_R_PTR_INC_VAL	 = 8,
					parameter FIFO_NUM_OF_FSM_STATE	 = 4,
					parameter FIFO_NUM_OF_REG_BYTE 	 = 1,
					//
					parameter TEST_DATA_W 		 	 = 16,
					parameter TEST_ECG_MEM_DEPTH 	 = 5000,
					parameter TEST_LOG2_ECG_MEM  	 = 13,
					parameter TEST_CFG_MEM_DEPTH 	 = 800,
					parameter TEST_LOG2_CFG_MEM  	 = 10,
					parameter TEST_ECG_STR 		 	 = 0,
					parameter TEST_ECG_END 		 	 = 4999,
					parameter TEST_CFG_STR 		 	 = 0,
					parameter TEST_CFG_END 		 	 = 799,
					parameter TEST_NUM_OF_FSM_STATE  = 4,
					parameter TEST_LOG2_FSM_STATE    = 2,
					//
					parameter COM_DATA_W			 = 16,
					parameter COM_ADDR_W			 = 7
					)
				   (input  core_clk,
					input  reset_n,
					input  test_ctrl_en,
					// com_if
					input  req,
					output rdy,
					input  [COM_ADDR_W-1:0] addr,
					output [COM_DATA_W-1:0] data,
               // core_if
               input   sync_mux_en,
               input   fifo_mux_en,
               input[SYNC_DATA_W-1:0] sync_data,
               input[FIFO_DATA_W-1:0] fifo_data,
               output [3:0] hybd_status
					);
               
//wire														fifo_mux_en; 
//wire 		[FIFO_DATA_W-1:0]								fifo_data; 
wire signed [FIFO_NUM_OF_MEM*FIFO_DATA_W-1:0] 				fifo_r_data;
wire 														fifo_r_en;

//wire														sync_mux_en; 
wire														sync_done;
wire														sync_done_flg;						
//wire 		[SYNC_DATA_W-1:0]								sync_data;
wire 		[SYNC_DATA_W-1:0]								sync_data_sel;
wire		[SYNC_DATA_W-1:0]								sync_offset;				

//wire 														hybd_gated_clk;
wire 														hybd_r_pk_init;
wire 														hybd_r_pk_en_flg;
wire 														hybd_done_flg;
wire 														hybd_done_init;
wire signed [FIFO_LOG2_NUM_OF_MEM+FIFO_LOG2_MEM_DEPTH-1:0]  hybd_r_pk_ref;

reg [3:0] hybd_status_reg;

assign sync_data_sel = fifo_mux_en ? fifo_data : sync_mux_en ? sync_data : 0;	  
assign hybd_status   = hybd_status_reg;

always @(posedge core_clk or negedge reset_n)
if (!reset_n) hybd_status_reg <= 0;
else          hybd_status_reg <= {hybd_done_init,hybd_r_pk_init,fifo_r_en,sync_done}; 

hybd_core i_hybd_core  (.clk	       ( core_clk ),	
                        .nReset	       ( reset_n  ),	
                        // fifo => core
                        .Enable	       ( test_ctrl_en ),
                        .push_data	   ( fifo_r_en    ),
                        .fifo_data     ( fifo_r_data  ),
                        // fifo <= core 
                        .Rp			   ( hybd_r_pk_init ), 			
                        .start		   ( hybd_done_init ),
                        .r_peak_pos_ref( hybd_r_pk_ref  ),
                        // uart_iface <=> core
                        .com_req 	( req  ),
                        .com_addr_i ( addr ),
                        .com_rdy 	( rdy  ),
                        .com_data_o ( data )
                        );

// hybd_r_pk_flg 
lib_posedge_flg_v1 i_hybd_r_pk_flg (.clk		  (core_clk) ,
									.reset_n	  (reset_n) ,
									.data_i		  (hybd_r_pk_init) ,
									.pos_edge_flg (hybd_r_pk_en_flg)
									);

// hybd_done_flg 
lib_posedge_flg_v1 i_hybd_done_flg (.clk		  (core_clk) ,
									.reset_n	  (reset_n) ,
									.data_i		  (hybd_done_init) ,
									.pos_edge_flg (hybd_done_flg)
									);

fifo_top # (FIFO_DATA_W, 
			FIFO_ADDR_W, 
			FIFO_NUM_OF_MEM, 
			FIFO_LOG2_NUM_OF_MEM, 
			FIFO_MEM_DEPTH,	
			FIFO_LOG2_MEM_DEPTH,
			FIFO_TX_WIN_TRIGGER,
			FIFO_R_PTR_INC_VAL, 
			FIFO_NUM_OF_FSM_STATE, 
			FIFO_NUM_OF_REG_BYTE
			)
i_fifo_top (.clk			( core_clk	), 
			.reset_n		( reset_n	),	
			// <= sync	
			.sync_offset_en	( sync_done_flg	),
			.sync_offset_i	( sync_offset ),
			// <= hybrid
			.hybd_done		( hybd_done_flg ),
			.hybd_r_pk_en	( hybd_r_pk_en_flg ),
			.hybd_r_pk_i	({5'b0, hybd_r_pk_ref}),	
			// <= rtu_slv
			.w_en			( fifo_mux_en ),					
			.data_i			( fifo_data	),
			// => hybrid
			.r_en_o			( fifo_r_en	),
			.data_o			( fifo_r_data ),
			.fifo_status_reg_o	(  )		
			);
			
// sync_clk_gate			
// clk_ctrl sync_clk_gate(.ena 	( ~sync_done ),
					   // .inclk 	( core_clk ),
					   // .outclk 	( sync_gated_clk )
					   // );		
         
// sync_done_flg 
lib_posedge_flg_v1 i_sync_done_flg (.clk		  (core_clk) ,
									.reset_n	  (reset_n) ,
									.data_i		  (sync_done) ,
									.pos_edge_flg (sync_done_flg)
									);
					   
sync_top  #(SYNC_DATA_W,
			SYNC_DIFF_MEM_DEPTH,
			SYNC_TMP_MEM_DEPTH,
			SYNC_LOG2_DIFF_DEPTH,
			SYNC_LOG2_TMP_DEPTH,
			SYNC_TMP_WINDOW_LENGTH,
			SYNC_DIFF_RESOLUTION,
			SYNC_OBS_WINDOW_FACTOR,
			SYNC_TMP_PTR_RST_VAL,
			SYNC_TMP_PTR_INC_VAL
			)
i_sync_top(	.clk	          ( core_clk ), 
			.reset_n          ( reset_n	 ),
			//						  
			.sync_cfg_en	  (	sync_mux_en	),
			.sync_diff_en	  (	fifo_mux_en	),
			.data_i			  (	sync_data_sel ),
			//
			.sync_offset_done (	sync_done   ),
			.sync_offset_o	  (	sync_offset	)
			);
	
endmodule 