module Decoder(
        input wire clk,
        input wire rst,
        input [31:0] instruction,
        output reg[4:0] op,
        output reg[4:0] rs1,
        output reg[4:0] rs2,
        output reg[4:0] rd,
        output reg[31:0] imm,
        output reg has_imm
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
               BLTU = 5'b11011,
               JAL_C = 5'b11100;
    integer value[3:0];
    always@(posedge clk) begin
        op = 5'b11111;
        if(instruction != 0) begin
            if(instruction[1:0] == 2'b11) begin
                case(instruction[6:0])
                    7'b0110111: begin
                        op <= LUI;
                        rd <= instruction[11:7];
                        imm <= (instruction[31:12] << 12);
                        has_imm <= 1;
                    end
                    7'b0010111: begin
                        op <= AUIPC;
                        rd <= instruction[11:7];
                        imm <= (instruction[31:12] << 12);
                        has_imm <= 1;
                    end
                    7'b1101111: begin
                        op <= JAL;
                        value[0] = instruction[31];
                        value[0] = value[0] << 20;
                        value[1] = instruction[19:12];
                        value[1] = value[1] << 12;
                        value[2] = instruction[20];
                        value[2] = value[2] << 11;
                        value[3] = instruction[30:21];
                        value[3] = value[3] << 1;
                        imm  <= (value[0] + value[1] + value[2] + value[3]);
                        rd <= instruction[11:7];
                        has_imm <= 1;
                    end
                    7'b1100111: begin
                        op <= JALR;
                        rs1 <= instruction[19:15];
                        rd <= instruction[11:7];
                        imm <= instruction[31:20];
                        has_imm <= 1;
                    end
                    7'b1100011: begin
                        case (instruction[14:12])
                            3'b000:
                                op  <= BEQ;
                            3'b001:
                                op  <= BNE;
                            3'b100:
                                op  <= BLT;
                            3'b101:
                                op  <= BGE;
                            3'b110:
                                op  <= BLTU;
                            3'b111:
                                op  <= BGEU;
                            default:
                                op  <= 5'b11111;
                        endcase
                        rs1  <= instruction[19:15];
                        rs2  <= instruction[24:20];
                        value[0] = instruction[31];
                        value[0] = value[0] << 12;
                        value[1] = instruction[7];
                        value[1] = value[1] << 11;
                        value[2] = instruction[30:25];
                        value[2] = value[2] << 5;
                        value[3] = instruction[11:8];
                        value[3] = value[3] << 1;
                        imm  <= (value[0] + value[1] + value[2] + value[3]);
                        has_imm <= 1;
                    end
                    7'b0000011: begin
                        case(instruction[14:12])
                            3'b000:
                                op  <= LB;
                            3'b001:
                                op  <= LH;
                            3'b010:
                                op  <= LW;
                            3'b100:
                                op  <= LBU;
                            3'b101:
                                op  <= LHU;
                            default:
                                op  <= 5'b11111;
                        endcase
                        rs1  <= instruction[19:15];
                        rd  <= instruction[11:7];
                        imm  <= instruction[31:20];
                        has_imm <= 1;
                    end
                    7'b0100011: begin
                        case(instruction[14:12])
                            3'b000:
                                op  <= SB;
                            3'b001:
                                op  <= SH;
                            3'b010:
                                op  <= SW;
                            default:
                                op  <= 5'b11111;
                        endcase
                        rs1  <= instruction[19:15];
                        rd   <= 0;
                        rs2  <= instruction[24:20];
                        value[0] = instruction[31:25];
                        value[0] = value[0] << 5;
                        value[1] = instruction[11:7];
                        imm  <= value[0] + value[1];
                        has_imm <= 1;
                    end
                    7'b0010011: begin
                        if(instruction[14:12] == 3'b101) begin
                            if(instruction[30] == 0) begin
                                op  <= SRL;
                                imm  <= instruction[25:20];
                            end
                            else begin
                                op  <= SRA;
                            end
                        end
                        else begin
                            case(instruction[14:12])
                                3'b000:
                                    op  <= ADD;
                                3'b001:
                                    op  <= SLL;
                                3'b010:
                                    op  <= SLT;
                                3'b011:
                                    op  <= SLTU;
                                3'b100:
                                    op  <= XOR;
                                3'b110:
                                    op  <= OR;
                                3'b111:
                                    op  <= AND;
                                default:
                                    op  <= 5'b11111;
                            endcase
                            imm  <= instruction[31:20];
                        end
                        rs1  <= instruction[19:15];
                        rd  <= instruction[11:7];
                        has_imm <= 1;
                    end
                    7'b0110011: begin
                        case(instruction[14:12])
                            3'b000: begin
                                if(instruction[30] == 0) begin
                                    op  <= ADD;
                                end
                                else begin
                                    op  <= SUB;
                                end
                            end
                            3'b001:
                                op  <= SLL;
                            3'b010:
                                op  <= SLT;
                            3'b011:
                                op  <= SLTU;
                            3'b100:
                                op  <= XOR;
                            3'b101: begin
                                if(instruction[30] == 0) begin
                                    op  <= SRL;
                                end
                                else begin
                                    op  <= SRA;
                                end
                            end
                            3'b110:
                                op  <= OR;
                            3'b111:
                                op  <= AND;
                            default:
                                op  <= 5'b11111;
                        endcase
                        imm  <= 32'hffffffff;
                        rs1  <= instruction[19:15];
                        rs2  <= instruction[24:20];
                        rd  <= instruction[11:7];
                        has_imm <= 0;
                    end
                endcase
            end
            else begin
                case(instruction[1:0])
                    2'b10: begin
                        case(instruction[15:13])
                            3'b000: begin
                                op <= ADD;
                                value[0] = instruction[12];
                                value[0] = value[0] << 5;
                                value[1] = instruction[6:2];
                                imm <= value[0] + value[1];
                                rd <= instruction[11:7];
                                rs1 <= instruction[11:7];
                                has_imm <= 1;
                            end
                            3'b001: begin
                                op <= JAL_C;
                                value[0] = instruction[12];
                                value[0] = value[0] << 1;
                                value[0] = value[0] + instruction[8];
                                value[0] = value[0] << 2;
                                value[0] = value[0] + instruction[10:9];
                                value[0] = value[0] << 1;
                                value[0] = value[0] + instruction[6];
                                value[0] = value[0] << 1;
                                value[0] = value[0] + instruction[7];
                                value[0] = value[0] << 1;
                                value[0] = value[0] + instruction[2];
                                value[0] = value[0] << 1;
                                value[0] = value[0] + instruction[11];
                                value[0] = value[0] << 3;
                                value[0] = value[0] + instruction[5:3];
                                value[0] = value[0] << 1;
                                imm <= value[0];
                                rd <= 1;
                                has_imm <= 1;
                            end
                            3'b011: begin
                                if(instruction[11:7] == 5'b00010) begin
                                    op <= ADD;
                                    rd <= 2;
                                    value[0] = instruction[12];
                                    value[0] = value[0] << 2;
                                    value[0] = value[0] + instruction[4:3];
                                    value[0] = value[0] << 1;
                                    value[0] = value[0] + instruction[5];
                                    value[0] = value[0] << 1;
                                    value[0] = value[0] + instruction[3];
                                    value[0] = value[0] << 1;
                                    value[0] = value[0] + instruction[6];
                                    value[0] = value[0] << 4;
                                    imm <= value[0];
                                    has_imm <= 1;
                                    rs1 <= 2;
                                end
                                else begin
                                    op <= LUI;
                                    rd <= instruction[11:7];
                                    value[0] = instruction[12];
                                    value[0] = value[0] << 17;
                                    value[1] = instruction[6:2];
                                    value[1] = value[1] << 12;
                                    imm <= value[0] + value[1];
                                    has_imm <= 1;
                                end
                            end
                            3'b100: begin
                                rs1 <= instruction[9:7] + 8;
                                rd <= instruction[9:7] + 8;
                                if(instruction[11:10] == 2'b11) begin
                                    has_imm <= 0;
                                    rs2 <= instruction[4:2] + 8;
                                    case(instruction[6:5])
                                        2'b00:
                                            op <= SUB;
                                        2'b01:
                                            op <= XOR;
                                        2'b10:
                                            op <= OR;
                                        2'b11:
                                            op <= AND;
                                    endcase
                                end
                                else begin
                                    has_imm <= 1;
                                    value[0] = instruction[12];
                                    value[0] = value[0] << 5;
                                    value[1] = instruction[6:2];
                                    imm <= value[0] + value[1];
                                    case(instruction[11:10])
                                        2'b00:
                                            op <= SRL;
                                        2'b01:
                                            op <= SRA;
                                        2'b10:
                                            op <= AND;
                                    endcase
                                end
                            end
                        endcase
                    end
                    2'b00: begin
                        if(instruction[15:13] == 3'b010) begin
                            op <= LW;
                            rd <= instruction[4:2] + 8;
                            rs1 <= instruction[9:7] + 8;
                            value[0] = instruction[12:10];
                            value[0] = value[0] << 3;
                            value[1] = instruction[5];
                            value[1] = value[1] << 6;
                            value[2] = instruction[6];
                            value[2] = value[2] << 2;
                            imm <= value[0] + value[1] + value[2];
                            has_imm <= 1;
                        end
                        else begin
                            op <= SW;
                            rs1 <= instruction[9:7] + 8;
                            rs2 <= instruction[4:2] + 8;
                            value[0] = instruction[12:10];
                            value[0] = value[0] << 3;
                            value[1] = instruction[5];
                            value[1] = value[1] << 6;
                            value[2] = instruction[6];
                            value[2] = value[2] << 2;
                            imm <= value[0] + value[1] + value[2];
                            rd <= 0;
                            has_imm <= 1;
                        end
                    end
                    2'b10: begin
                        case(instruction[15:13])
                            3'b000: begin
                                op <= SLL;
                                rd <= instruction[11:7];
                                rs1 <= instruction[11:7];
                                value[0] = instruction[12];
                                value[0] = value[0] << 5;
                                value[1] = instruction[6:2];
                                imm <= value[0] + value[1];
                                has_imm <= 1;
                            end
                            3'b100: begin
                                if(instruction[6:2] == 5'b00000) begin
                                    op <= JALR;
                                    rs1 <= instruction[11:7];
                                    rd <= 1;
                                    has_imm <= 0;
                                end
                                else begin
                                    op <= ADD;
                                    rd <= instruction[11:7];
                                    rs1 <= instruction[11:7];
                                    rs2 <= instruction[6:2];
                                    has_imm <= 0;
                                end
                            end
                        endcase
                    end
                endcase
            end
        end
    end
    always@(negedge clk) begin
        if(!rst) begin
            op <= op ;
            rs1 <= rs1 ;
            rs2 <= rs2 ;
            rd <= rd ;
            imm <= imm ;
        end
        else begin
            op <= 5'b11111;
        end
    end
endmodule
