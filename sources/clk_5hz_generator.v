`timescale 1ns / 1ps


module clk_5hz_generator(
    input  wire CLK,
    input  wire RESET,
    output reg  slow_clk
    );
    
    reg [23:0] cnt;
    
    always @(posedge CLK) begin
        if (RESET) begin
            cnt <= 0;
            slow_clk <= 0;
        end
        
        else begin
            if (cnt == 24'd12_499_999) begin
                cnt <= 0;
                slow_clk = ~slow_clk;
            end
            else
                cnt <= cnt + 1;
        end
    end
    
endmodule
