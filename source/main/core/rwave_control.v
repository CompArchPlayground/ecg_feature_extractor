/*
Patched version
*/

`timescale 1ps/1ps
`include "parameter.v"
 
module rwave_control(	output [`b16:0] r_peak_ref_o,
						output [`b11:0] r_peak_pos_ref_o, start_qrs_fin_2_o, end_qrs_fin_2_o,
						output 			Rp, 
						output  		stop_a, stop_b,
						output			serial_mode, parallel_mode,
						input [`b11:0]  max_pos_l3_n, min_pos_l3_n, max_pos_l3, min_pos_l3, q_begin_l3_temp, s_end_l3_temp,
						/*input [`b16:0] 	data_in1, data_in2, data_in3, data_in4,
										        data_in5, data_in6, data_in7, data_in8,*/
						input [`b16:0]	     thr1, thr2, 
				 input signed [`b16:0] 	tap1, tap2,
						input [`b16:0] 	cA0, cA1,   cA2,  cA3,  cA4,  cA5,  cA6,  cA7,  cA8,  cA9,
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

integer j;

wire signed [`b16:0] cA_store [0:`n3-2];
						
reg signed [`b16:0]  r_peak_ref, 		r_peak_ref1, 		r_peak_ref2, 		r_peak_ref3 /*tap_1_reg, tap_2_reg, tap_1a_reg*/;

reg signed [`b11:0] r_peak_pos_ref, 	r_peak_pos_ref1, 	r_peak_pos_ref2, 	r_peak_pos_ref3, 
					r_peak_pos_temp1, 	r_peak_pos_temp2, 	r_peak_pos_temp3,
					 start_qrs_fin_2,	end_qrs_fin_2;

reg 				r_win_full1, 		r_win_full2, 		r_win_full3, RRp;

reg 				counta, 			countb, 			k;

reg 	   [`b11:0] limit01_xa_find,	limit02_xa_find,	limit03_xb_find,	limit04_xb_find,
					limit1ecg,			limit2ecg,			limit3ecg,			limit4ecg,
				    limit5ecg,			limit6ecg,			limit21_xa_find,	limit22_xa_find,
				    limit23_xb_find,	limit24_xb_find,	start_var,			end_var;

reg signed [`b16:0] grad_ecg_qrs_abs1, 	grad_ecg_qrs1,		flip_grad_qrs_abs1,	flip_grad_qrs1,
					grad_ecg_qrs_abs2,	grad_ecg_qrs2,		flip_grad_qrs_abs2,	flip_grad_qrs2;

reg signed [`b11:0] start_qrs1,			end_qrs1,			start_qrs2,			end_qrs2;

reg 				start_qrs_found1,	end_qrs_found1,		grad_win_full1,		flip_grad_win_full1,
					start_qrs_found2,	end_qrs_found2,		grad_win_full2,		flip_grad_win_full2,
					stop1,				stop2;

reg 	   [`b11:0] c2,	c3,	c4,	c6,	c7,	c8,	c9;

/* New Reg Names */

reg 			par_mode,  ser_mode;
reg 			stop1_par, stop1_ser; 
reg			  	upper_limit_par_a, upper_limit_par_b, upper_limit_ser;
reg		   		lower_limit_par_a, lower_limit_par_b, lower_limit_ser;
reg		[1:0] 	state_ser, state_par_a, state_par_b;
reg				par_max_found;
reg       		mem_read;

assign r_peak_ref_o      = r_peak_ref;
assign r_peak_pos_ref_o  = r_peak_pos_ref; 
assign start_qrs_fin_2_o = start_qrs_fin_2; 
assign end_qrs_fin_2_o   = end_qrs_fin_2;

assign stop_a = stop1;
assign stop_b = stop2;
assign Rp 	  = RRp;

assign cA_store[0] = cA0;
assign cA_store[1] = cA1;
assign cA_store[2] = cA2;
assign cA_store[3] = cA3;
assign cA_store[4] = cA4;
assign cA_store[5] = cA5;
assign cA_store[6] = cA6;
assign cA_store[7] = cA7;
assign cA_store[8] = cA8;
assign cA_store[9] = cA9;
assign cA_store[10] = cA10;
assign cA_store[11] = cA11;
assign cA_store[12] = cA12;
assign cA_store[13] = cA13;
assign cA_store[14] = cA14;
assign cA_store[15] = cA15;
assign cA_store[16] = cA16;
assign cA_store[17] = cA17;
assign cA_store[18] = cA18;
assign cA_store[19] = cA19;
assign cA_store[20] = cA20;
assign cA_store[21] = cA21;
assign cA_store[22] = cA22;
assign cA_store[23] = cA23;
assign cA_store[24] = cA24;
assign cA_store[25] = cA25;
assign cA_store[26] = cA26;
assign cA_store[27] = cA27;
assign cA_store[28] = cA28;
assign cA_store[29] = cA29;
assign cA_store[30] = cA30;
assign cA_store[31] = cA31;
assign cA_store[32] = cA32;
assign cA_store[33] = cA33;
assign cA_store[34] = cA34;
assign cA_store[35] = cA35;
assign cA_store[36] = cA36;
assign cA_store[37] = cA37;
assign cA_store[38] = cA38;
assign cA_store[39] = cA39;
assign cA_store[40] = cA40;
assign cA_store[41] = cA41;
assign cA_store[42] = cA42;
assign cA_store[43] = cA43;
assign cA_store[44] = cA44;
assign cA_store[45] = cA45;
assign cA_store[46] = cA46;
assign cA_store[47] = cA47;
assign cA_store[48] = cA48;
assign cA_store[49] = cA49;
assign cA_store[50] = cA50;
assign cA_store[51] = cA51;
assign cA_store[52] = cA52;
assign cA_store[53] = cA53;
assign cA_store[54] = cA54;
assign cA_store[55] = cA55;
assign cA_store[56] = cA56;
assign cA_store[57] = cA57;
assign cA_store[58] = cA58;
assign cA_store[59] = cA59;
assign cA_store[60] = cA60;
assign cA_store[61] = cA61;
assign cA_store[62] = cA62;
assign cA_store[63] = cA63;
assign cA_store[64] = cA64;
assign cA_store[65] = cA65;
assign cA_store[66] = cA66;
assign cA_store[67] = cA67;
assign cA_store[68] = cA68;
assign cA_store[69] = cA69;
assign cA_store[70] = cA70;
assign cA_store[71] = cA71;
assign cA_store[72] = cA72;
assign cA_store[73] = cA73;
assign cA_store[74] = cA74;
assign cA_store[75] = cA75;
assign cA_store[76] = cA76;
assign cA_store[77] = cA77;
assign cA_store[78] = cA78;
assign cA_store[79] = cA79;
assign cA_store[80] = cA80;
assign cA_store[81] = cA81;
assign cA_store[82] = cA82;
assign cA_store[83] = cA83;
assign cA_store[84] = cA84;
assign cA_store[85] = cA85;
assign cA_store[86] = cA86;
assign cA_store[87] = cA87;
assign cA_store[88] = cA88;
assign cA_store[89] = cA89;
assign cA_store[90] = cA90;
assign cA_store[91] = cA91;
assign cA_store[92] = cA92;
assign cA_store[93] = cA93;
assign cA_store[94] = cA94;
assign cA_store[95] = cA95;
assign cA_store[96] = cA96;
assign cA_store[97] = cA97;
assign cA_store[98] = cA98;
assign cA_store[99] = cA99;

assign serial_mode	 = ser_mode;
assign parallel_mode = par_mode; 

localparam SERIAL_READY	= 0;
localparam SERIAL_LOOP  = 1;
localparam SERIAL_END   = 3;

localparam PARALLEL_READY_A = 0;
localparam PARALLEL_LOOP_A  = 1;
localparam PARALLEL_END_A	= 3;

localparam PARALLEL_READY_B = 0;
localparam PARALLEL_LOOP_B  = 1;
localparam PARALLEL_END_B   = 3;
/*
always@(posedge clk or negedge nReset)
begin
if(!nReset)
begin
tap_1_reg <= 0;
tap_1a_reg <= 0;
tap_2_reg <= 0;
end
else
begin
tap_1_reg <= tap1;
tap_1a_reg <= tap_1_reg;
tap_2_reg <= tap2;
end
end*/

/* Flags & Ref Position */
always @(posedge clk or negedge nReset)
begin
if (!nReset)
	begin
	/* Flags */
	ser_mode 		<=  1'b0;
	par_mode 		<=  1'b0;
	/* Ref Max Position */
	r_peak_pos_ref1 <=  0;
	r_peak_pos_ref2 <=  0;
	r_peak_pos_ref3 <=  0;
	end
else
	if (Enable)
	begin
		/* Flags */
		ser_mode 		<=  ((count1 == 2 && count2 == 1) && (min_pos_l3 < max_pos_l3)) ? 1'b1 : 1'b0;
		par_mode 		<=  ((count1 == 2 && count2 == 1) && (min_pos_l3 > max_pos_l3)) ? 1'b1 : 1'b0;
		/* Ref Max Position */
		r_peak_pos_ref1 <=  (r_win_full1) ? r_peak_pos_temp1 : r_peak_pos_ref1;
		r_peak_pos_ref2 <=  (r_win_full2) ? r_peak_pos_temp2 : r_peak_pos_ref2;
		r_peak_pos_ref3 <=  (r_win_full3) ? r_peak_pos_temp3 : r_peak_pos_ref3;
	end
	else
	 begin 
		/* Flags */
		ser_mode 		<=  1'b0;
		par_mode 		<=  1'b0;
		/* Ref Max Position */
		r_peak_pos_ref1 <=  0;
		r_peak_pos_ref2 <=  0;
		r_peak_pos_ref3 <=  0;
	end	
end

/* Combinational Block */
always @(*)
begin
/* stop1 */
stop1 		= (stop1_ser | stop1_par); // bitwise OR
mem_read 	= ((count1 == 2) && (count2 == 1)) ? 1'b1 : 1'b0;

/* upper and lower limits */
upper_limit_ser = (Enable && (count1 == 2 && count2 == 1) && (c2 == (limit2ecg + 1 /*- 1*/)) && (limit2ecg != 0)) ? 1'b1: 1'b0;
lower_limit_ser = (Enable && (count1 == 2 && count2 == 1) && (c2 == (limit1ecg - 1)) && (limit1ecg != 0)) ? 1'b1: 1'b0;

upper_limit_par_a = (Enable && (count1 == 2 && count2 == 1) && (c3 == (limit4ecg + 1/*- 1*/)) && (limit4ecg != 0)) ? 1'b1: 1'b0;
lower_limit_par_a = (Enable && (count1 == 2 && count2 == 1) && (c3 == (limit3ecg - 1)) && (limit3ecg != 0)) ? 1'b1: 1'b0;

upper_limit_par_b = (Enable && (count1 == 2 && count2 == 1) && (c4 == (limit6ecg + 1 /*- 1*/)) && (limit6ecg != 0)) ? 1'b1: 1'b0;
lower_limit_par_b = (Enable && (count1 == 2 && count2 == 1) && (c4 == (limit5ecg - 1)) && (limit5ecg != 0)) ? 1'b1: 1'b0;
end

/* FSM for SERIAL_MODE */
always @(posedge clk or negedge nReset)
begin
if (!nReset)
	begin
	state_ser	 	 <=  SERIAL_READY;
	r_peak_ref1 	 <=  0;
	r_peak_pos_temp1 <=  0;
	r_win_full1 	 <=  1'b0;
	c2				 <=  0;
	stop1_ser		 <=  1'b0;			
	end
else
	if (Enable)
		case (state_ser)
		SERIAL_READY:
					if (mem_read && ser_mode)
		if (lower_limit_ser)	
			begin
							state_ser	 		    <=  SERIAL_LOOP;
							r_peak_ref1 	 	  	<=  -32768; // most negetive number in a 16 bit signed vector
							r_peak_pos_temp1 		<=  0;
							r_win_full1 	 	  	<=  1'b0;
							c2	               		<=  c2 + 1;
							stop1_ser		 	    <=  1'b1;		
						end
						else	
						begin
							state_ser 			    <=  SERIAL_READY;
							r_peak_ref1 	 	  	<=  0;
							r_peak_pos_temp1 		<=  0;
							r_win_full1 	 	 	<=  1'b0;
							c2				 	    <=  c2 + 1;
							stop1_ser		 	    <=  1'b1;
						end
					else	
						begin
							state_ser 			    <=  SERIAL_READY;
							r_peak_ref1 	 	  	<=  0;
							r_peak_pos_temp1 		<=  0;
							r_win_full1 	 	  	<=  1'b0;
							c2				 	    <=  0;
							stop1_ser		 	    <=  1'b0;
						end					
		SERIAL_LOOP:
					if (!upper_limit_ser)
					if (c2 == limit1ecg)
					     begin
								state_ser			<=  SERIAL_LOOP;
								r_peak_ref1 		<=  r_peak_ref1 /*tap1*/;
								r_peak_pos_temp1 	<=  r_peak_pos_temp1 /*c3 - 1*/;
								r_win_full1 	 	<=  1'b0;
								c2 					<=  c2 + 1;
								stop1_ser		 	<=  1'b1;
							end
						else
						if (tap1 > r_peak_ref1)
							begin
							state_ser 			    <=  SERIAL_LOOP;
							r_peak_ref1 		   <=  tap1;
							r_peak_pos_temp1 <=  c2 - 1;
							r_win_full1 	 	  <=  1'b0;
							c2				 	       <=  c2 + 1;
							stop1_ser		 	    <=  1'b1;
							end
						else
							begin
							state_ser 			    <=  SERIAL_LOOP; 
							r_peak_ref1 		   <=  r_peak_ref1;
							r_peak_pos_temp1 <=  r_peak_pos_temp1;
							r_win_full1 	 	  <=  1'b0;
							c2				 	       <=  c2 + 1;
							stop1_ser		 	    <=  1'b1;
							end	
					else 
						if (tap1 > r_peak_ref1)
							begin
							state_ser 			    <=  SERIAL_END;
							r_peak_ref1 		   <=  tap1;
							r_peak_pos_temp1 <=  c2 - 1;
							r_win_full1 	 	  <=  1'b1;
							c2				 	       <=  0;
							stop1_ser		 	    <=  1'b0;
							end
						else
							begin
							state_ser 			    <=  SERIAL_END;
							r_peak_ref1 		   <=  r_peak_ref1;
							r_peak_pos_temp1 <=  r_peak_pos_temp1;
							r_win_full1 	 	  <=  1'b1;
							c2				 	       <=  0;
							stop1_ser		 	    <=  1'b0;
							end
		SERIAL_END:					
							begin
							  if (!Enable)	
										begin	
											state_ser 			    <=  SERIAL_READY;
											r_peak_ref1 		   <=  0;
											r_peak_pos_temp1 <=  0;
											r_win_full1 	 	  <=  1'b0;
											c2				 	       <=  0;
											stop1_ser		 	    <=  1'b0;
										end
								else /* Default */
										begin	
											state_ser 			    <=  SERIAL_END;
											r_peak_ref1 		   <=  r_peak_ref1;
											r_peak_pos_temp1 <=  r_peak_pos_temp1;
											r_win_full1 	 	  <=  1'b1;
											c2				 	       <=  0;
											stop1_ser		 	    <=  1'b0;
										end
							end
		
		default:					
										begin
											state_ser 			    <=  SERIAL_READY;
											r_peak_ref1 		   <=  r_peak_ref1;
											r_peak_pos_temp1 <=  r_peak_pos_temp1;
											r_win_full1 	 	  <=  1'b0;
											c2				 	       <=  0;
											stop1_ser		 	    <=  1'b0;
										end
		endcase
	else 
		begin
		state_ser	 	  <=  SERIAL_READY;
		r_peak_ref1 	  <=  0;
		r_peak_pos_temp1  <=  0;
		r_win_full1 	  <=  1'b0;
		c2				  <=  0;
		stop1_ser		  <=  1'b0;
		end
end

/* FSM for PARALLEL_MODE_A */
always @(posedge clk or negedge nReset)
begin
if (!nReset)
	begin
	state_par_a		 <=  PARALLEL_READY_A;
	r_peak_ref2 	 <=  0;
	r_peak_pos_temp2 <=  0;
	r_win_full2 	 <=  1'b0;
	c3 				 <=  0;
	stop1_par		 <=  1'b0;
	end
else
	if (Enable)
		case (state_par_a)
		PARALLEL_READY_A:
					if (mem_read && par_mode)
						if (lower_limit_par_a)	
						begin
							state_par_a			<=  PARALLEL_LOOP_A;
							r_peak_ref2 	 	<=  /*tap1*/ -32768;
							r_peak_pos_temp2 	<=  0;
							r_win_full2 	 	<=  1'b0;
							c3 					<=  c3 + 1;
							stop1_par		 	<=  1'b1;
						end
						else	
						begin
							state_par_a			<=  PARALLEL_READY_A;
							r_peak_ref2 	 	<=  0;
							r_peak_pos_temp2 	<=  0;
							r_win_full2 	 	<=  1'b0;
							c3 					<=  c3 + 1;
							stop1_par		 	<=  1'b1;
						end
					else	
						begin
							state_par_a			<=  PARALLEL_READY_A;
							r_peak_ref2 	 	<=  0;
							r_peak_pos_temp2 	<=  0;
							r_win_full2 	 	<=  1'b0;
							c3 					<=  0;
							stop1_par		 	<=  1'b0;
						end
							
		PARALLEL_LOOP_A:
					if (!upper_limit_par_a)
					  if (c3 == limit3ecg)
					     begin
								state_par_a			<=  PARALLEL_LOOP_A;
								r_peak_ref2 		<=  r_peak_ref2 /*tap1*/;
								r_peak_pos_temp2 	<=  r_peak_pos_temp2 /*c3 - 1*/;
								r_win_full2 	 	<=  1'b0;
								c3 					<=  c3 + 1;
								stop1_par		 	<=  1'b1;
							end
							else      
						if (tap1 > r_peak_ref2)
							begin
								state_par_a			<=  PARALLEL_LOOP_A;
								r_peak_ref2 		<=  tap1;
								r_peak_pos_temp2 	<=  c3 - 1;
								r_win_full2 	 	<=  1'b0;
								c3 					<=  c3 + 1;
								stop1_par		 	<=  1'b1;
							end
						else
							begin
								state_par_a			<=  PARALLEL_LOOP_A;
								r_peak_ref2 		<=  r_peak_ref2;
								r_peak_pos_temp2 	<=  r_peak_pos_temp2;
								r_win_full2 	 	<=  1'b0;
								c3 					<=  c3 + 1;
								stop1_par		 	<=  1'b1;
							end	
					else 
						if (tap1 > r_peak_ref2)
							begin
								state_par_a			<=  PARALLEL_END_A;
								r_peak_ref2 		<=  tap1;
								r_peak_pos_temp2 	<=  c3 - 1;
								r_win_full2 	 	<=  1'b1;
								c3 					<=  0;
								stop1_par		 	<=  1'b0;
							end
						else
							begin
								state_par_a			<=  PARALLEL_END_A;
								r_peak_ref2 		<=  r_peak_ref2;
								r_peak_pos_temp2 	<=  r_peak_pos_temp2;
								r_win_full2 	 	<=  1'b1;
								c3 					<=  0;
								stop1_par		 	<=  1'b0;
							end
		
		PARALLEL_END_A:		
							if (!Enable)
							begin
								state_par_a			<=  PARALLEL_READY_A;
								r_peak_ref2 		<=  0;
								r_peak_pos_temp2 	<=  0;
								r_win_full2 	 	<=  1'b0;
								c3 					<=  0;
								stop1_par		 	<=  1'b0;
							end
							else
							begin
								state_par_a			<=  PARALLEL_END_A;
								r_peak_ref2 		<=  r_peak_ref2;
								r_peak_pos_temp2 	<=  r_peak_pos_temp2;
								r_win_full2 	 	<=  1'b1;
								c3 					<=  0;
								stop1_par		 	<=  1'b0;
							end
						
				default:	
							begin
								state_par_a		 <=  PARALLEL_READY_A;
								r_peak_ref2 	 <=  0;
								r_peak_pos_temp2 <=  0;
								c3 				 <=  0;
								r_win_full2 	 <=  1'b0;
							end
		endcase
	else
		begin
		state_par_a		 <=  PARALLEL_READY_A;
		r_peak_ref2 	 <=  0;
		r_peak_pos_temp2 <=  0;
		c3 				 <=  0;
		r_win_full2 	 <=  1'b0;
		end	
end

/* FSM for PARALLEL_MODE_B */
always @(posedge clk or negedge nReset)
begin
if (!nReset)
	begin
	state_par_b		 <=  PARALLEL_READY_B;
	r_peak_ref3 	 <=  0;
	r_peak_pos_temp3 <=  0;
	r_win_full3 	 <=  1'b0;
	c4 				 <=  0;
	stop2			 <=  1'b0;
	end
else
	if (Enable)
		case (state_par_b)
		PARALLEL_READY_B:
					if (mem_read && par_mode)
						if (lower_limit_par_b)	
						begin
							state_par_b			<=  PARALLEL_LOOP_B;
							r_peak_ref3 	 	<=  /*tap2*/ -32768;
							r_peak_pos_temp3 	<=  0;
							r_win_full3  	 	<=  1'b0;
							c4 					<=  c4 + 1;
							stop2		 		<=  1'b1;
						end
						else	
						begin
							state_par_b			<=  PARALLEL_READY_B;
							r_peak_ref3 	 	<=  0;
							r_peak_pos_temp3 	<=  0;
							r_win_full3  	 	<=  1'b0;
							c4 					<=  c4 + 1;
							stop2		 		<=  1'b1;
						end
					else	
						begin
							state_par_b			<=  PARALLEL_READY_B;
							r_peak_ref3 	 	<=  0;
							r_peak_pos_temp3 	<=  0;
							r_win_full3  	 	<=  1'b0;
							c4 					<=  0;
							stop2		 		<=  1'b0;
						end
						
		PARALLEL_LOOP_B:
					if (!upper_limit_par_b)
						if (c4 == limit5ecg)
							begin
								state_par_b			<=  PARALLEL_LOOP_B;
								r_peak_ref3 		<=  r_peak_ref3 /*tap1*/;
								r_peak_pos_temp3 	<=  r_peak_pos_temp3 /*c3 - 1*/;
								r_win_full3 	 	<=  1'b0;
								c4 					<=  c4 + 1;
								stop2			 	<=  1'b1;
							end
						else
						if (tap2 > r_peak_ref3)
							begin
								state_par_b			<=  PARALLEL_LOOP_B;
								r_peak_ref3 		<=  tap2;
								r_peak_pos_temp3 	<=  c4 - 1;
								r_win_full3  	 	<=  1'b0;
								c4 					<=  c4 + 1;
								stop2		 		<=  1'b1;
							end
						else
							begin
								state_par_b			<=  PARALLEL_LOOP_B;
								r_peak_ref3 		<=  r_peak_ref3;
								r_peak_pos_temp3 	<=  r_peak_pos_temp3;
								r_win_full3  	 	<=  1'b0;
								c4 					<=  c4 + 1;
								stop2		 		<=  1'b1;
							end	
					else 
						if (tap2 > r_peak_ref3)
							begin
								state_par_b			<=  PARALLEL_END_B;
								r_peak_ref3 		<=  tap2;
								r_peak_pos_temp3 	<=  c4 - 1;
								r_win_full3  	 	<=  1'b1;
								c4 					<=  0;
								stop2		 		<=  1'b0;
							end
						else
							begin
								state_par_b			<=  PARALLEL_END_B;
								r_peak_ref3 		<=  r_peak_ref3;
								r_peak_pos_temp3 	<=  r_peak_pos_temp3;
								r_win_full3  	 	<=  1'b1;
								c4 					<=  0;
								stop2		 		<=  1'b0;
							end
		
		PARALLEL_END_B:		
							if (!Enable)
							begin
								state_par_b			<=  PARALLEL_READY_B;
								r_peak_ref3 		<=  0;
								r_peak_pos_temp3 	<=  0;
								r_win_full3  	 	<=  1'b0;
								c4 					<=  0;
								stop2		 		<=  1'b0;
							end
							else
							begin
								state_par_b			<=  PARALLEL_END_B;
								r_peak_ref3 		<=  r_peak_ref3;
								r_peak_pos_temp3 	<=  r_peak_pos_temp3;
								r_win_full3  	 	<=  1'b1;
								c4 					<=  0;
								stop2		 		<=  1'b0;
							end
							
				default:	
							begin
								state_par_b		 <=  PARALLEL_READY_B;
								r_peak_ref3 	 <=  0;
								r_peak_pos_temp3 <=  0;
								c4 				 <=  0;
								r_win_full3  	 <=  1'b0;
							end
		endcase
	else
		begin
			state_par_b		 <=  PARALLEL_READY_B;
			r_peak_ref3 	 <=  0;
			r_peak_pos_temp3 <=  0;
			c4 				 <=  0;
			r_win_full3  	 <=  1'b0;
		end	
end
/*
always @(posedge clk or negedge nReset)
begin
if (!nReset)
  begin
  r_peak_ref 		   = 0;
	r_peak_pos_ref 	= 0;
  end
else  
	case ({parallel_mode, serial_mode})
	2'b01: if (r_win_full1)
				begin
				r_peak_ref 		= r_peak_ref1;
				r_peak_pos_ref 	= r_peak_pos_temp1;
				//par_max_found 	= 1'b0;
				end
			else
				begin
				r_peak_ref 		= 0;
				r_peak_pos_ref 	= 0;
				//par_max_found 	= 1'b0;	
				end
					
	2'b10: 	if (r_win_full2 && r_win_full3)
	       begin
					r_peak_ref 		= (r_peak_ref2 >= r_peak_ref3) ? r_peak_ref2 	   : r_peak_ref3;
					r_peak_pos_ref 	= (r_peak_ref2 >= r_peak_ref3) ? r_peak_pos_temp2  : r_peak_pos_temp3;
					//par_max_found 	= 1'b1;
				end
			else
				begin
					r_peak_ref 		= 0;
					r_peak_pos_ref 	= 0;
					//par_max_found 	= 1'b0;
				end
	default:
	     begin
					r_peak_ref 		= 0;
					r_peak_pos_ref 	= 0;
					//par_max_found 	= 1'b0;
				end
	endcase
end 
*/

//MAX r_peak_ref  
always @(*)
begin
r_peak_ref = 0;
r_peak_pos_ref = 0;
if (count2 == 1)
begin
	if (min_pos_l3 < max_pos_l3)
	begin
		if (r_win_full1 != 0)
			r_peak_ref = r_peak_ref1;
		else
			r_peak_ref = r_peak_ref;
			r_peak_pos_ref = r_peak_pos_ref1;
	end
	else
	begin
		if (r_peak_pos_ref2 != 0 && r_peak_pos_ref3 != 0)
		begin
			if (r_peak_ref2 > r_peak_ref3)
			begin
				if (r_win_full3 != 0)
				begin
					r_peak_ref = r_peak_ref2;
				    r_peak_pos_ref = r_peak_pos_ref2;	
				end
				else
				begin
					r_peak_ref = r_peak_ref;
				    r_peak_pos_ref = r_peak_pos_ref; 	
				end
			end
			else	
			begin
				if (r_win_full3 != 0)
				begin
					r_peak_ref 		= r_peak_ref3;
				    r_peak_pos_ref 	= r_peak_pos_ref3;						
				end
				else
				begin
					r_peak_ref 		= r_peak_ref;
				    r_peak_pos_ref 	= r_peak_pos_ref;	
				end
			end
		end
		else
		begin
			r_peak_ref 		= r_peak_ref;
			r_peak_pos_ref 	= r_peak_pos_ref;
		end
	end
end
else
begin
	r_peak_ref = r_peak_ref;
	r_peak_pos_ref = r_peak_pos_ref;
end
end


always @(posedge clk or negedge nReset)
begin
if (!nReset)
begin
	c6 <=  0;
	c7 <=  0;
	counta <=  0;
	start_qrs_found1 <=  0;
	start_qrs1 <=  0;
	end_qrs_found1 <=  0;
	end_qrs1 <=  0;
	grad_ecg_qrs1 <=  0;
	grad_ecg_qrs_abs1 <=  0;
	flip_grad_qrs1 <=  0;
	flip_grad_qrs_abs1 <=  0;
	grad_win_full1 <=  0;
	flip_grad_win_full1 <=  0;
end
else if (Enable)
begin
	counta <= ~counta;
	if (count2 == 1) 
	begin
		if (q_begin_l3_flag != 0 && q_begin_l3_temp != 0)
		begin 
		if (c6 <= limit02_xa_find+1)
		begin
			if (c6 == 0)
			begin
				c6 <=  limit01_xa_find; 

				if (limit01_xa_find > limit02_xa_find)
					grad_win_full1 <=  1;
				else
					grad_win_full1 <=  grad_win_full1;
			end
			else
			begin
				if (start_qrs_found1 != 1)
				begin
					grad_ecg_qrs1 <=  cA_store[c6+1] - 									cA_store[c6];
 
					if (grad_ecg_qrs1[15] == 1)
					  	grad_ecg_qrs_abs1 <=  										~(grad_ecg_qrs1-1);
					else
					    grad_ecg_qrs_abs1<=  												grad_ecg_qrs1;

					if (grad_ecg_qrs_abs1 > thr1)
					begin
						start_qrs_found1 <=  1;
						if (limit01_xa_find == 											q_begin_l3_temp)
							start_qrs1 <=  
								((c6+1)<<`shift3)-1;
						else
							start_qrs1 <=  
				((c6+(limit01_xa_find-q_begin_l3_temp))										<<`shift3)-1;
					end
					else
					begin
						start_qrs_found1 <=  										start_qrs_found1;
						start_qrs1 <=  start_qrs1;

						if (counta)
							c6 <=  c6 + 1;
						else
							c6 <=  c6;
					end
				end
				else
				begin
					start_qrs_found1 <=  										start_qrs_found1;
					start_qrs1 <=  start_qrs1;
				end
				if (c6 == (limit02_xa_find+1)										||start_qrs_found1 != 0)
					grad_win_full1 <=  1;
				else
					grad_win_full1 <=  grad_win_full1;
			end
		end
		else
		begin
			start_qrs_found1 <=  start_qrs_found1;
			start_qrs1 <=  start_qrs1;
			grad_win_full1 <=  grad_win_full1;
		end
		end
		else
		begin
			start_qrs_found1 <=  start_qrs_found1;
			start_qrs1 <=  start_qrs1;
			grad_win_full1 <=  grad_win_full1;
		end

		if (cD_min_found != 0 && min_pos_l3_n != 0 && 
								s_end_l3_temp != 0)
		begin
			if (limit03_xb_find != limit04_xb_find)
			begin
			if (c7 == 0)
				c7 <=  limit03_xb_find;
			else
				c7 <=  c7;
			if (c7 >= limit04_xb_find)
			begin
				if (end_qrs_found1 != 1)
				begin	
					flip_grad_qrs1 <=  cA_store[c7] - 									cA_store[c7-1]; 

					if (flip_grad_qrs1[15] == 1)
					 	flip_grad_qrs_abs1 <=  										~(flip_grad_qrs1-1);
					else
					    	flip_grad_qrs_abs1										<=  flip_grad_qrs1;

					if (flip_grad_qrs_abs1 > thr2)
					begin
						end_qrs_found1 <=  1;
						end_qrs1 <=  ((c7+2)											<<`shift3)-1;
					end
					else
					begin
						end_qrs_found1 <=  											end_qrs_found1;
						end_qrs1 <=  end_qrs1;

						if (!counta)
						begin
							c7 <=  c7 - 1;
						end
						else
						begin
							c7 <=  c7;
						end
					end
				end
				else
				begin
					end_qrs_found1 <=  end_qrs_found1;
					end_qrs1 <=  end_qrs1;
				end
				if (c7 == limit04_xb_find || end_qrs_found1 											!= 0)
					flip_grad_win_full1 <=  1;
				else
					flip_grad_win_full1 <=  											flip_grad_win_full1;
			end
			else
			begin
				end_qrs_found1 <=  end_qrs_found1;
				end_qrs1 <=  end_qrs1;
				flip_grad_win_full1 <= flip_grad_win_full1;
			end
			end
			else
			begin
				end_qrs_found1 <=  end_qrs_found1;
				end_qrs1 <=  end_qrs1;
				flip_grad_win_full1 <=  												flip_grad_win_full1;
			end
		end
		else
		begin
			end_qrs_found1 <=  end_qrs_found1;
			end_qrs1 <=  end_qrs1;
			flip_grad_win_full1 <=  flip_grad_win_full1;
		end
	end
	else
	begin
		c6 <=  c6;
		c7 <=  c7;
		start_qrs_found1 <=  start_qrs_found1;
		start_qrs1 <=  start_qrs1;
		end_qrs_found1 <=  end_qrs_found1;
		end_qrs1 <=  end_qrs1;
		grad_win_full1 <=  grad_win_full1;
		flip_grad_win_full1 <=  flip_grad_win_full1;
	end
end
else
begin
	c6 <=  0;
	c7 <=  0;
	counta <=  0;
	start_qrs_found1 <=  0;
	start_qrs1 <=  0;
	end_qrs_found1 <=  0;
	end_qrs1 <=  0;
	grad_ecg_qrs1 <=  0;
	grad_ecg_qrs_abs1 <=  0;
	flip_grad_qrs1 <=  0;
	flip_grad_qrs_abs1 <=  0;
	grad_win_full1 <=  0;
	flip_grad_win_full1 <=  0;
end
end

always @(*)
begin
limit1ecg = 0;
limit2ecg = 0;
limit3ecg = 0;
limit4ecg = 0;
limit5ecg = 0;
limit6ecg = 0;
limit01_xa_find = 0;
limit02_xa_find = 0;
limit03_xb_find = 0;
limit04_xb_find = 0;

if (count2 == 1)
begin
	if (min_pos_l3 < max_pos_l3)
	begin
		limit1ecg = ((min_pos_l3+1)<<`shift3)-1;
		limit2ecg = ((max_pos_l3+1)<<`shift3)-1;
		limit3ecg = limit3ecg;
		limit4ecg = limit4ecg;
		limit5ecg = limit3ecg;
		limit6ecg = limit4ecg;

		if (cD_min_found != 0)
		begin
			limit01_xa_find = q_begin_l3_temp + (3-1);
			limit02_xa_find = min_pos_l3+1;
//			limit03_xb_find = s_end_l3_temp-(3*`rat)-1;
			limit03_xb_find = s_end_l3_temp-(3*`rat);
//			limit04_xb_find = min_pos_l3_n-1;
			limit04_xb_find = min_pos_l3_n-1;
		end
		else
		begin
			limit01_xa_find = limit01_xa_find;
			limit02_xa_find = limit02_xa_find;
			limit03_xb_find = limit03_xb_find;
			limit04_xb_find = limit04_xb_find;
		end
	end
	else
	begin
		limit1ecg = limit1ecg;
		limit2ecg = limit2ecg;

		if (min_pos_l3_n != 0)
		begin
			limit3ecg = ((min_pos_l3_n+1)<<`shift3)-1;
			limit4ecg = ((max_pos_l3+1)<<`shift3)-1;
		end
		else
		begin
			limit3ecg = limit3ecg;
			limit4ecg = limit4ecg;
		end
		
		if (max_pos_l3_n != 0)
		begin
			limit5ecg = ((min_pos_l3+1)<<`shift3)-1;
			limit6ecg = ((max_pos_l3_n+1)<<`shift3)-1;
		end
		else
		begin
			limit5ecg = limit5ecg;
			limit6ecg = limit6ecg;
		end

		limit01_xa_find = q_begin_l3_temp + (3 - 1);
		limit02_xa_find = min_pos_l3+1;
		limit03_xb_find = s_end_l3_temp - (3*`rat);
		limit04_xb_find = min_pos_l3-1;

	end
end
else
begin
	limit1ecg = limit1ecg;
	limit2ecg = limit2ecg;
	limit3ecg = limit3ecg;
	limit4ecg = limit4ecg;
	limit5ecg = limit5ecg;
	limit6ecg = limit6ecg;
	limit01_xa_find = limit01_xa_find;
	limit02_xa_find = limit02_xa_find;
	limit03_xb_find = limit03_xb_find;
	limit04_xb_find = limit04_xb_find;
end
end

always @(*)
begin
limit21_xa_find = 0;
limit22_xa_find = 0;
limit23_xb_find = 0;
limit24_xb_find = 0;
/* check */
if (r_peak_pos_ref != 0)
begin
	if (start_qrs1 != 0)
	begin
		limit21_xa_find = q_begin_l3_temp;
		limit22_xa_find = (r_peak_pos_ref>>`shift3)+1;
	end
	else
	begin
		limit21_xa_find = limit21_xa_find;
		limit22_xa_find = limit22_xa_find;
	end

	if (end_qrs1 != 0)
	begin
		//limit23_xb_find = s_end_l3_temp-(3*`rat)-1;	
		limit23_xb_find = s_end_l3_temp-(3*`rat);	

		limit24_xb_find = (r_peak_pos_ref>>`shift3)-1;
		//limit24_xb_find = (r_peak_pos_ref>>`shift3);

	end
	else
	begin
		limit23_xb_find = limit23_xb_find;
		limit24_xb_find = limit24_xb_find;
	end
end
else
begin
	limit21_xa_find = limit21_xa_find;
	limit22_xa_find = limit22_xa_find;
	limit23_xb_find = limit23_xb_find;
	limit24_xb_find = limit24_xb_find;
end
end

always @(*)
begin
start_var = 0;
end_var = 0;

if (q_begin_l3_temp != 0 && s_end_l3_temp != 0)
begin
	start_var = ((q_begin_l3_temp+(8*`rat))<<`shift3)-1;
	end_var = (((s_end_l3_temp)-(15*`rat)+2)<<`shift3)-1;
end
else
begin
	start_var = start_var;
	end_var = end_var;
end
end

always @(posedge clk or negedge nReset)
begin
if (!nReset)
begin
	c8 <=  0;
	c9 <=  0;
	countb <=  0;
	start_qrs_found2 <=  0;
	start_qrs2 <=  0;
	end_qrs_found2 <=  0;
	end_qrs2 <=  0;
	grad_ecg_qrs2 <=  0;
	grad_ecg_qrs_abs2 <=  0;
	flip_grad_qrs2 <=  0;
	flip_grad_qrs_abs2 <=  0;
	grad_win_full2 <=  0;
	flip_grad_win_full2 <=  0;
end
else if (Enable)
begin
	countb <= ~countb;
	if (count2 == 1) 
	begin
		if (q_begin_l3_flag != 0 && q_begin_l3_temp != 0)
		begin 
		if (c8 <= limit22_xa_find+1)
		begin
			if (c8 == 0)
			begin
				c8 <=  limit21_xa_find; 

				if (limit21_xa_find > limit22_xa_find)
					grad_win_full2 <=  1;
				else
					grad_win_full2 <=  grad_win_full2;
			end
			else
			begin
				if (start_qrs_found2 != 1)
				begin
					grad_ecg_qrs2 <=  cA_store[c8+1] - 									cA_store[c8];
 
					if (grad_ecg_qrs2[15] == 1)
					  	grad_ecg_qrs_abs2 <=  										~(grad_ecg_qrs2-1);
					else
					    grad_ecg_qrs_abs2<=  												grad_ecg_qrs2;

					if (grad_ecg_qrs_abs2 > thr1)
					begin
						start_qrs_found2 <=  1;
						if (limit21_xa_find == 											q_begin_l3_temp)
							start_qrs2 <=  
								((c8+1)<<`shift3)-1;
						else
							start_qrs2 <=  
				((c8+(limit21_xa_find-q_begin_l3_temp))										<<`shift3)-1;
					end
					else
					begin
						start_qrs_found2 <=  										start_qrs_found2;
						start_qrs2 <=  start_qrs2;

						if (countb)
							c8 <=  c8 + 1;
						else
							c8 <=  c8;
					end
				end
				else
				begin
					start_qrs_found2 <=  											start_qrs_found2;
					start_qrs2 <=  start_qrs2;
				end
				if (c8 == (limit22_xa_find+1)										||start_qrs_found2 != 0)
					grad_win_full2 <=  1;
				else
					grad_win_full2 <=  grad_win_full2;
			end
		end
		else
		begin
			start_qrs_found2 <=  start_qrs_found2;
			start_qrs2 <=  start_qrs2;
			grad_win_full2 <=  grad_win_full2;
		end
		end
		else
		begin
			start_qrs_found2 <=  start_qrs_found2;
			start_qrs2 <=  start_qrs2;
			grad_win_full2 <=  grad_win_full2;
		end


		if (cD_min_found != 0 && min_pos_l3_n != 0 && 
								s_end_l3_temp != 0)
		begin
			if (limit23_xb_find != limit24_xb_find)
			begin
			if (c9 == 0)
				c9 <=  limit23_xb_find;
			else
				c9 <=  c9;
			if (c9 >= limit24_xb_find)
			begin
				if (end_qrs_found2 != 1)
				begin	
					flip_grad_qrs2 <=  cA_store[c9] - 									cA_store[c9-1]; 

					if (flip_grad_qrs2[15] == 1)
					 	flip_grad_qrs_abs2 <=  										~(flip_grad_qrs2-1);
					else
					    	flip_grad_qrs_abs2										<=  flip_grad_qrs2;

					if (flip_grad_qrs_abs2 > thr2)
					begin
						end_qrs_found2 <=  1;
						end_qrs2 <=  ((c9+2)											<<`shift3)-1;
					end
					else
					begin
						end_qrs_found2 <=  											end_qrs_found2;
						end_qrs2 <=  end_qrs2;

						if (!countb)
						begin
							c9 <=  c9 - 1;
						end
						else
						begin
							c9 <=  c9;
						end
					end
				end
				else
				begin
					end_qrs_found2 <=  end_qrs_found2;
					end_qrs2 <=  end_qrs2;
				end
				if (c9 == limit24_xb_find || end_qrs_found2 											!= 0)
					flip_grad_win_full2 <=  1;
				else
					flip_grad_win_full2 <=  											flip_grad_win_full2;
			end
			else
			begin
				end_qrs_found2 <=  end_qrs_found2;
				end_qrs2 <=  end_qrs2;
				flip_grad_win_full2 <= flip_grad_win_full2;
			end
			end
			else
			begin
				end_qrs_found2 <=  end_qrs_found2;
				end_qrs2 <=  end_qrs2;
				flip_grad_win_full2 <=  												flip_grad_win_full2;
			end
		end
		else
		begin
			end_qrs_found2 <=  end_qrs_found2;
			end_qrs2 <=  end_qrs2;
			flip_grad_win_full2 <=  flip_grad_win_full2;
		end
	end
	else
	begin
		c8 <=  c8;
		c9 <=  c9;
		start_qrs_found2 <=  start_qrs_found2;
		start_qrs2 <=  start_qrs2;
		end_qrs_found2 <=  end_qrs_found2;
		end_qrs2 <=  end_qrs2;
		grad_win_full2 <=  grad_win_full2;
		flip_grad_win_full2 <=  flip_grad_win_full2;
	end
end
else
begin
	c8 <=  0;
	c9 <=  0;
	countb <=  0;
	start_qrs_found2 <=  0;
	start_qrs2 <=  0;
	end_qrs_found2 <=  0;
	end_qrs2 <=  0;
	grad_ecg_qrs2 <=  0;
	grad_ecg_qrs_abs2 <=  0;
	flip_grad_qrs2 <=  0;
	flip_grad_qrs_abs2 <=  0;
	grad_win_full2 <=  0;
	flip_grad_win_full2 <=  0;
end
end

always @(*)
begin
start_qrs_fin_2 = 0;
end_qrs_fin_2 = 0;
if (count2 == 1)
begin
	if (grad_win_full1 != 0)
	begin
		if (start_qrs1 != 0)
		begin
			if (r_peak_pos_ref != 0)
			begin
				if (start_qrs1 > r_peak_pos_ref)
				begin
					if (grad_win_full2 != 0)	
					begin
						if (start_qrs2 != 0)
						begin
							if (start_qrs2 > start_var)	
								start_qrs_fin_2 									  	     = start_var;
							else
								start_qrs_fin_2 									  	= start_qrs2;
						end
						else
						begin
							if (start_qrs1 > start_var)	
								start_qrs_fin_2 = 
									start_var;
							else
								start_qrs_fin_2 = 
								 	start_qrs1;
						end
					end
					else
						start_qrs_fin_2 = 
									start_qrs_fin_2;	
				end
				else
				begin
					if (start_qrs1 > start_var)
					     start_qrs_fin_2 = start_var;	
					else
						start_qrs_fin_2 = start_qrs1;
				end
			end
			else
				start_qrs_fin_2 = start_qrs_fin_2;
		end
		else
			start_qrs_fin_2 = start_var;
	end
	else
		start_qrs_fin_2 = start_qrs_fin_2;


	if (flip_grad_win_full1 != 0)
	begin
		if (end_qrs1 != 0)
		begin
			if (r_peak_pos_ref != 0)
			begin
				if (end_qrs1 < r_peak_pos_ref)
				begin
					if (flip_grad_win_full2 != 0)
					begin
						if (end_qrs2 != 0)
						begin
							if (end_qrs2 < end_var)								   end_qrs_fin_2 = end_var; 
							else
						  	  end_qrs_fin_2 = end_qrs2;	
						end
						else
						begin
							if (r_peak_pos_ref < 												end_var)	
								end_qrs_fin_2 = 
										end_var;	
							else
								end_qrs_fin_2 = 									  		r_peak_pos_ref;
						end
					end
					else
						end_qrs_fin_2 = end_qrs_fin_2;	
				end
				else
				begin
					if (end_qrs1 < end_var)
						end_qrs_fin_2 = end_var; 	
					else
						end_qrs_fin_2 = end_qrs1;
				end
			end
			else
				end_qrs_fin_2 = end_qrs_fin_2;
		end
		else
			end_qrs_fin_2 = end_var;
	end
	else
		end_qrs_fin_2 = end_qrs_fin_2;
end
else
begin
	start_qrs_fin_2 = start_qrs_fin_2;
	end_qrs_fin_2 = end_qrs_fin_2;
end


end

always@(posedge clk or negedge nReset)
begin
if (!nReset)
	    RRp<= 0;
else 
	if (Enable)
	/* <Patched> Ahmed */
		if (r_win_full1 || (r_win_full2 && r_win_full3)/*(par_max_found)*/)	
			RRp<= 1'b1;
		else												
			RRp<= 1'b0;
	else	RRp<= 1'b0; 
end
endmodule

