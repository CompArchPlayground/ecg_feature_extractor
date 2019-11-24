/*
Module		: 	hybd_core.v

HDL			: 	Verilog 2001

Function	: 	Top Level Module

Authors	  	:	Ahmed F Rahim,    MSc SoC 2012, University of Southampton.
				Sanmitra Ghosh,	  MSc SoC 2011, University of Southampton.

Current   	:	Stable, Bug free, Ready for Synthesis.

Version		
History		:	# Ahmed F Rahim : adapted core for fpga based hybrid_soc
				# Ahmed F Rahim	: added COM, re-designed FIFO, R_WAVE, ECG_MAX
				# Sanmitra Ghosh: designed LOOP and SYNC, changed overall arch of WAVELET_L3/L5 from Parallel TX to Sequential TX
*/

`timescale 1ps/1ps
`include "parameter.v"

module hybd_core (	input clk,	
				    input nReset,	
					// fifo => core
					input Enable,
					input push_data,
					input signed [(8*16)-1:0] fifo_data,
					// fifo <= core 
				    output Rp, 			
					output start,
					output signed [`b11:0]r_peak_pos_ref,
					// uart_iface <=> core
					input                com_req,
					input          [6:0] com_addr_i,
					output        		 com_rdy,
					output signed [15:0] com_data_o
					);

wire start_flg;					
					
wire signed [`b11:0] 	q_peak_pos_ref,	s_peak_pos_ref,	start_qrs_fin_2,	
						end_qrs_fin_2,	p_begin,		p_end,			p_peak_pos,
						t_begin,		t_end,			t_peak_pos; 

wire signed [`b16:0]	q_peak_ref,		r_peak_ref,		s_peak_ref,
						p_peak,			t_peak,			data_in1,		data_in2,
						data_in3,		data_in4,		data_in5,		data_in6,
						data_in7,		data_in8;

assign {data_in8,data_in7,data_in6,data_in5,data_in4,data_in3,data_in2,data_in1} = fifo_data;						
												
/* WAVELET 3 [Version: RWAVE Parallel, ECG_Max_Patched ] */
waveletl3 i_wavelet_l3 ( r_peak_ref,	r_peak_pos_ref,	start_qrs_fin_2, 	end_qrs_fin_2,		data_in1,		data_in2,
					     data_in3,		data_in4,		data_in5,			data_in6,    		data_in7,		data_in8,
					     clk,			nReset,			push_data,			Rp);

/* WAVELET 5 */
waveletl5 i_wavelet_l5 ( q_peak_ref,	q_peak_pos_ref,	s_peak_ref,	s_peak_pos_ref,	p_begin,			p_end,			p_peak,p_peak_pos,
					     t_begin,		t_end,			t_peak,		t_peak_pos,		start_qrs_fin_2,	end_qrs_fin_2,	r_peak_pos_ref, 
					     data_in1,		data_in2,		data_in3,	data_in4,		data_in5,			data_in6,		data_in7,
					     data_in8,		clk,			nReset,		push_data,		start);

lib_posedge_flg_v1 start_flg_gen (.clk			( clk ),
					              .reset_n		( nReset ),
								  .data_i		( start ),
								  .pos_edge_flg	( start_flg )
								  );
                    
/* COM */
com  #(	16,16,4,8,3 )
i_com ( clk, 			nReset, 		start_flg, 		Enable, 		      
		q_peak_pos_ref,	r_peak_pos_ref,	s_peak_pos_ref,	start_qrs_fin_2,
		end_qrs_fin_2,	p_begin,		p_end,			p_peak_pos,
		t_begin,		t_end,			t_peak_pos,		q_peak_ref,
		r_peak_ref,		s_peak_ref,		p_peak,			t_peak,			   
		com_req,		com_rdy,		com_addr_i,		com_data_o);
				
endmodule 