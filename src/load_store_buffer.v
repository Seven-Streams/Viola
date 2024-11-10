module LSB(
        input wire clk,
        input wire rst,
        input wire[31:0] pc_addr,
        input wire new_ins,
        input wire[31:0] addr,
        input wire[31:0] data,
        input wire[2:0] rob_number,
        input wire[4:0] op,
        input wire[2:0] committed_number,
        input wire[7:0] ram_loaded_data,
        output reg[2:0] output_number,
        output reg[31:0] output_value,
        output reg[31:0] ins_value,
        output reg ins_ready,
        output reg mem_ready,
        output reg[2:0] can_be_load,
        output reg[31:0] ram_addr,
        output reg ram_writing,
        output reg[7:0] ram_data,
        output reg buffer_full,
        output reg if_full
    );
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
    reg check;
    reg [2:0]head_check;
    reg [4:0]buffer_op[7:0];
    reg [2:0]buffer_rob_number[7:0];
    reg [31:0]buffer_addr[7:0];
    reg [31:0]buffer_data[7:0];
    reg [0:0]buffer_ready[7:0];
    reg [0:0]buffer_busy[7:0];
    reg [2:0]head;
    reg [2:0]tail;

    reg [31:0]if_addr[7:0];
    reg [31:0]if_ready[7:0];
    reg [2:0]if_head;
    reg [2:0]if_tail;

    reg [0:0] is_writing;
    reg [2:0] executing;
    reg [0:0] is_ins;
    reg [31:0] now_addr;
    reg [31:0] now_data;
    initial begin
        output_value = 0;
        ins_value = 0;
        executing = 0;
        buffer_full = 0;
        buffer_ready[0] = 0;
        buffer_ready[1] = 0;
        buffer_ready[2] = 0;
        buffer_ready[3] = 0;
        buffer_ready[4] = 0;
        buffer_ready[5] = 0;
        buffer_ready[6] = 0;
        buffer_ready[7] = 0;
        buffer_busy[0] = 0;
        buffer_busy[1] = 0;
        buffer_busy[2] = 0;
        buffer_busy[3] = 0;
        buffer_busy[4] = 0;
        buffer_busy[5] = 0;
        buffer_busy[6] = 0;
        buffer_busy[7] = 0;
        head = 0;
        tail = 0;
        if_full = 0;
        if_ready[0] = 0;
        if_ready[1] = 0;
        if_ready[2] = 0;
        if_ready[3] = 0;
        if_ready[4] = 0;
        if_ready[5] = 0;
        if_ready[6] = 0;
        if_ready[7] = 0;
        if_head = 0;
        ins_ready = 0;
        mem_ready = 0;
        if_tail = 0;
    end
    integer i;
    always@(posedge clk) begin
        head_check = buffer_rob_number[head];
        if(!rst) begin
            if(op != 5'b11111) begin
                buffer_op[tail] <= op;
                buffer_addr[tail] <= addr;
                buffer_data[tail] <= data;
                buffer_rob_number[tail] <= rob_number;
                buffer_ready[tail] <= 0;
                buffer_busy[tail] <= 1;
                tail <= tail + 1;
            end
            if(new_ins) begin
                if_addr[if_tail] <= pc_addr;
                if_ready[if_tail] <= 1;
                if_tail <= if_tail + 1;
            end
            if(committed_number != 0) begin
                for(i = 0; i < 8; i++) begin
                    if(buffer_rob_number[i] == committed_number) begin
                        buffer_ready[i] <= 1;
                    end
                end
            end
            if(buffer_busy[head] != 0) begin
                can_be_load <= buffer_rob_number[head];
            end
        end
    end

    always@(negedge clk) begin
        check = buffer_ready[head];
        if(!rst) begin
            if(head == (tail + 2) || (head == (tail + 1))) begin
                buffer_full <= 1;
            end
            else begin
                buffer_full <= 0;
            end
            if((if_head == (if_tail + 2)) || (if_head == (if_tail + 1))) begin
                if_full <= 1;
            end
            else begin
                if_full <= 0;
            end
            if(!executing) begin
                mem_ready <= 0;
                ins_ready <= 0;
                output_number <= 0;
                if(buffer_ready[head] && buffer_busy[head]) begin
                    now_addr <= buffer_addr[head];
                    now_data <= buffer_data[head];
                    is_ins <= 0;
                    if(buffer_op[head] == SB || buffer_op[head] == SH || buffer_op[head] == SW) begin
                        is_writing <= 1;
                    end
                    else begin
                        is_writing <= 0;
                    end
                    case(buffer_op[head])
                        LB: begin
                            executing <= 3;
                        end
                        LH: begin
                            executing <= 4;
                        end
                        LW: begin
                            executing <= 6;
                        end
                        LBU: begin
                            executing <= 3;
                        end
                        LHU: begin
                            executing <= 4;
                        end
                        SB: begin
                            executing <= 1;
                        end
                        SH: begin
                            executing <= 2;
                        end
                        SW: begin
                            executing <= 4;
                        end
                    endcase
                end
                else begin
                    is_writing <= 0;
                    now_addr <= if_addr[if_head];
                    is_ins <= 1;
                    if(if_ready[if_head]) begin
                        executing <= 6;
                    end
                end
            end
            else begin
                if(is_writing) begin
                    ins_ready <= 0;
                    ram_writing <= 1;
                    ram_addr <= now_addr + (executing - 1);
                    case(executing)
                        1: begin
                            ram_data <= now_data[7:0];
                        end
                        2: begin
                            ram_data <= now_data[15:8];
                        end
                        3: begin
                            ram_data <= now_data[23:16];
                        end
                        4: begin
                            ram_data <= now_data[31:24];
                        end
                    endcase
                    executing <= executing - 1;
                    if(executing == 1) begin
                        mem_ready <= 0;
                        ram_writing <= 1;
                        output_number <= buffer_rob_number[head];
                        buffer_busy[head] <= 0;
                        buffer_ready[head] <= 0;
                        head <= head + 1;
                    end
                    else begin
                        mem_ready <= 0;
                    end
                end
                else begin
                    ram_writing <= 0;
                    if(executing >= 3) begin
                        ram_addr <= now_addr + (executing - 3);
                    end
                    case(executing)
                        5: begin
                            now_data[31:24] = ram_loaded_data;
                        end
                        4: begin
                            now_data[23:16] = ram_loaded_data;
                        end
                        3: begin
                            now_data[15:8] = ram_loaded_data;
                        end
                        2: begin
                            now_data[7:0] = ram_loaded_data;
                        end
                        default: begin
                        end
                    endcase
                    executing <= executing - 1;
                    if(executing == 1) begin
                        if(is_ins) begin
                            ins_ready <= 1;
                            mem_ready <= 0;
                            ins_value <= now_data;
                            if_ready[if_head] <= 0;
                            if_head <= if_head + 1;
                        end
                        else begin
                            ins_ready <= 0;
                            mem_ready <= 1;
                            if(buffer_op[head] == LB) begin
                                if(now_data[7] == 1) begin
                                    output_value[31:8] <= 24'hffffff;
                                end
                                else begin
                                    output_value[31:8] <= 24'h000000;
                                end
                                output_value[7:0] <= now_data[7:0];
                            end
                            if(buffer_op[head] == LBU) begin
                                output_value[31:8] <= 24'h000000;
                                output_value[7:0] <= now_data[7:0];
                            end
                            if(buffer_op[head] == LH) begin
                                if(now_data[15] == 1) begin
                                    output_value[31:16] <= 16'hffff;
                                end
                                else begin
                                    output_value[31:16] <= 16'h0000;
                                end
                                output_value[15:0] <= now_data[15:0];
                            end
                            if(buffer_op[head] == LHU) begin
                                output_value[31:16] <= 16'h0000;
                                output_value[15:0] <= now_data[15:0];
                            end
                            output_number <= buffer_rob_number[head];
                            buffer_busy[head] <= 0;
                            buffer_ready[head] <= 0;
                            head <= head + 1;
                            if(buffer_op[head] == LW) begin
                                output_value <= now_data;
                            end
                        end
                    end
                    else begin
                        mem_ready <= 0;
                        ins_ready <= 0;
                    end
                end
            end
        end
        else begin
            executing = 0;
            buffer_full = 0;
            buffer_ready[0] = 0;
            buffer_ready[1] = 0;
            buffer_ready[2] = 0;
            buffer_ready[3] = 0;
            buffer_ready[4] = 0;
            buffer_ready[5] = 0;
            buffer_ready[6] = 0;
            buffer_ready[7] = 0;
            head = 0;
            tail = 0;
            if_full = 0;
            if_ready[0] = 0;
            if_ready[1] = 0;
            if_ready[2] = 0;
            if_ready[3] = 0;
            if_ready[4] = 0;
            if_ready[5] = 0;
            if_ready[6] = 0;
            if_ready[7] = 0;
            if_head = 0;
            ins_ready = 0;
            mem_ready = 0;
            if_tail = 0;
        end
    end
endmodule
