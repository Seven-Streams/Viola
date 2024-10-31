module IC(
        input wire clk,
        input wire [31:0] data,
        input wire data_ready,
        input wire branch_taken,
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
    reg [31:0] pc;
    reg [31:0] predicted_pc;
    reg [0:0] ready;
    reg [0:0] shooted;

    initial begin
        ready = 0;
        pc = 0;
        predicted_pc = 0;
        shooted = 0;
        ready = 0;
        rst = 0;
    end

    always@(posedge clk) begin
        if(data_ready) begin
            data_tmp <= data;
            ready <= 1;
        end
        if(pc_ready) begin
            pc <= nxt_pc;
        end
        if(branch_taken) begin
            if((branch_pc - pc) == 4) begin
                pc <= pc + 4; //OK.
                rst <= 0;
            end
            else begin
                pc <= branch_pc;
                predicted_pc <= branch_pc;
                rst <= 1;
                //TODO:flush the pipeline.
            end
        end
        if(jalr_ready) begin
            rst <= 0;
            pc <= jalr_addr;
            predicted_pc <= jalr_addr;
            ready <= 0;
        end
        if(pc_ready) begin
            rst <= 0;
            pc <= nxt_pc;
        end
        if((!branch_taken) && (!jalr_ready) && (!pc_ready)) begin
            rst <= 0;
        end
    end
    reg[31:0] value0;
    reg[31:0] value1;
    reg[31:0] value2;
    reg[31:0] value3;
    always@(negedge clk) begin
        if((!lsb_full) && (!iq_full) && (!shooted) && (!ready)) begin
            asking <= 1;
            addr <= predicted_pc;
            shooted <= 1;
        end
        else begin
            asking <= 0;
        end
        if(ready) begin
            instruction <= data_tmp;
            ready <= 0;
            case(data_tmp[6:0])
                7'b0010111: begin
                    value0 = data_tmp[31:12];
                    value0 = value0 << 12;
                    predicted_pc <= predicted_pc + value0;
                    shooted <= 0;
                end
                7'b1101111: begin
                    value0 = data_tmp[31];
                    value0 = value0 << 20;
                    value1 = data_tmp[20];
                    value1 = value1 << 11;
                    value2 = data_tmp[19:12];
                    value2 = value2 << 12;
                    value3 = data_tmp[30:21];
                    value3 = value3 << 1;
                    predicted_pc <= (predicted_pc + value0 + value1 + value2 + value3);
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
        now_pc <= pc;
    end
endmodule
