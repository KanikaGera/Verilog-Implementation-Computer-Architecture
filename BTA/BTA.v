// ****** DECODER *******
 
module decoder2_4 ( in1_2,out1,out2,out3,out4);

input [1:0] in1_2;
output reg out1,out2,out3,out4;

//reg [1:0] sel;

always @(in1_2) begin

out1=1'b0;
out2=1'b0;
out3=1'b0;
out4=1'b0;

case(in1_2)
	2'b00: out1=1'b1;
	2'b01: out2=1'b1;
	2'b10: out3=1'b1;
	2'b11: out4=1'b1;
endcase

end
endmodule

// ****** BTA  *******

module BTA ( in1,in2,in3,in4,out1,out2,out3,out4, newBTA, BTAWr,clk,reset);

input in1,in2,in3,in4, BTAWr,clk,reset;
input [15:0] newBTA;
output reg [15:0] out1,out2,out3,out4;

reg  [15:0] address [3:0];
integer i;

always @(posedge clk) begin

if(reset) begin
	//$display("YOP");
	for(i=0;i<4;i++)
		address[i]=16'b0;
	end
else if (BTAWr) begin
	if(in1==1)
		address[0]= newBTA;
	else if(in2==1)
		address[1]= newBTA;
	else if(in3==1)
		address[2]=newBTA;
	else if(in4==1)
		address[3]= newBTA;
	end

out1= address[0];
out2= address[1];
out3= address[2];
out4= address[3];

end

endmodule

// ****** MUX ********

module multiplexer4_2 ( in1, in2,in3,in4,sel,out);

input [15:0] in1,in2,in3,in4;
output reg [15:0] out ;


input [1:0] sel;

always @(in1 or in2 or in3 or in4) begin

case(sel)
	2'b00: out=in1;
	2'b01: out=in2;
	2'b10:out=in3;
	2'b11: out=in4;
endcase

end
endmodule


//*** Prediction BIT ********

module prediction_bit ( in1,in2,in3,in4,out1,out2,out3,out4, newPrediction, predictionWr,clk,reset);

input in1,in2,in3,in4, predictionWr,clk,reset;
input [1:0] newPrediction;
output reg [1:0] out1,out2,out3,out4;

reg  [1:0] predictions [3:0];
integer i;

always @(posedge clk) begin

if(reset) begin
	//$display("YOP");
	for(i=0;i<4;i++)
		predictions[i]=2'b00;
	end
else if (predictionWr) begin
	if(in1==1)
		predictions[0]= newPrediction;
	else if(in2==1)
		predictions[1]= newPrediction;
	else if(in3==1)
		predictions[2]= newPrediction;
	else if(in4==1)
		predictions[3]= newPrediction;
	end

out1= predictions[0];
out2= predictions[1];
out3= predictions[2];
out4= predictions[3];

end

endmodule

// ****** PredictionBIT MUX ********

module multiplexer4_2_2 ( in1, in2,in3,in4,sel,out);

input [1:0] in1,in2,in3,in4;
output reg [1:0] out ;


input [1:0] sel;

always @(in1 or in2 or in3 or in4) begin

case(sel)
	2'b00: out=in1;
	2'b01: out=in2;
	2'b10:out=in3;
	2'b11: out=in4;
endcase

end
endmodule

// TESTBENCH

module branchPredictionBuffer();

reg[1:0] pc;
wire [15:0] btaAddr;
wire [1:0] pred;


wire out1,out2,out3,out4;

wire [15:0]addr1,addr2,addr3,addr4;
reg clk,rst,BTAWr;
reg [15:0] newaddr;

wire [1:0] pred1,pred2,pred3,pred4;
reg predWr;
reg [1:0] newpred;

decoder2_4 tb(.in1_2(pc), .out1(out1), .out2(out2), .out3(out3), .out4(out4));

BTA tb2( .in1(out1) ,.in2(out2), .in3(out3), .in4(out4), .out1(addr1), .out2(addr2), .out3(addr3), .out4(addr4), .newBTA(newaddr), .BTAWr(BTAWr), .clk(clk), .reset(rst));

multiplexer4_2 tb3 ( .in1(addr1), .in2(addr2),.in3(addr3),.in4(addr4),.sel(pc),.out(btaAddr));

prediction_bit tb4( .in1(out1),.in2(out2), .in3(out3), .in4(out4), .out1(pred1), .out2(pred2), .out3(pred3), .out4(pred4), .newPrediction(newpred), .predictionWr(predWr), .clk(clk),.reset(rst));

multiplexer4_2_2 tb5 ( .in1(pred1), .in2(pred2), .in3(pred3),  .in4(pred4), .sel(pc), .out(pred));

initial begin
	clk=1;
	forever #10 clk=~clk;
end

always @(posedge clk) begin
	rst= 1;
	#40;
	rst=0;
	#10;

	$monitor("out1 = %b, out2=%b , out3=%b, out4=%b, addr1=%d , addr2= %d , addr3=%d, addr4=%d , BTA_Address_Selected=%d , pred1 = %d , pred2= %d , pred3= %d , pred4 =%d , Prediction_Made = %b", out1,out2,out3,out4,addr1,addr2,addr3,addr4,btaAddr, pred1, pred2, pred3, pred4, pred);

	$dumpfile("a.vcd");
	$dumpvars(0,branchPredictionBuffer);
	
	#20;
	pc=2'b11;
	BTAWr=1;
	newaddr= 16'd9;
	predWr=1;
	newpred=2'b01;

	#20;
	BTAWr=0;
	predWr=0;

	#30;
	pc=2'b10;
	BTAWr=1;
	newaddr= 16'd16;
	predWr=1;
	newpred=2'b01;

	#10;
	newpred=2'b11;

	#20;
	BTAWr=0;
	predWr=0;
	

	#100;
	$finish;


end

endmodule


