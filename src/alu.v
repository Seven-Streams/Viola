// 0 means do nothing.
module ALU(
        input wire[31:0] value_1,
        input wire[31:0] value_2,
        input wire[4:0] op,
        input wire pause,
        input wire[2:0] des_input,
        input wire is_branch_input,
        input wire clk,
        input wire rst,
        output reg[2:0] des_rob,
        output reg[2:0] des_rs,
        output reg[31:0] result,
        output reg is_branch_out
    );
    reg[31:0] tmp;
    reg[31:0] value1_tmp;
    reg[31:0] value2_tmp;
    reg[4:0] op_tmp;
    reg is_branch_tmp;
    initial begin
        is_branch_tmp = 0;
        value1_tmp = 0;
        value2_tmp = 0;
        tmp = 0;
        des_rob = 0;
        des_rs = 0;
        result = 0;
        is_branch_out = 0;
        op_tmp = 5'b11111;
        result = 0;
    end
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
               JALR = 5'b10001,
               LT = 5'b11010,
               LTU = 5'b11011;
    always @(posedge clk) begin
        if(!pause) begin
        is_branch_tmp = is_branch_input;
        value1_tmp = value_1;
        value2_tmp = value_2;
        op_tmp = op;
        case(op)
            LT:
                tmp = ($signed(value_1) < $signed(value_2)) ? 1 : 0;
            LTU:
                tmp = (value_1 < value_2) ? 1 : 0;
            JALR:
                tmp = value_1 + value_2;
            ADD:
                tmp = value_1 + value_2;
            AND:
                tmp = value_1 & value_2;
            OR:
                tmp = value_1 | value_2;
            SLL:
                tmp = value_1 << value_2[4:0];
            SRL:
                tmp = value_1 >> value_2[4:0];
            SLT:
                tmp = ($signed(value_1) < $signed(value_2)) ? 1 : 0;
            SLTU:
                tmp = ($unsigned(value_1) < $unsigned(value_2)) ? 1 : 0;
            SRA:
                tmp = value_1 >>> value_2[4:0];
            SUB:
                tmp = value_1 - value_2;
            XOR:
                tmp = value_1 ^ value_2;
            EQ:
                tmp = (value_1 == value_2) ? 1 : 0;
            default:
                tmp = 32'b0;
        endcase
        end
    end
    always @(negedge clk) begin
        if(!pause)begin
        if(!rst) begin
            des_rob = des_input;
            des_rs = des_input;
            case(op_tmp)
            GE:
                result = ($signed(value_1) >= $signed(value_2)) ? 1 : 0;
            NE:
                result = (value_1 != value_2) ? 1 : 0;
            GEU:
                result = ($unsigned(value_1) >= $unsigned(value_2)) ? 1 : 0;
            default:
            result = tmp;
        endcase
            is_branch_out = is_branch_tmp;
        end
        else begin
            des_rob = 0;
            des_rs = 0;
        end
        end
    end
endmodule
