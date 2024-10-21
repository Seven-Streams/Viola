// 0 means do nothing.
module ALU(
        input wire[31:0] value_1,
        input wire[31:0] value_2,
        input wire[3:0] op,
        input wire[2:0] des_input,
        input wire clk,
        output reg[2:0] des,
        output reg[31:0] result
    );
    reg[31:0] tmp;
    localparam [3:0]
               ADD = 4'b0000,
               AND = 4'b0001,
               OR  = 4'b0010,
               SLL = 4'b0011,
               SRL = 4'b0100,
               LT  = 4'b0101,
               LTU = 4'b0110,
               SRA = 4'b0111,
               SUB = 4'b1000,
               XOR = 4'b1001,
               EQ  = 4'b1010,
               GE  = 4'b1011,
               NEQ = 4'b1100,
               GEU = 4'b1101;
    always @(posedge clk) begin
        case(op)
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
            LT:
                tmp <= (value_1 < value_2) ? 1 : 0;
            LTU:
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
            NEQ:
                tmp <= (value_1 != value_2) ? 1 : 0;
            GEU:
                tmp <= ($unsigned(value_1) >= $unsigned(value_2)) ? 1 : 0;
            default:
                tmp <= 32'b0;
        endcase
    end
    always @(negedge clk) begin
            des <= des_input;
            result <= tmp;
    end
endmodule
