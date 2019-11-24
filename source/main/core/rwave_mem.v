`timescale 1ps/1ps
`include "parameter.v"

// `timescale 1ns / 10ps
// `include "parameter.v"

module rwave_mem (
				  output signed	[`b16:0] 	tap1, tap2,
				  input signed 	[15:0] 		data_in1, data_in2, data_in3, data_in4, 
											data_in5, data_in6, data_in7, data_in8,
				  input 		[`b16:0] 	count1,
				  input 	   	[`b9:0] 	count2,
				  input 			   		clk, nReset, Enable,
				  input 			   		stop1, stop2,
				  input				   		serial_mode, parallel_mode
				  );

parameter Y = 1600, INC = 50, fifo_lim = 1700;

/* Instantiation of the FIFO Modules */
reg signed [15:0] fifo_mem_a [0:799];
reg signed [15:0] fifo_mem_b [0:799];

reg   mem_write, mem_read;
reg  		toggle;
reg [15:0] 	ptr;
integer 	i, j;

assign tap1	=	fifo_mem_a[0];
assign tap2	=	fifo_mem_b[0];

/* Memory Read/Write Flags */
always @(*)
begin
mem_write	= ((count1 > 0)  && (count2 > 1) && (ptr <= 799)) 	? 1'b1 : 1'b0;
mem_read 	= ((count1 == 2) && (count2 == 1)) 					? 1'b1 : 1'b0;
end

/* MEM Write Block */
always @(posedge clk or negedge nReset)
begin
if(!nReset)
begin
  toggle <= #20 1'b0;
	ptr	<=	#20 0;
	/* Reset the FIFO */
	for (i=0;i<=799;i=i+1)
		fifo_mem_a[i]<= #20 0;
	for (i=0;i<=799;i=i+1)
		fifo_mem_b[i]<= #20 0;
end
else 
	if (Enable)
		if (mem_write)
		  /* MEM WRITE CYCLE */
		  if (!toggle)
				begin
					/* Fill FIFO A */
					fifo_mem_a[ptr]   <= #20 data_in1;
					fifo_mem_a[ptr+1] <= #20 data_in2;
					fifo_mem_a[ptr+2] <= #20 data_in3;
					fifo_mem_a[ptr+3] <= #20 data_in4;
					fifo_mem_a[ptr+4] <= #20 data_in5;
					fifo_mem_a[ptr+5] <= #20 data_in6;
					fifo_mem_a[ptr+6] <= #20 data_in7;
					fifo_mem_a[ptr+7] <= #20 data_in8;
					/* Fill FIFO B */
					fifo_mem_b[ptr]   <= #20 data_in1;
					fifo_mem_b[ptr+1] <= #20 data_in2;
					fifo_mem_b[ptr+2] <= #20 data_in3;
					fifo_mem_b[ptr+3] <= #20 data_in4;
					fifo_mem_b[ptr+4] <= #20 data_in5;
					fifo_mem_b[ptr+5] <= #20 data_in6;
					fifo_mem_b[ptr+6] <= #20 data_in7;
					fifo_mem_b[ptr+7] <= #20 data_in8;
					/* Increment ptr by 8 */
					ptr 	<= #20 ptr + 8;
					/* Toggle */
					toggle 	<= #20 ~toggle;
				end	
			else
			     begin
			     ptr <= #20 ptr;
			     toggle <= #20 ~toggle;
			     end 	 
		else  
		    if (mem_read)
				/* MEM READ CYCLE */
		        if (serial_mode && stop1)
					for (j = 799; j >= 1; j = j - 1)
					fifo_mem_a[j - 1] 	<= #20 fifo_mem_a[j];
		        else
					if (parallel_mode)
			            case ({stop1, stop2})  	
							2'b10: 	/* Load FIFO A */
									for (j = 799; j >= 1; j = j - 1)
									fifo_mem_a[j - 1]	<= #20 fifo_mem_a[j];
			
							2'b01:	/* Load FIFO B */
									for (j = 799; j >= 1; j = j - 1)
									fifo_mem_b[j - 1]	<= #20 fifo_mem_b[j];
			
							2'b11: 	begin
									/* Parallel Operation of both FIFOs */
									for (j = 799; j >= 1; j = j - 1)
									fifo_mem_b[j - 1]	<= #20 fifo_mem_b[j];	
									for (j = 799; j >= 1; j = j - 1)
									fifo_mem_a[j - 1]	<= #20 fifo_mem_a[j];
									end
						        
						  default: 	begin 
										ptr <= #20 0; 
										toggle <= #20 1'b0;
									end 
			            endcase
			        else 
		                begin 
							ptr <= #20 0; 
							toggle <= #20 1'b0;
						end 
			else 
				begin
					ptr <= #20 0;
					toggle <= #20 1'b0;
			    end 
	else    
		begin 
	        ptr <= #20 0; 
	        toggle <= #20 1'b0;
        end 
end		

endmodule 

// module rwave_mem (
				  // output signed	[`b16:0] 	tap1, tap2,
				  // input signed 	[`b16:0] 	data_in1, data_in2, data_in3, data_in4, 
											// data_in5, data_in6, data_in7, data_in8,
				  // input 		[`b16:0] 	count1,
				  // input 	   	[`b9:0] 	count2,
				  // input 			   		clk, nReset, Enable,
				  // input 			   		stop1, stop2,
				  // input				   		serial_mode, parallel_mode
				  // );

// parameter Y = 1600, INC = 50, fifo_lim = 1700;

// localparam DATA_W 		   = 16;
// localparam NUM_OF_MEM 	   = 8;
// localparam LOG2_NUM_OF_MEM = 3;
// localparam MEM_DEPTH 	   = 128;	
// localparam LOG2_MEM_DEPTH  = 7;

// reg   		mem_write, 
			// mem_read;
// reg  		toggle;
// reg 	   	[LOG2_MEM_DEPTH-1:0] ptr;
// wire       	r_inc_par, 
			// r_inc_ser; 
// wire signed [15:0]  data_a, data_b;

// integer 	i, j;

// assign tap1	= data_a;
// assign tap2	= data_b;

// assign mem_read_ser = mem_read & stop1;
// assign mem_read_par = mem_read & parallel_mode & stop2;

// /* Instantiation of the FIFO Modules */
// rwave_fifo #(DATA_W,NUM_OF_MEM,LOG2_NUM_OF_MEM,MEM_DEPTH,LOG2_MEM_DEPTH)
// rwave_fifo_a  (	.clk		( clk	),
				// .reset_n	( nReset ),
				// .w_en		( mem_write & ~toggle ),
				// .r_en		( mem_read_ser ),
				// .addr		( ptr ),
				// .data_i		( {data_in8,data_in7,data_in6,data_in5,data_in4,data_in3,data_in2,data_in1}	),
				// .data_o 	( data_a ),
				// .r_inc      ( r_inc_ser )
				// );

// rwave_fifo #(DATA_W,NUM_OF_MEM,LOG2_NUM_OF_MEM,MEM_DEPTH,LOG2_MEM_DEPTH)
// rwave_fifo_b  (	.clk		( clk ),
				// .reset_n	( nReset ),
				// .w_en		( mem_write & ~toggle ),
				// .r_en		( mem_read_par ),
				// .addr		( ptr ),
				// .data_i		( {data_in8,data_in7,data_in6,data_in5,data_in4,data_in3,data_in2,data_in1} ),
				// .data_o 	( data_b ),
				// .r_inc      ( r_inc_par )
				// );

// /* Memory Read/Write Flags */
// always @(*)
// begin
// mem_write	= ((count1 > 0)  && (count2 > 1) && (ptr <= 99)) 	? 1'b1 : 1'b0;
// mem_read 	= ((count1 == 2) && (count2 == 1)) 					? 1'b1 : 1'b0;
// end

// /* MEM Write Block */
// always @(posedge clk or negedge nReset)
// begin
// if(!nReset)
	// begin
	  // toggle <=  1'b0;
		// ptr	<=	0;
	// end
// else 
	// if (Enable)
		// if (mem_write)
			// if (!toggle)
				// begin
					// ptr 	<=  ptr + 1; // increment by 1 instead of 8 
					// toggle 	<=  ~toggle;
				// end	
			// else	toggle <=  ~toggle;
		// else if (mem_read_ser || mem_read_par)
			 // if (r_inc_ser || r_inc_par)
				// ptr <= ptr + 1;
			 // else
				// ptr <= ptr; // hold value
		// else 
			// begin
				// toggle <=  1'b0;
				// ptr	   <= 0;
			// end
	// else
		// begin 
			// ptr 	<=  0; 
			// toggle 	<=  1'b0;
		// end 
// end		

// endmodule 