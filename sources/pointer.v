`timescale 1ns / 1ps


module pointer(
    input  wire RESET,
    input  wire [1:0] sw,
    input  wire btn,
    input  wire [15:0] sx,
    input  wire [15:0] sy,
    input  wire v_sync,
    output wire [7:0] sprite_red,
    output wire [7:0] sprite_green,
    output wire [7:0] sprite_blue,
    output wire sprite_hit,
    output reg  [25:0] sprite_x,
    output reg  [25:0] sprite_y
    );
    
    wire sprite_hit_x, sprite_hit_y;
    
    assign sprite_hit_x = (sx >= sprite_x) && (sx < sprite_x + 16);
    assign sprite_hit_y = (sy >= sprite_y) && (sy < sprite_y + 16);
    assign sprite_hit   = sprite_hit_x & sprite_hit_y;
    
    assign sprite_red   = sprite_hit ? 8'hFF : 8'hXX;
    assign sprite_green = sprite_hit ? 8'h00 : 8'hXX;
    assign sprite_blue  = sprite_hit ? 8'h00 : 8'hXX;

    always @(posedge v_sync) begin
        if (RESET) begin
            sprite_x <= 26'd0;
            sprite_y <= 26'd0;
        end
        
        else begin
            if (btn && sw == 2'b00 && sprite_x > 0)            // Move left
                sprite_x <= sprite_x - 1;
            else if (btn && sw == 2'b01 && sprite_x < 800-16)  // Move right
                sprite_x <= sprite_x + 1;
            else if (btn && sw == 2'b10 && sprite_y > 0)       // Move up
                sprite_y <= sprite_y - 1;
            else if (btn && sw == 2'b11 && sprite_y < 600-16)  // Move down
                sprite_y <= sprite_y + 1;
        end
    end
    
endmodule
