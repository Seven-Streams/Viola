module ROB(
        input wire clk,
        input wire has_imm,
        input wire[31:0] imm,
        input wire[4:0] rd,
        input wire[4:0] op,
        input wire [31:0] value1_rf,
        input wire [31:0] value2_rf,
        input wire [2:0] query1_rf,
        input wire [2:0] query2_rf,
        input wire rs_full,
        input wire[2:0] alu_num,
        input wire[31:0] alu_value,
        input wire[2:0] mem_num,
        input wire[31:0] mem_value,
        input wire[2:0] ready_load_num,
        output reg rob_full,
        output reg[4:0] op_out,
        output reg[31:0] value1_out,
        output reg[31:0] value2_out,
        output reg[2:0] query1_out,
        output reg[2:0] query2_out,
        output reg commit,
        output reg[4:0] rd_out,
        output reg[2:0] num_out,
        output reg[31:0] value_out,
        output reg ls_commit,
        output reg[2:0] ls_num_out
    );
    reg [2:0] head;
    reg [2:0] tail;
    reg to_shoot;
    reg [4:0] rob_op[7:0];
    reg [4:0] rob_rd[7:0];
    reg [0:0]rob_busy[7:0];
    reg [1:0]rob_ready[7:0];//00 executing, 01 can be load_store committed, 11/10, can be committed.
    reg new_has_imm;
    reg [31:0]rob_value[7:0];
    reg [4:0] new_op;
    reg [4:0] new_rd;
    reg [31:0] new_value;
    initial begin
        new_has_imm = 0;
        head = 1;
        tail = 2;
        rob_full = 0;
        to_shoot = 0;
        commit = 0;
        ls_commit = 0;
        op_out = 5'b11111;
    end
    localparam [4:0]
               ADD = 5'b00000,
               AND = 5'b00001,
               OR  = 5'b00010,
               SLL = 5'b00011,
               SRL = 5'b00100,
               SLT  = 5'b00101,
               SLTU = 5'b00110,
               SRA = 5'b00111,
               SUB = 5'b01000,
               XOR = 5'b01001,
               BEQ  = 5'b01010,
               BGE  = 5'b01011,
               BNE = 5'b01100,
               BGEU = 5'b01101,
               LUI = 5'b01110,
               AUIPC = 5'b01111,
               JAL = 5'b10000,
               JALR = 5'b10001,
               LB = 5'b10010,
               LH = 5'b10011,
               LW = 5'b10100,
               LBU = 5'b10101,
               LHU = 5'b10110,
               SB = 5'b10111,
               SH = 5'b11000,
               SW = 5'b11001,
               BLT = 5'b11010,
               BLTU = 5'b11011;

    always@(posedge clk) begin
        if(op != 5'b11111) begin
            new_op <= op;
            new_has_imm <= has_imm;
            new_rd <= rd;
            new_value <= imm;
            to_shoot <= 1;
        end
        else begin
            to_shoot <= 0;
        end
        if(alu_num != 0) begin
            rob_value[alu_num] <= alu_value;
            rob_ready[alu_num] <= 2'b11;
        end
        if(mem_num != 0) begin
            rob_value[mem_num] <= mem_value;
            rob_ready[mem_num] <= 2'b11;
        end
        if(ready_load_num != 0) begin
            rob_ready[ready_load_num] <= 2'b01;
        end
    end

    always@(negedge clk) begin
        if(head == 0) begin
            head = 1;
        end
        if(tail == 0) begin
            tail = 1;
        end
        rob_full <= (head == (tail + 1));
        if(to_shoot) begin
            rob_op[tail] <= new_op;
            rob_rd[tail] <= new_rd;
            rob_ready[tail] <= 0;
            tail <= tail + 1;
            value1_out <= value1_rf;
            query1_out <= query1_rf;
            if(new_has_imm) begin
                value2_out <= new_has_imm;
                query2_out <= 0;
            end
            else begin
                value2_out <= value2_rf;
                query2_out <= query2_rf;
            end
        end
        if(rob_ready[head] == 2'b01) begin
            ls_commit <= 1;
            ls_num_out <= head;
        end
        else begin
            ls_commit <= 0;
        end
        if(rob_ready[head] == 2'b11) begin
            if(rob_rd[head != 0]) begin
                commit <= 1;
                rd_out <= rob_rd[head];
                value_out <= rob_value[head];
                num_out <= head;
            end
            head <= head + 1;
        end
        else begin
            commit <= 0;
        end
    end
endmodule
