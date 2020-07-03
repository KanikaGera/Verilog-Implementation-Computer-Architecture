`timescale 1ns/100ps

module RegFile(inp, rd , resA , rs , resB, rt, regWr, rst );

input [31:0] inp;
input [4:0] rs,rt,rd;
output [31:0] resA, resB;

input regWr,rst;
integer  i;

reg [31:0] Reg [0:31];


always @(rst) begin
	Reg[0]= 32'h8;
	Reg[1]=32'h7;
	Reg[2]= 32'h4;
	Reg[3]= 32'h3;
	for(i=4;i<32;i=i+1) 
	begin
		Reg[i]= 32'h0;
	end
	Reg[7]= 32'h8; // 0 and 7 are same
	Reg[15]= 32'd100;
end

assign resA = Reg[rs];
assign resB = Reg[rt];

always @(*) begin
	if(regWr==1'b1)
		Reg[rd]= inp;
end


endmodule

/*
module reg_tb();

reg [31:0] inp;
reg [4:0] rd;

wire [31:0] resA;
wire [31:0] resB;

reg [4:0] rs, rt;
reg rst , regWr;



RegFile tb (.inp(inp), .rd(rd) , .resA(resA) , .rs(rs) , .resB(resB), .rt(rt), .regWr(regWr), .rst(rst));

initial begin
	rs = 5'b00000;
	#10;
	rst = 1'b1;
	#10;
	regWr= 1'b1;
	rd= 5'b00001;
	inp = 32'h7;
	
end

always @(*) begin
	$display("Reset Done");
    $monitor(" resA = %d , resB = %d ", resA, resB);

    rst = 1'b0;
	rs = 5'b00000;
	#5;

	
	
	#10;


	rs= 5'b00000;
	rt= 5'b00001;
	#20;

	//$monitor("*** resA = %d , resB = %d ", resA, resB);


		
end

endmodule

*/








