create_clock -name clk -period 20.000 -waveform {0 10} [get_ports clk]
derive_pll_clocks
derive_clock_uncertainty
