module AU(
        input wire clk,
        input wire rst,
        input wire[31:0] value1,
        input wire[31:0] value2,
        input wire[4:0] op_input,
        input wire[2:0] rob_number_input,
        input wire[31:0] ls_value,
        output reg[31:0] addr,
        output reg[4:0] op,
        output reg[2:0] rob_number,
        output reg[3:0] instruction_number,
        output reg[31:0] ls_value_output
    );

    always@(negedge clk) begin
        if(!rst) begin
            ls_value_output <= ls_value;
            addr <= value1 + value2;
            op <= op_input;
            rob_number <= rob_number_input;
        end
        else begin
            rob_number <= 3'b0;
        end
    end
endmodule
