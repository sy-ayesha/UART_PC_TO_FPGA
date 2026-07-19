module uart_rx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       rst,
    input  wire        rx,
    output reg [7:0]   rx_data,
    output reg          rx_done
);
    localparam integer DIVISOR      = CLK_FREQ / BAUD_RATE;
    localparam integer HALF_DIVISOR = DIVISOR / 2;

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0] state;
    reg [2:0] bit_index;
    integer   count;
    reg [7:0] data_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            rx_done   <= 0;
            count     <= 0;
            bit_index <= 0;
        end else begin
            rx_done <= 0;
            case (state)
                IDLE: begin
                    if (rx == 1'b0) begin
                        count <= 0;
                        state <= START;
                    end
                end
                START: begin
                    if (count == HALF_DIVISOR - 1) begin
                        count <= 0;
                        if (rx == 1'b0) begin
                            state     <= DATA;
                            bit_index <= 0;
                        end else
                            state <= IDLE;
                    end else
                        count <= count + 1;
                end
                DATA: begin
                    if (count == DIVISOR - 1) begin
                        count <= 0;
                        data_reg[bit_index] <= rx;
                        if (bit_index == 7)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                    end else
                        count <= count + 1;
                end
                STOP: begin
                    if (count == DIVISOR - 1) begin
                        count   <= 0;
                        rx_data <= data_reg;
                        rx_done <= 1;
                        state   <= IDLE;
                    end else
                        count <= count + 1;
                end
            endcase
        end
    end
endmodule
