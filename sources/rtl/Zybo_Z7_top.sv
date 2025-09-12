/*
--------------------------------------------------------------------------------------------------------
	Module   : Zybo_Z7_top
	Type     : synthesizable, fpga top
	Standard : SystemVerilog
	Function : example for Arty Z7 devboard
--------------------------------------------------------------------------------------------------------
*/

module Zybo_Z7_top (
		// Clock definition
		input logic			sys_clk_125,	// input clock 125 MHz
		// Switches
		input logic [3:0]	sw,
		input logic [3:0]	btn,
		// RGB leds
		output logic		led5_r,
		output logic		led5_g,
		output logic		led5_b,
		output logic		led6_r,
		output logic		led6_g,
		output logic		led6_b,
		// 4 green leds
		output [3:0]		led);

	alias LD2 = led[0];
	alias LD3 = led[1];
	alias LD4 = led[2];
	alias LD5 = led[3];

	logic 		led_100_pcent;
	logic 		led_60_pcent;
	logic 		led_30_pcent;
	logic 		led_0_pcent;
	logic 		led_dim;

	// Instantiation of the clocking network
	//--------------------------------------
	clk_wiz_0 clknetwork (
		// Clock out ports
		.clk_out1           (clk_60),
		.clk_out2           (clk_100),
		// Status and control signals
		.reset              (sw[3]),
		.locked             (clk_locked),
		// Clock in ports
		.clk_in1            (sys_clk_125)
	);

	// General logic for device
	assign {led5_r, led5_g, led5_b} =
		(btn[0] == 1 ?	{led_100_pcent, led_30_pcent & sw[0], led_0_pcent} :
		(btn[1] == 1 ?	{led_100_pcent, led_0_pcent, led_100_pcent} :
		(btn[2] == 1 ?	{led_60_pcent, led_30_pcent, led_0_pcent & sw[1]} :
		(btn[3] == 1 ?	{led_60_pcent & sw[0], led_30_pcent, led_0_pcent & sw[1]} :
							{led_100_pcent, led_0_pcent, led_0_pcent}))));

	assign {led6_r, led6_g, led6_b} =
		(btn[0] == 1 ?	{led_0_pcent, led_100_pcent & sw[0], led_100_pcent}:
		(btn[1] == 1 ?	{led_0_pcent, led_60_pcent, led_100_pcent}	:
		(btn[2] == 1 ?	{led_100_pcent, led_100_pcent, led_0_pcent}	:
		(btn[3] == 1 ?	{led_60_pcent, led_100_pcent, led_60_pcent & sw[1]}	:
							{led_0_pcent, led_0_pcent, led_100_pcent}))));

	//---------------------------------------------------------------------------------------------------------------------------
	// General purpouse
	//---------------------------------------------------------------------------------------------------------------------------
	logic [7:0]	counter;

	always_ff @(posedge clk_100)
		if (counter == 8'b10101010)
			counter <= '0;
		else counter <= counter + 1;

	assign led_dim = counter[$right(counter)] & counter[$right(counter)+1];

	assign led_100_pcent = led_dim;
	assign led_60_pcent = ~counter[$left(counter)] & led_dim;
	assign led_30_pcent = counter[$left(counter)] & led_dim;
	assign led_0_pcent = 1'b0;

	assign LD2 = btn[0];
	assign LD3 = sw[2];
	assign LD4 = btn[2];
	assign LD5 = !btn[3];

endmodule
