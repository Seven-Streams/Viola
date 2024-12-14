module IQ(
        input wire clk,
        input wire rst,
        input wire[4:0] op,
        input wire[4:0] rs1,
        input wire[4:0] rs2,
        input wire[4:0] rd,
        input wire[31:0] imm,
        input wire has_imm,
        input wire rs_full,
        input wire rob_full,
        output reg iq_full,
        output reg[4:0] op_out,
        output reg[4:0] rs1_out,
        output reg[4:0] rs2_out,
        output reg[4:0] rd_out,
        output reg[31:0] imm_out,
        output reg has_imm_out,
        output reg shooted,
        output reg [4:0] op_tmp,
        output reg [4:0] rs1_tmp,
        output reg [4:0] rs2_tmp,
        output reg [4:0] rd_tmp,
        output reg [31:0] imm_tmp,
        output reg has_imm_tmp
    );
    reg [4:0] op_buffer[15:0];
    reg [4:0] rs1_buffer[15:0];
    reg [4:0] rs2_buffer[15:0];
    reg [0:0] busy[15:0];
    reg [4:0] rd_buffer[15:0];
    reg [31:0] imm_buffer[15:0];
    reg [0:0] has_imm_buffer[15:0];
    reg [3:0] head;
    reg [3:0] tail;
    reg add;
    reg [4:0]last;
    reg [4:0]cnt;
    integer init;
    initial begin
        op_tmp = 5'b11111;
        cnt = 0;
        rs1_tmp = 0;
        rs2_tmp = 0;
        rd_tmp = 0;
        imm_tmp = 0;
        has_imm_tmp = 0;
        for(init = 0; init < 16; init = init + 1) begin
            op_buffer[init] = 5'b11111;
            rs1_buffer[init] = 0;
            rs2_buffer[init] = 0;
            rd_buffer[init] = 0;
            imm_buffer[init] = 0;
            has_imm_buffer[init] = 0;
            busy[init] = 0;
        end
        shooted = 0;
        head = 0;
        tail = 0;
        op_out = 5'b11111;
        iq_full = 0;
        cnt = 0;
        add = 0;
        iq_full = 0;
        op_out = 5'b11111;
        rs1_out = 0;
        rs2_out = 0;
        rd_out = 0;
        imm_out = 0;
        has_imm_out = 0;
        shooted = 0;
        op_tmp = 5'b11111;
        rs1_tmp = 0;
        rs2_tmp = 0;
        rd_tmp = 0;
        imm_tmp = 0;
        has_imm_tmp = 0;
    end
    always@(posedge clk) begin
        add = 0;
        if(!rst) begin
            if(op != 5'b11111) begin
                op_buffer[tail] <= op;
                last = tail;
                rs1_buffer[tail] <= rs1;
                rs2_buffer[tail] <= rs2;
                rd_buffer[tail] <= rd;
                imm_buffer[tail] <= imm;
                has_imm_buffer[tail] <= has_imm;
                tail <= tail + 1;
                add = 1;
            end
        end else begin
          tail = 0;
        end
    end

    always@(negedge clk) begin
        cnt = cnt + add;
        if(add == 1) begin
            busy[last] = 1;
        end
        iq_full = (cnt >= 15);
        if(!rst) begin
            op_out <= op_tmp;
            rs1_out <= rs1_tmp;
            rs2_out <= rs2_tmp;
            rd_out <= rd_tmp;
            imm_out <= imm_tmp;
            has_imm_out <= has_imm_tmp;
            if((rob_full == 0)&&(busy[head] == 1) && (rs_full == 0)) begin
                op_tmp <= op_buffer[head];
                rs1_tmp <= rs1_buffer[head];
                rs2_tmp <= rs2_buffer[head];
                rd_tmp <= rd_buffer[head];
                imm_tmp <= imm_buffer[head];
                has_imm_tmp <= has_imm_buffer[head];
                shooted <= 1;
                busy[head] = 0;
                head <= head + 1;
                cnt = cnt - 1;
            end
            else begin
                op_tmp <= 5'b11111;
                shooted <= 0;
            end
        end
        else begin
            op_tmp = 5'b11111;
            rs1_tmp = 0;
            rs2_tmp = 0;
            rd_tmp = 0;
            imm_tmp = 0;
            has_imm_tmp = 0;
            shooted <= 0;
            head = 0;
            for(init = 0; init < 16; init = init + 1) begin
                busy[init] = 0;
            end
            op_out = 5'b11111;
            cnt = 0;
            iq_full = 0;
        end
    end
endmodule
