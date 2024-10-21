module AU(
        input wire clk,
        input wire[31:0] value1,
        input wire[31:0] value2,
        input wire is_load_input,
        input wire[3:0] instruction_number_input,
        input wire[2:0] reg_number_input,
        output reg[31:0] addr,
        output reg is_load,
        output reg[2:0] reg_number,
        output reg[3:0] instruction_number
    );
    reg [31:0] addr_tmp;
    always@(posedge clk) begin
        addr_tmp <= value1 + value2;
    end
    always@(negedge clk) begin
        addr <= addr_tmp;
        is_load <= is_load_input;
        reg_number <= reg_number_input;
        instruction_number <= instruction_number_input;
    end
endmodule
