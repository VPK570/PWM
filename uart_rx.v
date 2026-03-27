`timescale 1ns/1ps
module uart_rx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       rx,
    output reg  [7:0] duty_out,
    output reg        duty_valid
);
    localparam CLKS_PER_BIT = 1042;
    localparam HALF_BIT     = CLKS_PER_BIT / 2;

    localparam IDLE    = 3'd0;
    localparam START   = 3'd1;
    localparam RECEIVE = 3'd2;
    localparam STOP    = 3'd3;
    localparam PROCESS = 3'd4;

    reg [2:0]  state;
    reg [13:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  rx_shift;
    reg [7:0]  rx_byte;
    reg [7:0]  digit [0:2];
    reg [1:0]  digit_count;
    reg [9:0]  val;          // ← moved to module level (Verilog-2001 compatible)

    // 2-FF synchronizer
    reg rx_sync1, rx_sync2;
    always @(posedge clk) begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            clk_count   <= 0;
            bit_index   <= 0;
            rx_shift    <= 8'h00;
            rx_byte     <= 8'h00;
            duty_valid  <= 1'b0;
            digit_count <= 2'd0;
            duty_out    <= 8'd128;
            digit[0]    <= 8'd0;
            digit[1]    <= 8'd0;
            digit[2]    <= 8'd0;
            val         <= 10'd0;
        end else begin
            duty_valid <= 1'b0;

            case (state)
                IDLE: begin
                    if (rx_sync2 == 1'b0) begin
                        state     <= START;
                        clk_count <= 0;
                    end
                end

                START: begin
                    if (clk_count == HALF_BIT) begin
                        if (rx_sync2 == 1'b0) begin
                            state     <= RECEIVE;
                            clk_count <= 0;
                            bit_index <= 0;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                RECEIVE: begin
                    if (clk_count == CLKS_PER_BIT) begin
                        clk_count           <= 0;
                        rx_shift[bit_index] <= rx_sync2;
                        if (bit_index == 3'd7)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                STOP: begin
                    if (clk_count == CLKS_PER_BIT) begin
                        rx_byte   <= rx_shift;
                        state     <= PROCESS;
                        clk_count <= 0;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                PROCESS: begin
                    if (rx_byte >= 8'h30 && rx_byte <= 8'h39) begin
                        if (digit_count < 2'd3) begin
                            digit[digit_count] <= rx_byte - 8'h30;
                            digit_count        <= digit_count + 1;
                        end
                    end else if (rx_byte == 8'h0A || rx_byte == 8'h0D) begin
                        if (digit_count == 2'd3) begin
                            val        = digit[0]*100 + digit[1]*10 + digit[2];
                            duty_out   <= (val > 10'd255) ? 8'd255 : val[7:0];
                            duty_valid <= 1'b1;
                        end else if (digit_count == 2'd2) begin
                            duty_out   <= digit[0]*10 + digit[1];
                            duty_valid <= 1'b1;
                        end else if (digit_count == 2'd1) begin
                            duty_out   <= digit[0];
                            duty_valid <= 1'b1;
                        end
                        digit_count <= 2'd0;
                    end
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
