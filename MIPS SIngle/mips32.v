`timescale 1ns/100ps
module mips_32 ( pc_out ,alu_result);

//, clk
reg rst ;

reg  clk;

output reg [31:0] pc_out;
output reg [31:0] alu_result;

//CONTROL UNIT TB

reg [5:0] opcode;


wire aluSrcA, memRd, memWr, hiWr, loWr, maluOp, regDst, regWr, jump, branch, jalr;

wire [1:0] aluSrcB,hiSel, loSel;

wire [2:0] memtoReg, aluCtrl;

//wire [31:0] instr = 32'b100000_00000_00001_00010_xxxxxxxxxx;
assign regWr =1'b1;
initial begin

	rst = 1'b1;
	$display("Reset Done");
	rst=1'b0;

	pc = 32'h4;

	#10;

	clk=0;
	forever #10 clk =~ clk;

	

end


ControlUnit cu_tb (.opcode(opcode) , .aluSrcA(aluSrcA), .aluSrcB(aluSrcB), .aluCtrl(aluCtrl), .memRd(memRd), .memWr(memWr), .hiSel(hiSel), .loSel(loSel), .hiWr(hiWr), .loWr(loWr), .maluOp(maluOp), .memtoReg(memtoReg), .regDst(regDst), .regWr(regWr), .jump(jump), .branch(branch) , .jalr(jalr) ,.clk(clk));


// REGISTER FILE TB

reg [31:0] inp;
reg [4:0] rd;

wire [31:0] resA;
reg [31:0] res_Rd;
wire [31:0] resB;

reg [4:0] rs, rt,t_rs;


RegFile regfile_tb (.inp(inp), .rd(rd) , .resA(resA) , .rs(rs) , .resB(resB), .rt(rt), .regWr(regWr), .rst(rst));


// ALU TB

reg [31:0] srcA,srcB;

wire [31:0] resultA, resultB;

wire zf;

ALU alu_tb ( .src1(srcA),.src2(srcB),.aluCtrl(aluCtrl), .resultA(resultA), .resultB(resultB),.zeroFlag(zf));


// IM TB
wire [31:0] instr;

reg [31:0] pc , pc_next_seq, pc_next_beq, pc_next_j,pc_j, pc_beq,pc_rs;

reg [31:0] Hi, Lo, tempHi, tempLo;

InstMem IM_tb(.pc(pc), .instruction(instr));

// Adder64 TB

wire [63:0] resadder64;
reg [63:0] inp1adder64, inp2adder64;

adder64 add64_tb(.inp1(inp1adder64), .inp2(inp2adder64), .maluOp(maluOp),.res(resadder64),.clk(clk));

// DataMemory TB

reg [31:0] memAccessAdr ;
reg [31:0] memWriteData ;

wire [31:0] memReadData ;

DataMemory DM_tb( .memRd(memRd), .memWr(memWr), .memAccessAdr(memAccessAdr), .memWriteData(memWriteData), .memReadData(memReadData),.rst(rst));


reg[31:0] zext_shamt;
reg[31:0] sext_imm;
reg[31:0] zext_imm;
reg[31:0] upper_imm;
reg[31:0] shift_sext_imm;


//assign pc= 32'h4;

always @(posedge clk) begin
	//$display("Welcome");
	

	//$monitor(" src1  = %d , src2 =%d , aluCtrl = %d ,memRd = %d , memWr = %d , hiSel = %d , loSel = %d , hiWr =%d , loWr =%d , maluOp =%d, memtoReg = %d, regDst = %d , regWr =%d , jump= %d , branch =%d , jalr = %d ", aluSrcA,aluSrcB,aluCtrl, memRd, memWr,hiSel, loSel, hiWr, loWr, maluOp, memtoReg, regDst, regWr, jump,branch,jalr );
	
	#20;
	opcode = instr[31:26];
	zext_shamt = {{27{1'b0}}, instr[10:6]}; 
	sext_imm={{16{instr[15]}},instr[15:0]}; 
	zext_imm={{16{1'b0}},instr[15:0]};
	upper_imm={instr[15:0],{16{1'b0}}};

	if(opcode == 5'b00000)
	begin
		$display("BYE");
		$finish;

	end

	$monitor("************ instr = %b", instr);

	#10;

	$monitor("************ opcode = %b zext_shamt = %b sext_imm =%b ", opcode, zext_shamt, sext_imm);
	#10;

	$display("Control Signals Generated");

	#10;
	rs <= instr[25:21];
	rt <= instr [20:16];
	#20;


	$monitor("*** rs = %d , rt = %d,resA = %d , resB = %d ", rs,rt,resA, resB);
	$display("Reg[rs], Reg[rt] Loaded");

	#10;

	srcA = (aluSrcA==1'b1) ? zext_shamt : resA;
	//srcA= resA;

	case(aluSrcB)
		2'b00: begin srcB= resB; end
		2'b01: begin srcB = sext_imm; end
		2'b10: begin srcB = zext_imm; end
	endcase
	
	$monitor(" ALUresA = %d , ALUresB = %d , zeroFlag = %b ", resultA, resultB, zf);
	$display("ALU Calculation Done");

	#20;
	//rd<= instr[15:11];
	case (regDst)
		1'b1: rd = instr[15:11];
		1'b0: rd = rt;
		default : rd = 32'hx;
	endcase
	//rd = (regDst==1'b1)? instr[15:11] : rt ;

	memAccessAdr = resultA;
	memWriteData = resB;

	pc_next_seq = pc+ 32'd4;

	case( memtoReg)
		3'b000: begin inp = resultA; end
		3'b010: begin inp = Hi ; end
		3'b011: begin inp = Lo; end
		3'b001: begin inp = memReadData; end
		3'b100: begin inp = upper_imm; end
		3'b101: begin inp = pc_next_seq ; end
	endcase

	pc_rs= resA;
	//inp = resultA;

	$monitor("Result Stored Back in Register File at dest = %d inp = %d", rd,inp);


	inp1adder64= {Hi, Lo};
	inp2adder64= {resultA, resultB};

	
	if(maluOp)
	begin
		$monitor("inp1 = %d , inp2 = %d , resadder64 = %d ",inp1adder64, inp2adder64,resadder64);
	end		

	#20;

	case(hiSel)
		2'b00: begin tempHi = resultA; end
		2'b01: begin tempHi = resA; end
		2'b10: begin tempHi = resadder64[63:32]; end
	endcase

	if(hiWr)
		Hi = tempHi;



	case(loSel) 
		2'b00: begin tempLo = resultB; end
		2'b01: begin tempLo = resA; end
		2'b10: begin tempLo = resadder64[31:0]; end
	endcase

	if(loWr)
		Lo = tempLo;

	t_rs=rs;
	//t_resA =resA;

	rs=rd;
	$monitor("rd = %d Content of Reg[rd]= %d ",rd, res_Rd);

	res_Rd=resA;
	rs=t_rs;

	
	#10;
	$monitor("Hi = %d , Lo= %d ",Hi, Lo);

	

	if(memWr)
		$monitor("Stored %d at Memory Loc %d", resB, resultA);


	/*
	#10*/
	
	

	#10;
	
	shift_sext_imm = sext_imm <<2;
	
	
	pc_next_beq = pc_next_seq + shift_sext_imm;

	pc_next_j = {pc[31:28],shift_sext_imm[27:0]};

	pc_beq = (branch && zf)? pc_next_beq : pc_next_seq ;

	pc_j =(jump==1'b1)? pc_next_j : pc_beq;

	pc =(jalr==1'b1)? pc_rs : pc_j;

	$monitor("pc = %d", pc);

	pc_out=pc;
	alu_result= resultA;

	/*
	$dumpfile("mips_32_final_1.vcd");
	$dumpvars(0, mips_32);*/

	
	
end

endmodule

/*
module mips32_tb();

reg clk;
wire [31:0] pc_out;
wire [31:0] alu_result;

initial begin
	clk=0;
	forever #10 clk =~ clk;
end

mips_32 mipsTB(.pc_out(pc_out), .alu_result(alu_result),.clk(clk));

always @(posedge clk)
begin
	$dumpfile("mips_32_1.vcd");
	$dumpvars(0, mips32_tb);
end

endmodule

*/
