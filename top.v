`timescale 1ns / 1ps
module top #(
    parameter STRING_LENGTH=4,
    parameter CHAR_ENCODING=8, // ASCII: 8 | Unicode(Turkish): 12
    parameter LAST_CHAR = 255,   
    parameter BPP=12,
    parameter PAGES=1, 
    parameter PNG_W=256, 
    parameter PNG_H=256, 
    parameter FRAME_W=640,
    parameter FRAME_H=480,
    parameter FPS=25, // 40 ms
    parameter CLK_PERIOD=100, // nanoseconds
    parameter MSB_BPP=8,
    parameter COLORED = 1,
    parameter DATA_WIDTH = COLORED ? 3*MSB_BPP : MSB_BPP  
    ) (
    input sys_clk, pix_clk, rstb, read,
    input [CHAR_ENCODING*STRING_LENGTH-1 : 0] str,
    input [STRING_LENGTH*DATA_WIDTH-1 : 0] str_color,
    input [$clog2(FRAME_W-2):0] start_x,
    input [$clog2(FRAME_H-2):0] start_y
);

wire fval, dval, lval;
wire [DATA_WIDTH-1:0] pix_modified;
wire [BPP-1:0] pix_data;
wire [$clog2(FRAME_W):0] pix; 
wire [$clog2(FRAME_H):0] line;
wire fval_out, dval_out, lval_out;

main_process #(.STRING_LENGTH(STRING_LENGTH), .CHAR_ENCODING(CHAR_ENCODING), .LAST_CHAR(LAST_CHAR), .DATA_WIDTH(DATA_WIDTH), .BPP(BPP), .PAGES(PAGES), .PNG_W(PNG_W), .PNG_H(PNG_H), .FRAME_W(FRAME_W), .FRAME_H(FRAME_H))
d5 (
    .fval(fval), 
    .lval(lval), 
    .dval(dval), 
    .pix_clk(pix_clk),
    .str(str),
    .str_color(str_color), 
    .start_x(start_x), 
    .start_y(start_y),
    .pix_data(150), // pix_data[BPP-1:BPP-MSB_BPP] 
    .pix_modified(pix_modified),
    .fval_out(fval_out), 
    .dval_out(dval_out), 
    .lval_out(lval_out)
);
    
pgm_reader #(.FILE_PREFIX("img"), .FILE_EXT(".pgm"), .WIDTH(FRAME_W), .HEIGHT(FRAME_H), .BPP(BPP)) 
d3 (
    .rstb(rstb),
    .clk(sys_clk),
    .read(read),
    .row(line),
    .column(pix),
    .data_out(pix_data)
);

frame_timing_generator #(.FPS(FPS), .CLK_PERIOD(CLK_PERIOD), .WIDTH(FRAME_W), .HEIGHT(FRAME_H), .T_IDLE2FVAL(8192), .T_LVALHIGH_DVALHIGH(16), .T_DVALLOW_LVALLOW(16), .T_LVALLOW(16))
d4 (
    .clk(pix_clk),
    .rstb(rstb),
    .en(1'b1),
    .fval(fval),
    .lval(lval),
    .dval(dval),
    .pix(pix),
    .line(line)
);

file_frame_grabber #(.WIDTH(FRAME_W), .HEIGHT(FRAME_H), .BPP(MSB_BPP), .OUTPUT_PATH("output/"), .SCALETO8BIT(1), .COLORED(COLORED), .DATA_WIDTH(DATA_WIDTH)) 
d6 (
    .rstb(rstb),
    .pix_clk(pix_clk),
    .fval(fval_out),
    .lval(lval_out),
    .dval(dval_out),
    .pix_data(pix_modified)
);

endmodule