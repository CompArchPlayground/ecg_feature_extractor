`timescale 1ps/1ps
`include "parameter.v"

module rwave_top (	output [`b16:0] r_peak_ref, 
					output [`b11:0] r_peak_pos_ref, start_qrs_fin_2, end_qrs_fin_2, 
					output Rp, 
					input [`b11:0]  max_pos_l3_n, 		min_pos_l3_n, 
									max_pos_l3, 		min_pos_l3, 
									q_begin_l3_temp, 	s_end_l3_temp, 			
					input [`b16:0] 	data_in1, data_in2, data_in3, data_in4, 
									data_in5, data_in6, data_in7, data_in8, 
					input [`b16:0]	thr1, thr2, 
					input [`b16:0] 	cA0,  cA1,   cA2,  cA3,  cA4,  cA5,  cA6,  cA7,  cA8,  cA9,
									cA10, cA11, cA12, cA13, cA14, cA15, cA16, cA17, cA18, cA19,
									cA20, cA21, cA22, cA23, cA24, cA25, cA26, cA27, cA28, cA29,
									cA30, cA31, cA32, cA33, cA34, cA35, cA36, cA37, cA38, cA39,
									cA40, cA41, cA42, cA43, cA44, cA45, cA46, cA47, cA48, cA49,
									cA50, cA51, cA52, cA53, cA54, cA55, cA56, cA57, cA58, cA59,
									cA60, cA61, cA62, cA63, cA64, cA65, cA66, cA67, cA68, cA69,
									cA70, cA71, cA72, cA73, cA74, cA75, cA76, cA77, cA78, cA79,
									cA80, cA81, cA82, cA83, cA84, cA85, cA86, cA87, cA88, cA89,
									cA90, cA91, cA92, cA93, cA94, cA95, cA96, cA97, cA98, cA99,
					input [`b16:0]  count1,
					input [`b9:0]   count2,
					input 			q_begin_l3_flag, s_end_l3_flag, cD_min_found,
					input 			clk, nReset, Enable);

wire		  	stop_a, stop_b;
wire		  	serial_mode, parallel_mode;
wire     [`b16:0] tap1, tap2; 

rwave_control RWAVE_CONTROL	(.r_peak_ref_o(r_peak_ref),			.r_peak_pos_ref_o(r_peak_pos_ref), 		.start_qrs_fin_2_o(start_qrs_fin_2), 
							 .end_qrs_fin_2_o(end_qrs_fin_2),
							 .Rp(Rp), 							
							 .stop_a(stop_a),  		.stop_b(stop_b),		
							 
							 .serial_mode(serial_mode), 	.parallel_mode(parallel_mode),		
							 
							 .max_pos_l3_n(max_pos_l3_n), 				.min_pos_l3_n(min_pos_l3_n), 
							 .max_pos_l3(max_pos_l3), 					.min_pos_l3(min_pos_l3), 
							 .q_begin_l3_temp(q_begin_l3_temp), 		.s_end_l3_temp(s_end_l3_temp),
							 /*
							 .data_in1(data_in1), 	.data_in2(data_in2), 	.data_in3(data_in3), 		.data_in4(data_in4),				
							 .data_in5(data_in5), 	.data_in6(data_in6), 	.data_in7(data_in7), 		.data_in8(data_in8),	*/			
							 
							 .thr1(thr1), 	.thr2(thr2), 			
							 
							 .tap1(tap1), 	.tap2(tap2),
							 
							 .cA0(cA0), 	.cA1(cA1), 		.cA2(cA2),  	.cA3(cA3),  		.cA4(cA4),  		
							 .cA10(cA10), 	.cA11(cA11), 	.cA12(cA12), 	.cA13(cA13), 		.cA14(cA14), 		
							 .cA20(cA20), 	.cA21(cA21), 	.cA22(cA22), 	.cA23(cA23), 		.cA24(cA24), 		
							 .cA30(cA30), 	.cA31(cA31), 	.cA32(cA32), 	.cA33(cA33), 		.cA34(cA34), 		
							 .cA40(cA40), 	.cA41(cA41), 	.cA42(cA42), 	.cA43(cA43), 		.cA44(cA44), 		
							 .cA50(cA50), 	.cA51(cA51), 	.cA52(cA52), 	.cA53(cA53), 		.cA54(cA54), 		
							 .cA60(cA60), 	.cA61(cA61), 	.cA62(cA62), 	.cA63(cA63), 		.cA64(cA64), 		
							 .cA70(cA70), 	.cA71(cA71), 	.cA72(cA72), 	.cA73(cA73), 		.cA74(cA74), 		
							 .cA80(cA80), 	.cA81(cA81), 	.cA82(cA82), 	.cA83(cA83),		.cA84(cA84), 		
							 .cA90(cA90), 	.cA91(cA91), 	.cA92(cA92), 	.cA93(cA93), 		.cA94(cA94), 		
							 
							 .cA5(cA5),  	.cA6(cA6),  	.cA7(cA7),  	.cA8(cA8),  		.cA9(cA9),
							 .cA15(cA15), 	.cA16(cA16), 	.cA17(cA17),	.cA18(cA18), 		.cA19(cA19),
						     .cA25(cA25),	.cA26(cA26), 	.cA27(cA27),	.cA28(cA28), 		.cA29(cA29),
							 .cA35(cA35), 	.cA36(cA36), 	.cA37(cA37), 	.cA38(cA38), 		.cA39(cA39),
							 .cA45(cA45), 	.cA46(cA46), 	.cA47(cA47), 	.cA48(cA48), 		.cA49(cA49),
							 .cA55(cA55), 	.cA56(cA56), 	.cA57(cA57), 	.cA58(cA58), 		.cA59(cA59),
							 .cA65(cA65), 	.cA66(cA66), 	.cA67(cA67), 	.cA68(cA68), 		.cA69(cA69),
							 .cA75(cA75), 	.cA76(cA76), 	.cA77(cA77), 	.cA78(cA78), 		.cA79(cA79),
							 .cA85(cA85), 	.cA86(cA86), 	.cA87(cA87), 	.cA88(cA88), 		.cA89(cA89),
							 .cA95(cA95), 	.cA96(cA96), 	.cA97(cA97), 	.cA98(cA98), 		.cA99(cA99),
							 
							 .count1(count1),				.count2(count2),
							 
							 .q_begin_l3_flag(q_begin_l3_flag),			.s_end_l3_flag(s_end_l3_flag), 				.cD_min_found(cD_min_found),
							 
							 .clk(clk),				.nReset(nReset), 	.Enable(Enable)
							 );
						
rwave_mem 	 RWAVE_MEM( .tap1( tap1 ), 			.tap2( tap2 ),
						.data_in1( data_in1 ), 	.data_in2( data_in2 ), 	.data_in3( data_in3 ), 		.data_in4( data_in4 ), 
						.data_in5( data_in5 ), 	.data_in6( data_in6 ),	.data_in7( data_in7 ), 		.data_in8( data_in8 ),
						.count1( count1 ),		.count2( count2 ),		.clk( clk ), 					.nReset( nReset ),		
						.Enable( Enable ),		.stop1( stop_a ), 		.stop2( stop_b ),				.serial_mode( serial_mode ), 			
						.parallel_mode( parallel_mode )
						);
						
endmodule 