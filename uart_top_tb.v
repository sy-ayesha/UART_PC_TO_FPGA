`timescale 1ns/1ps
module uart_top_tb;
    reg clk = 0;
    reg key0_n = 0;      // start in reset (active-low, so 0 = reset asserted)
    reg rx_line = 1;
    wire tx_line;
    wire [6:0] HEX0, HEX1;

    uart_top DUT (
        .clk(clk),
        .key0_n(key0_n),
        .rx(rx_line),
        .tx(tx_line),
        .HEX0(HEX0),
        .HEX1(HEX1)
    );

    always #10 clk = ~clk; // 50 MHz

    integer k;
    reg [7:0] test_byte;
    localparam BIT_PERIOD = 104166; // ns, ~9600 baud

    task send_byte(input [7:0] data);
        integer j;
        begin
            rx_line = 0; #(BIT_PERIOD);
            for (j = 0; j < 8; j = j + 1) begin
                rx_line = data[j];
                #(BIT_PERIOD);
            end
            rx_line = 1; #(BIT_PERIOD);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, uart_top_tb);

        key0_n = 0;          // hold reset
        #100 key0_n = 1;     // release reset (button not pressed)
        #1000;

        test_byte = 8'h41;
        $display("---- Sending byte 0x%h ----", test_byte);
        send_byte(test_byte);
        #(BIT_PERIOD * 12);
        $display("HEX1=%b HEX0=%b (expected upper=0x%h lower=0x%h)",
                   HEX1, HEX0, test_byte[7:4], test_byte[3:0]);

        #2000;
        test_byte = 8'h39;
        $display("---- Sending byte 0x%h ----", test_byte);
        send_byte(test_byte);
        #(BIT_PERIOD * 12);
        $display("HEX1=%b HEX0=%b (expected upper=0x%h lower=0x%h)",
                   HEX1, HEX0, test_byte[7:4], test_byte[3:0]);

        #2000;
        $finish;
    end

    initial begin
        $monitor("T=%0t | rx=%b | tx=%b | HEX1=%b | HEX0=%b",
                   $time, rx_line, tx_line, HEX1, HEX0);
    end
endmodule
