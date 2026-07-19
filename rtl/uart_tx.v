module uart_tx (
    input  wire       clk,
    input  wire       rst,
    input  wire        baud_tick,
    input  wire        tx_start,
    input  wire [7:0]  tx_data,
    output reg          tx,
    output reg          tx_busy
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    reg [1:0] state;
    reg [2:0] bit_index;
    reg [7:0] data_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            tx        <= 1'b1;
            tx_busy   <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    if (tx_start) begin
                        data_reg <= tx_data;
                        tx_busy  <= 1;
                        state    <= START;
                    end
                end
                START: if (baud_tick) begin
                    tx        <= 1'b0;
                    state     <= DATA;
                    bit_index <= 0;
                end
                DATA: if (baud_tick) begin
                    tx <= data_reg[bit_index];
                    if (bit_index == 7)
                        state <= STOP;
                    else
                        bit_index <= bit_index + 1;
                end
                STOP: if (baud_tick) begin
                    tx      <= 1'b1;
                    tx_busy <= 0;
                    state   <= IDLE;
                end
            endcase
        end
    end
endmodule
