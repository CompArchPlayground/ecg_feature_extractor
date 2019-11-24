/*
Module		  : ecg_signal_max.v

HDL			    : Verilog 2001

Function	 :	Finds min/max from an incoming stream of 800 ecg samples (@ 8 samples per cycle) 

Authors	  :	# Dwaipayan Biswas, MSc SoC 2011, University of Southampton.
            # Sanmitra Ghosh,   MSc SoC 2011, University of Southampton 
            # Ahmed F Rahim,    MSc SoC 2012, University of Southampton.

Current   :	Stable, Bug free, Ready for Synthesis.

Version		
History		 :	# Dwaipayan Biswas, MSc SoC 2011, University of Southampton.
            - Module Created
            - Tested with parallel stream of 800 samples 
            
            # Sanmitra Ghosh, MSc SoC 2011, University of Southampton 
            - Incorporated sequential read capability (8 samples/cycle)
            - This version had bugs due to the unpredictable behaviour of 'for' loops.
			- The last 8 samples of any ECG window were discarded
            
            # Ahmed F Rahim, MSc SoC 2012, University of Southampton.
            - Bug fixes: ecg min/max, last 8 samples are now computed
            - Removed 'for' loops and replaced them with a tree structure.
            - This version was fully functionally verified against Matlab Code.
	    - Removed latches in the min/max tree ... this was causing problem during scan chain insertion  
*/

`timescale 1ps/1ps
`include "parameter.v"


module ecg_signal_max(thr1,thr2,count1,count2,min_pos_l3,
max_pos_l3,data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8,clk,nReset,Enable);
  
output [`b16:0] thr1,thr2;

reg signed [`b16:0] ecg_max,      ecg_min,
                    ecg_min_p,    ecg_max_p,
                    ecg_max_p_01, ecg_max_p_02, 
                    ecg_max_p_03, ecg_max_p_04,
                    ecg_max_p_11, ecg_max_p_12,
                    
                    ecg_min_p_01, ecg_min_p_02, 
                    ecg_min_p_03, ecg_min_p_04,
                    ecg_min_p_11, ecg_min_p_12,
                    thr1,         thr2;

input signed [`b16:0] data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8;
input [`b11:0] min_pos_l3,max_pos_l3;

input [15:0] count1;
input [`b9:0] count2;

input clk, nReset,Enable;
wire clk, nReset,Enable;

reg [`b16:0] diff,diff_abs,thr1_temp,temp1,thr2_temp,temp2,c5;
reg signed [`b16:0] ecg_signal [0:7];
reg t,k;

always@(*)
		  begin
		   // max
		   // qf
		   ecg_max_p_01 = (ecg_signal[0] >= ecg_signal[1]) ? ecg_signal[0] : ecg_signal[1]; 
		   ecg_max_p_02 = (ecg_signal[2] >= ecg_signal[3]) ? ecg_signal[2] : ecg_signal[3]; 
		   ecg_max_p_03 = (ecg_signal[4] >= ecg_signal[5]) ? ecg_signal[4] : ecg_signal[5]; 
		   ecg_max_p_04 = (ecg_signal[6] >= ecg_signal[7]) ? ecg_signal[6] : ecg_signal[7]; 
		   // sf
		   ecg_max_p_11 = (ecg_max_p_01 >= ecg_max_p_02) ? ecg_max_p_01 : ecg_max_p_02; 
		   ecg_max_p_12 = (ecg_max_p_03 >= ecg_max_p_04) ? ecg_max_p_03 : ecg_max_p_04; 
		   //f
		   ecg_max_p    = (ecg_max_p_11 >= ecg_max_p_12) ? ecg_max_p_11 : ecg_max_p_12; 
		   		   		    
		  // find min
		  // qf
		   ecg_min_p_01 = (ecg_signal[0] <= ecg_signal[1]) ? ecg_signal[0] : ecg_signal[1]; 
		   ecg_min_p_02 = (ecg_signal[2] <= ecg_signal[3]) ? ecg_signal[2] : ecg_signal[3]; 
		   ecg_min_p_03 = (ecg_signal[4] <= ecg_signal[5]) ? ecg_signal[4] : ecg_signal[5]; 
		   ecg_min_p_04 = (ecg_signal[6] <= ecg_signal[7]) ? ecg_signal[6] : ecg_signal[7]; 
		   // sf
		   ecg_min_p_11 = (ecg_min_p_01 <= ecg_min_p_02) ? ecg_min_p_01 : ecg_min_p_02; 
		   ecg_min_p_12 = (ecg_min_p_03 <= ecg_min_p_04) ? ecg_min_p_03 : ecg_min_p_04; 
		   //f
		   ecg_min_p    = (ecg_min_p_11 <= ecg_min_p_12) ? ecg_min_p_11 : ecg_min_p_12; 
		  end


always @(posedge clk or negedge nReset)
begin
if (!nReset)
  begin
	ecg_max <=  -32768;
	ecg_min <=  32767;
	end
else
  if (Enable)
    if (count1 > 0)
      if (c5 <= 100)
        if (k == 0)
        begin
          if (ecg_max < ecg_max_p) ecg_max <=  ecg_max_p;
          else                      ecg_max <=  ecg_max; 
	        if (ecg_min > ecg_min_p) ecg_min <=  ecg_min_p;
          else                      ecg_min <=  ecg_min;
        end
        else 
        begin
           ecg_max <=  ecg_max;
	         ecg_min <=  ecg_min;
        end  
      else // c < 99
        begin
           ecg_max <=  ecg_max;
	         ecg_min <=  ecg_min;
        end 
    else // count1 > 0
        begin
           ecg_max <=  ecg_max;
	         ecg_min <=  ecg_min;
        end 
else // enable
    begin
       ecg_max <=  -32768;
	     ecg_min <=  32767;
    end 
end
       
always @(posedge clk or negedge nReset)
if (!nReset)
begin
	t<=  0;
	k<=  0;
  c5 <=  0;
  ecg_signal[0] <=  0;
  ecg_signal[1] <=  0;
  ecg_signal[2] <=  0;
  ecg_signal[3] <=  0;
  ecg_signal[4] <=  0;
  ecg_signal[5] <=  0;
  ecg_signal[6] <=  0;
  ecg_signal[7] <=  0;  
  end
else 
if (Enable)
begin
	k<=  ~k;
	if (count1 > 0)
		if (c5 <= /*99*/ 100 && k==1)
		begin
		  	          c5 <=  c5 + 1;
			ecg_signal[0] <=  data_in1;
			ecg_signal[1] <=  data_in2;
			ecg_signal[2] <=  data_in3;
			ecg_signal[3] <=  data_in4;
			ecg_signal[4] <=  data_in5;
			ecg_signal[5] <=  data_in6;
			ecg_signal[6] <=  data_in7;
			ecg_signal[7] <=  data_in8;
		end
		else 
		  if (c5==101) t<=  1;
			else         t<=  0;
	else // (count1 < 0)
		begin
		  c5  <=  0;
		  t   <=  0;
		end
end
else
begin
	t        <=  0;
	k        <=  0;
  c5       <=  0;
	ecg_signal[0] <=  0;
  ecg_signal[1] <=  0;
  ecg_signal[2] <=  0;
  ecg_signal[3] <=  0;
  ecg_signal[4] <=  0;
  ecg_signal[5] <=  0;
  ecg_signal[6] <=  0;
  ecg_signal[7] <=  0;  
end


always @(*)
begin
diff = 0;
diff_abs = 0; 
temp1 = 0; 
thr1_temp = 0;
thr1 = 0; 
temp2 = 0;  
thr2_temp = 0; 
thr2 = 0; 
if (count2 == 1)
begin
	 diff = ecg_max - ecg_min;
	// change this later
	// diff = 2926;
	if (diff[15] == 1)
		diff_abs = ~(diff-1);
	else
		diff_abs = diff;

	if (min_pos_l3 < max_pos_l3)
	begin
		if (diff_abs > 4000)	
		begin
			thr1_temp = (diff_abs >> `div2);
			temp1 = thr1_temp<<`mul1;
			thr1 = temp1;
			temp1 = thr1_temp>>`div1;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div2;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div4;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div6;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div12;
			thr1 = thr1 + temp1 + 1;

			thr2_temp = (diff_abs >> `div3);

			temp2 = thr2_temp<<`mul1;
			thr2 = temp2;
			temp2 = thr2_temp>>`div1;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div2;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div4;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div6;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div12;
			thr2 = thr2 + temp2 + 1;
		end
		else
		begin
			if (diff_abs > 2000)
			begin
				thr1_temp = (diff_abs >> `div3);

				temp1 = thr1_temp<<`mul1;
				thr1 = temp1;
				temp1 = thr1_temp>>`div1;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div2;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div4;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div6;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div12;
				thr1 = thr1 + temp1 + 1;
			
				thr2_temp = (diff_abs >> `div4);

				temp2 = thr2_temp<<`mul1;
				thr2 = temp2;
				temp2 = thr2_temp>>`div1;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div2;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div4;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div6;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div12;
				thr2 = thr2 + temp2 + 1;
			end
			else
			begin
				thr1_temp = (diff_abs >> `div6);
				temp1 = thr1_temp<<`mul1;
				thr1 = temp1;
				temp1 = thr1_temp>>`div1;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div2;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div4;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div6;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div12;
				thr1 = thr1 + temp1 + 1 + 2;
				thr2_temp = (diff_abs >> `div3);
				temp2 = thr2_temp<<`mul1;
				thr2 = temp2;
				temp2 = thr2_temp>>`div1;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div2;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div4;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div6;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div12;
				thr2 = thr2 + temp2 + 1;
			end
		end
	end
	else
	begin
		if (diff_abs > 4000)	
		begin
			thr1_temp = (diff_abs >> `div7);
			temp1 = thr1_temp<<`mul1;
			thr1 = temp1;
			temp1 = thr1_temp>>`div1;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div2;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div4;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div6;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div12;
			thr1 = thr1 + temp1 + 1;
			thr2_temp = (diff_abs >> `div4);
			temp2 = thr2_temp<<`mul1;
			thr2 = temp2;
			temp2 = thr2_temp>>`div1;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div2;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div4;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div6;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div12;
			thr2 = thr2 + temp2 + 1;
		end
		else
		begin
			if (diff_abs > 2000)
			begin
				thr1_temp = (diff_abs >> `div5);

				temp1 = thr1_temp<<`mul1;
				thr1 = temp1;
				temp1 = thr1_temp>>`div1;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div2;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div4;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div6;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div12;
				thr1 = thr1 + temp1 + 1;
			
				thr2_temp = (diff_abs >> `div3);

				temp2 = thr2_temp<<`mul1;
				thr2 = temp2;
				temp2 = thr2_temp>>`div1;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div2;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div4;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div6;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div12;
				thr2 = thr2 + temp2 + 1;
			end
			else
			begin
				thr1_temp = (diff_abs >> `div5);

				temp1 = thr1_temp<<`mul1;
				thr1 = temp1;
				temp1 = thr1_temp>>`div1;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div2;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div4;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div6;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div12;
				thr1 = thr1 + temp1 + 1;
			
				thr2_temp = (diff_abs >> `div3);

				temp2 = thr2_temp<<`mul1;
				thr2 = temp2;
				temp2 = thr2_temp>>`div1;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div2;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div4;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div6;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div12;
				thr2 = thr2 + temp2 + 1;
			end
		end
	end
end
else
begin
	thr1 = thr1;
	thr2 = thr2;
	temp1 = temp1;
	temp2 = temp2;
	thr1_temp = thr1_temp;
	thr2_temp = thr2_temp;
	diff = diff;
	diff_abs = diff_abs;
end
end

/*
module ecg_signal_max (thr1,thr2,count1,count2,min_pos_l3,
max_pos_l3,data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8,clk,nReset,Enable);
  
output [`b16:0] thr1,thr2;

reg signed [`b16:0] ecg_max,ecg_min,thr1,thr2;

input signed [`b16:0] data_in1,data_in2,data_in3,data_in4,data_in5,data_in6,data_in7,data_in8;
input [`b11:0] min_pos_l3,max_pos_l3;

input [15:0] count1;
input [`b9:0] count2;

input clk, nReset,Enable;
wire clk, nReset,Enable;

reg [`b16:0] diff,diff_abs,thr1_temp,temp1,thr2_temp,temp2,c5;
reg signed [`b16:0] ecg_signal [0:7];
reg t,k;
reg [3:0] i,j;
always @(posedge clk or negedge nReset)
begin
if (!nReset)
begin
	ecg_max <=  0;
	ecg_min <=  0;
	t<=  0;
	i<= 0;
	k<=  0;

c5 <=  0;
for (j=0; j<8; j=j+1)
		ecg_signal[j] <=  0;
end
else if (Enable)
begin
	k<=  ~k;

	if (count1 > 0)
	begin
		if (c5 <= 99 && k==1)
		begin
			ecg_signal[0] <=  data_in1;
			ecg_signal[1] <=  data_in2;
			ecg_signal[2] <=  data_in3;
			ecg_signal[3] <=  data_in4;
			ecg_signal[4] <=  data_in5;
			ecg_signal[5] <=  data_in6;
			ecg_signal[6] <=  data_in7;
			ecg_signal[7] <=  data_in8;

		for(i=0;i<=7;i=i+1) 
			begin
				
			if (ecg_signal[i]<ecg_min)
					ecg_min <=  ecg_signal[i];
					else
					ecg_min <=  ecg_min;
			
		end

		for(j=0;j<=7;j=j+1) 
		begin	
			if (ecg_signal[j]>ecg_max)
					ecg_max <=  ecg_signal[j];
					else
					ecg_max <=  ecg_max ;
		end


			c5 <=  c5 + 1;
			if (c5==100)
				t <=  1;
				else 
				t <=  0;

		end
		else
			begin
				t<=  1;
			end
	end
	else
		begin
		c5 <=  0;
		t<=  0;
		end
end
else
begin
	ecg_max <=  0;
	ecg_min <=  0;
	t<=  0;
	i<=0;
	k<=  0;

c5 <=  0;
for (j=0; j<8; j=j+1)
		ecg_signal[j] <=  0;
end
end

always @(*)
begin

diff = 0;
diff_abs = 0; 
temp1 = 0; 
thr1_temp = 0;
thr1 = 0; 
temp2 = 0;  
thr2_temp = 0; 
thr2 = 0; 

if (count2 == 1)
begin
	diff = ecg_max - ecg_min;
	if (diff[15] == 1)
		diff_abs = ~(diff-1);
	else
		diff_abs = diff;

	if (min_pos_l3 < max_pos_l3)
	begin
		if (diff_abs > 4000)	
		begin
			thr1_temp = (diff_abs >> `div2);

			temp1 = thr1_temp<<`mul1;
			thr1 = temp1;
			temp1 = thr1_temp>>`div1;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div2;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div4;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div6;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div12;
			thr1 = thr1 + temp1 + 1;

			thr2_temp = (diff_abs >> `div3);

			temp2 = thr2_temp<<`mul1;
			thr2 = temp2;
			temp2 = thr2_temp>>`div1;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div2;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div4;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div6;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div12;
			thr2 = thr2 + temp2 + 1;
		end
		else
		begin
			if (diff_abs > 2000)
			begin
				thr1_temp = (diff_abs >> `div3);

				temp1 = thr1_temp<<`mul1;
				thr1 = temp1;
				temp1 = thr1_temp>>`div1;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div2;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div4;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div6;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div12;
				thr1 = thr1 + temp1 + 1;
			
				thr2_temp = (diff_abs >> `div4);

				temp2 = thr2_temp<<`mul1;
				thr2 = temp2;
				temp2 = thr2_temp>>`div1;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div2;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div4;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div6;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div12;
				thr2 = thr2 + temp2 + 1;
			end
			else
			begin
				thr1_temp = (diff_abs >> `div6);

				temp1 = thr1_temp<<`mul1;
				thr1 = temp1;
				temp1 = thr1_temp>>`div1;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div2;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div4;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div6;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div12;
				thr1 = thr1 + temp1 + 1 + 2;
			
				thr2_temp = (diff_abs >> `div3);

				temp2 = thr2_temp<<`mul1;
				thr2 = temp2;
				temp2 = thr2_temp>>`div1;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div2;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div4;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div6;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div12;
				thr2 = thr2 + temp2 + 1;
			end
		end
	end
	else
	begin
		if (diff_abs > 4000)	
		begin
			thr1_temp = (diff_abs >> `div7);

			temp1 = thr1_temp<<`mul1;
			thr1 = temp1;
			temp1 = thr1_temp>>`div1;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div2;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div4;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div6;
			thr1 = thr1 + temp1;
			temp1 = thr1_temp>>`div12;
			thr1 = thr1 + temp1 + 1;

			thr2_temp = (diff_abs >> `div4);

			temp2 = thr2_temp<<`mul1;
			thr2 = temp2;
			temp2 = thr2_temp>>`div1;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div2;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div4;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div6;
			thr2 = thr2 + temp2;
			temp2 = thr2_temp>>`div12;
			thr2 = thr2 + temp2 + 1;
		end
		else
		begin
			if (diff_abs > 2000)
			begin
				thr1_temp = (diff_abs >> `div5);

				temp1 = thr1_temp<<`mul1;
				thr1 = temp1;
				temp1 = thr1_temp>>`div1;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div2;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div4;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div6;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div12;
				thr1 = thr1 + temp1 + 1;
			
				thr2_temp = (diff_abs >> `div3);

				temp2 = thr2_temp<<`mul1;
				thr2 = temp2;
				temp2 = thr2_temp>>`div1;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div2;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div4;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div6;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div12;
				thr2 = thr2 + temp2 + 1;
			end
			else
			begin
				thr1_temp = (diff_abs >> `div5);

				temp1 = thr1_temp<<`mul1;
				thr1 = temp1;
				temp1 = thr1_temp>>`div1;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div2;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div4;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div6;
				thr1 = thr1 + temp1;
				temp1 = thr1_temp>>`div12;
				thr1 = thr1 + temp1 + 1;
			
				thr2_temp = (diff_abs >> `div3);

				temp2 = thr2_temp<<`mul1;
				thr2 = temp2;
				temp2 = thr2_temp>>`div1;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div2;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div4;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div6;
				thr2 = thr2 + temp2;
				temp2 = thr2_temp>>`div12;
				thr2 = thr2 + temp2 + 1;
			end
		end
	end
end
else
begin
	thr1 = thr1;
	thr2 = thr2;
	temp1 = temp1;
	temp2 = temp2;
	thr1_temp = thr1_temp;
	thr2_temp = thr2_temp;
	diff = diff;
	diff_abs = diff_abs;
end

end */

endmodule

