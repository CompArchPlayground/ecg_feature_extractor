`timescale 1ps/1ps
//---------------------------------------------------------------------------------------
// test bench   
//---------------------------------------------------------------------------------------

module hybd_tb;

reg  			  clk, reset_n, r_val;
reg 		[3:0] param_num;
reg 		[2:0] window_num;
reg 		[15:0] test_cntr;
reg 		[1:0] next_tb_state, tb_state;

wire signed [15:0] tb_data, ecg_data, cfg_data;
wire tb_req,  tb_rdy, test_done_en;		
wire pll_clk, test_ctrl_en, cfg_en, ecg_en;

localparam CLK_PERIOD   = 20000;
localparam WAIT_FOR_RDY = 2'b00;
localparam READ_PARAM   = 2'b01;
localparam END			   = 2'b11;

localparam TEST_DATA_W 		 	 = 16;
localparam TEST_ECG_MEM_DEPTH 	 = 5000;
localparam TEST_LOG2_ECG_MEM  	 = 13;
localparam TEST_CFG_MEM_DEPTH 	 = 800;
localparam TEST_LOG2_CFG_MEM  	 = 10;
localparam TEST_ECG_STR 		 	 = 0;
localparam TEST_ECG_END 		 	 = 4999;
localparam TEST_CFG_STR 		 	 = 0;
localparam TEST_CFG_END 		 	 = 799;
localparam TEST_NUM_OF_FSM_STATE  = 4;
localparam TEST_LOG2_FSM_STATE    = 2;

// reset_gen
initial
begin
					clk = 1'b0;
				reset_n = 1'b1;
//           test_ctrl_en = 1'b0;
		   
#(CLK_PERIOD/5)      reset_n = 1'b0;
#(CLK_PERIOD/5)      reset_n = 1'b1;

//#(CLK_PERIOD/5) test_ctrl_en = 1'b1;
end 

// 50M clk_gen
always #(CLK_PERIOD/2) clk = ~clk;

// PLL instance

clk_1M 	i_clk_gen ( .areset ( ~reset_n ),
					.inclk0 ( clk ),
					.c0	    ( pll_clk ),
					.locked ( test_ctrl_en )
					);

// test_ctrl               
test_ctrl #(TEST_DATA_W,
			TEST_ECG_MEM_DEPTH,
			TEST_LOG2_ECG_MEM,
			TEST_CFG_MEM_DEPTH,
			TEST_LOG2_CFG_MEM,
			TEST_ECG_STR,
			TEST_ECG_END,
			TEST_CFG_STR,
			TEST_CFG_END,
			TEST_NUM_OF_FSM_STATE,
			TEST_LOG2_FSM_STATE
			)
i_test_ctrl(.clk	     ( pll_clk ), 
			.reset_n     ( reset_n ),
			.test_en     ( test_ctrl_en ),
			.test_done   ( test_done_en ),			
			.cfg_en_o	 ( cfg_en ),
			.ecg_en_o	 ( ecg_en ),
			.cfg_data_o  ( cfg_data ),
			.ecg_data_o	 ( ecg_data )
			);          
               
// DUT instance 

hybd_top i_hybd_top(.core_clk	  ( pll_clk	),
					.reset_n	  ( reset_n ),
					.test_ctrl_en ( test_ctrl_en ),
					//
					.req ( tb_req ),
					.rdy (  ),
					.addr( {param_num,window_num} ),
					.data( tb_data ),
               //
               .sync_mux_en ( cfg_en ),
               .fifo_mux_en ( ecg_en ),
               .sync_data   ( cfg_data ),
               .fifo_data   ( ecg_data ),
               .hybd_status ( )
					);	

assign tb_req = (tb_state == READ_PARAM);
					
// read_param_fsm

always@(posedge pll_clk or negedge reset_n)
if (!reset_n) 	tb_state <= WAIT_FOR_RDY;
else 			tb_state <= next_tb_state; 

always@(*)
begin
next_tb_state = WAIT_FOR_RDY;
	
	case (tb_state)
		
		WAIT_FOR_RDY: if (test_cntr == 2000) 
						next_tb_state = READ_PARAM; 
					  else 
						next_tb_state = WAIT_FOR_RDY;
		
		READ_PARAM	: if (param_num == 15 && window_num == 5) 
						next_tb_state = END; 
					  else 
						next_tb_state = READ_PARAM;

		END 		: begin next_tb_state = END; $display("SIM ended at: ", $time); end 
	
	endcase
end  

// cntrs

always@(posedge pll_clk or negedge reset_n)
if (!reset_n) 	test_cntr <= 0;
else if (test_done_en && test_cntr != 2000) test_cntr <= test_cntr + 1;

always@(posedge pll_clk or negedge reset_n)
if (!reset_n) 	param_num <= 0;
else 
   if (tb_state == READ_PARAM) param_num <= param_num + 1;

always@(posedge pll_clk or negedge reset_n)
if (!reset_n) 	window_num <= 0;
else if (tb_state == READ_PARAM && param_num == 15) window_num <= window_num + 1;

// delayed r_val

always@(posedge pll_clk or negedge reset_n)
if (!reset_n) 	r_val <= 1'b0;
else 			r_val <= tb_req;

// msg
always@(tb_state)   
	if (tb_state == READ_PARAM) $display("READ started at: ", $time);

// always@(window_num) 
	// if (tb_rdy) $display("WIN # %d", window_num);

// always@(param_num)  
	// if (tb_rdy) $display("PAR # %d", param_num);

always@(*)
	if (r_val) $display("VALUE = ", tb_data); 

endmodule 