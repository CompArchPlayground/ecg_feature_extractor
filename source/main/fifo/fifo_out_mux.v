`timescale 1 ps/1 ps
module fifo_out_mux #( parameter DATA_W 		 = 16,
					   parameter ADDR_W		     = 11,
					   parameter NUM_OF_MEM 	 = 8,
					   parameter LOG2_NUM_OF_MEM = 3
					 )
					 ( input [(DATA_W*NUM_OF_MEM)-1:0] data_i,
					   input [ADDR_W-1:0]			   addr_i,
					   output[(DATA_W*NUM_OF_MEM)-1:0] data_o  
					 );
													
assign data_o[(DATA_W*1)-1:DATA_W*0] =   (addr_i[LOG2_NUM_OF_MEM-1:0] == 0) ? data_i[(DATA_W*1)-1:DATA_W*0]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 1) ? data_i[(DATA_W*2)-1:DATA_W*1]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 2) ? data_i[(DATA_W*3)-1:DATA_W*2]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 3) ? data_i[(DATA_W*4)-1:DATA_W*3]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 4) ? data_i[(DATA_W*5)-1:DATA_W*4]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 5) ? data_i[(DATA_W*6)-1:DATA_W*5]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 6) ? data_i[(DATA_W*7)-1:DATA_W*6]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 7) ? data_i[(DATA_W*8)-1:DATA_W*7]: {DATA_W{1'b0}};
										 
assign data_o[(DATA_W*2)-1:DATA_W*1] =   (addr_i[LOG2_NUM_OF_MEM-1:0] == 0) ? data_i[(DATA_W*2)-1:DATA_W*1]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 1) ? data_i[(DATA_W*3)-1:DATA_W*2]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 2) ? data_i[(DATA_W*4)-1:DATA_W*3]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 3) ? data_i[(DATA_W*5)-1:DATA_W*4]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 4) ? data_i[(DATA_W*6)-1:DATA_W*5]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 5) ? data_i[(DATA_W*7)-1:DATA_W*6]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 6) ? data_i[(DATA_W*8)-1:DATA_W*7]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 7) ? data_i[(DATA_W*1)-1:DATA_W*0]: {DATA_W{1'b0}};
										 
assign data_o[(DATA_W*3)-1:DATA_W*2] =   (addr_i[LOG2_NUM_OF_MEM-1:0] == 0) ? data_i[(DATA_W*3)-1:DATA_W*2]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 1) ? data_i[(DATA_W*4)-1:DATA_W*3]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 2) ? data_i[(DATA_W*5)-1:DATA_W*4]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 3) ? data_i[(DATA_W*6)-1:DATA_W*5]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 4) ? data_i[(DATA_W*7)-1:DATA_W*6]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 5) ? data_i[(DATA_W*8)-1:DATA_W*7]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 6) ? data_i[(DATA_W*1)-1:DATA_W*0]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 7) ? data_i[(DATA_W*2)-1:DATA_W*1]: {DATA_W{1'b0}};
										 
assign data_o[(DATA_W*4)-1:DATA_W*3] =   (addr_i[LOG2_NUM_OF_MEM-1:0] == 0) ? data_i[(DATA_W*4)-1:DATA_W*3]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 1) ? data_i[(DATA_W*5)-1:DATA_W*4]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 2) ? data_i[(DATA_W*6)-1:DATA_W*5]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 3) ? data_i[(DATA_W*7)-1:DATA_W*6]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 4) ? data_i[(DATA_W*8)-1:DATA_W*7]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 5) ? data_i[(DATA_W*1)-1:DATA_W*0]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 6) ? data_i[(DATA_W*2)-1:DATA_W*1]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 7) ? data_i[(DATA_W*3)-1:DATA_W*2]: {DATA_W{1'b0}};
										 
assign data_o[(DATA_W*5)-1:DATA_W*4] =   (addr_i[LOG2_NUM_OF_MEM-1:0] == 0) ? data_i[(DATA_W*5)-1:DATA_W*4]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 1) ? data_i[(DATA_W*6)-1:DATA_W*5]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 2) ? data_i[(DATA_W*7)-1:DATA_W*6]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 3) ? data_i[(DATA_W*8)-1:DATA_W*7]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 4) ? data_i[(DATA_W*1)-1:DATA_W*0]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 5) ? data_i[(DATA_W*2)-1:DATA_W*1]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 6) ? data_i[(DATA_W*3)-1:DATA_W*2]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 7) ? data_i[(DATA_W*4)-1:DATA_W*3]: {DATA_W{1'b0}};
										 
assign data_o[(DATA_W*6)-1:DATA_W*5] =   (addr_i[LOG2_NUM_OF_MEM-1:0] == 0) ? data_i[(DATA_W*6)-1:DATA_W*5]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 1) ? data_i[(DATA_W*7)-1:DATA_W*6]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 2) ? data_i[(DATA_W*8)-1:DATA_W*7]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 3) ? data_i[(DATA_W*1)-1:DATA_W*0]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 4) ? data_i[(DATA_W*2)-1:DATA_W*1]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 5) ? data_i[(DATA_W*3)-1:DATA_W*2]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 6) ? data_i[(DATA_W*4)-1:DATA_W*3]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 7) ? data_i[(DATA_W*5)-1:DATA_W*4]: {DATA_W{1'b0}};
										 
assign data_o[(DATA_W*7)-1:DATA_W*6] =   (addr_i[LOG2_NUM_OF_MEM-1:0] == 0) ? data_i[(DATA_W*7)-1:DATA_W*6]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 1) ? data_i[(DATA_W*8)-1:DATA_W*7]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 2) ? data_i[(DATA_W*1)-1:DATA_W*0]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 3) ? data_i[(DATA_W*2)-1:DATA_W*1]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 4) ? data_i[(DATA_W*3)-1:DATA_W*2]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 5) ? data_i[(DATA_W*4)-1:DATA_W*3]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 6) ? data_i[(DATA_W*5)-1:DATA_W*4]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 7) ? data_i[(DATA_W*6)-1:DATA_W*5]: {DATA_W{1'b0}};
										 
assign data_o[(DATA_W*8)-1:DATA_W*7] =   (addr_i[LOG2_NUM_OF_MEM-1:0] == 0) ? data_i[(DATA_W*8)-1:DATA_W*7]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 1) ? data_i[(DATA_W*1)-1:DATA_W*0]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 2) ? data_i[(DATA_W*2)-1:DATA_W*1]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 3) ? data_i[(DATA_W*3)-1:DATA_W*2]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 4) ? data_i[(DATA_W*4)-1:DATA_W*3]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 5) ? data_i[(DATA_W*5)-1:DATA_W*4]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 6) ? data_i[(DATA_W*6)-1:DATA_W*5]:
										 (addr_i[LOG2_NUM_OF_MEM-1:0] == 7) ? data_i[(DATA_W*7)-1:DATA_W*6]: {DATA_W{1'b0}};
endmodule 