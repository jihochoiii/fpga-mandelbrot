`timescale 1ns / 1ps


module mandelbrot_calc #(
    FP_WIDTH = 26,                               // Total width of fixed-point number representation
    FP_INT = 6,                                  // Integer bits in fixed-point number
    ITER_MAX = 31,                               // Maximum # of iterations
    ITER_WIDTH = $clog2(ITER_MAX+1)              // Maximum iteration width
    )
    (
    input  wire CLK,
    input  wire RESET,
    input  wire zoom_in,
    input  wire zoom_out,
    input  wire [FP_WIDTH-1:0] sprite_x,         // Horizontal position of pointer
    input  wire [FP_WIDTH-1:0] sprite_y,         // Vertical position of pointer
    output reg  [18:0] addra,                    // BRAM write address
    output reg  [ITER_WIDTH-1:0] iter            // BRAM write data (# of iterations)
    );
    
    localparam FP_FRAC = FP_WIDTH - FP_INT;      // Fractional bits in fixed-point number
    localparam FB_WIDTH = 800;
    localparam FB_HEIGHT = 600;
    
    wire signed [FP_WIDTH-1:0] step;
    wire signed [FP_WIDTH-1:0] x_start;          // Starting real position
    wire signed [FP_WIDTH-1:0] y_start;          // Starting imaginary position
    wire init;
    
    mandelbrot_coord #(
        .FP_WIDTH(FP_WIDTH)
    )
    mandelbrot_coord_inst (
        .CLK(CLK),
        .RESET(RESET),
        .zoom_in(zoom_in),
        .zoom_out(zoom_out),
        .sprite_x(sprite_x),
        .sprite_y(sprite_y),
        .step(step),
        .x_start(x_start),
        .y_start(y_start),
        .init(init)
    );
    
    reg signed [FP_WIDTH-1:0] x0;                // Current real component of C
    reg signed [FP_WIDTH-1:0] y0;                // Current imaginary component of C
    reg signed [FP_WIDTH-1:0] x;                 // Real component of Zn
    reg signed [FP_WIDTH-1:0] y;                 // Imaginary component of Zn
    reg signed [2*FP_WIDTH-1:0] x_temp;          // Temporary real component of Zn (for sign extension)
    reg signed [2*FP_WIDTH-1:0] y_temp;          // Temporary imaginary component of Zn (for sign extension)
    reg [$clog2(FB_WIDTH+1)-1:0] horizontal;     // Current horizontal pixel position on screen
    
    reg calculating;
    reg state;
    localparam IDLE = 1'b0;
    localparam NEXT = 1'b1;
    
    always @(posedge CLK) begin
        // Initial pixel position
        if (RESET | init) begin
            calculating <= 1;
            state <= IDLE;
            addra <= 0;
            iter <= 0;
            x0 <= x_start;
            y0 <= y_start;
            x <= 0;
            y <= 0;
            x_temp <= 0;
            y_temp <= 0;
            horizontal <= 0;
        end
        
        else begin
            // Calculate the escape time (n) for current coordinate C
            if (calculating) begin
                case (state)
                    NEXT: begin
                        state <= IDLE;
                        x_temp <= x;
                        y_temp <= y;
                    end
                    default: begin
                        // If |Zn| <= 2  or iter < ITER_MAX
                        if (((((x_temp * x_temp) + (y_temp * y_temp)) >>> 2*FP_FRAC) <= 4) && (iter < ITER_MAX)) begin
                            state <= NEXT;
                            iter <= iter + 1;
                            x <= ((x_temp * x_temp) >>> FP_FRAC) - ((y_temp * y_temp) >>> FP_FRAC) + x0;
                            y <= ((x_temp * y_temp) >>> (FP_FRAC-1)) + y0;
                        end
                        else
                            calculating <= 0;
                    end
                endcase
            end
            
            // Next pixel position
            else if (addra < 480000-1) begin
                calculating <= 1;
                addra <= addra + 1;
                iter <= 0;
                x <= 0;
                y <= 0;
                x_temp <= 0;
                y_temp <= 0;
                if (horizontal == FB_WIDTH-1) begin
                    horizontal <= 0;
                    x0 <= x_start;
                    y0 <= y0 - step;
                end
                else begin
                    horizontal <= horizontal + 1;
                    x0 <= x0 + step;
                end
            end
        end
    end
    
endmodule
