`timescale 1ns/100ps
module DataMemory( memRd, memWr, memAccessAdr, memWriteData, memReadData,rst);

input memRd;
input memWr;
input rst;

input [31:0] memAccessAdr ;
input [31:0] memWriteData ;

output reg [31:0] memReadData ;

integer i;
reg [31:0] ram [255:0]; //byte addressable = 8 bits 

wire [7:0] ram_addr = memAccessAdr >> 2; //divides by 4

always @(rst) begin
	for(i=0;i<256;i=i+1)
		ram[i] <= 32'h00000000;
end

always @(memWr) begin
		ram[ram_addr] = memWriteData;
end

always @(memRd) begin
         memReadData = ram[ram_addr];
end

endmodule

/*
module dm_tb();

reg memRd;
reg memWr;


reg [31:0] memAccessAdr ;
reg [31:0] memWriteData ;

wire [31:0] memReadData ;



DataMemory tb1( .memRd(memRd), .memWr(memWr), .memAccessAdr(memAccessAdr), .memWriteData(memWriteData), .memReadData(memReadData),.rst(1'b0));
reg clk;

initial begin
    clk=0;
    forever #10 clk=~clk;
end

always @(posedge clk) begin
    memWr=1'b1;
    memAccessAdr = 32'h4;
    memWriteData = 32'hb;
        $monitor("Stored in DataMemory");
    #20;
    memWr=1'b0;
    memRd= 1'b1;
        $monitor("Reading DataMemory at Addr = %d Val =%d", memAccessAdr, memReadData);
    $finish;
    
end

endmodule

*/



