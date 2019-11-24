`timescale 1 ps/1 ps

module fifo_ctrl_fsm    #(  parameter DATA_W 		  = 16, 
							parameter NUM_OF_MEM 	  = 8,
							parameter LOG2_NUM_OF_MEM = 3,
							parameter MEM_DEPTH 	  = 256,	
							parameter LOG2_MEM_DEPTH  = 8,
							parameter NUM_OF_FSM_STATE= 4
						)
						(	input 		 clk, 
										 reset_n, 
							input		 hybd_done, 
										 loop_done,
										 tx_w_done,
										 sync_done,
							output 		 r_en,
							output reg 	 toggle,
							output [3:0] fsm_state_o
						);
localparam  FIRST_LOOP	= 4'b0000;					 
localparam	WAIT_TX_WIN	= 4'b0001;
localparam	START_READ 	= 4'b0010;
localparam  WAIT_LOOP   = 4'b0100;
localparam  WAIT_HYBD   = 4'b1000;

reg [NUM_OF_FSM_STATE-1:0]	state, next_state;
reg [7:0]					r_cntr;
//reg 						toggle;

assign fsm_state_o = state;
assign r_en = (state == START_READ || state == WAIT_LOOP || state == WAIT_HYBD);

always @(posedge clk or negedge reset_n)
begin
if (!reset_n) begin 
	r_cntr <= 0;
	toggle <= 1'b0; end
else if (state == START_READ && !toggle) begin
	r_cntr <= r_cntr + 1;
	toggle <= ~toggle; end 
else if (state == START_READ && toggle) begin
	toggle <= ~toggle; end 
else begin
	r_cntr <= 0;
	toggle <= 1'b0; end 
end

// FSM state reg
always @(posedge clk or negedge reset_n)
begin
if (!reset_n)
	state <= FIRST_LOOP;
else 
	state <= next_state;
end
					 
// FSM comb
always @(*)
begin
next_state = 4'b0000;

case (state)
	
	FIRST_LOOP : if (sync_done)
					next_state = START_READ;
				 else
					next_state = FIRST_LOOP;
	
	WAIT_TX_WIN: if (tx_w_done)
					next_state = START_READ;
				 else 	
					next_state = WAIT_TX_WIN;
	
	START_READ:  if (r_cntr == 100)
					next_state = WAIT_LOOP;
				 else
					next_state = START_READ;

	WAIT_LOOP:   if (loop_done)
					next_state = WAIT_HYBD;
				 else 
					next_state = WAIT_LOOP;
	
	WAIT_HYBD:	 if (hybd_done)
					next_state = WAIT_TX_WIN;
				 else 
					next_state = WAIT_HYBD;

endcase

end

endmodule 