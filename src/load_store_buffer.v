module LSB(
        input wire clk,
        input wire[31:0] addr,
        input wire is_load,
        input wire[2:0] reg_number,
        input wire[2:0] instruction_number,//This is to show the type of load and store(sb, sh.etc).
        input wire[2:0] committed_number,
        input wire[31:0] store_value,
        output reg[2:0] output_reg,
        output reg[31:0] output_value0,
        output reg[31:0] output_value1,
        output reg[31:0] output_value2,
        output reg[31:0] output_value3,
        output reg buffer_full
    );
    reg output_busy;
    reg [2:0]buffer[7:0];
    reg [2:0]buffer_ins_type[7:0];
    reg [2:0]buffer_addr[7:0];
    reg [31:0]buffer_data[7:0];
    reg [0:0]buffer_ready[7:0];
    reg [2:0]head;
    reg [2:0]tail;
    initial begin
        buffer_full = 0;
        buffer_ready[0] = 0;
        buffer_ready[1] = 0;
        buffer_ready[2] = 0;
        buffer_ready[3] = 0;
        buffer_ready[4] = 0;
        buffer_ready[5] = 0;
        buffer_ready[6] = 0;
        buffer_ready[7] = 0;
        head = 0;
        tail = 1;
        output_busy = 0;
    end
    integer i;
    always@(posedge clk) begin
        if(!buffer_full) begin
            if(reg_number != 0) begin
                buffer[tail] <= reg_number;
                buffer_ins_type[tail] <= instruction_number;
                buffer_addr[tail] <= addr;
                buffer_ready[tail] <= 0;
                tail <= tail + 1;
            end
        end
        if(committed_number != 0) begin
            for(i = 0; i < 8; i++) begin
                if(buffer[i] == committed_number) begin
                  buffer_data[i] <= store_value;
                  buffer_ready[i] <= 1;
                end
            end
        end
    end

    always@(negedge clk) begin
        if(head == (tail + 1)) begin
            buffer_full <= 1;
        end
        if((!output_busy)) begin

        end
        //TODO:shoot the ready instructions.
    end
endmodule
