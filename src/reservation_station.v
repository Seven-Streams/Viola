module RS(
        input wire clk,
        input wire[31:0] alu_data,
        input wire[2:0] alu_des_in,
        input wire[31:0] memory_data,
        input wire[2:0] memory_des_in,
        input wire[5:0] op,
        input wire[31:0] value1,
        input wire[31:0] value2,
        input wire[2:0] query1,
        input wire[2:0] query2,
        input wire memory_busy,
        output reg[5:0] alu_op,
        output reg[31:0] alu_value1,
        output reg[31:0] alu_value2,
        output reg[2:0] alu_des,
        output reg[5:0] memory_op,
        output reg[31:0] memory_value1,
        output reg[31:0] memory_value2,
        output reg[2:0] memory_des,
        output reg rs_full
    );
    reg[5:0] op_rs[5:0];
    reg[31:0] value1_rs[5:0];
    reg[31:0] value2_rs[5:0];
    reg[2:0] des_rs[5:0];
    reg[5:0] query1_rs[5:0];
    reg[5:0] query2_rs[5:0];
    reg busy[5:0];
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
    initial begin
        busy[0] = 0;
        busy[1] = 0;
        busy[2] = 0;
        busy[3] = 0;
        busy[4] = 0;
        busy[5] = 0;
    end
    integer i;
    integer j;
    integer k;
    integer l;
    reg flag;
    always@(posedge clk) begin
        for(j = 0; j < 6; j++) begin
            if(busy[j]) begin
                if(query1_rs[j] == alu_des_in) begin
                    value1_rs[j] <= alu_data;
                    query1_rs[j] <= 0;
                end
                if(query2_rs[j] == alu_des_in) begin
                    value2_rs[j] <= alu_data;
                    query2_rs[j] <= 0;
                end
                if(query1_rs[j] == memory_des_in) begin
                    value1_rs[j] <= memory_data;
                    query1_rs[j] <= 0;
                end
                if(query2_rs[j] == memory_des_in) begin
                    value2_rs[j] <= memory_data;
                    query2_rs[j] <= 0;
                end
            end
        end
        flag = 1;
        if(op >= LB && (!(op > SW))) begin
            for(i = 3; (i < 6) && flag; i++) begin
                if(!busy[i]) begin
                    busy[i] <= 1;
                    op_rs[i] <= op;
                    value1_rs[i] <= value1;
                    value2_rs[i] <= value2;
                    des_rs[i] <= alu_des_in;
                    query1_rs[i] <= query1;
                    query2_rs[i] <= query2;
                    flag = 0;
                end
            end
        end
        else begin
            for(i = 0; (i < 3) && flag; i++) begin
                if(!busy[i]) begin
                    busy[i] <= 1;
                    op_rs[i] <= op;
                    value1_rs[i] <= value1;
                    value2_rs[i] <= value2;
                    des_rs[i] <= alu_des_in;
                    query1_rs[i] <= query1;
                    query2_rs[i] <= query2;
                    flag = 0;
                end
            end
        end
    end
    logic alu_shooted;
    logic memory_shooted;
    always@(negedge clk) begin
        if(busy[0] & busy[1] & busy[2] & busy[3] & busy[4] & busy[5]) begin
            rs_full <= 1;
        end
        alu_shooted = 0;
        memory_shooted = 0;
        for(k = 0; k < 3 && (!alu_shooted); k++) begin
            if(busy[k]) begin
                if(query1_rs[k] == 0 && query2_rs[k] == 0) begin
                    alu_value1 <= value1_rs[k];
                    alu_value2 <= value2_rs[k];
                    alu_des <= des_rs[k];
                    alu_op <= op_rs[k];
                    busy[k] <= 0;
                    alu_shooted = 1;
                end
            end
        end
        if(!memory_busy) begin
            for(l = 3; l < 6 && (!memory_shooted); l++) begin
                if(busy[l]) begin
                    if(query1_rs[l] == 0 && query2_rs[l] == 0) begin
                        memory_value1 <= value1_rs[l];
                        memory_value2 <= value2_rs[l];
                        memory_des <= des_rs[l];
                        memory_op <= op_rs[l];
                        busy[l] <= 0;
                        memory_shooted = 1;
                    end
                end
            end
        end
        if(!alu_shooted) begin
            alu_des <= 0;
        end
        if(!memory_shooted) begin
            memory_des <= 0;
        end
    end
endmodule
