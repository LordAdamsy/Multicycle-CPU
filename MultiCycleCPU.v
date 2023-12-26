`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: MultiCycleCPU
// Project Name: Multi-cycle-cpu
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module MultiCycleCPU (reset, clk);
    //Input Clock Signals
    input reset;
    input clk;
    
    wire [31:0] PC_in;
    wire [31:0] PC;
    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] func;
    wire PCWrite;
    wire PCWriteCond;
    wire IorD;
    wire MemWrite;
    wire MemRead;
    wire IRWrite;
    wire [1:0] MemtoReg;
    wire [1:0] RegDst;
    wire RegWrite;
    wire ExtOp;
    wire LuiOp;
    wire [1:0] ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [3:0] ALUOp;
    wire [1:0] PCSource;
    wire [31:0] address;
    wire [31:0] Write_data;
    wire [31:0] Mem_data;
    wire [31:0] Read_data1;
    wire [31:0] Read_data2;
    wire [31:0] ImmExtOut;
    wire [31:0] ImmExtShift;
    wire [4:0] ALUConf;
    wire Sign;
    wire [31:0] In1;
    wire [31:0] In2;
    wire Zero;
    wire [31:0] Result;
    wire [31:0] MDR_o;
    wire [31:0] A_o;
    wire [31:0] B_o;
    wire [31:0] ALUOut_o;
    wire [4:0] Write_register;
    wire signal;
    
    Controller Controller_1(reset,clk,opcode,func,PCWrite,PCWriteCond,IorD,MemWrite,MemRead,IRWrite,MemtoReg,RegDst,RegWrite,ExtOp,LuiOp,ALUSrcA,ALUSrcB,ALUOp,PCSource);
    PC PC_1(reset,clk,signal,PC_in,PC);
    InstAndDataMemory I_1(reset,clk,address,B_o,MemRead,MemWrite,Mem_data);
    InstReg I_2(reset, clk, IRWrite, Mem_data,opcode, rs, rt, rd, shamt, func);
    RegisterFile R_1(reset, clk, RegWrite, rs, rt, Write_register, Write_data, Read_data1, Read_data2);
    ImmProcess I_3(ExtOp, LuiOp, {rs,rt,rd,shamt,func}, ImmExtOut, ImmExtShift);
    ALUControl A_1(ALUOp, func, ALUConf, Sign);
    ALU A_2(ALUConf, Sign, In1, In2, Zero, Result);

    //声明寄存器
    RegTemp MDR(reset,clk,Mem_data,MDR_o);
    RegTemp A(reset,clk,Read_data1,A_o);
    RegTemp B(reset,clk,Read_data2,B_o);
    RegTemp ALUOut(reset,clk,Result,ALUOut_o);
    
    //端口连接
    assign address=IorD?ALUOut_o:PC;
    assign signal=(PCWriteCond&&Zero)||PCWrite;
    assign Write_register=(RegDst==2'b01)?rd:(RegDst==2'b00)?rt:5'd30;
    assign Write_data=(MemtoReg==2'b01)?MDR_o:((MemtoReg==2'b00)?ALUOut_o:PC);
    assign In1=(ALUSrcA==2'b00)?A_o:(ALUSrcA==2'b01)?PC:(ALUSrcA==2'b11)?shamt:32'b0;
    assign In2=(ALUSrcB==2'b00)?B_o:(ALUSrcB==2'b01)?32'd4:(ALUSrcB==2'b11)?ImmExtShift:(ALUSrcB==2'b10)?ImmExtOut:32'b0;
    assign PC_in=(PCSource==2'b00)?Result:(PCSource==2'b01)?ALUOut_o:(PCSource==2'b10)?{PC[31:28],{rs,rt,rd,shamt,func}<<2}:(PCSource==2'b11)?A_o:32'b0;

endmodule