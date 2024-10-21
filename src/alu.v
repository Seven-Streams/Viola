module ALU(
        input wire[31:0] value_1,
        input wire[31:0] value_2,
        input wire[3:0] op,
        input wire clk,
        output reg[2:0] des,
        output reg[31:0] result,
        output reg busy
    );

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
    always @(*) begin
        if (!busy) begin
            case(op)
                ADD:
                    result <= value_1 + value_2;
                AND:
                    result <= value_1 & value_2;
                OR:
                    result <= value_1 | value_2;
                SLL:
                    result <= value_1 << value_2[4:0];
                SRL:
                    result <= value_1 >> value_2[4:0];
                LT:
                    result <= (value_1 < value_2) ? 1 : 0;
                LTU:
                    result <= ($unsigned(value_1) < $unsigned(value_2)) ? 1 : 0;
                SRA:
                    result <= value_1 >>> value_2[4:0];
                SUB:
                    result <= value_1 - value_2;
                XOR:
                    result <= value_1 ^ value_2;
                EQ:
                    result <= (value_1 == value_2) ? 1 : 0;
                GE:
                    result <= (value_1 >= value_2) ? 1 : 0;
                NEQ:
                    result <= (value_1 != value_2) ? 1 : 0;
                GEU:
                    result <= ($unsigned(value_1) >= $unsigned(value_2)) ? 1 : 0;
                default:
                    result <= 32'b0;
            endcase
            busy <= 1;
        end
    end

endmodule
