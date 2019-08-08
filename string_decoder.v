`timescale 1ns / 1ps
module string_decoder #(
    parameter STRING_LENGTH = 60,
    parameter CHAR_ENCODING = 12,
    parameter DATA_WIDTH = 24,
    parameter PAGES = 2, 
    parameter PNG_W = 64,
    parameter PNG_H = 64,
    parameter LAST_CHAR = 383
    ) (
    input [CHAR_ENCODING*STRING_LENGTH-1 : 0] str, 
    input [STRING_LENGTH*DATA_WIDTH-1 : 0] str_color,
    input [5*CHAR_ENCODING-1:0] data_in,
    input enable_start,
    input [$clog2(STRING_LENGTH)-1:0] char_count,
    output reg [$clog2((LAST_CHAR-31)*6)-1:0] data_addr, 
    output reg [$clog2(PAGES*PNG_W*PNG_H)-1:0] pattern_addr,
    output reg [CHAR_ENCODING-1:0] char_width,
    output reg [CHAR_ENCODING-1:0] char_length,
    output reg [DATA_WIDTH-1:0] char_color 
);

always @(*) begin 
char_width = data_in[3*CHAR_ENCODING-1:2*CHAR_ENCODING];
char_length = data_in[2*CHAR_ENCODING-1:CHAR_ENCODING];
pattern_addr = PNG_W*data_in[4*CHAR_ENCODING-1:3*CHAR_ENCODING] + data_in[5*CHAR_ENCODING-1:4*CHAR_ENCODING] + data_in[CHAR_ENCODING-1:0]*PNG_W*PNG_H;
char_color = str_color[STRING_LENGTH*DATA_WIDTH - DATA_WIDTH*char_count - 1 -: DATA_WIDTH];
case (enable_start) 
1'b0: begin data_addr <= 'd0; 
             end
1'b1: begin data_addr <= (str[CHAR_ENCODING*STRING_LENGTH - CHAR_ENCODING*char_count - 1 -: CHAR_ENCODING] - 32)*6;
           
             end
endcase

end

endmodule