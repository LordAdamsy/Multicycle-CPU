`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: Controller
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


module Controller(reset, clk, OpCode, Funct, 
                PCWrite, PCWriteCond, IorD, MemWrite, MemRead,
                IRWrite, MemtoReg, RegDst, RegWrite, ExtOp, LuiOp,
                ALUSrcA, ALUSrcB, ALUOp, PCSource);
                
    //Input Clock Signals
    input reset;
    input clk;
    //Input Signals
    input  [5:0] OpCode;
    input  [5:0] Funct;
    //Output Control Signals
    output reg PCWrite;
    output reg PCWriteCond;
    output reg IorD;
    output reg MemWrite;
    output reg MemRead;
    output reg IRWrite;
    output reg [1:0] MemtoReg;
    output reg [1:0] RegDst;
    output reg RegWrite;
    output reg ExtOp;
    output reg LuiOp;
    output reg [1:0] ALUSrcA;
    output reg [1:0] ALUSrcB;
    output reg [3:0] ALUOp;
    output reg [1:0] PCSource;
      
    reg [2:0] state;
    parameter [2:0] sIF=5'd0;
    parameter [2:0] sID=5'd1;
    parameter [2:0] sEX=5'd2;
    parameter [2:0] sMEM=5'd3;
    parameter [2:0] sWB=5'd4;
    parameter [2:0] s_0=5'd5;

    //--------------Your code below-----------------------
    
    always @(posedge reset or posedge clk) begin
       if(reset)begin
         state<=s_0;
         PCSource<=1'b00;
         PCWriteCond<=1'b0;
         IorD<=1'b0;
         MemWrite<=1'b0;
         MemRead<=1'b0;
         IRWrite<=1'b0;
         MemtoReg<=2'b00;
         RegDst<=2'b00;
         RegWrite<=1'b0;
         ExtOp<=1'b0;
         LuiOp<=1'b0;
         ALUSrcA<=1'b00;
         ALUSrcB<=2'b00;
         ALUOp<=3'b000;
       end
       
       else begin
       case(state)
       s_0:begin
         state<=sIF;
         end
       
       
       sIF:begin
         PCSource<=2'b00; 
           PCWrite<=1'b1;
         IRWrite<=1'b1;
         MemRead<=1'b1; 
         if(RegWrite==1'b1)
           RegWrite<=1'b0;
         if(MemWrite==1'b1)
             MemWrite<=1'b0;
         if(PCWriteCond==1'b1)
           PCWriteCond<=1'b0;
         ALUSrcA<=2'b01;
         IorD<=1'b0;
         ALUSrcB<=2'b01;
         state<=sID;
         end
       
       sID:begin
         MemRead<=1'b0;
          if(MemWrite==1'b1)
           MemWrite<=1'b0;
          if(IRWrite==1'b1)
             IRWrite<=1'b0;
          if(PCWrite==1'b1)
           PCWrite<=1'b0;
          if(RegWrite==1'b1)
           RegWrite<=1'b0;
         if(PCWriteCond==1'b1)
           PCWriteCond<=1'b0;
         ALUSrcA<=2'b01;
         ALUSrcB<=2'b11;
         state<=sEX;
         end
         
       sEX:begin
          if(PCWrite==1'b1)
            PCWrite<=1'b0;
          if(MemWrite==1'b1)
            MemWrite<=1'b0;
          if(MemRead==1'b1)
              MemRead<=1'b0;
          if(IRWrite==1'b1)
            IRWrite<=1'b0;
          if(RegWrite==1'b1)
            RegWrite<=1'b0;
          if(PCWriteCond==1'b1)
            PCWriteCond<=1'b0;
          if(OpCode==6'd0&&Funct!=6'h0&&Funct!=6'h02&&Funct!=6'h03&&Funct!=6'h08&&Funct!=6'h09)begin//R指令
            ALUSrcA<=2'b00;
            ALUSrcB<=2'b00;
            state<=sMEM;
            end
          else if(OpCode==6'h04)begin//BEQ指令
            ALUSrcA<=2'b00;
            ALUSrcB<=2'b00;
            PCWriteCond<=1'b1;
            PCSource<=2'b01;
            state<=sIF;
            end
          else if(OpCode==6'h02)begin//j指令
            PCWrite<=1'b1;
            PCSource<=2'b10;
            state<=sIF;
            end
          else if(OpCode==6'h03)begin//jal指令
              PCWrite<=1'b1;
              PCSource<=2'b10;
              RegDst<=2'b11;
              MemtoReg<=2'b11;
              RegWrite<=1'b1;
              state<=sIF;
              end
          else if(OpCode==6'h23||OpCode==6'h2b)begin//lw或sw指令
            ALUSrcA<=2'b00;
            ALUSrcB<=2'b10;
            LuiOp<=1'b0;
            ExtOp<=1'b1;
            state<=sMEM;
            end
          else if(OpCode==6'h0f)begin//lui指令
            ALUSrcB<=2'b10;
            ALUSrcA<=2'b00;
            LuiOp<=1'b1;
            ExtOp<=1'b1;
            state<=sMEM;
            end
          else if(OpCode==6'h08||OpCode==6'h0c||OpCode==6'h0a||OpCode==6'h0b)begin//其他i指令且需要符号拓展
            ALUSrcB<=2'b10;
            ALUSrcA<=2'b00;
            LuiOp<=1'b0;
            ExtOp<=1'b1;
            state<=sMEM;
            end
          else if(OpCode==6'h09)begin//其他i指令且需要无符号拓展
              ALUSrcB<=2'b10;
              ALUSrcA<=2'b00;
              LuiOp<=1'b0;
              ExtOp<=1'b0;
              state<=sMEM;
              end
          else if(OpCode==6'h0&&(Funct==6'h0||Funct==6'h2||Funct==6'h3))begin//sll,sra,srl指令
            ALUSrcB<=2'b00;
            ALUSrcA<=2'b11;
            state<=sMEM;
            end
          else if(OpCode==6'h0&&Funct==6'h08)begin//jr指令
            PCWrite<=1'b1;
            PCSource<=2'b11;
            state<=sIF;
            end
          else if(OpCode==6'h0&&Funct==6'h09)begin//jalr指令
            PCWrite<=1'b1;
            PCSource<=2'b11;
            ALUSrcA<=2'b01;
            ALUSrcB<=2'b01;
            state<=sMEM;
            end
         end
         
         sMEM:begin
          if(PCWrite==1'b1)
           PCWrite<=1'b0;
         if(MemWrite==1'b1)
           MemWrite<=1'b0;
          if(MemRead==1'b1)
             MemRead<=1'b0;
         if(IRWrite==1'b1)
           IRWrite<=1'b0;
         if(RegWrite==1'b1)
           RegWrite<=1'b0;
         if(PCWriteCond==1'b1)
           PCWriteCond<=1'b0;
           if(OpCode==6'd0&&Funct!=6'h0&&Funct!=6'h02&&Funct!=6'h03&&Funct!=6'h08&&Funct!=6'h09)begin//R指令
             RegWrite<=1'b1;
             RegDst<=2'b01;
             MemtoReg<=2'b00;
             state<=sIF;
           end           
           else if(OpCode==6'h2b)begin//sw指令
             MemWrite<=1'b1;
             IorD<=1'b1;
             state<=sIF;
            end
            else if(OpCode==6'h23)begin//lw指令
              MemRead<=1'b1;
              IorD<=1'b1;
              state<=sWB;
            end
            else if(OpCode==6'h0f)begin//lui指令
              RegDst<=2'b00;
              MemtoReg<=2'b00;
              RegWrite<=1'b1;
              state<=sIF;
            end
            else if(OpCode==6'h08||OpCode==6'h09||OpCode==6'h0c||OpCode==6'h0a||OpCode==6'h0b)begin//其他i指令
              RegDst<=2'b00;
              MemtoReg<=2'b00;
              RegWrite<=1'b1;
              state<=sIF;
            end
            else if(OpCode==6'h0&&(Funct==6'h0||Funct==6'h2||Funct==6'h3))begin//sll,sra,srl指令
              RegWrite<=1'b1;
              RegDst<=2'b01;
              MemtoReg<=2'b00;
              state<=sIF;
            end
            else if(OpCode==6'h0&&Funct==6'h09)begin//jalr指令
              RegWrite<=1'b1;
              RegDst<=2'b01;
              MemtoReg<=2'b00;
              state<=sIF;
            end
          end
          
          sWB:begin
          if(PCWrite==1'b1)
            PCWrite<=1'b0;
          if(MemRead==1'b1)
              MemRead<=1'b0;
          if(MemWrite==1'b1)
            MemWrite<=1'b0;
          if(IRWrite==1'b1)
            IRWrite<=1'b0;
          if(RegWrite==1'b1)
            RegWrite<=1'b0;
          if(PCWriteCond==1'b1)
            PCWriteCond<=1'b0;
             if(OpCode==6'h23)begin//lw指令
               RegWrite<=1'b1;
               RegDst<=2'b00;
               MemtoReg<=2'b01;
               state<=sIF;
             end
           end
         endcase
       end
     end

    //--------------Your code above-----------------------


    //ALUOp
    always @(*) begin
        ALUOp[3] = OpCode[0];
        if (state == sIF || state == sID) begin
            ALUOp[2:0] = 3'b000;
        end else if (OpCode == 6'h00&&Funct!=6'h2f) begin 
            ALUOp[2:0] = 3'b010;
        end else if (OpCode == 6'h04) begin
            ALUOp[2:0] = 3'b001;
        end else if (OpCode == 6'h00 &&Funct==6'h2f) begin
            ALUOp[2:0] = 3'b111;
        end else if (OpCode == 6'h0c) begin
            ALUOp[2:0] = 3'b100;
        end else if (OpCode == 6'h0a || OpCode == 6'h0b) begin
            ALUOp[2:0] = 3'b101;
        end else begin
            ALUOp[2:0] = 3'b000;
        end
    end

endmodule