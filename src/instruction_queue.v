module IQ(
        input wire clk,
        input wire[4:0] op,
        input wire[4:0] rs1,
        input wire[4:0] rs2,
        input wire[4:0] rd,
        input wire[31:0] imm,
        input wire rob_full,
        output reg iq_full,
        output reg[4:0] op_out,
        output reg[4:0] rs1_out,
        output reg[4:0] rs2_out,
        output reg[4:0] rd_out,
        output reg[31:0] imm_out
    );
    reg [4:0] op_buffer[15:0];
    reg [4:0] rs1_buffer[15:0];
    reg [4:0] rs2_buffer[15:0];
    reg [0:0] busy[15:0];
    reg [4:0] rd_buffer[15:0];
    reg [31:0] imm_buffer[15:0];
    reg [3:0] head;
    reg [3:0] tail;

    initial begin
        head = 0;
        tail = 1;
        busy[0] = 0;
        busy[1] = 0;
        busy[2] = 0;
        busy[3] = 0;
        busy[4] = 0;
        busy[5] = 0;
        busy[6] = 0;
        busy[7] = 0;
        busy[8] = 0;
        busy[9] = 0;
        busy[10] = 0;
        busy[11] = 0;
        busy[12] = 0;
        busy[13] = 0;
        busy[14] = 0;
        busy[15] = 0;
        iq_full = 0;
    end

    always@(posedge clk) begin
      if(op != 5'b11111) begin
          op_buffer[tail] <= op;
          rs1_buffer[tail] <= rs1;
          rs2_buffer[tail] <= rs2;
          rd_buffer[tail] <= rd;
          imm_buffer[tail] <= imm;
          busy[tail] <= 1;
          tail <= tail + 1;
      end
    end
    
    always@(negedge clk) begin
      iq_full <= (head == (tail + 1));
      if((rob_full == 0)&&(busy[head] == 1)) begin
          op_out <= op_buffer[head];
          rs1_out <= rs1_buffer[head];
          rs2_out <= rs2_buffer[head];
          rd_out <= rd_buffer[head];
          imm_out <= imm_buffer[head];
          busy[head] <= 0;
          head <= head + 1;
      end
    end
endmodule
