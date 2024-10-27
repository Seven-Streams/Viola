module LSB(
        input wire clk,
        input wire[31:0] pc_addr,
        input wire new_ins,
        input wire[31:0] addr,
        input wire[31:0] data,
        input wire[2:0] rob_number,
        input wire[4:0] op,
        input wire[2:0] committed_number,
        output reg[2:0] output_reg,
        output reg[31:0] output_value0,
        output reg[31:0] output_value1,
        output reg[31:0] output_value2,
        output reg[31:0] output_value3,
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

    reg [4:0]buffer_op[7:0];
    reg [2:0]buffer_rob_number[7:0];
    reg [31:0]buffer_addr[7:0];
    reg [31:0]buffer_data[7:0];
    reg [0:0]buffer_ready[7:0];
    reg [2:0]head;
    reg [2:0]tail;

    reg [31:0]if_addr[7:0];
    reg [31:0]if_ready[7:0];
    reg [2:0]if_head;
    reg [2:0]if_tail;
    initial begin
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
        if_tail = 0;
    end

    always@(posedge clk) begin
        if(op != 5'b11111) begin
            buffer_op[head] <= op;
            buffer_addr[head] <= addr;
            buffer_data[head] <= data;
            buffer_rob_number[head] <= rob_number;
            buffer_ready[head] <= 0;
            head <= head + 1;
        end
        if(new_ins) begin
            if_addr[if_head] <= pc_addr;
            if_ready[if_head] <= 0;
            if_head <= if_head + 1;
        end
    end

    always@(negedge clk) begin
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
        //TODO: the operation with ram.
    end
endmodule
