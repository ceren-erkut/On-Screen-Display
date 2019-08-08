`timescale 1ns / 1ps
module main_process #(
    parameter STRING_LENGTH=4, 
    parameter CHAR_ENCODING=12, 
    parameter LAST_CHAR = 383, 
    parameter DATA_WIDTH=24, 
    parameter BPP=12,
    parameter MSB_BPP=8,
    parameter PAGES=2, 
    parameter PNG_W=256, 
    parameter PNG_H=256, 
    parameter FRAME_W=640, 
    parameter FRAME_H=480
    ) (
    input fval, dval, lval, pix_clk,
    input [CHAR_ENCODING*STRING_LENGTH-1:0] str,
    input [STRING_LENGTH*DATA_WIDTH-1:0] str_color,
    input [$clog2(FRAME_W-2):0] start_x, 
    input [$clog2(FRAME_H-2):0] start_y,
    input [MSB_BPP-1:0] pix_data,
    output [DATA_WIDTH-1:0] pix_modified,
    output fval_out, dval_out, lval_out
);

wire [5*CHAR_ENCODING-1:0] data_out;
wire [$clog2((LAST_CHAR-31)*6)-1:0] data_add;
wire [$clog2(PAGES*PNG_W*PNG_H)-1:0] pattern_add;
wire [$clog2(PAGES*PNG_W*PNG_H)-1:0] pattern_addrr;
wire [DATA_WIDTH-1:0] char_color;
wire [CHAR_ENCODING-1:0] char_lengthh;
wire [CHAR_ENCODING-1:0] char_widthh;
wire [$clog2(STRING_LENGTH)-1:0] char_count;
wire [MSB_BPP-1:0] pix_in;
wire start;


pattern_data_rom  #(.PAGES(PAGES), .PNG_W(PNG_W), .PNG_H(PNG_H), .MSB_BPP(MSB_BPP), .LAST_CHAR(LAST_CHAR), .CHAR_ENCODING(CHAR_ENCODING))
d0 (
    .data_addr(data_add), 
    .pattern_addr(pattern_addrr), 
    .pattern_out(pix_in), 
    .data_out(data_out)
);


string_decoder #(.STRING_LENGTH(STRING_LENGTH), .CHAR_ENCODING(CHAR_ENCODING), .DATA_WIDTH(DATA_WIDTH), .PAGES(PAGES), .PNG_W(PNG_W), .PNG_H(PNG_H), .LAST_CHAR(LAST_CHAR)) 
d1 (
    .str(str), 
    .str_color(str_color),
    .data_in(data_out),
    .enable_start(start), 
    .data_addr(data_add),
    .pattern_addr(pattern_add),
    .char_length(char_lengthh), 
    .char_width(char_widthh),
    .char_count(char_count),
    .char_color(char_color)
);
                       
                       
modify_pixel #(.PAGES(PAGES), .PNG_W(PNG_W), .PNG_H(PNG_H), .FRAME_W(FRAME_W), .FRAME_H(FRAME_H), .STRING_LENGTH(STRING_LENGTH), .DATA_WIDTH(DATA_WIDTH), .MSB_BPP(MSB_BPP), .CHAR_ENCODING(CHAR_ENCODING)) 
d2 (
    .pattern_addr(pattern_add), 
    .pix_font(pix_in), 
    .scan_addr(pattern_addrr), 
    .start_x(start_x),
    .start_y(start_y),
    .char_color(char_color),
    .char_length(char_lengthh), 
    .char_width(char_widthh), 
    .pix_clk(pix_clk), 
    .fval(fval), 
    .lval(lval), 
    .dval(dval), 
    .pix_data(pix_data), 
    .pix_modified(pix_modified),
    .enable_start(start),
    .char_count(char_count),
    .fval_out(fval_out), 
    .lval_out(lval_out), 
    .dval_out(dval_out)
);


endmodule