module adder64( inp1, inp2 , maluOp, res, clk);

input [63:0] inp1;
input [63:0] inp2;
input clk;

input maluOp;

output reg [63:0] res;

real a,b;

always @(posedge clk) begin
	a = inp1;
	b = inp2;
	if(maluOp)
		res = a + b;
	else
		res= a-b;
end

endmodule

/*
module adder_tb();

wire [63:0] rest;
reg [63:0] inp1, inp2;
reg clk;

adder64 tb(.inp1(inp1), .inp2(inp2), .maluOp(1'b1),.res(rest), .clk(clk));

initial begin
	clk=0;
	forever #10 clk =~ clk;
end
always @(posedge clk) begin
	$monitor("result = %b , %d", rest,rest);
	
	#20;

	inp1=64'd56;
	inp2= 64'd12;

	#20;
	$finish;
	
end

endmodule

*/






	