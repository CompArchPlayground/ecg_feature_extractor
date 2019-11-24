`timescale 1ps/1ps
`include "parameter.v"

module level3arch (count1,count2,max_pos_l3,min_pos_l3,
q_begin_l3_temp,q_begin_l3_flag,qwindow1_full,s_end_l3_temp,
swindow1_full,s_end_l3_flag,max_pos_l3_n,min_pos_l3_n,
cD_min_found,
cA0,cA1,cA2,cA3,cA4,cA5,cA6,cA7,cA8,cA9,cA10,cA11,cA12,cA13,cA14,cA15,cA16,cA17,cA18,cA19,cA20,cA21,cA22,cA23,cA24,cA25,cA26,cA27,cA28,cA29,cA30,cA31,cA32,cA33,cA34,cA35,cA36,cA37,cA38,cA39,cA40,cA41,cA42,cA43,cA44,cA45,cA46,cA47,cA48,cA49,cA50,cA51,cA52,cA53,cA54,cA55,cA56,cA57,cA58,cA59,cA60,cA61,cA62,cA63,cA64,cA65,cA66,cA67,cA68,cA69,cA70,cA71,cA72,cA73,cA74,cA75,cA76,cA77,cA78,cA79,cA80,cA81,cA82,cA83,cA84,cA85,cA86,cA87,cA88,cA89,cA90,cA91,cA92,cA93,cA94,cA95,cA96,cA97,cA98,cA99,data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8,clk,nReset,Enable);

output [15:0] count1;
output [`b9:0] count2;

output signed [`b16:0] 
cA0,cA1,cA2,cA3,cA4,cA5,cA6,cA7,cA8,cA9,cA10,cA11,cA12,cA13,cA14,cA15,cA16,cA17,cA18,cA19,cA20,cA21,cA22,cA23,cA24,cA25,cA26,cA27,cA28,cA29,cA30,cA31,cA32,cA33,cA34,cA35,cA36,cA37,cA38,cA39,cA40,cA41,cA42,cA43,cA44,cA45,cA46,cA47,cA48,cA49,cA50,cA51,cA52,cA53,cA54,cA55,cA56,cA57,cA58,cA59,cA60,cA61,cA62,cA63,cA64,cA65,cA66,cA67,cA68,cA69,cA70,cA71,cA72,cA73,cA74,cA75,cA76,cA77,cA78,cA79,cA80,cA81,cA82,cA83,cA84,cA85,cA86,cA87,cA88,cA89,cA90,cA91,cA92,cA93,cA94,cA95,cA96,cA97,cA98,cA99; 

output signed [`b11:0] max_pos_l3,min_pos_l3;

output [`b11:0] q_begin_l3_temp,s_end_l3_temp,max_pos_l3_n,min_pos_l3_n;

output q_begin_l3_flag,qwindow1_full,swindow1_full,s_end_l3_flag,cD_min_found;

reg signed [`b16:0] cD_l3,cA_l3,max_val_l3,min_val_l3,q1maxv,
s1minv,max_val_l3_n,min_val_l3_n;

reg signed [`b11:0] max_pos_l3,min_pos_l3,q_begin_l3,q1maxp,
s_end_l3,s1minp,max_pos_l3_n,max_pos_l3_temp,min_pos_l3_n,
min_pos_l3_temp,q_begin_l3_temp,s_end_l3_temp;

reg q_begin_l3_flag,qwindow1_full,swindow1_full,s_end_l3_flag,
cD_max_found,cD_min_found;

input [`b16:0] data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8;

input clk, nReset,Enable;
wire clk, nReset,Enable;

reg [`b16:0] data0, data1;
reg [15:0] count1;
reg [`b9:0] count2;
reg [`b9:0] count3;
reg [`b16:0] pos;

reg signed [`b16:0] cD_l3_store [0:`n3-2];
reg signed [`b16:0] cA_l3_store [0:`n3-2];

reg [`b11:0] temp1,temp2,temp3,temp4,temp5,temp6,temp7,temp8;
reg [`b11:0] c2,c3,c4,c5;
reg t,p;

integer i;

always @(posedge clk or negedge nReset)

if (!nReset)
	begin
		data0 <=  0;
		data1 <=  0;
		cD_l3 <=  0;
		cA_l3 <=  0;
		count1 <=  0;
		count2 <=  `n3;
		count3 <=  0;
		pos <= 0;
		t<=0;
		for (i=0; i<=`n3-2; i=i+1)
		begin
			cD_l3_store[i] <=  0;
			cA_l3_store[i] <=  0;
		end
	end
else if (Enable)
	begin
		if (count1 < 3 && count2 > 0)
		begin
		
			case(count1)
		0:	count1<=  count1+1;
		1:begin	
			data0<=  data_in1+data_in2+data_in3+data_in4;
			data1<=  data_in5+data_in6+data_in7+data_in8;

			count1<=  count1+1;
				if (count3 != 0 && count3 < `n3)
					begin
					   cD_l3_store[count3-1] <=  cD_l3;
					   cA_l3_store[count3-1] <=  cA_l3;
					end
					else	
					begin
						cD_l3_store[count3-1] <=  0;
						cA_l3_store[count3-1] <=  0;
					end

			count3<=  count3 +1;

			end

		2:begin
				if (count2>1)
			begin
		//	data1<=  data_in1+data_in2+data_in3+data_in4;
			cA_l3 <=  data0 + data1;
			cD_l3 <=  data0 - data1;
			pos <=  pos + 1; 
			count2<=  count2-1;
			count1<=  1; 
			end
			end
			endcase
		end
			else
			begin
			data0<=  0;
			data1<=  0;
			end
		
	end
else
begin
		data0 <=  0;
		data1 <=  0;
		cD_l3 <=  0;
		cA_l3 <=  0;
		count1 <=  0;
		count2 <=  `n3;
		count3 <=  0;
		pos <= 0;
		t<=0;
		for (i=0; i<=`n3-2; i=i+1)
		begin
			cD_l3_store[i] <=  0;
			cA_l3_store[i] <=  0;
		end
end
always @(posedge clk or negedge nReset)

if (!nReset)
begin
	max_val_l3 <=  0;
	max_pos_l3 <=  0;
	min_val_l3 <=  0;
	min_pos_l3 <=  0;
end
else if (Enable)
begin
	if (count1 == 1)
	begin
		if (count2 > 0)
		begin
			if (count2 == (`n3-1))
			begin
				max_val_l3 <=  cD_l3;
				min_val_l3 <=  cD_l3;
				max_pos_l3 <=  pos - 1;				
				min_pos_l3 <=  pos - 1;								end
			else
			begin
				if (cD_l3 > max_val_l3)
				begin
					max_val_l3 <=  cD_l3;
					max_pos_l3 <=  pos - 1;
					min_val_l3 <=  min_val_l3;
					min_pos_l3 <=  min_pos_l3;
				end
				else
				begin
					if (cD_l3 < min_val_l3)
					begin
						min_val_l3 <=  cD_l3;
						min_pos_l3 <=  pos - 1;
						max_val_l3 <=  max_val_l3;
						max_pos_l3 <=  max_pos_l3;						     end
					else
					begin
						max_val_l3 <=  max_val_l3;
						min_val_l3 <=  min_val_l3;
						max_pos_l3 <=  max_pos_l3;
						min_pos_l3 <=  min_pos_l3;
					end					
				end
			end
		end
		else
		begin
			max_val_l3 <=  max_val_l3;
			min_val_l3 <=  min_val_l3;
			max_pos_l3 <=  max_pos_l3;
			min_pos_l3 <=  min_pos_l3;
		end
	end
	else
	begin
		max_val_l3 <=  max_val_l3;
		min_val_l3 <=  min_val_l3;
		max_pos_l3 <=  max_pos_l3;
		min_pos_l3 <=  min_pos_l3;
	end
end
else
begin
	max_val_l3 <=  0;
	max_pos_l3 <=  0;
	min_val_l3 <=  0;
	min_pos_l3 <=  0;
end

always @(*)
begin

temp1 = 0;
temp2 = 0;
temp3 = 0;
temp4 = 0;
temp5 = 0;
temp6 = 0;
temp7 = 0;
temp8 = 0;

if (count2 == 1)
begin
	if (min_pos_l3 < max_pos_l3)
	begin
		temp1 = min_pos_l3 - `q_window_l3 - 1;
		temp2 = min_pos_l3 - 1;
		temp3 = max_pos_l3 + 1;
		temp4 = max_pos_l3 + `s_window_l3 - 1;
		temp5 = temp5;
		temp6 = temp6;
		temp7 = max_pos_l3;
		temp8 = max_pos_l3 + (10*`rat);
	end
	else
	begin
		//temp1 = max_pos_l3 - `q_window_l3 - 1;
		temp1 = max_pos_l3 - `q_window_l3;

		temp2 = max_pos_l3 - 1;
		temp3 = min_pos_l3 + 1;
		temp4 = min_pos_l3 + `s_window_l3 - 1;
		temp5 = min_pos_l3;
		temp6 = min_pos_l3 + (10*`rat);
		temp7 = max_pos_l3 - (15*`rat);
		temp8 = max_pos_l3;
	end
end
else
begin
	temp1 = temp1;
	temp2 = temp2;
	temp3 = temp3;
	temp4 = temp4;
	temp5 = temp5;
	temp6 = temp6;
	temp7 = temp7;
	temp8 = temp8;
end
end


always @(posedge clk or negedge nReset)

if (!nReset)
begin
   
	c2 <=  0;
	c3 <=  0;
	c4 <=  0;
	c5 <=  0;

	q1maxv <=  0;
	q1maxp <=  0;
	qwindow1_full <=  0;


	s1minv <=  0;
	s1minp <=  0;
	swindow1_full <=  0;

	max_val_l3_n <=  0;
	max_pos_l3_temp <=  0;
	max_pos_l3_n <=  0;
	cD_max_found <=  0;

	min_val_l3_n <=  0;
	min_pos_l3_temp <=  0;
	min_pos_l3_n <=  0;
	cD_min_found <=  0;
end
else if (Enable)
begin
	if (count1 == 2 && count2 == 1)
	begin
		if (c2 <= temp2)
		begin
			if (c2 == 0)
				c2 <=  temp1; 
			else 
			begin
				if (c2 == temp1) 
				begin
				  c2 <=  temp1;
				  q1maxv <=  cD_l3_store[temp1];
				  q1maxp <=  temp1;
				  c2 <=  c2 + 1;
				end
				else
				begin
			 		if (cD_l3_store[c2] > q1maxv)
				  	begin
				  		q1maxv <=  cD_l3_store[c2];
						q1maxp <=  c2;
				  	end
				  	else
				  	begin
				  		q1maxv <=  q1maxv;
						q1maxp <=  q1maxp;
				  	end
	
				  c2 <=  c2 + 1;

				  if (c2 >= temp2)
					qwindow1_full <=  1;
				  else
					qwindow1_full <=  qwindow1_full;
				end
			end
		end
		else
		begin
			c2 <=  c2;
			q1maxv <=  q1maxv;
			q1maxp <=  q1maxp;
			qwindow1_full <=  qwindow1_full;
		end

		if (c3 <= temp4)
		begin
			if (c3 == 0)
				c3 <=  temp3; 
			else 
			begin
				if (c3 == temp3) 
				begin
				  c3 <=  temp3;
				  s1minv <=  cD_l3_store[temp3];
				  s1minp <=  temp3;
				  c3 <=  c3 + 1;
				end
				else
				begin
			 		if (cD_l3_store[c3] < s1minv)
				  	begin
				  		s1minv <=  cD_l3_store[c3];
						s1minp <=  c3;
				  	end
				  	else
				  	begin
					  	s1minv <=  s1minv;
						s1minp <=  s1minp;
					end
	
				  c3 <=  c3 + 1;

			       if (c3 >= temp4)
					swindow1_full <=  1;
				  else
					swindow1_full <=  swindow1_full;
				end
			end
		end
		else
		begin
			c3 <=  c3;
			s1minv <=  s1minv;
			s1minp <=  s1minp;
			swindow1_full <=  swindow1_full;
		end


		if (c4 <= temp6)
		begin
			if (c4 == 0)
				c4 <=  temp5; 
			else 
			begin
				if (c4 == temp5) 
				begin
				  c4 <=  temp5;
				  max_val_l3_n <=  cD_l3_store[temp5];
				  max_pos_l3_temp <=  temp5;
				  c4 <=  c4 + 1;
				end
				else
				begin
			 	  if (cD_l3_store[c4] > max_val_l3_n)
				  begin
				  	max_val_l3_n <=  cD_l3_store[c4];
					max_pos_l3_temp <=  c4;
				  end
				  else
				  begin
				  	max_val_l3_n <=  max_val_l3_n;
				    max_pos_l3_temp <=  max_pos_l3_temp;
				  end
	
				  c4 <=  c4 + 1;

				  if (c4 >= temp6)
					cD_max_found <=  1;
				  else
					cD_max_found <=  cD_max_found;

				end
			end
		end
		else
		begin
			c4 <=  c4;
			max_val_l3_n <=  max_val_l3_n;
			max_pos_l3_temp <=  max_pos_l3_temp;
			max_pos_l3_n <=  max_pos_l3_n;
		end
		if (cD_max_found == 1)
			max_pos_l3_n <=  max_pos_l3_temp;
		else
			max_pos_l3_n <=  max_pos_l3_n;

		if (c5 <= temp8)
		begin
			if (c5 == 0)
				c5 <=  temp7; 
			else 
			begin
				if (c5 == temp7) 
				begin
					c5 <=  temp7;
					min_val_l3_n <=  cD_l3_store[temp7];
					min_pos_l3_temp <=  temp7;
					c5 <=  c5 + 1;
				end
				else
				begin
			 	  if (cD_l3_store[c5] < min_val_l3_n)
				  begin
				  	min_val_l3_n <=  cD_l3_store[c5];
					min_pos_l3_temp <=  c5;
				  end
				  else
				  begin
				  	min_val_l3_n <=  min_val_l3_n;
				    min_pos_l3_temp <=  min_pos_l3_temp;
				  end
	
				  c5 <=  c5 + 1;

				  if (c5 >= temp8)
					cD_min_found <=  1;
				  else
					cD_min_found <=  cD_min_found;

				end
			end
		end
		else
		begin
			c5 <=  c5;
			min_val_l3_n <=  min_val_l3_n;
			min_pos_l3_temp <=  min_pos_l3_temp;
			min_pos_l3_n <=  min_pos_l3_n;
			cD_min_found <=  cD_min_found;
		end

		if (cD_min_found == 1)
			min_pos_l3_n <=  min_pos_l3_temp;
		else
			min_pos_l3_n <=  min_pos_l3_n;
	end
	else
	begin
		c2 <=  c2;
		c3 <=  c3;
		c4 <=  c4;
		c5 <=  c5;

		q1maxv <=  q1maxv;
		q1maxp <=  q1maxp;
		qwindow1_full <=  qwindow1_full;

		s1minv <=  s1minv;
		s1minp <=  s1minp;
		swindow1_full <=  swindow1_full;

		max_val_l3_n <=  max_val_l3_n;
		max_pos_l3_temp <=  max_pos_l3_temp;
		max_pos_l3_n <=  max_pos_l3_n;
		cD_max_found <=  cD_max_found;

		min_val_l3_n <=  min_val_l3_n;
		min_pos_l3_temp <=  min_pos_l3_temp;
		min_pos_l3_n <=  min_pos_l3_n;
		cD_min_found <=  cD_min_found;
	end
end
else
begin
	c2 <=  0;
	c3 <=  0;
	c4 <=  0;
	c5 <=  0;

	q1maxv <=  0;
	q1maxp <=  0;
	qwindow1_full <=  0;


	s1minv <=  0;
	s1minp <=  0;
	swindow1_full <=  0;

	max_val_l3_n <=  0;
	max_pos_l3_temp <=  0;
	max_pos_l3_n <=  0;
	cD_max_found <=  0;

	min_val_l3_n <=  0;
	min_pos_l3_temp <=  0;
	min_pos_l3_n <=  0;
	cD_min_found <=  0;
end	
always @(*)
begin
	q_begin_l3 = 0;
	q_begin_l3_flag  = 0;

     	          if (qwindow1_full != 0)
	 	begin
			q_begin_l3 = q1maxp;
			q_begin_l3_flag = 1;
	     end
	     else
	     begin
	      	q_begin_l3 = q_begin_l3;
			q_begin_l3_flag = q_begin_l3_flag;
	     end

end


always @(*)
begin
	s_end_l3 = 0;
	s_end_l3_flag = 0;
	
		if (swindow1_full != 0)
		begin
			s_end_l3 = s1minp;
			s_end_l3_flag = 1;
		end
		else
		begin
			s_end_l3 = s_end_l3;
			s_end_l3_flag = s_end_l3_flag;
		end
end


always @(*)
begin

q_begin_l3_temp = 0;
s_end_l3_temp = 0;
		
if (count1 == 2 && count2 == 1)
begin
	if (qwindow1_full != 0)
	begin
		if (q_begin_l3_flag != 0)
			q_begin_l3_temp = (q_begin_l3-(8*`rat));
		else
			q_begin_l3_temp = q_begin_l3_temp;
	end
	else
		q_begin_l3_temp = q_begin_l3_temp;

	if (swindow1_full != 0)
	begin
		if (s_end_l3_flag != 0)
     			s_end_l3_temp = (s_end_l3+(15*`rat));
		else
			s_end_l3_temp = s_end_l3_temp;
	end
	else
		s_end_l3_temp = s_end_l3_temp;
end
else
begin
	q_begin_l3_temp = q_begin_l3_temp;
	s_end_l3_temp = s_end_l3_temp;
end

end


assign {cA0,cA1,cA2,cA3,cA4,cA5,cA6,cA7,cA8,cA9,cA10,cA11,cA12,cA13,cA14,cA15,cA16,cA17,cA18,cA19,cA20,cA21,cA22,cA23,cA24,cA25,cA26,cA27,cA28,cA29,cA30,cA31,cA32,cA33,cA34,cA35,cA36,cA37,cA38,cA39,cA40,cA41,cA42,cA43,cA44,cA45,cA46,cA47,cA48,cA49,cA50,cA51,cA52,cA53,cA54,cA55,cA56,cA57,cA58,cA59,cA60,cA61,cA62,cA63,cA64,cA65,cA66,cA67,cA68,cA69,cA70,cA71,cA72,cA73,cA74,cA75,cA76,cA77,cA78,cA79,cA80,cA81,cA82,cA83,cA84,cA85,cA86,cA87,cA88,cA89,cA90,
cA91,cA92,cA93,cA94,cA95,cA96,cA97,cA98,cA99} = {cA_l3_store[0],cA_l3_store[1],cA_l3_store[2],cA_l3_store[3],cA_l3_store[4],cA_l3_store[5],cA_l3_store[6],cA_l3_store[7],cA_l3_store[8],cA_l3_store[9],cA_l3_store[10],cA_l3_store[11],cA_l3_store[12],cA_l3_store[13],cA_l3_store[14],cA_l3_store[15],cA_l3_store[16],cA_l3_store[17],cA_l3_store[18],cA_l3_store[19],cA_l3_store[20],cA_l3_store[21],cA_l3_store[22],cA_l3_store[23],cA_l3_store[24],cA_l3_store[25],cA_l3_store[26],cA_l3_store[27],cA_l3_store[28],cA_l3_store[29],cA_l3_store[30],cA_l3_store[31],cA_l3_store[32],cA_l3_store[33],cA_l3_store[34],cA_l3_store[35],cA_l3_store[36],cA_l3_store[37],cA_l3_store[38],cA_l3_store[39],cA_l3_store[40],cA_l3_store[41],cA_l3_store[42],cA_l3_store[43],cA_l3_store[44],cA_l3_store[45],cA_l3_store[46],cA_l3_store[47],cA_l3_store[48],cA_l3_store[49],cA_l3_store[50],cA_l3_store[51],cA_l3_store[52],cA_l3_store[53],cA_l3_store[54],cA_l3_store[55],cA_l3_store[56],cA_l3_store[57],cA_l3_store[58],cA_l3_store[59],cA_l3_store[60],cA_l3_store[61],cA_l3_store[62],cA_l3_store[63],cA_l3_store[64],cA_l3_store[65],cA_l3_store[66],cA_l3_store[67],cA_l3_store[68],cA_l3_store[69],cA_l3_store[70],cA_l3_store[71],cA_l3_store[72],cA_l3_store[73],cA_l3_store[74],cA_l3_store[75],cA_l3_store[76],cA_l3_store[77],cA_l3_store[78],cA_l3_store[79],cA_l3_store[80],cA_l3_store[81],cA_l3_store[82],cA_l3_store[83],cA_l3_store[84],cA_l3_store[85],cA_l3_store[86],cA_l3_store[87],cA_l3_store[88],cA_l3_store[89],cA_l3_store[90],cA_l3_store[91],cA_l3_store[92],cA_l3_store[93],cA_l3_store[94],cA_l3_store[95],cA_l3_store[96],cA_l3_store[97],cA_l3_store[98],cA_l3_store[99]};

endmodule

