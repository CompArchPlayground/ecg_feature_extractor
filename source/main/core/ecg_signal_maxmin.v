/*
Module		 : ecg_signal_maxmin.v

HDL			 : Verilog 2001

Function	 :	Wavelet Level 5 computation core 

Authors	  	 :	# Dwaipayan Biswas, MSc SoC 2011, University of Southampton.
				# Sanmitra Ghosh,   MSc SoC 2011, University of Southampton 
				# Ahmed F Rahim,    MSc SoC 2012, University of Southampton.

Current   	 :	Stable, Bug free, Ready for Synthesis.

Version		
History		 :	# Dwaipayan Biswas, MSc SoC 2011, University of Southampton.
				- Module Created
				- Tested with parallel stream of 800 samples 
            
            # Sanmitra Ghosh, MSc SoC 2011, University of Southampton 
				- Incorporated sequential read capability (8 samples/cycle)
				            
            # Ahmed F Rahim, MSc SoC 2012, University of Southampton.
				- Bug fixes: fixed incomplete if/else statements which had inferred latches.
*/

`timescale 1ps/1ps
`include "parameter.v"

module ecg_signal_maxmin(q_peak_ref,q_peak_pos_ref,s_peak_ref,s_peak_pos_ref,p_peak,p_peak_pos,p_begin,p_end,t_peak,t_peak_pos,t_begin,t_end,array_2,p1_cD_full,p2_cD_full,t_cD_full,p_zero,p1maxp,p1minp,p2maxp,p2minp,
t1maxp,t1minp,start_qrs_fin_2,end_qrs_fin_2,r_peak_pos_ref,
count1,count2,data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8,clk,nReset,Enable,start1);
  

output [`b11:0] q_peak_pos_ref,s_peak_pos_ref,p_peak_pos,t_peak_pos;

output [`b16:0] q_peak_ref,s_peak_ref,p_peak,t_peak;
output start1;
reg signed [`b11:0] q_peak_pos_ref,s_peak_pos_ref,p_peak_pos,
t_peak_pos,max1p,min1p,max2p,min2p,q_peak_pos_temp,
s_peak_pos_temp;

input [`b16:0] data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8;
reg signed [`b16:0] q_peak_ref,s_peak_ref,p_peak,t_peak,max1v,
min1v,max2v,min2v;

input [`b11:0] p_begin,p_end,t_begin,t_end,p1maxp,p1minp,
p2maxp,p2minp,t1maxp,t1minp,start_qrs_fin_2,end_qrs_fin_2,
r_peak_pos_ref;


input array_2,p1_cD_full,p2_cD_full,t_cD_full,p_zero;

input [`b6:0] count1;
input [`b6:0] count2;

input clk, nReset,Enable;
wire clk, nReset,Enable;

wire [`b11:0] temp1,temp2,temp3,temp4,temp5,temp6,temp7,temp8;

reg [`b11:0] c2,c3,c5,c6,c7;

reg p_full,t_full,q_peak_found,s_peak_found,k;

reg signed [`b16:0] ecg_signal [0:`m-1];
integer i;
assign start1=t_full;

assign temp1 = p_begin;
assign temp2 = p_end;

assign temp3 = t_begin;
assign temp4 = t_end;

assign temp5 = start_qrs_fin_2;
assign temp6 = r_peak_pos_ref;

assign temp7 = r_peak_pos_ref;
assign temp8 = end_qrs_fin_2;
/*
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk or negedge nReset)
if (!nReset)
begin
c5 <=  0;
k<=  0;



end
else if (Enable)
begin
k<=  ~k;

if (count1 > 0)
	begin
		if (c5 <= 799 && k==1 )
		begin
			

			c5 <=  c5 + 8;
		end
		else
			ecg_signal[c5] <=  0;
	end
	else
		c5 <=  0;
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/

always @(posedge clk or negedge nReset)
begin
if (!nReset)
begin
	k<=  0;
	c5 <=  0;
	for(i=0;i<=799;i=i+1)
	begin
		ecg_signal[i]<=  0;
	end
end
else 
	if (Enable)
	begin
		k<=  ~k;
		if (count1 > 0)
			if (c5 <= 799 && k==1)
				begin
							  c5 <=  c5 + 8;
				ecg_signal[c5]   <=  data_in1;
				ecg_signal[c5+1] <=  data_in2;
				ecg_signal[c5+2] <=  data_in3;
				ecg_signal[c5+3] <=  data_in4;
				ecg_signal[c5+4] <=  data_in5;
				ecg_signal[c5+5] <=  data_in6;
				ecg_signal[c5+6] <=  data_in7;
				ecg_signal[c5+7] <=  data_in8;
				end
			else 		  	  c5 <=  c5;
		else
			begin
				c5  <=  0;
				k   <=  0; 
			end
	end
	else
		begin
				k   <=  0;
				c5  <=  0;
		end
end

always @(posedge clk or negedge nReset)
if (!nReset)
begin
	c2 <=  0;
	c3 <=  0;
	c6 <=  0;
	c7 <=  0;

	q_peak_found <=  0;
	q_peak_ref <=  0;
	q_peak_pos_ref <=  0;
	q_peak_pos_temp <=  0;

	s_peak_found <=  0;
	s_peak_ref <=  0;
	s_peak_pos_ref <=  0;
	s_peak_pos_temp <=  0;
   
	max1v <=  0;
	max1p <=  0;
	min1v <=  0;
	min1p <=  0;
	max2v <=  0;
	max2p <=  0;
	min2v <=  0;
	min2p <=  0;

	p_full <=  0;
	t_full <=  0;
end
else if (Enable)
begin
	if (count1 == 2 && count2 == 1)
	begin
		if (p1_cD_full != 0 || p2_cD_full != 0)
		begin
		if (c2 <= temp2)
		begin
			if (c2 == 0 && p_zero == 0)
				c2 <=  temp1;
			else 
			begin
				if (c2 == temp1) 
				begin
					c2 <=  temp1;
				  	max1v <=  ecg_signal[temp1];
				  	min1v <=  ecg_signal[temp1];
				  	max1p <=  temp1;
				  	min1p <=  temp1;
				  	c2 <=  c2 + 1;
				end
				else
				begin
			 		if (ecg_signal[c2] > max1v)
				  	begin
				  		max1v <=  ecg_signal[c2];
						max1p <=  c2;
						min1v <=  min1v;
						min1p <=  min1p;
				  	end
				  	else
				  	begin
			 	  		if (ecg_signal[c2] < min1v)
				  		begin
					  	    min1v <=  ecg_signal[c2];
							min1p <=  c2;
				  			max1v <=  max1v;
							max1p <=  max1p;
				  		end
						else
						begin
				  			max1v <=  max1v;
							max1p <=  max1p;
							min1v <=  min1v;
							min1p <=  min1p;
						end
					end

					c2 <=  c2 + 1;

					if (c2 >= temp2)
						p_full <=  1;
					else
						p_full <=  p_full;
				end	
			end
		end
		else
		begin
			c2 <=  c2;
			max1v <=  max1v;
			max1p <=  max1p;
			min1v <=  min1v;
			min1p <=  min1p;
			p_full <=  p_full;

		end
		end
		else
		begin
			c2 <=  c2;
			max1v <=  max1v;
			max1p <=  max1p;
			min1v <=  min1v;
			min1p <=  min1p;
			p_full <=  p_full;

		end


		if (c3 <= temp4)
		begin
			if (c3 == 0)
				c3 <= temp3; 
			else 
			begin
				if (c3 == temp3) 
				begin
					c3 <=  temp3;
				  	max2v <=  ecg_signal[temp3];
				  	min2v <=  ecg_signal[temp3];
				  	max2p <=  temp3;
				  	min2p <=  temp3;
				  	c3 <=  c3 + 1;
				end
				else
				begin
			 		if (ecg_signal[c3] > max2v)
				  	begin
				  		max2v <=  ecg_signal[c3];
						max2p <=  c3;
						min2v <=  min2v;
						min2p <=  min2p;
				  	end
				  	else
				  	begin
			 	  		if (ecg_signal[c3] < min2v)
				  		begin
					  	    min2v <=  ecg_signal[c3];
							min2p <=  c3;
				  			max2v <=  max2v;
							max2p <=  max2p;
				  		end
						else
						begin
				  			max2v <=  max2v;
							max2p <=  max2p;
							min2v <=  min2v;
							min2p <=  min2p;
						end
					end
	
				  	c3 <=  c3 + 1;

				  	if (c3 >= temp4)
						t_full <=  1;
				  	else
						t_full <=  t_full;
				end
			end
		end
		else
		begin
			c3 <=  c3;
			max2v <=  max2v;
			max2p <=  max2p;
			min2v <=  min2v;
			min2p <=  min2p;
			t_full <=  t_full;
		end


		if (end_qrs_fin_2 != 0 && r_peak_pos_ref != 0)
		begin
		if (c6 <= temp8)
		begin
			if (c6 == 0)
				c6 <= temp7; 
			else 
			begin
				if (c6 == temp7) 
				begin
				  c6 <=  temp7;
				  s_peak_ref <=  ecg_signal[temp7];
				  s_peak_pos_temp <=  temp7;

				  if (temp7 == temp8)
					s_peak_found <=  1;
				  else
					s_peak_found <=  s_peak_found;

				  c6 <=  c6 + 1;
				end
				else
				begin
			 	     if (ecg_signal[c6] < s_peak_ref)
				     begin
				  	  s_peak_ref <=  ecg_signal[c6];
					  s_peak_pos_temp <=  c6;
				     end
				     else
				     begin
				  	  s_peak_ref <=  s_peak_ref;
					  s_peak_pos_temp <= 											 s_peak_pos_temp;
				     end

				    	c6 <=  c6 + 1;
	
					if (c6 >= temp8)
						s_peak_found <=  1;
				  	else
					  s_peak_found <=  s_peak_found;
				end
			end
		end
		else
		begin
			c6 <=  c6;
			s_peak_ref <=  s_peak_ref;
			s_peak_pos_ref <=  s_peak_pos_ref;
			s_peak_pos_temp <=  s_peak_pos_temp;

		end

		if (s_peak_found == 1)
			s_peak_pos_ref <=  s_peak_pos_temp;
		else
			s_peak_pos_ref <=  s_peak_pos_ref;
		end
		else
		begin
			c6 <=  c6;
			s_peak_ref <=  s_peak_ref;
			s_peak_pos_ref <=  s_peak_pos_ref;
			s_peak_pos_temp <=  s_peak_pos_temp;
		end
			
		if (start_qrs_fin_2 != 0 && r_peak_pos_ref != 0)
		begin
		if (c7 <= temp6)
		begin
			if (c7 == 0 && temp5!= 0)
				c7 <=  temp5; 
			else 
			begin
				if (c7 == temp5) 
				begin
				  	c7 <=  temp5;
				  	q_peak_ref <=  ecg_signal[temp5];
				  	q_peak_pos_temp <=  temp5;

				 	if (temp5 == temp6)
						q_peak_found <=  1;
				  	else
					  q_peak_found <=  q_peak_found;

				  	c7 <=  c7 + 1;
				end
				else
				begin
			 	     if (ecg_signal[c7] < q_peak_ref)
				     begin
				  	  q_peak_ref <=  ecg_signal[c7];
					  q_peak_pos_temp <=  c7;
				     end
				     else
				     begin
				  	  q_peak_ref <=  q_peak_ref;
					  q_peak_pos_temp <= 											 q_peak_pos_temp;
				     end

				    	c7 <=  c7 + 1;
	
					if (c7 >= temp6)
						q_peak_found <=  1;
				  	else
					  q_peak_found <=  q_peak_found;
				end
			end
		end
		else
		begin
			c7 <=  c7;
			q_peak_ref <=  q_peak_ref;
			q_peak_pos_ref <=  q_peak_pos_ref;
			q_peak_pos_temp <=  q_peak_pos_temp;

		end
		if (q_peak_found == 1)
			q_peak_pos_ref <=  q_peak_pos_temp;
		else
			q_peak_pos_ref <=  q_peak_pos_ref;
		end
		else
		begin
			c7 <=  c7;
			q_peak_ref <=  q_peak_ref;
			q_peak_pos_ref <=  q_peak_pos_ref;
			q_peak_pos_temp <=  q_peak_pos_temp;
		end

	end
	else
	begin
		c2 <=  c2;
		c3 <=  c3;
		c6 <=  c6;
		c7 <=  c7;

		max1v <=  max1v;
		max1p <=  max1p;
		min1v <=  min1v;
		min1p <=  min1p;
		max2v <=  max2v;
		max2p <=  max2p;
		min2v <=  min2v;
		min2p <=  min2p;

		p_full <=  p_full;
		t_full <=  t_full;

		s_peak_ref <=  s_peak_ref;
		s_peak_pos_ref <=  s_peak_pos_ref;
		s_peak_pos_temp <=  s_peak_pos_temp;

		q_peak_ref <=  q_peak_ref;
		q_peak_pos_ref <=  q_peak_pos_ref;
		q_peak_pos_temp <=  q_peak_pos_temp;
	end
end
else
begin
	c2 <=  0;
	c3 <=  0;
	c6 <=  0;
	c7 <=  0;

	q_peak_found <=  0;
	q_peak_ref <=  0;
	q_peak_pos_ref <=  0;
	q_peak_pos_temp <=  0;

	s_peak_found <=  0;
	s_peak_ref <=  0;
	s_peak_pos_ref <=  0;
	s_peak_pos_temp <=  0;
   
	max1v <=  0;
	max1p <=  0;
	min1v <=  0;
	min1p <=  0;
	max2v <=  0;
	max2p <=  0;
	min2v <=  0;
	min2p <=  0;

	p_full <=  0;
	t_full <=  0;
end

always @(*)
begin

p_peak = 0;
p_peak_pos = 0;

		if (p_full == 1)
		begin
			if (p1_cD_full != 0 || p2_cD_full != 0)
			begin
				if (array_2 != 0)
				begin
					if (p2minp < p2maxp)
					begin
						p_peak = max1v;
						p_peak_pos = max1p;
					end
					else
					begin
						p_peak = min1v;
						p_peak_pos = min1p;
					end
				end
				else
				begin
					if (p1minp < p1maxp)
					begin
						p_peak = max1v;
						p_peak_pos = max1p;
					end
					else
					begin
						p_peak = min1v;
						p_peak_pos = min1p;
					end
				end
			end
			else
			begin
				p_peak = p_peak;
				p_peak_pos = p_peak_pos;
			end
		end
		else
		begin
			p_peak = p_peak;
			p_peak_pos = p_peak_pos;
		end

end


always @(*)
begin

t_peak = 0;
t_peak_pos = 0;

		if (t_full == 1)
		begin
			if (t_cD_full != 0)
			begin
				if (t1minp < t1maxp)
				begin
					t_peak = max2v;
					t_peak_pos = max2p;
				end
				else
				begin
					t_peak = min2v;
					t_peak_pos = min2p;
				end
			end
			else
			begin
				t_peak = t_peak;
				t_peak_pos = t_peak_pos;
			end
		end
		else
		begin
			t_peak = t_peak;
			t_peak_pos = t_peak_pos;
		end
end


endmodule

