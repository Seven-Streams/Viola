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
               BLTU = 5'b11011;
    always@(posedge clk) begin
        op = 5'b11111;
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
                imm  <= (instruction[31] << 20 | instruction[19:12] << 12 | instruction[20] << 11 | instruction[30:21] << 1);
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
                imm  <= (instruction[31] << 12 | instruction[7] << 11 | instruction[30:25] << 5 | instruction[11:8] << 1);
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
                imm  <= (instruction[31:25] << 5 | instruction[11:7]);
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
