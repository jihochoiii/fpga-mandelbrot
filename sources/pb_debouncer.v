`timescale 1ns / 1ps


module pb_debouncer(
    input  wire slow_clk,
    input  wire RESET,
    input  wire [3:1] i_btn,
    output reg  [3:1] o_btn
    );
    
    reg [3:1] reg_i_btn;
    
    always @(posedge slow_clk) begin
        if (RESET) begin
            reg_i_btn[3:1] <= 3'b0;
            o_btn[3:1] <= 3'b0;
        end
        
        else begin
            reg_i_btn[3:1] <= i_btn[3:1];
            
            if (!i_btn[1] && reg_i_btn[1])
                o_btn[1] <= 0;
            else
                o_btn[1] <= i_btn[1] & ~reg_i_btn[1];
            if (!i_btn[2] && reg_i_btn[2])
                o_btn[2] <= 0;
            else
                o_btn[2] <= i_btn[2] & ~reg_i_btn[2];
            if (!i_btn[3] && reg_i_btn[3])
                o_btn[3] <= 0;
            else
                o_btn[3] <= i_btn[3] & ~reg_i_btn[3];
        end
    end

endmodule
