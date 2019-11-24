`timescale 1 ps/1 ps

module test_ctrl #( parameter DATA_W 		= 16,
					//
					parameter ECG_MEM_DEPTH = 5000,
					parameter LOG2_ECG_MEM  = 13,
					parameter CFG_MEM_DEPTH = 800,
					parameter LOG2_CFG_MEM  = 10,
					// 
					parameter ECG_STR = 0,
					parameter ECG_END = 4999,
					//
					parameter CFG_STR = 0,
					parameter CFG_END = 799,
					//
					parameter NUM_OF_FSM_STATE= 4,
					parameter LOG2_FSM_STATE  = 2
					)
				  (	input		  		clk, reset_n,
					// trigger
					input 				test_en,
					// status
					output            test_done,			
				    // enable  
					output reg			cfg_en_o,
					output reg			ecg_en_o,
					// data  
					output [DATA_W-1:0] cfg_data_o,
					output [DATA_W-1:0] ecg_data_o
				    );
		
localparam RDY = 0;
localparam CFG = 1;
localparam ECG = 3;
localparam END = 2;

reg [LOG2_FSM_STATE-1:0] next_state, state;
reg [LOG2_CFG_MEM-1:0]   cfg_cntr;
reg [LOG2_ECG_MEM-1:0]   ecg_cntr;

assign cfg_en = (state == CFG);
assign ecg_en = (state == ECG);
assign test_done = (state == END);

// cfg_en_o delay 				
always@(posedge clk or negedge reset_n)
if (!reset_n)  cfg_en_o <= 1'b0;
else 		   cfg_en_o <= cfg_en;

// ecg_en_o delay
always@(posedge clk or negedge reset_n)
if (!reset_n)  ecg_en_o <= 1'b0;
else 		   ecg_en_o <= ecg_en;

// state_reg					
always@(posedge clk or negedge reset_n)
if (!reset_n)  state <= RDY;
else 		   state <= next_state;

// cfg cntr					
always@(posedge clk or negedge reset_n)
if (!reset_n)  			cfg_cntr <= CFG_STR;
else if (state == CFG) 	cfg_cntr <= cfg_cntr + 1;
else 					cfg_cntr <= CFG_STR;

// ecg cntr					
always@(posedge clk or negedge reset_n)
if (!reset_n)  			ecg_cntr <= ECG_STR;
else if (state == ECG) 	ecg_cntr <= ecg_cntr + 1;
else 					ecg_cntr <= ECG_STR;

// next_state_decode
always@(*)
begin
next_state = RDY;

case(state)

	RDY: if (test_en) next_state = CFG;
		 else 		  next_state = RDY;
	
	CFG: if (cfg_cntr == CFG_END) next_state = ECG;
		 else 					  next_state = CFG;
		 
	ECG: if (ecg_cntr == ECG_END) next_state = END;
		 else 					  next_state = ECG;
	
	END: next_state = END;

endcase
end
// mem_inst

ecg_mem_8192x16	ecg_mem(.aclr 	( ~reset_n ),
						.address( ecg_cntr ),
						.clock 	( clk ),
						.data 	( {DATA_W{1'b0}} ),
						.rden 	( ecg_en ),
						.wren 	( 1'b0 ),
						.q 		( ecg_data_o )
						);

cfg_mem_1024x16	cfg_mem(.aclr 	( ~reset_n ),
						.address( cfg_cntr ),
						.clock 	( clk ),
						.data 	( {DATA_W{1'b0}} ),
						.rden 	( cfg_en ),
						.wren 	( 1'b0 ),
						.q 		( cfg_data_o )
						);

endmodule 