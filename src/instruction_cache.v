module IC(
        input wire clk,
        input wire [31:0] data,
        input wire data_ready,
        input wire [31:0] branch_pc,
        input wire [31:0] jalr_addr,
        input wire [2:0] pc_signal,
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
    initial begin
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
        flag = 0;
        jalr_tmp = 0;
        if(rst) begin
            head = 0;
            rst <= 0;
        end
        else begin
            if(data_ready) begin
                flag = 1;
                rem = predicted_pc[5:1];
                if(cache[rem][0] != predicted_pc) begin
                    cache[rem][0] = predicted_pc;
                    cache[rem][1] = data;
                end
            end
            case(pc_signal)
                3'b001:begin
                    rst <= 0;
                    pc <= jalr_addr;
                    jalr_tmp = 1;
                    jalr_addr_tmp = jalr_addr;
                    head <= head + 1;
                end
                3'b010:begin
                  pc <= branch_pc;
                head <= head + 1;
                end
                3'b011:begin
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
                3'b100:begin
                    pc <= pc + (ic_size[head] == 1 ? 4 : 2);
                    rst <= 1;
                end
                default:begin
                    rst <= 0;
                end
        endcase
        end
    end
    reg[31:0] value0;
    reg[31:0] value1;
    reg[31:0] value2;
    reg[31:0] value3;
    reg [4:0] rem;
    reg [4:0] rem2;
    always@(negedge clk) begin
        if(!rst) begin
            if((!lsb_full) && (!iq_full) && (!shooted) && (!ready)) begin
                rem2 = predicted_pc[5:1];
                if(cache[rem2][0] == predicted_pc) begin
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
                data_tmp = cache[rem2][1];
                instruction = data_tmp;
                ready <= 0;
                if(data_tmp[1:0] == 2'b11) begin
                    ic_size[tail] <= 1;
                    tail <= tail + 1;
                    case(data_tmp[6:0])
                        7'b1101111: begin
                            value0 = 0;
                            value0[20] = data_tmp[31];
                            value0[19:12] = data_tmp[19:12];
                            value0[11] = data_tmp[20];
                            value0[10:1] = data_tmp[30:21];
                            if(data_tmp[31] == 0) begin
                                predicted_pc = (predicted_pc + value0);
                            end
                            else begin
                                value0[31:20] = 12'hfff;
                                predicted_pc = predicted_pc + value0;
                            end
                            shooted <= 0;
                        end
                        7'b1100011: begin
                            value0 = 0;
                            value0[12] = data_tmp[31];
                            value0[11] = data_tmp[7];
                            value0[10:5] = data_tmp[30:25];
                            value0[4:1] = data_tmp[11:8];
                            if(data_tmp[31] == 0) begin
                                predicted_pc = predicted_pc + value0;
                            end
                            else begin
                                value0[31:12] = 20'hfffff;
                                predicted_pc = predicted_pc + value0;
                            end
                            shooted <= 0;
                        end
                        7'b1100111: begin
                            shooted <= 1;
                        end
                        default: begin
                            predicted_pc = predicted_pc + 4;
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
                        if(data_tmp[1:0] == 2'b01) begin
                            case(data_tmp[15:13])
                        3'b001: begin
                            value[0] = 0;
                            value[0][11] = data_tmp[12];
                            value[0][10] = data_tmp[8];
                            value[0][9:8] = data_tmp[10:9];
                            value[0][7] = data_tmp[6];
                            value[0][6] = data_tmp[7];
                            value[0][5] = data_tmp[2];
                            value[0][4] = data_tmp[11];
                            value[0][3:1] = data_tmp[5:3];
                            if(data_tmp[12] == 0) begin
                                predicted_pc = predicted_pc + value[0];
                            end
                            else begin
                                pc_tmp[11:0] = value[0][11:0];
                                pc_tmp[31:12] = 20'hfffff;
                                predicted_pc = predicted_pc + pc_tmp;
                            end
                            shooted <= 0;
                        end
                        3'b101:begin
                            value[0] = 0;
                            value[0][11] = data_tmp[12];
                            value[0][10] = data_tmp[8];
                            value[0][9:8] = data_tmp[10:9];
                            value[0][7] = data_tmp[6];
                            value[0][6] = data_tmp[7];
                            value[0][5] = data_tmp[2];
                            value[0][4] = data_tmp[11];
                            value[0][3:1] = data_tmp[5:3];
                            if(data_tmp[12] == 0) begin
                                predicted_pc = predicted_pc + value[0];
                            end
                            else begin
                                value[0][31:12] = 20'hfffff;
                                predicted_pc = predicted_pc + value[0];
                            end
                            shooted <= 0;                            
                        end
                        3'b110:begin
                                value0 = 0;
                                value0[7:6] = data_tmp[6:5];
                                value0[5] = data_tmp[2];
                                value0[4:3] = data_tmp[11:10];
                                value0[2:1] = data_tmp[4:3];
                                if(data_tmp[12] == 0) begin
                                    predicted_pc = predicted_pc + value0;
                                    shooted <= 0;
                                end
                                else begin
                                    value0[31:8] = 24'hffffff;
                                    predicted_pc = predicted_pc + value0;
                                    shooted <= 0;
                                end
                        end
                        3'b111:begin
                                value0 = 0;
                                value0[7:6] = data_tmp[6:5];
                                value0[5] = data_tmp[2];
                                value0[4:3] = data_tmp[11:10];
                                value0[2:1] = data_tmp[4:3];
                                if(data_tmp[12] == 0) begin
                                    predicted_pc = predicted_pc + value0;
                                    shooted <= 0;
                                end
                                else begin
                                    value0[31:8] = 24'hffffff;
                                    predicted_pc = predicted_pc + value0;
                                    shooted <= 0;
                                end
                        end
                        default:begin
                            predicted_pc = predicted_pc + 2;
                            shooted <= 0;
                        end
                        endcase
                        end
                        else begin
                        
                                predicted_pc = predicted_pc + 2;
                                shooted <= 0;
                        end
                    end
                end
            end
            else begin
                instruction = 0;
            end
            now_pc <= pc;
            if(jalr_tmp) begin
                shooted <= 0;
                predicted_pc = jalr_addr_tmp;
            end
            if(flag) begin
                ready <= 1;
            end
        end else begin
            ready <= 0;
            asking = 0;
            tail <= 0;
            instruction <= 0;
            predicted_pc = pc;
            shooted <= 0;
        end
    end
endmodule