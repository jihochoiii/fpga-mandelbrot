`timescale 1ns / 1ps


module mandelbrot_coord #(
    FP_WIDTH = 26
    )
    (
    input  wire CLK,
    input  wire RESET,
    input  wire zoom_in,
    input  wire zoom_out,
    input  wire [FP_WIDTH-1:0] sprite_x,
    input  wire [FP_WIDTH-1:0] sprite_y,
    output reg  signed [FP_WIDTH-1:0] step,
    output reg  signed [FP_WIDTH-1:0] x_start,
    output reg  signed [FP_WIDTH-1:0] y_start,
    output reg  init
    );
    
    reg reg_zoom_in, reg_zoom_out;
    reg [1:0] zoom;
    reg signed [FP_WIDTH-1:0] reg_x_start_1;
    reg signed [FP_WIDTH-1:0] reg_y_start_1;
    reg signed [FP_WIDTH-1:0] reg_x_start_2;
    reg signed [FP_WIDTH-1:0] reg_y_start_2;

    reg [1:0] state;
    localparam IDLE     = 2'b00;
    localparam INIT     = 2'b01;
    localparam ZOOM_IN  = 2'b10;
    localparam ZOOM_OUT = 2'b11;
    
    always @(posedge CLK) begin
        if (RESET) begin
            state <= INIT;
            init <= 0;
            zoom <= 0;
            reg_zoom_in <= 0;
            reg_zoom_out <= 0;
        end
        
        else begin
            reg_zoom_in <= zoom_in;
            reg_zoom_out <= zoom_out;
            
            case (state)
                INIT: begin
                    state <= IDLE;
                    init <= 1;
                    step <= 26'b00_0000_0000_0001_0000_0000_0000;       // 2^(-8)
                    x_start <= 26'b11_1110_0000_0000_0000_0000_0000;    // -2.0
                    y_start <= 26'b00_0001_0010_1100_0000_0000_0000;    // 1.171875
                end
                ZOOM_IN: begin
                    state <= IDLE;
                    init <= 1;
                    step <= step >> 2;
                    x_start <= x_start + ((sprite_x + 8) * step) - (26'd400 * (step >> 2));
                    y_start <= y_start - ((sprite_y + 8) * step) + (26'd300 * (step >> 2));
                    zoom <= zoom + 1;
                    if (zoom == 1) begin
                        reg_x_start_1 <= x_start;
                        reg_y_start_1 <= y_start;
                    end
                    else if (zoom == 2) begin
                        reg_x_start_2 <= x_start;
                        reg_y_start_2 <= y_start;
                    end
                end
                ZOOM_OUT: begin
                    state <= IDLE;
                    init <= 1;
                    step <= step << 2;
                    zoom <= zoom - 1;
                    if (zoom == 1) begin
                        x_start <= 26'b11_1110_0000_0000_0000_0000_0000;
                        y_start <= 26'b00_0001_0010_1100_0000_0000_0000;
                    end
                    else if (zoom == 2) begin
                        x_start <= reg_x_start_1;
                        y_start <= reg_y_start_1;
                    end
                    else if (zoom == 3) begin
                        x_start <= reg_x_start_2;
                        y_start <= reg_y_start_2;
                    end
                end
                default: begin
                    init <= 0;
                    if (zoom_in && !reg_zoom_in && zoom < 3)
                        state <= ZOOM_IN;
                    else if (zoom_out & !reg_zoom_out && zoom > 0)
                        state <= ZOOM_OUT;
                end
            endcase
        end
    end
    
endmodule
