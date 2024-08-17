`timescale 1ns / 1ps


module color_map(
    input  wire [4:0] iter,
    output reg  [7:0] map_red,
    output reg  [7:0] map_green,
    output reg  [7:0] map_blue
    );
    
    always @(iter) begin
        case (iter)
            5'd0: begin
                map_red <= 8'd0;
                map_green <= 8'd0;
                map_blue <= 8'd0;
            end
            5'd1: begin
                map_red <= 8'd0;
                map_green <= 8'd0;
                map_blue <= 8'd8;
            end
            5'd2: begin
                map_red <= 8'd0;
                map_green <= 8'd0;
                map_blue <= 8'd16;
            end
            5'd3: begin
                map_red <= 8'd4;
                map_green <= 8'd0;
                map_blue <= 8'd31;
            end
            5'd4: begin
                map_red <= 8'd9;
                map_green <= 8'd1;
                map_blue <= 8'd47;
            end
            5'd5: begin
                map_red <= 8'd6;
                map_green <= 8'd2;
                map_blue <= 8'd60;
            end
            5'd6: begin
                map_red <= 8'd4;
                map_green <= 8'd4;
                map_blue <= 8'd73;
            end
            5'd7: begin
                map_red <= 8'd2;
                map_green <= 8'd5;
                map_blue <= 8'd86;
            end
            5'd8: begin
                map_red <= 8'd0;
                map_green <= 8'd7;
                map_blue <= 8'd100;
            end
            5'd9: begin
                map_red <= 8'd6;
                map_green <= 8'd25;
                map_blue <= 8'd119;
            end
            5'd10: begin
                map_red <= 8'd12;
                map_green <= 8'd44;
                map_blue <= 8'd138;
            end
            5'd11: begin
                map_red <= 8'd18;
                map_green <= 8'd63;
                map_blue <= 8'd157;
            end
            5'd12: begin
                map_red <= 8'd24;
                map_green <= 8'd82;
                map_blue <= 8'd177;
            end
            5'd13: begin
                map_red <= 8'd40;
                map_green <= 8'd103;
                map_blue <= 8'd193;
            end
            5'd14: begin
                map_red <= 8'd57;
                map_green <= 8'd125;
                map_blue <= 8'd209;
            end
            5'd15: begin
                map_red <= 8'd95;
                map_green <= 8'd153;
                map_blue <= 8'd219;
            end
            5'd16: begin
                map_red <= 8'd134;
                map_green <= 8'd181;
                map_blue <= 8'd229;
            end
            5'd17: begin
                map_red <= 8'd172;
                map_green <= 8'd208;
                map_blue <= 8'd238;
            end
            5'd18: begin
                map_red <= 8'd211;
                map_green <= 8'd236;
                map_blue <= 8'd248;
            end
            5'd19: begin
                map_red <= 8'd226;
                map_green <= 8'd234;
                map_blue <= 8'd219;
            end
            5'd20: begin
                map_red <= 8'd241;
                map_green <= 8'd233;
                map_blue <= 8'd191;
            end
            5'd21: begin
                map_red <= 8'd244;
                map_green <= 8'd217;
                map_blue <= 8'd143;
            end
            5'd22: begin
                map_red <= 8'd248;
                map_green <= 8'd201;
                map_blue <= 8'd95;
            end
            5'd23: begin
                map_red <= 8'd251;
                map_green <= 8'd185;
                map_blue <= 8'd47;
            end
            5'd24: begin
                map_red <= 8'd255;
                map_green <= 8'd170;
                map_blue <= 8'd0;
            end
            5'd25: begin
                map_red <= 8'd255;
                map_green <= 8'd170;
                map_blue <= 8'd0;
            end
            5'd26: begin
                map_red <= 8'd204;
                map_green <= 8'd128;
                map_blue <= 8'd0;
            end
            5'd27: begin
                map_red <= 8'd178;
                map_green <= 8'd107;
                map_blue <= 8'd0;
            end
            5'd28: begin
                map_red <= 8'd153;
                map_green <= 8'd87;
                map_blue <= 8'd0;
            end
            5'd29: begin
                map_red <= 8'd130;
                map_green <= 8'd70;
                map_blue <= 8'd1;
            end
            5'd30: begin
                map_red <= 8'd106;
                map_green <= 8'd52;
                map_blue <= 8'd3;
            end
            5'd31: begin
                map_red <= 8'd82;
                map_green <= 8'd34;
                map_blue <= 8'd5;
            end
        endcase
    end
    
endmodule
