/*
Module		: 	com.v
HDL			: 	Verilog 2001
Function	: 	Pin Multiplexer and Output Reg Bank
Authors	  	:	Ahmed F Rahim,    MSc SoC 2012, University of Southampton.
Current   	:	Stable, Bug free, Ready for Synthesis.
Version		
History		:	Added to HYBRID top level
*/

`timescale 1ps/1ps

module com #( parameter PARAM_W 			 = 16, 
			  parameter NUM_OF_PARAM 		 = 16, 
			  parameter LOG2_NUM_OF_PARAM  = 4,
			  parameter PARAM_MEM_DEPTH 	 = 8,
			  parameter LOG2_PARAM_MEM_DEPTH = 3
			  )
			( input						clk, 
										reset_n, 
			  input 					hybd_done,
			  input						hybd_en,
			  // param in
			  input signed 	[PARAM_W-6:0] 	q_peak_pos_ref,r_peak_pos_ref,s_peak_pos_ref,
											start_qrs_fin_2,end_qrs_fin_2,
											p_begin,p_finish,p_peak_pos,
											t_begin,t_finish,t_peak_pos, 			
			  input signed 	[PARAM_W-1:0] 	q_peak_ref,r_peak_ref,s_peak_ref,p_peak,t_peak,
			  // com iface
			  input 					com_req,
			  output	reg			com_rdy,			  
			  input 		[LOG2_NUM_OF_PARAM+LOG2_PARAM_MEM_DEPTH-1:0] addr_i,
			  output signed	[PARAM_W-1:0]	data_o
			);

// 11'b
wire [PARAM_W-1:0]	p_pk_pos,
						q_pk_pos,
						r_pk_pos, 
						s_pk_pos,
						t_pk_pos,
						//
						qrs_start, 
						qrs_end, 
						//
						p_start, 
						p_end,
						//
						t_start, 
						t_end; 					

// 16'b
wire [PARAM_W-1:0]	p_pk_ref, 
						q_pk_ref, 
						r_pk_ref, 
						s_pk_ref, 
						t_pk_ref;

wire [(NUM_OF_PARAM*PARAM_W)-1:0] data_in_v, data_out_v;
reg [(NUM_OF_PARAM*PARAM_W)-1:0] data_out_reg;
wire [LOG2_PARAM_MEM_DEPTH-1:0]   addr_sel, r_addr;

wire w_en, r_en, hybd_en_flg;

reg [LOG2_PARAM_MEM_DEPTH-1:0] 	w_addr;
reg [NUM_OF_PARAM-1:0] 			mem_sel, mem_sel_reg;

assign addr_sel = (w_en)? w_addr : (r_en)? addr_i[LOG2_PARAM_MEM_DEPTH-1:0] : 0;

// *_en  
//assign com_rdy 	= hybd_en_flg & ~hybd_en; 

always @(posedge clk or negedge reset_n)
if (!reset_n)					 
 com_rdy <= 1'b0;
else
 com_rdy <= r_en;

assign w_en 	= hybd_done;
assign r_en 	= com_req;	
	
assign p_pk_pos = {{5{p_peak_pos[10]}}, p_peak_pos};
assign q_pk_pos = {{5{q_peak_pos_ref[10]}}, q_peak_pos_ref};
assign r_pk_pos = {{5{r_peak_pos_ref[10]}}, r_peak_pos_ref};
assign s_pk_pos = {{5{s_peak_pos_ref[10]}}, s_peak_pos_ref};
assign t_pk_pos = {{5{t_peak_pos[10]}}, t_peak_pos};
assign qrs_start= {{5{start_qrs_fin_2[10]}}, start_qrs_fin_2};
assign qrs_end  = {{5{end_qrs_fin_2[10]}}, end_qrs_fin_2};
assign p_start  = {{5{p_begin[10]}}, p_begin};
assign p_end    = {{5{p_finish[10]}}, p_finish};
assign t_start	= {{5{t_begin[10]}}, t_begin};
assign t_end	= {{5{t_finish[10]}}, t_finish};

assign p_pk_ref = p_peak; 
assign q_pk_ref = q_peak_ref; 
assign r_pk_ref = r_peak_ref; 
assign s_pk_ref = s_peak_ref; 
assign t_pk_ref = t_peak;

// data_i packing
assign data_in_v   = { t_end,    t_pk_ref, t_pk_pos, t_start,
					   qrs_end,  s_pk_ref, r_pk_ref, q_pk_ref,
					   s_pk_pos, r_pk_pos, q_pk_pos, qrs_start,
					   p_end, 	 p_pk_ref, p_pk_pos, p_start
					 };
                
// data_o select
assign data_o = mem_sel_reg[0] ? data_out_v[(PARAM_W)-1:0] :
				mem_sel_reg[1] ? data_out_v[2*(PARAM_W)-1:1*(PARAM_W)] :
				mem_sel_reg[2] ? data_out_v[3*(PARAM_W)-1:2*(PARAM_W)] :
				mem_sel_reg[3] ? data_out_v[4*(PARAM_W)-1:3*(PARAM_W)] :
				mem_sel_reg[4] ? data_out_v[5*(PARAM_W)-1:4*(PARAM_W)] :
				mem_sel_reg[5] ? data_out_v[6*(PARAM_W)-1:5*(PARAM_W)] :
				mem_sel_reg[6] ? data_out_v[7*(PARAM_W)-1:6*(PARAM_W)] :
				mem_sel_reg[7] ? data_out_v[8*(PARAM_W)-1:7*(PARAM_W)] :
				mem_sel_reg[8] ? data_out_v[9*(PARAM_W)-1:8*(PARAM_W)] :
				mem_sel_reg[9] ? data_out_v[10*(PARAM_W)-1:9*(PARAM_W)] :
				mem_sel_reg[10] ? data_out_v[11*(PARAM_W)-1:10*(PARAM_W)] :
				mem_sel_reg[11] ? data_out_v[12*(PARAM_W)-1:11*(PARAM_W)] :
				mem_sel_reg[12] ? data_out_v[13*(PARAM_W)-1:12*(PARAM_W)] :
				mem_sel_reg[13] ? data_out_v[14*(PARAM_W)-1:13*(PARAM_W)] :
				mem_sel_reg[14] ? data_out_v[15*(PARAM_W)-1:14*(PARAM_W)] :
				mem_sel_reg[15] ? data_out_v[16*(PARAM_W)-1:15*(PARAM_W)] : 0;

always@(*)
	case(addr_i[LOG2_NUM_OF_PARAM+LOG2_PARAM_MEM_DEPTH-1:LOG2_PARAM_MEM_DEPTH])
		
		4'h0: mem_sel = 16'h0001;
		4'h1: mem_sel = 16'h0002;
		4'h2: mem_sel = 16'h0004;
		4'h3: mem_sel = 16'h0008;	
		4'h4: mem_sel = 16'h0010;
		4'h5: mem_sel = 16'h0020;
		4'h6: mem_sel = 16'h0040;
		4'h7: mem_sel = 16'h0080;
		4'h8: mem_sel = 16'h0100;
		4'h9: mem_sel = 16'h0200;
		4'hA: mem_sel = 16'h0400;
		4'hB: mem_sel = 16'h0800;
		4'hC: mem_sel = 16'h1000;
		4'hD: mem_sel = 16'h2000;
		4'hE: mem_sel = 16'h4000;
		4'hF: mem_sel = 16'h8000;
	endcase

// data_out_reg
always @(posedge clk or negedge reset_n)
if (!reset_n)					 
	data_out_reg <= 0;
else if (r_en)
	data_out_reg <= data_out_v;   

always @(posedge clk or negedge reset_n)
if (!reset_n)					 
	mem_sel_reg <= 0;
else if (r_en)
	mem_sel_reg <= mem_sel;    
   
// w_addr
always @(posedge clk or negedge reset_n)
if (!reset_n)					 
	w_addr <= 0;
else if (w_en)
	w_addr <= (&w_addr) ? 0 : w_addr+1;
	
// MEM instantiation
generate
genvar n;
for (n = 0; n < NUM_OF_PARAM ; n = n+1) begin

:PARAM_MEM  param_mem_8x16	i_param_mem (.aclr 	 ( ~reset_n ),
									     .address( addr_sel ),
									     .clock  ( clk ),
									     .data 	 ( data_in_v[((n+1)*PARAM_W)-1:n*PARAM_W] ),
									     .rden 	 ( r_en & mem_sel[n] ),
									     .wren 	 ( w_en ),
									     .q 	 ( data_out_v[((n+1)*PARAM_W)-1:n*PARAM_W] )
									    );

end
endgenerate

lib_posedge_flg_v2 en_flg_gen (.clk			( clk ),
					           .reset_n		( reset_n ),
							   .data_i		( hybd_en ),
							   .pos_edge_flg( hybd_en_flg )
							   );

endmodule 