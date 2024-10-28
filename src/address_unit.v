module AU(
        input wire clk,
        input wire rst,
        input wire[31:0] value1,
        input wire[31:0] value2,
        input wire[4:0] op_input,
        input wire[2:0] reg_number_input,
        output reg[31:0] addr,
        output reg[4:0] op,
        output reg[2:0] reg_number,
        output reg[3:0] instruction_number
    );

    always@(negedge clk) begin
        if(!rst) begin
        addr <= value1 + value2;
        op <= op_input;
        reg_number <= reg_number_input;
        end else begin
            reg_number <= 3'b0;
        end
    end
endmodule
