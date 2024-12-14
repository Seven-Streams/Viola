module AU(
        input wire clk,
        input wire rst,
        input wire pause,
        input wire[31:0] value1,
        input wire[31:0] value2,
        input wire[4:0] op_input,
        input wire[2:0] rob_number_input,
        input wire[31:0] ls_value,
        output reg[31:0] addr,
        output reg[4:0] op,
        output reg[2:0] rob_number,
        output reg[31:0] ls_value_output
    );
    initial begin
        rob_number = 0;
        op = 5'b11111;
        op_tmp = 5'b11111;
        rob_number_tmp = 0;
        addr = 0;
    end
    reg [31:0] value_tmp;
    reg [4:0] op_tmp;
    reg [2:0] rob_number_tmp;
    reg [31:0] ls_value_tmp;
    always@(posedge clk) begin
        if(!pause) begin
        value_tmp = value1 + value2;
        op_tmp = op_input;
        rob_number_tmp = rob_number_input;
        ls_value_tmp = ls_value;
        end
    end
    always@(negedge clk) begin
        if(!pause) begin
        if(!rst) begin
            ls_value_output <= ls_value_tmp;
            addr <= value_tmp;
            op <= op_tmp;
            rob_number <= rob_number_tmp;
        end
        else begin
            rob_number <= 3'b0;
        end
        end
    end
endmodule
