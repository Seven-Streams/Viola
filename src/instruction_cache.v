module IC(
        input wire clk,
        input wire [31:0] data,
        input wire data_ready,
        input wire branch_taken,
        input wire branch_not_taken,
        input wire [31:0] branch_pc,
        input wire [31:0] jalr_addr,
        input wire jalr_ready,
        input wire pc_ready,
        input wire [31:0] nxt_pc,
        input wire lsb_full,
        input wire iq_full,
        output reg [31:0] instruction,
        output reg [0:0] asking,
        output reg [31:0] addr,
        output reg [31:0] now_pc,
        output reg rst
    );
    reg [31:0] data_tmp;
    reg [31:0] data_tmp2;
    reg [31:0] pc;
    reg [31:0] predicted_pc;
    reg [0:0] ready;
    reg jalr_tmp;
    reg [0:0] ready_tmp;
    reg [0:0] shooted;
    reg [0:0] ic_size[31:0];
    reg [4:0] head;
    reg [4:0] tail;
    reg [31:0]predicted_pc_tmp;
    reg [31:0] jalr_addr_tmp;
    reg [31:0] cache[31:0][1:0];
    integer value[0:0];
    integer i;
    reg [31:0] pc_tmp;
    reg flag;
    reg ready_value;
    initial begin
        ready_value = 0;
        flag = 0;
        pc = 0;
        predicted_pc = 0;
        shooted = 0;
        ready = 0;
        rst = 0;
        head = 0;
        tail = 0;
        for(i = 0; i < 32; i = i + 1) begin
            cache[i][0] = 1;
            cache[i][1] = 0;
        end
    end

    always@(posedge clk) begin
        jalr_tmp = 0;
        if(rst) begin
            head = 0;
            rst <= 0;
        end
        else begin
            if(data_ready) begin
                data_tmp2 <= data;
                ready <= 1;
            end
            if(branch_taken) begin
                pc <= branch_pc;
                head <= head + 1;
            end
            if(branch_not_taken) begin
                pc <= pc + (ic_size[head] == 1 ? 4 : 2);
                rst <= 1;
                ready <= 0;
            end
            if(jalr_ready) begin
                rst <= 0;
                pc <= jalr_addr;
                jalr_tmp = 1;
                //TODO:MOVE predicted_PC and shooted to another part.
                predicted_pc <= jalr_addr;
                ready <= 0;
                head <= head + 1;
            end
            if(pc_ready) begin
                rst <= 0;
                if(nxt_pc == 32'hffffffff) begin
                    pc <= pc + (ic_size[head] == 1 ? 4 : 2);
                    head <= head + 1;
                end
                else begin
                    pc <= nxt_pc;
                    head <= head + 1;
                end
            end
            if((!branch_not_taken) && (!jalr_ready) && (!pc_ready)) begin
                rst <= 0;
            end
        end
    end
    reg[31:0] value0;
    reg[31:0] value1;
    reg[31:0] value2;
    reg[31:0] value3;
    reg [4:0] rem;
    always@(negedge clk) begin
        if(!rst) begin
            if((!lsb_full) && (!iq_full) && (!shooted) && (!ready)) begin
                rem = predicted_pc[5:1];
                if(cache[rem][0] == predicted_pc) begin
                    ready <= 1;
                end
                else begin
                    asking <= 1;
                    addr <= predicted_pc;
                end
                shooted <= 1;
            end
            else begin
                asking <= 0;
            end
            if(ready) begin
                rem = predicted_pc[5:1];
                if(cache[rem][0] != predicted_pc) begin
                    cache[rem][0] = predicted_pc;
                    cache[rem][1] = data_tmp2;
                end
                data_tmp = cache[rem][1];
                instruction <= data_tmp;
                ready <= 0;
                if(data_tmp[1:0] == 2'b11) begin
                    ic_size[tail] <= 1;
                    tail <= tail + 1;
                    case(data_tmp[6:0])
                        7'b1101111: begin
                            value0 = data_tmp[31];
                            value0 = value0 << 20;
                            value1 = data_tmp[20];
                            value1 = value1 << 11;
                            value2 = data_tmp[19:12];
                            value2 = value2 << 12;
                            value3 = data_tmp[30:21];
                            value3 = value3 << 1;
                            if(value0 == 0) begin
                                predicted_pc <= (predicted_pc + value0 + value1 + value2 + value3);
                            end
                            else begin
                                pc_tmp = value0 + value1 + value2 + value3;
                                pc_tmp[31:20] = 12'hfff;
                                predicted_pc <= predicted_pc + pc_tmp;
                            end
                            shooted <= 0;
                        end
                        7'b1100011: begin
                            value0 = data_tmp[31];
                            value1 = data_tmp[7];
                            value1 = value1 << 11;
                            value2 = data_tmp[30:25];
                            value2 = value2 << 5;
                            value3 = data_tmp[11:8];
                            value3 = value3 << 1;
                            if(value0 == 0) begin
                                predicted_pc <= predicted_pc + value0 + value1 + value2 + value3;
                            end
                            else begin
                                pc_tmp = value1 + value2 + value3;
                                pc_tmp[31:12] = 20'hfffff;
                                predicted_pc <= predicted_pc + pc_tmp;
                            end
                            shooted <= 0;
                        end
                        7'b1100111: begin
                            shooted <= 1;
                        end
                        default: begin
                            predicted_pc <= predicted_pc + 4;
                            shooted <= 0;
                        end//Predict branch always not taken.
                    endcase
                end
                else begin
                    ic_size[tail] <= 0;
                    tail <= tail + 1;
                    if(data_tmp[1:0] == 2'b10 && data_tmp[15:13] == 3'b100 && data_tmp[6:2] == 5'b00000) begin
                        shooted <= 1;
                    end
                    else begin
                        if(data_tmp[1:0] == 2'b01 && (data_tmp[15:13] == 3'b001 || data_tmp[15:13] == 3'b101)) begin
                            value[0] = data_tmp[12];
                            value[0] = value[0] << 1;
                            value[0] = value[0] + data_tmp[8];
                            value[0] = value[0] << 2;
                            value[0] = value[0] + data_tmp[10:9];
                            value[0] = value[0] << 1;
                            value[0] = value[0] + data_tmp[6];
                            value[0] = value[0] << 1;
                            value[0] = value[0] + data_tmp[7];
                            value[0] = value[0] << 1;
                            value[0] = value[0] + data_tmp[2];
                            value[0] = value[0] << 1;
                            value[0] = value[0] + data_tmp[11];
                            value[0] = value[0] << 3;
                            value[0] = value[0] + data_tmp[5:3];
                            value[0] = value[0] << 1;
                            if(data_tmp[12] == 0) begin
                                predicted_pc <= predicted_pc + value[0];
                            end
                            else begin
                                pc_tmp[11:0] = value[0][11:0];
                                pc_tmp[31:12] = 20'hfffff;
                                predicted_pc <= predicted_pc + pc_tmp;
                            end
                            shooted <= 0;
                        end
                        else begin
                            if(data_tmp[1:0] == 2'b01 && (data_tmp[15:13] == 3'b110 || data_tmp[15:13] == 3'b111)) begin
                                value0 = data_tmp[6:5];
                                value0 = value0 << 1;
                                value0 = value0 + data_tmp[2];
                                value0 = value0 << 2;
                                value0 = value0 + data_tmp[11:10];
                                value0 = value0 << 2;
                                value0 = value0 + data_tmp[4:3];
                                value0 = value0 << 1;
                                if(data_tmp[12] == 0) begin
                                    predicted_pc <= predicted_pc + value0;
                                    shooted <= 0;
                                end
                                else begin
                                    pc_tmp[7:0] = value0[7:0];
                                    pc_tmp[31:8] = 24'hffffff;
                                    predicted_pc <= predicted_pc + pc_tmp;
                                    shooted <= 0;
                                end
                            end
                            else begin
                                predicted_pc <= predicted_pc + 2;
                                shooted <= 0;
                            end
                        end
                    end
                end
            end
            else begin
                instruction <= 0;
            end
            now_pc <= pc;
        if(jalr_tmp) begin
            shooted = 0;
        end
        end else begin
            asking = 0;
            tail <= 0;
            instruction <= 0;
            predicted_pc <= pc;
            shooted <= 0;
        end
    end
endmodule