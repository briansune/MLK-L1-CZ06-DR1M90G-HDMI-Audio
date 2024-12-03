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

module packet_picker (
	clk_pixel,
	clk_audio,
	reset,
	video_field_end,
	packet_enable,
	packet_pixel_counter,
	audio_sample_word,
	header,
	sub
);
	reg _sv2v_0;
	parameter signed [31:0] VIDEO_ID_CODE = 4;
	parameter real VIDEO_RATE = 0;
	parameter [0:0] IT_CONTENT = 1'b0;
	parameter signed [31:0] AUDIO_BIT_WIDTH = 0;
	parameter signed [31:0] AUDIO_RATE = 0;
	parameter [63:0] VENDOR_NAME = 0;
	parameter [127:0] PRODUCT_DESCRIPTION = 0;
	parameter [7:0] SOURCE_DEVICE_INFORMATION = 0;
	input wire clk_pixel;
	input wire clk_audio;
	input wire reset;
	input wire video_field_end;
	input wire packet_enable;
	input wire [4:0] packet_pixel_counter;
	input wire [(2 * AUDIO_BIT_WIDTH) - 1:0] audio_sample_word;
	output wire [23:0] header;
	output wire [223:0] sub;
	reg [7:0] packet_type = 8'd0;
	wire [23:0] headers [255:0];
	wire [223:0] subs [255:0];
	assign header = headers[packet_type];
	assign sub[0+:56] = subs[packet_type][0+:56];
	assign sub[56+:56] = subs[packet_type][56+:56];
	assign sub[112+:56] = subs[packet_type][112+:56];
	assign sub[168+:56] = subs[packet_type][168+:56];
	assign headers[0] = 24'hxxxx00;
	assign subs[0][0+:56] = 56'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	assign subs[0][56+:56] = 56'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	assign subs[0][112+:56] = 56'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	assign subs[0][168+:56] = 56'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	wire clk_audio_counter_wrap;
	audio_clock_regeneration_packet #(
		.VIDEO_RATE(VIDEO_RATE),
		.AUDIO_RATE(AUDIO_RATE)
	) audio_clock_regeneration_packet(
		.clk_pixel(clk_pixel),
		.clk_audio(clk_audio),
		.clk_audio_counter_wrap(clk_audio_counter_wrap),
		.header(headers[1]),
		.sub(subs[1])
	);
	localparam [3:0] SAMPLING_FREQUENCY = (AUDIO_RATE == 32000 ? 4'b0011 : (AUDIO_RATE == 44100 ? 4'b0000 : (AUDIO_RATE == 88200 ? 4'b1000 : (AUDIO_RATE == 176400 ? 4'b1100 : (AUDIO_RATE == 48000 ? 4'b0010 : (AUDIO_RATE == 96000 ? 4'b1010 : (AUDIO_RATE == 192000 ? 4'b1110 : 4'bxxxx)))))));
	localparam signed [31:0] AUDIO_BIT_WIDTH_COMPARATOR = (AUDIO_BIT_WIDTH < 20 ? 20 : (AUDIO_BIT_WIDTH == 20 ? 25 : (AUDIO_BIT_WIDTH < 24 ? 24 : (AUDIO_BIT_WIDTH == 24 ? 29 : -1))));
	function automatic signed [2:0] sv2v_cast_3_signed;
		input reg signed [2:0] inp;
		sv2v_cast_3_signed = inp;
	endfunction
	localparam [2:0] WORD_LENGTH = sv2v_cast_3_signed(AUDIO_BIT_WIDTH_COMPARATOR - AUDIO_BIT_WIDTH);
	localparam [0:0] WORD_LENGTH_LIMIT = (AUDIO_BIT_WIDTH <= 20 ? 1'b0 : 1'b1);
	reg [(2 * AUDIO_BIT_WIDTH) - 1:0] audio_sample_word_transfer;
	reg audio_sample_word_transfer_control = 1'd0;
	always @(posedge clk_audio) begin
		audio_sample_word_transfer <= audio_sample_word;
		audio_sample_word_transfer_control <= !audio_sample_word_transfer_control;
	end
	reg [1:0] audio_sample_word_transfer_control_synchronizer_chain = 2'd0;
	always @(posedge clk_pixel) audio_sample_word_transfer_control_synchronizer_chain <= {audio_sample_word_transfer_control, audio_sample_word_transfer_control_synchronizer_chain[1]};
	reg sample_buffer_current = 1'b0;
	reg [1:0] samples_remaining = 2'd0;
	reg [191:0] audio_sample_word_buffer [1:0];
	reg [(2 * AUDIO_BIT_WIDTH) - 1:0] audio_sample_word_transfer_mux;
	always @(*) begin
		if (_sv2v_0)
			;
		if (audio_sample_word_transfer_control_synchronizer_chain[0] ^ audio_sample_word_transfer_control_synchronizer_chain[1])
			audio_sample_word_transfer_mux = audio_sample_word_transfer;
		else
			audio_sample_word_transfer_mux = {audio_sample_word_buffer[sample_buffer_current][(((samples_remaining * 2) + 1) * 24) + (23 >= (24 - AUDIO_BIT_WIDTH) ? 23 : (23 + (23 >= (24 - AUDIO_BIT_WIDTH) ? 0 + AUDIO_BIT_WIDTH : (24 - AUDIO_BIT_WIDTH) - 22)) - 1)-:(23 >= (24 - AUDIO_BIT_WIDTH) ? 0 + AUDIO_BIT_WIDTH : (24 - AUDIO_BIT_WIDTH) - 22)], audio_sample_word_buffer[sample_buffer_current][((samples_remaining * 2) * 24) + (23 >= (24 - AUDIO_BIT_WIDTH) ? 23 : (23 + (23 >= (24 - AUDIO_BIT_WIDTH) ? 0 + AUDIO_BIT_WIDTH : (24 - AUDIO_BIT_WIDTH) - 22)) - 1)-:(23 >= (24 - AUDIO_BIT_WIDTH) ? 0 + AUDIO_BIT_WIDTH : (24 - AUDIO_BIT_WIDTH) - 22)]};
	end
	reg sample_buffer_used = 1'b0;
	reg sample_buffer_ready = 1'b0;
	function automatic signed [(24 - AUDIO_BIT_WIDTH) - 1:0] sv2v_cast_C9FA5_signed;
		input reg signed [(24 - AUDIO_BIT_WIDTH) - 1:0] inp;
		sv2v_cast_C9FA5_signed = inp;
	endfunction
	always @(posedge clk_pixel) begin
		if (sample_buffer_used)
			sample_buffer_ready <= 1'b0;
		if (audio_sample_word_transfer_control_synchronizer_chain[0] ^ audio_sample_word_transfer_control_synchronizer_chain[1]) begin
			audio_sample_word_buffer[sample_buffer_current][(samples_remaining * 2) * 24+:24] <= {audio_sample_word_transfer_mux[0+:AUDIO_BIT_WIDTH], sv2v_cast_C9FA5_signed(0)};
			audio_sample_word_buffer[sample_buffer_current][((samples_remaining * 2) + 1) * 24+:24] <= {audio_sample_word_transfer_mux[AUDIO_BIT_WIDTH+:AUDIO_BIT_WIDTH], sv2v_cast_C9FA5_signed(0)};
			if (samples_remaining == 2'd3) begin
				samples_remaining <= 2'd0;
				sample_buffer_ready <= 1'b1;
				sample_buffer_current <= !sample_buffer_current;
			end
			else
				samples_remaining <= samples_remaining + 1'd1;
		end
	end
	reg [191:0] audio_sample_word_packet;
	reg [3:0] audio_sample_word_present_packet;
	reg [7:0] frame_counter = 8'd0;
	wire signed [31:0] k;
	always @(posedge clk_pixel)
		if (reset)
			frame_counter <= 8'd0;
		else if ((packet_pixel_counter == 5'd31) && (packet_type == 8'h02)) begin
			frame_counter = frame_counter + 8'd4;
			if (frame_counter >= 8'd192)
				frame_counter = frame_counter - 8'd192;
		end
	audio_sample_packet #(
		.SAMPLING_FREQUENCY(SAMPLING_FREQUENCY),
		.WORD_LENGTH({WORD_LENGTH[0], WORD_LENGTH[1], WORD_LENGTH[2], WORD_LENGTH_LIMIT})
	) audio_sample_packet(
		.frame_counter(frame_counter),
		.valid_bit(8'b00000000),
		.user_data_bit(8'b00000000),
		.audio_sample_word(audio_sample_word_packet),
		.audio_sample_word_present(audio_sample_word_present_packet),
		.header(headers[2]),
		.sub(subs[2])
	);
	function automatic signed [6:0] sv2v_cast_7_signed;
		input reg signed [6:0] inp;
		sv2v_cast_7_signed = inp;
	endfunction
	auxiliary_video_information_info_frame #(
		.VIDEO_ID_CODE(sv2v_cast_7_signed(VIDEO_ID_CODE)),
		.IT_CONTENT(IT_CONTENT)
	) auxiliary_video_information_info_frame(
		.header(headers[130]),
		.sub(subs[130])
	);
	source_product_description_info_frame #(
		.VENDOR_NAME(VENDOR_NAME),
		.PRODUCT_DESCRIPTION(PRODUCT_DESCRIPTION),
		.SOURCE_DEVICE_INFORMATION(SOURCE_DEVICE_INFORMATION)
	) source_product_description_info_frame(
		.header(headers[131]),
		.sub(subs[131])
	);
	audio_info_frame audio_info_frame(
		.header(headers[132]),
		.sub(subs[132])
	);
	reg audio_info_frame_sent = 1'b0;
	reg auxiliary_video_information_info_frame_sent = 1'b0;
	reg source_product_description_info_frame_sent = 1'b0;
	reg last_clk_audio_counter_wrap = 1'b0;
	always @(posedge clk_pixel) begin
		if (sample_buffer_used)
			sample_buffer_used <= 1'b0;
		if (reset || video_field_end) begin
			audio_info_frame_sent <= 1'b0;
			auxiliary_video_information_info_frame_sent <= 1'b0;
			source_product_description_info_frame_sent <= 1'b0;
			packet_type <= 8'bxxxxxxxx;
		end
		else if (packet_enable) begin
			if (last_clk_audio_counter_wrap ^ clk_audio_counter_wrap) begin
				packet_type <= 8'd1;
				last_clk_audio_counter_wrap <= clk_audio_counter_wrap;
			end
			else if (sample_buffer_ready) begin
				packet_type <= 8'd2;
				audio_sample_word_packet <= audio_sample_word_buffer[!sample_buffer_current];
				audio_sample_word_present_packet <= 4'b1111;
				sample_buffer_used <= 1'b1;
			end
			else if (!audio_info_frame_sent) begin
				packet_type <= 8'h84;
				audio_info_frame_sent <= 1'b1;
			end
			else if (!auxiliary_video_information_info_frame_sent) begin
				packet_type <= 8'h82;
				auxiliary_video_information_info_frame_sent <= 1'b1;
			end
			else if (!source_product_description_info_frame_sent) begin
				packet_type <= 8'h83;
				source_product_description_info_frame_sent <= 1'b1;
			end
			else
				packet_type <= 8'd0;
		end
	end
	initial _sv2v_0 = 0;
endmodule
