module uart_top (
    input  wire       clk,
    input  wire       key0_n,
    input  wire       rx,
    output wire        tx,
    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1
);
    wire rst = ~key0_n;
    wire baud_tick;
    wire [7:0] rx_data;
    wire       rx_done;
    wire       tx_busy;
    reg        tx_start;
    reg  [7:0] tx_data;
    reg  [7:0] display_reg;

    baud_gen #(.CLK_FREQ(50_000_000), .BAUD_RATE(9600)) BG (
        .clk(clk), .rst(rst), .baud_tick(baud_tick)
    );

    uart_rx #(.CLK_FREQ(50_000_000), .BAUD_RATE(9600)) RX (
        .clk(clk), .rst(rst), .rx(rx),
        .rx_data(rx_data), .rx_done(rx_done)
    );

    uart_tx TX (
        .clk(clk), .rst(rst), .baud_tick(baud_tick),
        .tx_start(tx_start), .tx_data(tx_data),
        .tx(tx), .tx_busy(tx_busy)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            display_reg <= 8'b0;
            tx_start    <= 0;
            tx_data     <= 8'b0;
        end else begin
            tx_start <= 0;
            if (rx_done) begin
                display_reg <= rx_data;
                tx_data     <= rx_data;
                tx_start    <= 1;
            end
        end
    end

    hex_to_sevenseg H0 (.hex_in(display_reg[3:0]), .seg_out(HEX0));
    hex_to_sevenseg H1 (.hex_in(display_reg[7:4]), .seg_out(HEX1));
endmodule
