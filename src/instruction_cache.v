module IC(
  input wire clk,
  input wire pause,
  input rst,
  input wire[31:0] addr_in,
  input wire asking_in,
  input wire[31:0] instruction_in,
  input wire ins_ready_in,
  output reg[31:0] addr_out,
  output reg[31:0] instruction_out,
  output reg asking_out,
  output reg ready_out
);
 reg[31:0] addr_tmp;
 reg[31:0] cache[31:0][1:0];
 reg[31:0] in_cache_addr;
 reg shoot;
 reg[4:0] rem;
 integer i;
 initial begin
  instruction_out = 0;
  shoot = 0;
  ready_out = 0;
  addr_tmp = 1;
  asking_out = 0;
  addr_out = 0;
    for(i = 0; i < 32; i = i + 1) begin
      cache[i][1] = 32'h0;
      cache[i][0] = 32'h1;
    end
  in_cache_addr = 32'h1;
  rem = 0;
 end

always@(posedge clk) begin
  if(!pause) begin
  if(rst == 1 || ready_out == 1) begin
    addr_tmp = 1;
  end else begin
    if(asking_in == 1) begin
      addr_tmp = addr_in;
      rem = addr_tmp[5:1];
      in_cache_addr = cache[rem][0];
    end
    if(ins_ready_in == 1) begin
      cache[rem][1] = instruction_in;
      cache[rem][0] = addr_tmp;
      in_cache_addr = addr_tmp;
    end
  end
  end
end

always@(negedge clk) begin
  if(!pause)begin
  ready_out = 0;
  asking_out = 0;
  addr_out = 0;
  if(!rst) begin
    if(addr_tmp[0] == 0) begin
        if(addr_tmp == in_cache_addr) begin
          instruction_out = cache[rem][1];
          shoot = 0;
          ready_out = 1;
        end else begin
          if(!shoot) begin
            shoot = 1;
            asking_out = 1;
            addr_out = addr_tmp;
      end
      end
    end
  end else begin
    shoot = 0;
  end
end
end
endmodule