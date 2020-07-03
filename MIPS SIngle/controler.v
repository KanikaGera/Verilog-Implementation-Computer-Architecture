`timescale 1ns/100ps

module ControlUnit (opcode , aluSrcA, aluSrcB, aluCtrl, memRd, memWr, hiSel, loSel, hiWr, loWr, maluOp, memtoReg, regDst, regWr, jump, branch , jalr ,clk);

input [5:0] opcode;
input clk;

output aluSrcA, memRd, memWr, hiWr, loWr, maluOp, regWr, jump, branch, jalr;

output reg regDst;
output reg [1:0] aluSrcB,hiSel, loSel;

output reg [2:0] memtoReg, aluCtrl;

`define ADD  6'b100000
`define SUB  6'b100001 
`define MUL   6'b100010
`define DIV  6'b100011
`define MADD  6'b100100
`define MSUB  6'b100101
`define SLL  6'b100110
`define MFHI  6'b100111
`define MFLO 6'b101000
`define MTHI 6'b101001 
`define MTLO 6'b101010 

`define ADDI 6'b000001
`define ORI 6'b000010
`define LUI 6'b000011 
`define BEQ  6'b000100
`define LW   6'b000101
`define SW   6'b000110

`define J    6'b000111
`define JALR  6'b001000

//****** DEFINING ALUCTRL SIGNALS ********//

`define ADDc 3'b000
`define SUBc 3'b001
`define MULc 3'b010
`define DIVc 3'b011
`define SHIFTc 3'b100
`define ORc 3'b101

assign aluSrcA = (opcode == `SLL);

always @(clk)
begin
	if(opcode== `ADDI || opcode ==`LW || opcode == `SW) begin
		aluSrcB = 2'b01;
		aluCtrl = `ADDc ;
		end
	else if (opcode == `ORI) begin
		aluSrcB =2'b10;
		aluCtrl = `ORc;
		end
	else begin
		aluSrcB =2'b00;

		if (opcode == `SLL) 
			aluCtrl = `SHIFTc;

		else if (opcode == `BEQ || opcode == `SUB)
			aluCtrl = `SUBc;

		else if (opcode == `ADD)
			aluCtrl = `ADDc;

		else if (opcode == `MUL || opcode == `MADD || opcode == `MSUB)
			aluCtrl = `MULc;

		else if (opcode == `DIV)
			aluCtrl = `DIVc;

		else
			aluCtrl =3'bxxx;
		end
end

assign memRd = (opcode==`LW);
assign memWr = (opcode == `SW);

always @(clk)
begin
	if (opcode == `MTHI) begin
		hiSel = 2'b01;
		loSel = 2'bxx;
		
	end
	else if ( opcode == `MTLO) begin
		loSel = 2'b01;
		hiSel = 2'bxx;
		
	end
	else if (opcode == `MADD || opcode == `MSUB) begin
		hiSel = 2'b10;
		loSel = 2'b10;
		
	end
	else begin
		hiSel = 2'b00;
		loSel =2'b00;
		
	end
end

assign hiWr = (opcode == `MUL || opcode ==`DIV || opcode == `MADD || opcode == `MSUB || opcode == `MTHI);

assign loWr = (opcode == `MUL || opcode ==`DIV || opcode == `MADD || opcode == `MSUB || opcode == `MTLO);

assign maluOp = (opcode == `MADD); //MADD =1 MSUB=0 else dont care

//assign regDst  = 

always @(clk) begin
	if(opcode==`MTHI || opcode== `MTLO || opcode== `SW || opcode== `BEQ || opcode== `J || opcode== `MUL || opcode== `MADD || opcode== `MSUB || opcode== `DIV)
		regDst = 1'bx;
	else if (opcode==`ADD || opcode==`SUB || opcode == `JALR || (opcode == `SLL) || (opcode == `MFHI)|| (opcode==`MFLO) )
		regDst = 1'b1;
	else
		regDst = 1'b0;
end

assign regWr = ! (opcode == `MTLO || opcode == `MTHI || opcode ==`SW || opcode ==`BEQ || opcode ==`J || opcode ==`MUL ||opcode == `DIV ||opcode == `MADD || opcode ==`MSUB);

assign jump = (opcode== `J);

assign branch = (opcode == `BEQ);

assign jalr = (opcode == `JALR);

always @(clk) begin
	if(opcode == `MFHI)
	  memtoReg = 3'b010;
	else if (opcode == `MFLO)
		memtoReg = 3'b011;
	else if (opcode == `LW)
		memtoReg = 3'b001;
	else if (opcode == `LUI)
		memtoReg = 3'b100;
	else if (opcode == `JALR)
		memtoReg =3'b101;
	else
		memtoReg = 3'b000;
end

endmodule

/*
module ctrl_tb();

reg [5:0] opcode;
reg clk;

wire src1, memRd, memWr, hiWr, loWr, maluOp, regDst, regWr, jump, branch, jalr;

wire [1:0] src2,hiSel, loSel;

wire [2:0] memtoReg, aluCtrl;

initial begin
	clk=0;
	forever #10 clk =~ clk;
end


ControlUnit tb (.opcode(opcode) , .aluSrcA(src1), .aluSrcB(src2), .aluCtrl(aluCtrl), .memRd(memRd), .memWr(memWr), .hiSel(hiSel), .loSel(loSel), .hiWr(hiWr), .loWr(loWr), .maluOp(maluOp), .memtoReg(memtoReg), .regDst(regDst), .regWr(regWr), .jump(jump), .branch(branch) , .jalr(jalr) ,.clk(clk));




always @(*) begin

	$display("Welcome");

	$monitor(" src1  = %d , src2 =%d , aluCtrl = %d ,memRd = %d , memWr = %d , hiSel = %d , loSel = %d , hiWr =%d , loWr =%d , maluOp =%d, memtoReg = %d, regDst = %d , regWr =%d , jump= %d , branch =%d , jalr = %d ", src1,src2,aluCtrl, memRd, memWr,hiSel, loSel, hiWr, loWr, maluOp, memtoReg, regDst, regWr, jump,branch,jalr );

	#20;

	opcode = 6'b100000;

	#20;

	opcode = 6'b100001;

	#20;

	$finish;

 end

 endmodule
 */






