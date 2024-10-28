module Decoder(
        input wire clk,
        input wire rst,
        input [31:0] instruction,
        output reg[4:0] op,
        output reg[4:0] rs1,
        output reg[4:0] rs2,
        output reg[4:0] rd,
        output reg[31:0] imm
    );
    reg [4:0] op_tmp;
    reg[4:0] rs1_tmp;
    reg[4:0] rs2_tmp;
    reg[4:0] rd_tmp;
    reg[31:0] imm_tmp;
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
                op_tmp<= LUI;
                rd_tmp<= instruction[11:7];
                imm_tmp<= (instruction[31:12] << 12);
            end
            7'b0010111: begin
                op_tmp<= AUIPC;
                rd_tmp<= instruction[11:7];
                imm_tmp<= (instruction[31:12] << 12);
            end
            7'b1101111: begin
                op_tmp<= JAL;
                imm_tmp <= (instruction[31] << 20 | instruction[19:12] << 12 | instruction[20] << 11 | instruction[30:21] << 1);
            end
            7'b1100111: begin
                op_tmp<= JALR;
                rs1_tmp<= instruction[19:15];
                rd_tmp<= instruction[11:7];
                imm_tmp<= instruction[31:20];
            end
            7'b1100011: begin
                case (instruction[14:12])
                    3'b000:
                        op_tmp <= BEQ;
                    3'b001:
                        op_tmp <= BNE;
                    3'b100:
                        op_tmp <= BLT;
                    3'b101:
                        op_tmp <= BGE;
                    3'b110:
                        op_tmp <= BLTU;
                    3'b111:
                        op_tmp <= BGEU;
                    default:
                        op_tmp <= 5'b11111;
                endcase
                rs1_tmp <= instruction[19:15];
                rs2_tmp <= instruction[24:20];
                imm_tmp <= (instruction[31] << 12 | instruction[7] << 11 | instruction[30:25] << 5 | instruction[11:8] << 1);
            end
            7'b0000011: begin
                case(instruction[14:12])
                    3'b000:
                        op_tmp <= LB;
                    3'b001:
                        op_tmp <= LH;
                    3'b010:
                        op_tmp <= LW;
                    3'b100:
                        op_tmp <= LBU;
                    3'b101:
                        op_tmp <= LHU;
                    default:
                        op_tmp <= 5'b11111;
                endcase
                rs1_tmp <= instruction[19:15];
                rd_tmp <= instruction[11:7];
                imm_tmp <= instruction[31:20];
            end
            7'b0100011: begin
                case(instruction[14:12])
                    3'b000:
                        op_tmp <= SB;
                    3'b001:
                        op_tmp <= SH;
                    3'b010:
                        op_tmp <= SW;
                    default:
                        op_tmp <= 5'b11111;
                endcase
                rs1_tmp <= instruction[19:15];
                rs2_tmp <= instruction[24:20];
                imm_tmp <= (instruction[31:25] << 5 | instruction[11:7]);
            end
            7'b0010011: begin
                if(instruction[14:12] == 3'b101) begin
                    if(instruction[30] == 0) begin
                        op_tmp <= SRL;
                        imm_tmp <= instruction[25:20];
                    end
                    else begin
                        op_tmp <= SRA;
                    end
                end
                else begin
                    case(instruction[14:12])
                        3'b000:
                            op_tmp <= ADD;
                        3'b001:
                            op_tmp <= SLL;
                        3'b010:
                            op_tmp <= SLT;
                        3'b011:
                            op_tmp <= SLTU;
                        3'b100:
                            op_tmp <= XOR;
                        3'b110:
                            op_tmp <= OR;
                        3'b111:
                            op_tmp <= AND;
                        default:
                            op_tmp <= 5'b11111;
                    endcase
                    imm_tmp <= instruction[31:20];
                end
                rs1_tmp <= instruction[19:15];
                rd_tmp <= instruction[11:7];
            end
            7'b0110011: begin
                case(instruction[14:12])
                    3'b000: begin
                        if(instruction[30] == 0) begin
                            op_tmp <= ADD;
                        end
                        else begin
                            op_tmp <= SUB;
                        end
                    end
                    3'b001:
                        op_tmp <= SLL;
                    3'b010:
                        op_tmp <= SLT;
                    3'b011:
                        op_tmp <= SLTU;
                    3'b100:
                        op_tmp <= XOR;
                    3'b101: begin
                        if(instruction[30] == 0) begin
                            op_tmp <= SRL;
                        end
                        else begin
                            op_tmp <= SRA;
                        end
                    end
                    3'b110:
                        op_tmp <= OR;
                    3'b111:
                        op_tmp <= AND;
                    default:
                        op_tmp <= 5'b11111;
                endcase
                imm_tmp <= 32'hffffffff;
                rs1_tmp <= instruction[19:15];
                rs2_tmp <= instruction[24:20];
                rd_tmp <= instruction[11:7];
            end
        endcase
    end
    always@(negedge clk) begin
        if(!rst) begin
            op <= op_tmp;
            rs1 <= rs1_tmp;
            rs2 <= rs2_tmp;
            rd <= rd_tmp;
            imm <= imm_tmp;
        end
        else begin
            op <= 5'b11111;
        end
    end
endmodule
