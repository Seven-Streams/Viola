module MEM_BUS(
  input wire clk,
  input wire rst,
  input wire [31:0] data_in,
  input wire [2:0]  num_in,
  output reg [31:0] data_out,
  output reg [2:0]  num_out
);
 reg [31:0] data_tmp;
  reg [2:0]  num_tmp;
  initial begin
    data_tmp = 0;
    num_tmp = 0;
  end
  always @(posedge clk) begin
    if(rst == 1) begin
      data_tmp = 0;
      num_tmp = 0;
    end else begin
      data_tmp = data_in;
      num_tmp = num_in;
    end
  end
  always @(negedge clk) begin
    data_out = data_tmp;
    num_out = num_tmp;
  end
endmodule