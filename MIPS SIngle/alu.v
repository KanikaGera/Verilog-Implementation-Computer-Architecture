`timescale 1ns/100ps

module ALU ( src1,src2,aluCtrl, resultA, resultB,zeroFlag);

input [31:0] src1;
input [31:0] src2 ; 
input [2:0] aluCtrl ;
output  [31:0] resultA ;
output  [31:0] resultB ;
reg [63:0] resultTemp;
output  zeroFlag;

integer in1, in2, outA,outB;


`define ADDc 3'b000
`define SUBc 3'b001
`define MULc 3'b010
`define DIVc 3'b011
`define SHIFTc 3'b100
`define ORc 3'b101

always @(*)
	begin
		in1= src1;
		in2= src2;
		case( {aluCtrl} )
		`ADDc: 
			begin 
			outA = in1+ in2;
			outB = 0;
			end
		`ORc: 
			begin 
			outA = in1 | in2;
			outB =0;
			end
		`SUBc: 
			begin 
			outA = in1- in2;
			outB =0;
			end
		`MULc: 
			begin 
			resultTemp = in1* in2;
			outA = resultTemp[63:32];
			outB = resultTemp[31:0];
			end
		`DIVc:
			begin 
			outA= in1/ in2;
			outB = in1 % in2;
			end
		`SHIFTc: 
			begin 
			outA= in2 << in1;
			outB =0;
			end
		default: 
			begin
				outA = 0;
				outB =0;
			end
		endcase

	end
assign zeroFlag = ((in1==in2 && aluCtrl==`SUBc)?1'b1:1'b0);
assign resultA=outA;
assign resultB=outB;
endmodule

/*
module alu_tb ();

reg [31:0] src1,src2;
reg [2:0] aluCtrl;
wire [31:0] resA, resB;

wire zf;

ALU tb ( .src1(src1),.src2(src2),.aluCtrl(aluCtrl), .resultA(resA), .resultB(resB),.zeroFlag(zf));

always @(*) begin
	$monitor(" resA = %d , resB = %d , zeroFlag = %b ", resA, resB, zf);
	#20;
	src1= 32'h0000_0007;
	src2= 32'h000_0002;
	aluCtrl= 3'b000;

	#20;
	aluCtrl = 3'b001;

	#20;
	aluCtrl= 3'b010;

	#20;
	aluCtrl = 3'b011;

	#20;
	aluCtrl = 3'b100; //Shift

	#20;
	aluCtrl = 3'b101;

	$finish;
end

endmodule
*/


