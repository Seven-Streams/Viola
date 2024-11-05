// 0 means do nothing.
module ALU(
        input wire[31:0] value_1,
        input wire[31:0] value_2,
        input wire[4:0] op,
        input wire[2:0] des_input,
        input wire clk,
        input wire rst,
        output reg[2:0] des,
        output reg[31:0] result
    );
    reg[31:0] tmp;
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
               EQ  = 5'b01010,
               GE  = 5'b01011,
               NE = 5'b01100,
               GEU = 5'b01101,
               JAL = 5'b10000,
               JALR = 5'b10001;
    always @(posedge clk) begin
        case(op)
            JAL:
                tmp <= value_1 + value_2;
            JALR:
                tmp <= value_1 + value_2;
            ADD:
                tmp <= value_1 + value_2;
            AND:
                tmp <= value_1 & value_2;
            OR:
                tmp <= value_1 | value_2;
            SLL:
                tmp <= value_1 << value_2[4:0];
            SRL:
                tmp <= value_1 >> value_2[4:0];
            SLT:
                tmp <= (value_1 < value_2) ? 1 : 0;
            SLTU:
                tmp <= ($unsigned(value_1) < $unsigned(value_2)) ? 1 : 0;
            SRA:
                tmp <= value_1 >>> value_2[4:0];
            SUB:
                tmp <= value_1 - value_2;
            XOR:
                tmp <= value_1 ^ value_2;
            EQ:
                tmp <= (value_1 == value_2) ? 1 : 0;
            GE:
                tmp <= (value_1 >= value_2) ? 1 : 0;
            NE:
                tmp <= (value_1 != value_2) ? 1 : 0;
            GEU:
                tmp <= ($unsigned(value_1) >= $unsigned(value_2)) ? 1 : 0;
            default:
                tmp <= 32'b0;
        endcase
    end
    always @(negedge clk) begin
            if(!rst) begin
            des <= des_input;
            result <= tmp;
            end else begin
                des <= 3'b0;
            end
    end
endmodule
