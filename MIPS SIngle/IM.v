module InstMem( pc, instruction);

input [31:0] pc;
output reg [31:0] instruction;

wire [4:0] rom_addr = pc >>2;
reg [31:0] rom [31:0];

initial 
begin
	rom[0]  = 32'h0;
	rom[1]  = 32'b100000_00000_00001_00100_00010_xxxxxx;   // add
	rom[2]  = 32'b100001_00000_00001_00100_xxxxxxxxxxx;   //sub
	rom[3]  = 32'b100011_00000_00001_xxxxx_xxxxxxxxxxx;   //div
	rom[4]  = 32'b100010_00000_00001_xxxxx_xxxxxxxxxxx;   //mul
	rom[5]  = 32'b100100_00010_00011_xxxxx_xxxxxxxxxxx;   // madd 
	rom[6]  = 32'b100101_00011_00011_xxxxx_xxxxxxxxxxx;   //msub
	rom[7]  = 32'b100110_xxxxx_00010_00100_00010_xxxxxx;  //sll rt store in rd
	rom[8]  = 32'b100111_xxxxx_xxxxx_00100_xxxxx_xxxxxx;  // mfhi rd
	rom[9]  = 32'b101000_xxxxx_xxxxx_00100_xxxxx_xxxxxx;  //mflo rd
	rom[10] = 32'b101001_00000_xxxxx_xxxxx_xxxxx_xxxxxx;  // mthi
	rom[11] = 32'b101010_00000_xxxxx_xxxxx_xxxxx_xxxxxx;  //mtlo

	rom[12] = 32'b000001_00000_00100_00000_00000_000100;  // addi rs =0 rt =4 imm = 4
	rom[13] = 32'b000010_00000_00100_00000_00000_000111;  // ori
	rom[14] = 32'b000110_00000_00001_00000_00000_000100;  // sw store Reg[rt] at Reg[rs]+sext(Imm)
	rom[15] = 32'b000101_00000_00101_00000_00000_000100;  // lw load Reg[rs]+sext(Imm) at rt
	rom[16] = 32'b000011_xxxxx_00110_00000_00000_000001;  // lui imm:16'b0 to Reg[rt]
	rom[17] = 32'b000100_00000_00111_00000_00000_000010;  // beq when taken. imm= 2 pc=pc+4 + 8 => rom= rom+1+2 
	rom[18] = 32'h0;
	rom[19] = 32'h0;
	rom[20] = 32'b100000_00000_00001_00100_00010_xxxxxx;  // Branch Taken => add instr
	rom[21] = 32'b000100_00000_00001_00000_00000_000010;   // beq when not taken
	rom[22] = 32'b000111_xxxxx_xxxxx_00000_00000_011101; //j to 29
	rom[23] = 32'h0;
	rom[24] = 32'b100000_00000_00001_00100_00010_xxxxxx;  // Branch to be Taken => add instr;	
	rom[25] = 32'b100010_00000_00001_xxxxx_xxxxxxxxxxx;   // jalr to this instr mul
	rom[26] = 32'h0;
	rom[27] = 32'h0;
	rom[28] = 32'h0;
	rom[29] = 32'b100001_00000_00001_00100_00010_xxxxxx;  // jump to be Taken => sub instr;
	rom[30] = 32'b001000_01111_xxxxx_10000_xxxxx_xxxxxx; //jalr to 25 . 25*4= 100 is stored in Reg[15] . store pc+4 in Reg[16] 
	rom[31] = 32'h0;
end

always @(*) begin
	instruction = rom[rom_addr]; 
end

endmodule

/*
module inst_tb ();

reg [31:0] pc = 32'h4;
wire [31:0] instr;
wire [4:0] rom_addr = pc >>2;

InstMem tb3(.pc(pc), .instruction(instr));

always @(pc) begin
	$monitor("rom_addr = %b , Instr = %b" ,rom_addr, instr);
	#10;
	pc = pc+ 32'h4;
	
	$finish;
end

endmodule

*/

