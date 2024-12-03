// ==========================================================
//  ____         _                ____                      
// | __ )  _ __ (_)  __ _  _ __  / ___|  _   _  _ __    ___ 
// |  _ \ | '__|| | / _` || '_ \ \___ \ | | | || '_ \  / _ \
// | |_) || |   | || (_| || | | | ___) || |_| || | | ||  __/
// |____/ |_|   |_| \__,_||_| |_||____/  \__,_||_| |_| \___|
//                                                          
// ==========================================================
// Programmed By: BrianSune
// Contact: briansune@gmail.com
// ==========================================================
// 

`timescale 1ns / 1ns

module hdmi_test(
	
	input				sys_clk,
	input				nrst,
	
	output				hdmi_clk,
	output	[2 : 0]		hdmi_d
);
	
	// wire				sys_clock;
	wire				dvi_pixel_clock;
	wire				dvi_bit_clock;
	
	wire				global_rst;
	
	wire				dvi_den;
	wire				dvi_hsync;
	wire				dvi_vsync;
	wire	[23 : 0]	dvi_data;
	
	dvi_pll_v2 dvi_pll_v2_inst0(
		
		.refclk				(sys_clk),
		.pllreset			(~nrst),
		.clk1_out			(dvi_bit_clock),
		.clk0_out			(dvi_pixel_clock),
		.lock				(global_rst)
	);
	
	hdmi_tmds_audio hdmi_tmds_audio_inst0(
		
		.clk_pixel			(dvi_pixel_clock),
		.clk_pixel_x5		(dvi_bit_clock),
		.sys_nrst			(global_rst),
		
		// .den				(dvi_den),
		// .hsync				(dvi_hsync),
		// .vsync				(dvi_vsync),
		// .pixel_data			(dvi_data),
		
		.hdmi_clk			(hdmi_clk),
		.hdmi_d				(hdmi_d)
	);
	
endmodule
