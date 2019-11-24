`timescale 1ps/1ps
`include "parameter.v"

module waveletl5 (q_peak_ref,q_peak_pos_ref,s_peak_ref,s_peak_pos_ref,p_begin,
p_end,p_peak,p_peak_pos,t_begin,t_end,t_peak,t_peak_pos,
start_qrs_fin_2,end_qrs_fin_2,r_peak_pos_ref,data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8,clk,nReset,Enable,start1);

output signed [`b11:0] q_peak_pos_ref,s_peak_pos_ref,p_begin,p_end,
p_peak_pos,t_begin,t_end,t_peak_pos; 

output signed [`b16:0] q_peak_ref,s_peak_ref,p_peak,t_peak; 

input signed [`b11:0] start_qrs_fin_2,end_qrs_fin_2,r_peak_pos_ref;
output start1;

input [`b16:0] data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8;

input clk, nReset,Enable;
wire clk, nReset,Enable;

wire [`b6:0] count1_l5,count2_l5;

wire signed [`b11:0] p1maxp,p1minp,p2maxp,p2minp,t1maxp,t1minp;

wire array_2,p1_cD_full,p2_cD_full,t_cD_full,p_zero;

level5arch l5arch(p_begin,p_end,p1maxp,p1minp,p2maxp,p2minp,t_begin,t_end,t1maxp,
t1minp,array_2,p1_cD_full,p2_cD_full,t_cD_full,p_zero,count1_l5,
count2_l5,start_qrs_fin_2,end_qrs_fin_2,data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8,clk,nReset,Enable);

ecg_signal_maxmin ecg_mxmn(q_peak_ref,q_peak_pos_ref,s_peak_ref,s_peak_pos_ref,p_peak,p_peak_pos,p_begin,p_end,t_peak,t_peak_pos,t_begin,t_end,array_2,
p1_cD_full,p2_cD_full,t_cD_full,p_zero,p1maxp,p1minp,
p2maxp,p2minp,t1maxp,t1minp,start_qrs_fin_2,end_qrs_fin_2,
r_peak_pos_ref,count1_l5,count2_l5,data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8,
clk,nReset,Enable,start1);

endmodule

