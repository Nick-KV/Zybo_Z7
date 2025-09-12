/*
--------------------------------------------------------------------------------------------------------
	Module   : Arty_Z7_test_top
	Type     : synthesizable, fpga top
	Standard : SystemVerilog
	Function : example for Arty Z7 devboard
--------------------------------------------------------------------------------------------------------
*/

module Arty_Z7_test_top #(
		parameter device_config  = "orange") // set to "orange" - for first config and "cyan" - for second
	(
		// Clock definition
		input logic			sys_clk_125,	// input clock 125 MHz
		// Switches
		input logic [3:0]	sw,
		input logic [3:0]	btn,
		// RGB leds
		output logic		led0_r,
		output logic		led0_g,
		output logic		led0_b,
		output logic		led1_r,
		output logic		led1_g,
		output logic		led1_b,
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
		.reset              (btn[0]),
		.locked             (clk_locked),
		// Clock in ports
		.clk_in1            (sys_clk_125)
	);

	// Instantiation of device
	generate
		if (device_config == "orange") begin
			assign {led0_r, led0_g, led0_b} = {led_100_pcent, led_30_pcent & sw[0], led_0_pcent & sw[1]};
			assign {led1_r, led1_g, led1_b} = {led_0_pcent, led_100_pcent & sw[0], led_100_pcent & sw[1]};
		end
		else if (device_config == "cyan") begin
			assign {led1_r, led1_g, led1_b} = {led_0_pcent, led_100_pcent, led_100_pcent};
		end
		else begin
			assign {led0_r, led0_g, led0_b} = {led_100_pcent, led_0_pcent, led_100_pcent};
		end
	endgenerate

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
	assign LD3 = sw[0];
	assign LD4 = btn[2];
	assign LD5 = !btn[3];

endmodule
