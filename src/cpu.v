// RISCV32 CPU top module
// port modifi_fation allowed for debugging purposes
module cpu(
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
	input  wire					        rdy_in,			// ready signal, pause cpu when low

  input  wire [ 7:0]          mem_din,		// data input bus
  output wire [ 7:0]          mem_dout,		// data output bus
  output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
  output wire                 mem_wr,			// write/read signal (1 for write)
	
	input  wire                 io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here
// Specifi_fations:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indi_fates program stop (will output '\0' through uart tx)

  assign mem_dout = lsb.ram_data;
  assign mem_a = lsb.ram_addr;
  assign mem_wr = lsb.ram_writing;
  assign dbgreg_dout = 0;

reg pause = 1;

always @(posedge clk_in) begin
  pause <= (!rdy_in) | io_buffer_full;
end

AU au(
  .clk(clk_in),
  .rst(i_f.rst),
  .pause(pause),
  .value1(rs.memory_value1),
  .value2(rs.memory_imm),
  .op_input(rs.memory_op),
  .rob_number_input(rs.memory_des),
  .ls_value(rs.memory_value2)
);

ALU alu(
  .pause(pause),
  .clk(clk_in),
  .rst(i_f.rst),
  .value_1(rs.alu_value1),
  .value_2(rs.alu_value2),
  .is_branch_input(rs.is_branch_out),
  .op(rs.alu_op),
  .des_input(rs.alu_des)
);

IF i_f(
  .pause(pause),
  .clk(clk_in),
  .data(ic.instruction_out),
  .data_ready(ic.ready_out),
  .branch_taken(rob.branch_taken),
  .branch_pc(rob.branch_pc),
  .jalr_addr(rob.jalr_pc),
  .jalr_ready(rob.jalr_ready),
  .pc_ready(rob.pc_ready),
  .nxt_pc(rob.nxt_pc),
  .lsb_full(lsb.if_full),
  .iq_full(iq.iq_full),
  .branch_not_taken(rob.branch_not_taken)
);

Decoder decoder(
  .pause(pause),
  .clk(clk_in),
  .rst(i_f.rst),
  .instruction(i_f.instruction)
);

IQ iq(
  .pause(pause),
  .clk(clk_in),
  .rst(i_f.rst),
  .op(decoder.op),
  .rs1(decoder.rs1),
  .rs2(decoder.rs2),
  .rd(decoder.rd),
  .imm(decoder.imm),
  .has_imm(decoder.has_imm),
  .rob_full(rob.rob_full),
  .rs_full(rs.rs_full)
);

ROB rob(
  .pause(pause),
  .clk(clk_in),
  .rst(i_f.rst),
  .has_imm(iq.has_imm_out),
  .imm(iq.imm_out),
  .now_pc(i_f.pc),
  .rd(iq.rd_out),
  .op(iq.op_out),
  .value1_rf(rf.value1),
  .value2_rf(rf.value2),
  .query1_rf(rf.query1),
  .query2_rf(rf.query2),
  .alu_num(alu.des_rob),
  .alu_value(alu.result),
  .is_branch_input(alu.is_branch_out),
  .mem_num(mem_bus.num_out),
  .mem_value(mem_bus.data_out),
  .ready_load_num(lsb.can_be_load)
);

RF rf(
  .pause(pause),
  .clk(clk_in),
  .rst(i_f.rst),
  .commit(rob.commit),
  .reg_num(rob.rd_out),
  .data_in(rob.value_out),
  .num_in(rob.num_out),
  .instruction(iq.shooted),
  .rs1(iq.rs1_tmp),
  .rs2(iq.rs2_tmp),
  .rd(iq.rd_tmp),
  .dependency_num(rob.tail) 
);

RS rs(
  .pause(pause),
  .clk(clk_in),
  .rst(i_f.rst),
  .alu_data(alu.result),
  .alu_des_in(alu.des_rs),
  .memory_data(mem_bus.data_out),
  .memory_des_in(mem_bus.num_out),
  .des_in(rob.target),
  .op(rob.op_out),
  .value1(rob.value1_out),
  .value2(rob.value2_out),
  .query1(rob.query1_out),
  .query2(rob.query2_out),
  .is_branch_input(rob.is_branch_out),
  .imm_in(rob.imm_out)
);

LSB lsb(
  .pause(pause),
  .clk(clk_in),
  .rst(i_f.rst),
  .pc_addr(ic.addr_out),
  .new_ins(ic.asking_out),
  .addr(au.addr),
  .data(au.ls_value_output),
  .rob_number(au.rob_number),
  .op(au.op),
  .committed_number(rob.ls_num_out),
  .ram_loaded_data(mem_din)
);

IC ic(
  .pause(pause),
  .clk(clk_in),
  .rst(i_f.rst),
  .addr_in(i_f.addr),
  .asking_in(i_f.asking),
  .instruction_in(lsb.ins_value),
  .ins_ready_in(lsb.ins_ready)
);

MEM_BUS mem_bus(
  .pause(pause),
  .clk(clk_in),
  .rst(i_f.rst),
  .data_in(lsb.output_value),
  .num_in(lsb.output_number)
);

endmodule

