module RF(
        input wire clk,
        input wire rst,
        input wire commit,
        input wire [4:0] reg_num,
        input wire [31:0] data_in,
        input wire [2:0] num_in,
        input wire instruction,
        input wire [4:0] rs1,
        input wire [4:0] rs2,
        input wire [4:0] rd,
        input wire [2:0] dependency_num,
        output reg [31:0] value1,
        output reg [31:0] value2,
        output reg [2:0] query1,
        output reg [2:0] query2
    );
    reg [31:0]check;
    reg [2:0]dependency[31:0];
    reg [31:0]regs[31:0];
    reg [4:0] rs1_tmp;
    reg [4:0] rs2_tmp;
    reg [4:0] rd_tmp;
    reg [2:0] dependency_tmp;
    reg [31:0] value1_tmp;
    reg [31:0] value2_tmp;
    reg [2:0] query1_tmp;
    reg [2:0] query2_tmp;
    integer cnt;
    initial begin
        query1 = 0;
        query2 = 0;
        for(cnt = 0; cnt < 32; cnt = cnt + 1) begin
            dependency[cnt] = 0;
            regs[cnt] = 0;
        end
    end
    always@(posedge clk) begin
        check = regs[2];
        rs1_tmp = rs1;
        rs2_tmp = rs2;
        rd_tmp = rd;
        dependency_tmp = dependency_num;
        if(!rst) begin
            if(instruction && (rd != 0)) begin
                dependency[rd] <= dependency_num;
            end
            if(commit) begin
                if(dependency[reg_num] == num_in) begin
                    dependency[reg_num] = 0;
                end
                regs[reg_num] = data_in;
            end
        end
        if(!rst) begin
            if(instruction) begin
                if(dependency[rs1_tmp] == 0) begin
                    value1_tmp = regs[rs1_tmp];
                    query1_tmp = 0;
                end
                else begin
                    query1_tmp = dependency[rs1_tmp];
                end
                if(dependency[rs2_tmp] == 0) begin
                    value2_tmp = regs[rs2_tmp];
                    query2_tmp = 0;
                end
                else begin
                    query2_tmp = dependency[rs2_tmp];
                end
            end
        end
        else begin
            for(i = 0; i < 32; i = i + 1) begin
                dependency[i] = 0;
            end
        end
    end
    integer i;
    always@(negedge clk) begin
        value1 <= value1_tmp;
        value2 <= value2_tmp;
        query1 <= query1_tmp;
        query2 <= query2_tmp;
    end
endmodule
