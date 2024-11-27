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
        input wire buffer_full,
        output reg[2:0] output_number,
        output reg[31:0] output_value,
        output reg[31:0] ins_value,
        output reg ins_ready,
        output reg mem_ready,
        output reg[2:0] can_be_load,
        output reg[31:0] ram_addr,
        output reg ram_writing,
        output reg[7:0] ram_data,
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
    reg [4:0]buffer_op[7:0];
    reg [31:0]buffer_addr[7:0];
    reg [31:0]buffer_data[7:0];
    reg [0:0]buffer_busy[7:0];

    reg [31:0]if_addr[7:0];
    reg [31:0]if_ready[7:0];
    reg [2:0]if_head;
    reg [2:0]if_tail;
    reg writing_flag;

    reg [0:0] is_writing;
    reg [2:0] executing;
    reg [0:0] is_ins;
    reg [31:0] now_addr;
    reg [31:0] now_data;
    reg [2:0] now_committed;
    initial begin
        output_value = 0;
        now_committed = 0;
        ins_value = 0;
        executing = 0;
        buffer_busy[0] = 0;
        buffer_busy[1] = 0;
        buffer_busy[2] = 0;
        buffer_busy[3] = 0;
        buffer_busy[4] = 0;
        buffer_busy[5] = 0;
        buffer_busy[6] = 0;
        buffer_busy[7] = 0;
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
        if(!rst) begin
            if(op != 5'b11111) begin
                buffer_op[rob_number] <= op;
                buffer_addr[rob_number] <= addr;
                buffer_data[rob_number] <= data;
                buffer_busy[rob_number] <= 1;
                can_be_load <= rob_number;
            end
            else begin
                can_be_load <= 0;
            end
            if(new_ins) begin
                if_addr[if_tail] <= pc_addr;
                if_ready[if_tail] <= 1;
                if_tail <= if_tail + 1;
            end
            if(committed_number != 0) begin
                now_committed = committed_number;
            end else begin
                now_committed = 0;
            end
        end
    end

    always@(negedge clk) begin
        if(!rst) begin
            if((if_head == (if_tail + 2)) || (if_head == (if_tail + 1))) begin
                if_full <= 1;
            end
            else begin
                if_full <= 0;
            end
            if(1) begin
                if(!executing) begin
                ram_writing <= 0;
                mem_ready <= 0;
                ins_ready <= 0;
                output_number <= 0;
                if((buffer_busy[now_committed] == 1) && (now_committed != 0)) begin
                    now_addr <= buffer_addr[now_committed];
                    now_data <= buffer_data[now_committed];
                    is_ins <= 0;
                    if(buffer_op[now_committed] == SB || buffer_op[now_committed] == SH || buffer_op[now_committed] == SW) begin
                        is_writing <= 1;
                        writing_flag <= 1;
                    end
                    else begin
                        is_writing <= 0;
                    end
                    case(buffer_op[now_committed])
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
                    if(executing == 1) begin
                        if(!writing_flag) begin
                            now_committed <= 0;
                            mem_ready <= 0;
                            output_number <= now_committed;
                            buffer_busy[now_committed] <= 0;
                            executing <= executing - 1;
                            ram_writing <= 0;
                            ram_addr <= 0;
                        end
                        else begin
                            ram_addr <= now_addr + (executing - 1);
                            ram_writing <= 1;
                            writing_flag <= 0;
                        end
                    end
                    else begin
                        ram_addr <= now_addr + (executing - 1);
                        executing <= executing - 1;
                        ram_writing <= 1;
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
                            now_committed <= 0;
                            ins_ready <= 0;
                            mem_ready <= 1;
                            if(buffer_op[now_committed] == LB) begin
                                if(now_data[7] == 1) begin
                                    output_value[31:8] <= 24'hffffff;
                                end
                                else begin
                                    output_value[31:8] <= 24'h000000;
                                end
                                output_value[7:0] <= now_data[7:0];
                            end
                            if(buffer_op[now_committed] == LBU) begin
                                output_value[31:8] <= 24'h000000;
                                output_value[7:0] <= now_data[7:0];
                            end
                            if(buffer_op[now_committed] == LH) begin
                                if(now_data[15] == 1) begin
                                    output_value[31:16] <= 16'hffff;
                                end
                                else begin
                                    output_value[31:16] <= 16'h0000;
                                end
                                output_value[15:0] <= now_data[15:0];
                            end
                            if(buffer_op[now_committed] == LHU) begin
                                output_value[31:16] <= 16'h0000;
                                output_value[15:0] <= now_data[15:0];
                            end
                            if(buffer_op[now_committed] == LW) begin
                                output_value <= now_data;
                            end
                            output_number <= now_committed;
                            buffer_busy[now_committed] <= 0;
                        end
                    end
                    else begin
                        mem_ready <= 0;
                        ins_ready <= 0;
                    end
                end
                end
            end
        end
        else begin
            executing = 0;
            if_full = 0;
            is_ins = 0;
            for(i = 0; i < 8; i = i + 1) begin
                buffer_busy[i] = 0;
                if_ready[i] = 0;

            end
            if_head = 0;
            ins_ready = 0;
            mem_ready = 0;
            if_tail = 0;
            now_committed = 0;
        end
    end
endmodule
