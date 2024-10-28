module RF(
        input wire clk,
        input wire rst,
        input wire commit,
        input wire [4:0] reg_num,
        input wire [31:0] data_in,
        input wire [2:0] num_in,
        input wire instrcution,
        input wire [4:0] rs1,
        input wire [4:0] rs2,
        input wire [4:0] rd,
        input wire [2:0] dependency_num,
        output reg [31:0] value1,
        output reg [31:0] value2,
        output reg [2:0] query1,
        output reg [2:0] query2
    );
    reg busy;
    reg [2:0] last_num;
    reg [31:0] last_reg;
    reg [2:0] query1_tmp;
    reg [2:0] query2_tmp;
    reg [31:0] value1_tmp;
    reg [31:0] value2_tmp;
    reg [2:0]dependency[31:0];
    reg [31:0]regs[31:0];
    always@(posedge clk) begin
        if(!rst) begin
            if(busy && (last_reg != 0)) begin
                dependency[last_reg] = dependency_num;
                busy = 0;
            end
            if(commit) begin
                if(dependency[reg_num] == num_in) begin
                    regs[reg_num] = 0;
                end
                regs[reg_num] = data_in;
            end
        end
    end
    integer i;
    always@(negedge clk) begin
        if(!rst) begin
        if(instrcution) begin
            if(dependency[rs1] == 0) begin
                value1_tmp <= regs[rs1];
                query1_tmp <= 0;
            end
            else begin
                query1_tmp <= dependency[rs1];
            end
            if(dependency[rs2] == 0) begin
                value2_tmp <= regs[rs2];
                query2_tmp <= 0;
            end
            else begin
                query2_tmp <= dependency[rs2];
            end
            busy<= 1;
            last_num <= dependency_num;
            last_reg <= rd;
        end
        end else begin
            for(i = 0; i < 32; i = i + 1) begin
                dependency[i] = 0;
            end
        end
    end
endmodule
