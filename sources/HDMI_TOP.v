`timescale 1ns / 1ps
`default_nettype none

// Project F: Display Controller DVI Demo
// (C)2020 Will Green, Open source hardware released under the MIT License
// Learn more at https://projectf.io

module HDMI_TOP(
    input  wire CLK,                // Board clock is 125 MHz on PYNQ-Z2
    input  wire RESET,              // Reset button
    inout  wire hdmi_tx_cec,        // CE control bidirectional
    output wire hdmi_tx_clk_n,      // HDMI clock differential negative
    output wire hdmi_tx_clk_p,      // HDMI clock differential positive
    output wire [2:0] hdmi_tx_n,    // Three HDMI channels differential negative
    output wire [2:0] hdmi_tx_p,    // Three HDMI channels differential positive
    input  wire [1:0] sw,
    input  wire [3:1] btn,
    output wire clk_lock,           // Clock locked?
    output wire de,                 // Display enable
    output wire [3:0] led
    );

    // PB debouncer
    wire slow_clk;
    wire [3:1] o_btn;
    
    assign led = {o_btn, RESET};
    
    clk_5hz_generator clk_5hz_generator_inst (
        .CLK(CLK),
        .RESET(RESET),
        .slow_clk(slow_clk)
    );
    
    pb_debouncer pb_debouncer_inst (
        .slow_clk(slow_clk),
        .RESET(RESET),
        .i_btn(btn),
        .o_btn(o_btn)
    );

    // Display clocks
    wire pix_clk;                   // Pixel clock
    wire pix_clk_5x;                // 5x clock for 10:1 DDR SerDes

    display_clocks #(               // Display clock for 800x600 60Hz is 40 MHz
        .MULT_MASTER(8.0),
        .DIV_MASTER(1),
        .DIV_5X(5.0),
        .DIV_1X(25),
        .IN_PERIOD(8.0)
    )
    display_clocks_inst (
        .i_clk(CLK),
        .i_rst(RESET),
        .o_clk_1x(pix_clk),
        .o_clk_5x(pix_clk_5x),
        .o_locked(clk_lock)
    );

    // Display timings
    wire signed [15:0] sx;          // Horizontal screen position (signed)
    wire signed [15:0] sy;          // Vertical screen position (signed)
    wire h_sync;                    // Horizontal sync
    wire v_sync;                    // Vertical sync
    wire frame;                     // Frame start

    display_timings #(              // 640x480  800x600 1280x720 1920x1080
        .H_RES(800),                //     640      800     1280      1920
        .V_RES(600),                //     480      600      720      1080
        .H_FP(40),                  //      16       40      110        88
        .H_SYNC(128),               //      96      128       40        44
        .H_BP(88),                  //      48       88      220       148
        .V_FP(1),                   //      10        1        5         4
        .V_SYNC(4),                 //       2        4        5         5
        .V_BP(23),                  //      33       23       20        36
        .H_POL(1),                  //       0        1        1         1
        .V_POL(1)                   //       0        1        1         1
    )
    display_timings_inst (
        .i_pix_clk(pix_clk),
        .i_rst(!clk_lock),
        .o_hs(h_sync),
        .o_vs(v_sync),
        .o_de(de),
        .o_frame(frame),
        .o_sx(sx),
        .o_sy(sy)
    );

    // HDMI RGB output
    wire [7:0] red;
    wire [7:0] green;
    wire [7:0] blue;
    wire [7:0] sprite_red;
    wire [7:0] sprite_green;
    wire [7:0] sprite_blue;
    wire sprite_hit;
    wire [25:0] sprite_x;
    wire [25:0] sprite_y;
    wire [7:0] map_red;
    wire [7:0] map_green;
    wire [7:0] map_blue;
    
    assign red   = sprite_hit ? sprite_red : map_red;
    assign green = sprite_hit ? sprite_green : map_green;
    assign blue  = sprite_hit ? sprite_blue : map_blue;
    
    // Pointer
    pointer pointer_inst (
        .RESET(RESET),
        .sw(sw),
        .btn(btn[3]),
        .sx(sx),
        .sy(sy),
        .v_sync(v_sync),
        .sprite_red(sprite_red),
        .sprite_green(sprite_green),
        .sprite_blue(sprite_blue),
        .sprite_hit(sprite_hit),
        .sprite_x(sprite_x),
        .sprite_y(sprite_y)
    );
    
    // Color map
    color_map color_map_inst (
        .iter(o_iter),
        .map_red(map_red),
        .map_green(map_green),
        .map_blue(map_blue)
    );

    // Mandelbrot iteration calculator
    mandelbrot_calc #(
        .FP_WIDTH(26),
        .FP_INT(6),
        .ITER_MAX(31),
        .ITER_WIDTH(5)
    )
    mandelbrot_calc_inst (
        .CLK(CLK),
        .RESET(RESET),
        .zoom_in(o_btn[2]),
        .zoom_out(o_btn[1]),
        .sprite_x(sprite_x),
        .sprite_y(sprite_y),
        .addra(addra),
        .iter(i_iter)
    );

    // BRAM read and write
    wire [18:0] addra;
    reg  [18:0] addrb;
    wire [4:0] i_iter;
    wire [4:0] o_iter;
    
    blk_mem_gen_0 bram_inst (
        .addra(addra),
        .clka(CLK),
        .dina(i_iter),
        .wea(1'b1),
        .addrb(addrb),
        .clkb(pix_clk),
        .doutb(o_iter)
    );
    
    always @(posedge pix_clk) begin
        if (sy >= 0 && sy < 600 && sx >= -3 && sx < 800-3) begin
            if (sy == 0 && sx == -3)
                addrb <= 0;
            else
                addrb <= addrb + 1;
        end
    end

    // TMDS encoding and serialization
    wire tmds_ch0_serial, tmds_ch1_serial, tmds_ch2_serial, tmds_chc_serial;
    
    dvi_generator dvi_out (
        .i_pix_clk(pix_clk),
        .i_pix_clk_5x(pix_clk_5x),
        .i_rst(!clk_lock),
        .i_de(de),
        .i_data_ch0(blue),
        .i_data_ch1(green),
        .i_data_ch2(red),
        .i_ctrl_ch0({v_sync, h_sync}),
        .i_ctrl_ch1(2'b00),
        .i_ctrl_ch2(2'b00),
        .o_tmds_ch0_serial(tmds_ch0_serial),
        .o_tmds_ch1_serial(tmds_ch1_serial),
        .o_tmds_ch2_serial(tmds_ch2_serial),
        .o_tmds_chc_serial(tmds_chc_serial)  // Encode pixel clock via same path
    );

    // TMDS buffered output
    OBUFDS #(.IOSTANDARD("TMDS_33"))
        tmds_buf_ch0 (.I(tmds_ch0_serial), .O(hdmi_tx_p[0]), .OB(hdmi_tx_n[0]));
    OBUFDS #(.IOSTANDARD("TMDS_33"))
        tmds_buf_ch1 (.I(tmds_ch1_serial), .O(hdmi_tx_p[1]), .OB(hdmi_tx_n[1]));
    OBUFDS #(.IOSTANDARD("TMDS_33"))
        tmds_buf_ch2 (.I(tmds_ch2_serial), .O(hdmi_tx_p[2]), .OB(hdmi_tx_n[2]));
    OBUFDS #(.IOSTANDARD("TMDS_33"))
        tmds_buf_chc (.I(tmds_chc_serial), .O(hdmi_tx_clk_p), .OB(hdmi_tx_clk_n));

    assign hdmi_tx_cec = 1'bz;

endmodule
