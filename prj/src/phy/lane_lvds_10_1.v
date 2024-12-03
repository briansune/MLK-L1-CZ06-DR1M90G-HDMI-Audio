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

`timescale 1ns/1ns

module lane_lvds_10_1 (
    input wire      I_pixel_clk,
    input wire      I_serial_clk,
    input wire      I_rst,

    input wire[9:0] I_data_in,

    output wire     O_serial_out
);

    reg      S_odd_even;     
    reg      S_odd_even_1d;  
    reg      S_odd_even_2d;  
    reg      S_load_en;      
    reg      S_load_en_1d;   
    reg      S_load_en_2d;   
    reg[9:0] S_shift_data;   
    reg[1:0] S_oddr_data;    


    always @(posedge I_pixel_clk or posedge I_rst) begin
        if(I_rst)
            S_odd_even <= 1'b0;
        else
            S_odd_even <= ~S_odd_even;
    end

    always @(posedge I_serial_clk) begin
        S_odd_even_1d <= S_odd_even;
        S_odd_even_2d <= S_odd_even_1d;
    end

    always @(posedge I_serial_clk) begin
        S_load_en    <= S_odd_even_1d ^ S_odd_even_2d;
        S_load_en_1d <= S_load_en;
        S_load_en_2d <= S_load_en_1d;
    end

    always @(posedge I_serial_clk or posedge I_rst) begin
        if(I_rst)
            S_shift_data <= 'd0;
        else
            if(S_load_en_2d)
                S_shift_data <= I_data_in;
            else 
                S_shift_data <= S_shift_data << 2;
    end

    always @(posedge I_serial_clk) begin
        S_oddr_data <= S_shift_data[9:8];
    end

    DR1_LOGIC_ODDR U_ODDR(
        .clk   ( I_serial_clk   ),
        .rst   ( I_rst          ),

        .d1    ( S_oddr_data[0] ),
        .d0    ( S_oddr_data[1] ),

        .q     ( O_serial_out   )
    );
    
endmodule
