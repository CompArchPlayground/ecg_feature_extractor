`timescale 1ps/1ps
`include "parameter.v"

module waveletl3 (r_peak_ref,r_peak_pos_ref,
start_qrs_fin_2,end_qrs_fin_2,
data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8,clk,nReset,push_data,Rp);

output signed [`b11:0] r_peak_pos_ref,start_qrs_fin_2,
end_qrs_fin_2;
output signed [`b16:0] r_peak_ref;

output Rp;

input push_data;

wire [`b16:0]
cA0_l3,cA1_l3,cA2_l3,cA3_l3,cA4_l3,cA5_l3,cA6_l3,cA7_l3,cA8_l3,cA9_l3,cA10_l3,cA11_l3,cA12_l3,cA13_l3,cA14_l3,cA15_l3,cA16_l3,cA17_l3,cA18_l3,cA19_l3,cA20_l3,cA21_l3,cA22_l3,cA23_l3,cA24_l3,cA25_l3_l3,cA26_l3,cA27_l3,cA28_l3,cA29_l3,cA30_l3,cA31_l3,cA32_l3,cA33_l3,cA34_l3,cA35_l3,cA36_l3,cA37_l3,cA38_l3,cA39_l3,cA40_l3,cA41_l3,cA42_l3,cA43_l3,cA44_l3,cA45_l3,cA46_l3,cA47_l3,cA48_l3,cA49_l3,cA50_l3,cA51_l3,cA52_l3,cA53_l3,cA54_l3,cA55_l3,cA56_l3,cA57_l3,cA58_l3,cA59_l3,cA60_l3,cA61_l3,cA62_l3,cA63_l3,cA64_l3,cA65_l3,cA66_l3,cA67_l3,cA68_l3,cA69_l3,cA70_l3,cA71_l3,cA72_l3,cA73_l3,cA74_l3,cA75_l3,cA76_l3,cA77_l3,cA78_l3,cA79_l3,cA80_l3,cA81_l3,cA82_l3,cA83_l3,cA84_l3,cA85_l3,cA86_l3,cA87_l3,cA88_l3,cA89_l3,cA90_l3,cA91_l3,cA92_l3,cA93_l3,cA94_l3,cA95_l3,cA96_l3,cA97_l3,cA98_l3,cA99_l3;

input [`b16:0] data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8;

input clk, nReset;

wire Rp;

wire [15:0] count1_l3;
wire [`b9:0] count2_l3;

wire [`b11:0] max_pos_l3,min_pos_l3,q_begin_l3_temp,s_end_l3_temp,max_pos_l3_n,min_pos_l3_n;

wire signed [`b16:0] thr1,thr2,tap1,tap2;

wire qwindow1_full,swindow1_full,q_begin_l3_flag,s_end_l3_flag,cD_min_found;

level3arch l3_arch(count1_l3,count2_l3,max_pos_l3,min_pos_l3,
q_begin_l3_temp,q_begin_l3_flag,qwindow1_full,s_end_l3_temp,swindow1_full,
s_end_l3_flag,max_pos_l3_n,min_pos_l3_n,cD_min_found,
cA0_l3,cA1_l3,cA2_l3,cA3_l3,cA4_l3,cA5_l3,cA6_l3,cA7_l3,cA8_l3,cA9_l3,cA10_l3,cA11_l3,cA12_l3,cA13_l3,cA14_l3,cA15_l3,cA16_l3,cA17_l3,cA18_l3,cA19_l3,cA20_l3,cA21_l3,cA22_l3,cA23_l3,cA24_l3,cA25_l3_l3,cA26_l3,cA27_l3,cA28_l3,cA29_l3,cA30_l3,cA31_l3,cA32_l3,cA33_l3,cA34_l3,cA35_l3,cA36_l3,cA37_l3,cA38_l3,cA39_l3,cA40_l3,cA41_l3,cA42_l3,cA43_l3,cA44_l3,cA45_l3,cA46_l3,cA47_l3,cA48_l3,cA49_l3,cA50_l3,cA51_l3,cA52_l3,cA53_l3,cA54_l3,cA55_l3,cA56_l3,cA57_l3,cA58_l3,cA59_l3,cA60_l3,cA61_l3,cA62_l3,cA63_l3,cA64_l3,cA65_l3,cA66_l3,cA67_l3,cA68_l3,cA69_l3,cA70_l3,cA71_l3,cA72_l3,cA73_l3,cA74_l3,cA75_l3,cA76_l3,cA77_l3,cA78_l3,cA79_l3,cA80_l3,cA81_l3,cA82_l3,cA83_l3,cA84_l3,cA85_l3,cA86_l3,cA87_l3,cA88_l3,cA89_l3,cA90_l3,cA91_l3,cA92_l3,cA93_l3,cA94_l3,
cA95_l3,cA96_l3,cA97_l3,cA98_l3,cA99_l3,data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8,clk,nReset,push_data);


// QRS Refinement*********************************


ecg_signal_max ecgmax(thr1,thr2,count1_l3,count2_l3,min_pos_l3,
max_pos_l3,data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8,clk,nReset,push_data);
/*
rwave_refine r_ref(r_peak_ref,r_peak_pos_ref,start_qrs_fin_2,end_qrs_fin_2,
max_pos_l3_n,min_pos_l3_n,cD_min_found,count1_l3,count2_l3,max_pos_l3,
min_pos_l3,data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8,thr1,thr2,q_begin_l3_temp,s_end_l3_temp,
q_begin_l3_flag,s_end_l3_flag,tap1,tap2,STOP1,STOP2,
cA0_l3,cA1_l3,cA2_l3,cA3_l3,cA4_l3,cA5_l3,cA6_l3,cA7_l3,cA8_l3,cA9_l3,cA10_l3,cA11_l3,cA12_l3,cA13_l3,cA14_l3,cA15_l3,cA16_l3,cA17_l3,cA18_l3,cA19_l3,cA20_l3,cA21_l3,cA22_l3,cA23_l3,cA24_l3,cA25_l3_l3,cA26_l3,cA27_l3,cA28_l3,cA29_l3,cA30_l3,cA31_l3,cA32_l3,cA33_l3,cA34_l3,cA35_l3,cA36_l3,cA37_l3,cA38_l3,cA39_l3,cA40_l3,cA41_l3,cA42_l3,cA43_l3,cA44_l3,cA45_l3,cA46_l3,cA47_l3,cA48_l3,cA49_l3,cA50_l3,cA51_l3,cA52_l3,cA53_l3,cA54_l3,cA55_l3,cA56_l3,cA57_l3,cA58_l3,cA59_l3,cA60_l3,cA61_l3,cA62_l3,cA63_l3,cA64_l3,cA65_l3,cA66_l3,cA67_l3,cA68_l3,cA69_l3,cA70_l3,cA71_l3,cA72_l3,cA73_l3,cA74_l3,cA75_l3,cA76_l3,cA77_l3,cA78_l3,cA79_l3,cA80_l3,cA81_l3,cA82_l3,cA83_l3,cA84_l3,cA85_l3,cA86_l3,cA87_l3,cA88_l3,cA89_l3,cA90_l3,cA91_l3,cA92_l3,cA93_l3,cA94_l3,
cA95_l3,cA96_l3,cA97_l3,cA98_l3,cA99_l3,clk,nReset,Enable,Rp);

rwave_mem RMEM(tap1,tap2,ecg_raw,data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8,clk,nReset,Enable,count1_l3,count2_l3,STOP1,STOP2);
*/

rwave_top r_ref(r_peak_ref,		r_peak_pos_ref,		start_qrs_fin_2,	end_qrs_fin_2,		Rp,
				
				max_pos_l3_n,	min_pos_l3_n,				
				max_pos_l3,		min_pos_l3,
				
				q_begin_l3_temp,	s_end_l3_temp,
				
				data_in1,		data_in2,			data_in3,			data_in4,
				data_in5,		data_in6,			data_in7,			data_in8,
				
				thr1,			thr2,				
				
				cA0_l3,		cA1_l3,		cA2_l3,		cA3_l3,		cA4_l3,		cA5_l3,		cA6_l3,		cA7_l3,		cA8_l3,		cA9_l3,	
				cA10_l3, 	cA11_l3, 	cA12_l3,	cA13_l3,	cA14_l3,	cA15_l3,	cA16_l3,	cA17_l3,	cA18_l3,	cA19_l3,
				cA20_l3,	cA21_l3,	cA22_l3,	cA23_l3,	cA24_l3,	cA25_l3_l3,	cA26_l3,	cA27_l3,	cA28_l3,	cA29_l3,
				cA30_l3,	cA31_l3,	cA32_l3,	cA33_l3,	cA34_l3,	cA35_l3,	cA36_l3,	cA37_l3,	cA38_l3,	cA39_l3,
				cA40_l3,	cA41_l3,	cA42_l3,	cA43_l3,	cA44_l3,	cA45_l3,	cA46_l3,	cA47_l3,	cA48_l3,	cA49_l3,
				cA50_l3,	cA51_l3,	cA52_l3,	cA53_l3,	cA54_l3,	cA55_l3,	cA56_l3,	cA57_l3,	cA58_l3,	cA59_l3,
				cA60_l3,	cA61_l3,	cA62_l3,	cA63_l3,	cA64_l3,	cA65_l3,	cA66_l3,	cA67_l3,	cA68_l3,	cA69_l3,
				cA70_l3,	cA71_l3,	cA72_l3,	cA73_l3,	cA74_l3,	cA75_l3,	cA76_l3,	cA77_l3,	cA78_l3,	cA79_l3,
				cA80_l3,	cA81_l3,	cA82_l3,	cA83_l3,	cA84_l3,	cA85_l3,	cA86_l3,	cA87_l3,	cA88_l3,	cA89_l3,
				cA90_l3,	cA91_l3,	cA92_l3,	cA93_l3,	cA94_l3,	cA95_l3,	cA96_l3,	cA97_l3,	cA98_l3,	cA99_l3,
				
				count1_l3,	count2_l3, 	
				
				q_begin_l3_flag,		s_end_l3_flag,		cD_min_found,
				
				clk,		nReset,	 	push_data);				
				
endmodule

