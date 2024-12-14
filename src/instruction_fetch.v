module IF(
        input wire clk,
        input wire [31:0] data,
        input wire data_ready,
        input wire pause,
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
        output reg [31:0] pc,
        output reg rst
    );
    reg [31:0] data_tmp;
    reg [31:0] predicted_pc;
    reg [31:0] normal_nxt_pc;
    reg [0:0] ready;
    reg jalr_tmp;
    reg [0:0] ready_tmp;
    reg [0:0] shooted;
    reg [0:0] ic_size[31:0];
    reg [4:0] head;
    reg [4:0] tail;
    reg [31:0]predicted_pc_tmp;
    reg [31:0] jalr_addr_tmp;
    integer value[0:0];
    integer i;
    reg [31:0] pc_tmp;
    reg flag;
    reg short;
    initial begin
        jalr_addr_tmp = 0;
        short = 0;
        flag = 0;
        pc = 0;
        predicted_pc = 0;
        shooted = 0;
        ready = 0;
        rst = 0;
        head = 0;
        addr = 0;
        tail = 0;
        instruction = 0;
        asking = 0;
    end

    always@(posedge clk) begin
        if(!pause) begin
        flag = 0;
        jalr_tmp = 0;
        if(rst) begin
            head = 0;
            rst <= 0;
        end
        else begin
            if(data_ready) begin
                data_tmp = data;
                data_tmp0 = data;
                data_tmp1 = data;
                flag = 1;
            end
            if(branch_taken) begin
                pc = branch_pc;
                head <= head + 1;
            end
            if(branch_not_taken) begin
                pc = normal_nxt_pc;
                rst <= 1;
            end
            if(jalr_ready) begin
                rst <= 0;
                pc = jalr_addr;
                jalr_tmp = 1;
                jalr_addr_tmp = jalr_addr;
                head <= head + 1;
            end
            if(pc_ready) begin
                rst <= 0;
                if(nxt_pc == 32'hffffffff) begin
                    pc = normal_nxt_pc;
                    head <= head + 1;
                end
                else begin
                    pc = nxt_pc;
                    head <= head + 1;
                end
            end
            if((!branch_not_taken) && (!jalr_ready) && (!pc_ready)) begin
                rst <= 0;
            end
        end
    end
    end
    reg[31:0] data_tmp0;
    reg[31:0] data_tmp1;
    reg[31:0] value0;
    reg[31:0] value1;
    reg[31:0] value2;
    reg[31:0] value3;
    reg [4:0] rem;
    reg [4:0] rem2;
    always@(negedge clk) begin
        if(!pause)begin
        if(!rst) begin
            short = ic_size[head] == 1 ? 1 : 0;
            normal_nxt_pc <= pc + (short ? 4 : 2);
            if((!lsb_full) && (!iq_full) && (!shooted) && (!ready)) begin
                asking <= 1;
                addr <= predicted_pc;
                shooted <= 1;
            end
            else begin
                asking <= 0;
            end
            if(ready) begin
                instruction = data_tmp;
                ready <= 0;
                case(data_tmp[1:0])
                2'b11:begin
                    ic_size[tail] <= 1;
                    tail <= tail + 1;
                    case(data_tmp0[6:0])
                        7'b1101111: begin
                            value0 = 0;
                            value0[20] = data_tmp0[31];
                            value0[19:12] = data_tmp0[19:12];
                            value0[11] = data_tmp0[20];
                            value0[10:1] = data_tmp0[30:21];
                            if(data_tmp0[31] == 0) begin
                                predicted_pc = (predicted_pc + value0);
                            end
                            else begin
                                value0[31:20] = 12'hfff;
                                predicted_pc = predicted_pc + value0;
                            end
                            shooted <= 0;
                        end
                        7'b1100011: begin
                            value1 = 0;
                            value1[12] = data_tmp0[31];
                            value1[11] = data_tmp0[7];
                            value1[10:5] = data_tmp0[30:25];
                            value1[4:1] = data_tmp0[11:8];
                            if(data_tmp0[31] == 0) begin
                                predicted_pc = predicted_pc + value1;
                            end
                            else begin
                                value1[31:12] = 20'hfffff;
                                predicted_pc = predicted_pc + value1;
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
                2'b10:begin
                    ic_size[tail] <= 0;
                    tail <= tail + 1;
                    if(data_tmp[15:13] == 3'b100 && data_tmp[6:2] == 5'b00000) begin
                        shooted <= 1;
                    end else begin
                        predicted_pc = predicted_pc + 2;
                        shooted <= 0;
                    end
                end
                2'b01:begin
                    ic_size[tail] <= 0;
                          case(data_tmp1[15:13])
                        3'b001: begin
                            value[0] = 0;
                            value[0][11] = data_tmp1[12];
                            value[0][10] = data_tmp1[8];
                            value[0][9:8] = data_tmp1[10:9];
                            value[0][7] = data_tmp1[6];
                            value[0][6] = data_tmp1[7];
                            value[0][5] = data_tmp1[2];
                            value[0][4] = data_tmp1[11];
                            value[0][3:1] = data_tmp1[5:3];
                            if(data_tmp1[12] == 0) begin
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
                            value[0][11] = data_tmp1[12];
                            value[0][10] = data_tmp1[8];
                            value[0][9:8] = data_tmp1[10:9];
                            value[0][7] = data_tmp1[6];
                            value[0][6] = data_tmp1[7];
                            value[0][5] = data_tmp1[2];
                            value[0][4] = data_tmp1[11];
                            value[0][3:1] = data_tmp1[5:3];
                            if(data_tmp1[12] == 0) begin
                                predicted_pc = predicted_pc + value[0];
                            end
                            else begin
                                value[0][31:12] = 20'hfffff;
                                predicted_pc = predicted_pc + value[0];
                            end
                            shooted <= 0;                            
                        end
                        3'b110:begin
                                value2 = 0;
                                value2[7:6] = data_tmp1[6:5];
                                value2[5] = data_tmp1[2];
                                value2[4:3] = data_tmp1[11:10];
                                value2[2:1] = data_tmp1[4:3];
                                if(data_tmp1[12] == 0) begin
                                    predicted_pc = predicted_pc + value2;
                                    shooted <= 0;
                                end
                                else begin
                                    value2[31:8] = 24'hffffff;
                                    predicted_pc = predicted_pc + value2;
                                    shooted <= 0;
                                end
                        end
                        3'b111:begin
                                value3 = 0;
                                value3[7:6] = data_tmp1[6:5];
                                value3[5] = data_tmp1[2];
                                value3[4:3] = data_tmp1[11:10];
                                value3[2:1] = data_tmp1[4:3];
                                if(data_tmp1[12] == 0) begin
                                    predicted_pc = predicted_pc + value3;
                                    shooted <= 0;
                                end
                                else begin
                                    value3[31:8] = 24'hffffff;
                                    predicted_pc = predicted_pc + value3;
                                    shooted <= 0;
                                end
                        end
                        default:begin
                            predicted_pc = predicted_pc + 2;
                            shooted <= 0;
                        end
                    endcase
                end
                default:begin
                    ic_size[tail] <= 0;
                    predicted_pc = predicted_pc + 2;
                    shooted <= 0;
                end
                endcase
                tail <= tail + 1;
            end else begin
                instruction = 0;
            end
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
    end
endmodule