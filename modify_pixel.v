`timescale 1ns / 1ps
module modify_pixel #(
    parameter PAGES = 2,
    parameter PNG_W = 64,
    parameter PNG_H = 64,
    parameter FRAME_W = 640,
    parameter FRAME_H = 480,
    parameter STRING_LENGTH = 60,
    parameter DATA_WIDTH = 24,
    parameter MSB_BPP = 8,
    parameter CHAR_ENCODING = 12
    ) (
    input [$clog2(PAGES*PNG_W*PNG_H)-1:0] pattern_addr,
    input [MSB_BPP-1:0] pix_font,
    input [DATA_WIDTH-1:0] char_color,
    input [CHAR_ENCODING-1:0] char_width, 
    input [CHAR_ENCODING-1:0] char_length, 
    input [MSB_BPP-1:0] pix_data,
    input pix_clk, fval, lval, dval,
    input [$clog2(FRAME_W-2):0] start_x,
    input [$clog2(FRAME_H-2):0] start_y,
    output reg [$clog2(PAGES*PNG_W*PNG_H)-1:0] scan_addr,
    output reg [DATA_WIDTH-1:0] pix_modified, 
    output enable_start,
    output reg [$clog2(STRING_LENGTH)-1:0] char_count,
    output reg fval_out, dval_out, lval_out
);

reg start = 1'b0;
integer line = 0, column = 0, pixel_count = 0;
parameter TOP_VALUE = 2**MSB_BPP - 1;
assign enable_start = start;

always @(posedge pix_clk) begin
    scan_addr <= pattern_addr;
    if (dval == 1) begin
        pixel_count <= pixel_count + 1;
        if ((start_y*FRAME_W + start_x-1 + line*FRAME_W == pixel_count) || start == 1'b1) begin
            start <= 1'b1; 
            if (start == 1'b1) begin
                if (column < char_width ) begin // horizontal scanning within one char
                    scan_addr <= pattern_addr + PNG_W*line + column;
                    pix_modified[DATA_WIDTH-1:DATA_WIDTH-MSB_BPP] <= (TOP_VALUE - pix_font)*pix_data/TOP_VALUE + char_color[DATA_WIDTH-1:DATA_WIDTH-MSB_BPP]*pix_font/TOP_VALUE; // RED
                    pix_modified[DATA_WIDTH-MSB_BPP-1:DATA_WIDTH-MSB_BPP*2] <= (TOP_VALUE - pix_font)*pix_data/TOP_VALUE + char_color[DATA_WIDTH-MSB_BPP-1:DATA_WIDTH-MSB_BPP*2]*pix_font/TOP_VALUE; // GREEN
                    pix_modified[DATA_WIDTH-2*MSB_BPP-1:DATA_WIDTH-MSB_BPP*3] <= (TOP_VALUE - pix_font)*pix_data/TOP_VALUE + char_color[DATA_WIDTH-2*MSB_BPP-1:DATA_WIDTH-MSB_BPP*3]*pix_font/TOP_VALUE; // BLUE
                    column <= column + 1; 
                end
                else if (column == char_width && line + 1 == char_length) begin // displaying the string is now completed
                    start <= 1'b0;
                    line <= 0;
                    column <= 0;
                end
                else if (char_count + 1 == STRING_LENGTH) begin // vertical transition from the end of the line to the beginning of the new line
                    start <= 1'b0;
                    char_count <= 0;
                    column <= 0;
                    line <= line + 1;
                    scan_addr <= pattern_addr + PNG_W*line + column;
                    pix_modified[DATA_WIDTH-1:DATA_WIDTH-MSB_BPP] <= (TOP_VALUE - pix_font)*pix_data/TOP_VALUE + char_color[DATA_WIDTH-1:DATA_WIDTH-MSB_BPP]*pix_font/TOP_VALUE; // RED                             
                    pix_modified[DATA_WIDTH-MSB_BPP-1:DATA_WIDTH-MSB_BPP*2] <= (TOP_VALUE - pix_font)*pix_data/TOP_VALUE + char_color[DATA_WIDTH-MSB_BPP-1:DATA_WIDTH-MSB_BPP*2]*pix_font/TOP_VALUE; // GREEN       
                    pix_modified[DATA_WIDTH-2*MSB_BPP-1:DATA_WIDTH-MSB_BPP*3] <= (TOP_VALUE - pix_font)*pix_data/TOP_VALUE + char_color[DATA_WIDTH-2*MSB_BPP-1:DATA_WIDTH-MSB_BPP*3]*pix_font/TOP_VALUE; // BLUE    
                end
                else begin // horizontal transition between two chars
                    char_count <= char_count + 1;
                    column <= 0;
                    scan_addr <= pattern_addr + PNG_W*line + column;
                    pix_modified[DATA_WIDTH-1:DATA_WIDTH-MSB_BPP] <= (TOP_VALUE - pix_font)*pix_data/TOP_VALUE + char_color[DATA_WIDTH-1:DATA_WIDTH-MSB_BPP]*pix_font/TOP_VALUE; // RED                             
                    pix_modified[DATA_WIDTH-MSB_BPP-1:DATA_WIDTH-MSB_BPP*2] <= (TOP_VALUE - pix_font)*pix_data/TOP_VALUE + char_color[DATA_WIDTH-MSB_BPP-1:DATA_WIDTH-MSB_BPP*2]*pix_font/TOP_VALUE; // GREEN       
                    pix_modified[DATA_WIDTH-2*MSB_BPP-1:DATA_WIDTH-MSB_BPP*3] <= (TOP_VALUE - pix_font)*pix_data/TOP_VALUE + char_color[DATA_WIDTH-2*MSB_BPP-1:DATA_WIDTH-MSB_BPP*3]*pix_font/TOP_VALUE; // BLUE    
                end
            end
            else begin
                pix_modified <= {DATA_WIDTH/MSB_BPP{pix_data}};
            end  
        end
        else begin
            pix_modified <= {DATA_WIDTH/MSB_BPP{pix_data}};
        end
    end
    else begin
        pix_modified <= {DATA_WIDTH/MSB_BPP{pix_data}};
    end
    fval_out <= fval; dval_out <= dval; lval_out <= lval;
    if (fval == 0) begin 
        pixel_count <= 0;
        char_count <= 0;
        column <= 0;
        line <= 0;
    end
end

endmodule