module baud_gen #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire rst,
    output reg  baud_tick
);
    localparam integer DIVISOR = CLK_FREQ / BAUD_RATE; // ~5208
    integer count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count     <= 0;
            baud_tick <= 0;
        end else if (count == DIVISOR - 1) begin
            count     <= 0;
            baud_tick <= 1;
        end else begin
            count     <= count + 1;
            baud_tick <= 0;
        end
    end
endmodule
