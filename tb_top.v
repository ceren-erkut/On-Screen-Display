`timescale 1ns / 1ps
module tb_top;
    parameter FPS=25; // 40 ms
    parameter CLK_PERIOD=100; // nanoseconds
    parameter STRING_LENGTH=4;
    parameter CHAR_ENCODING=8; // ASCII: 8 | Unicode(Turkish): 12
    parameter LAST_CHAR = 255;
    parameter PAGES=1, PNG_W=256, PNG_H=256, FRAME_W=640, FRAME_H=480;
    parameter BPP=12;
    parameter MSB_BPP=8;
    parameter COLORED = 1;     
    parameter DATA_WIDTH = COLORED ? 3*MSB_BPP : MSB_BPP;
    
reg sys_clk, pix_clk, rstb, read;
reg [CHAR_ENCODING*STRING_LENGTH-1 : 0] str;
reg [STRING_LENGTH*DATA_WIDTH-1 : 0] str_color;
reg [$clog2(FRAME_W-2):0] start_x;
reg [$clog2(FRAME_H-2):0] start_y;


top #(.STRING_LENGTH(STRING_LENGTH), .CHAR_ENCODING(CHAR_ENCODING), .LAST_CHAR(LAST_CHAR), .BPP(BPP), .PAGES(PAGES), .PNG_W(PNG_W), .PNG_H(PNG_H), .FRAME_W(FRAME_W), .FRAME_H(FRAME_H), .FPS(FPS), .CLK_PERIOD(CLK_PERIOD), .MSB_BPP(MSB_BPP), .COLORED(COLORED), .DATA_WIDTH(DATA_WIDTH))
d5 (
    .sys_clk(sys_clk),
    .pix_clk(pix_clk),
    .rstb(rstb),
    .read(read),
    .str(str),
    .str_color(str_color), 
    .start_x(start_x), 
    .start_y(start_y) 
    
);
    

initial begin
    rstb = 1'b0;
    read = 1'b0;
    sys_clk = 1'b1;
    pix_clk = 1'b1;

    str[CHAR_ENCODING*STRING_LENGTH-1 : CHAR_ENCODING*STRING_LENGTH-CHAR_ENCODING] = 'h130; // ?
    str[CHAR_ENCODING*STRING_LENGTH-1-CHAR_ENCODING : CHAR_ENCODING*STRING_LENGTH-CHAR_ENCODING*2] = 'h131; // ?
    str[CHAR_ENCODING*STRING_LENGTH-1-CHAR_ENCODING*2 : CHAR_ENCODING*STRING_LENGTH-CHAR_ENCODING*3] = 'h020;// space
    str[CHAR_ENCODING*STRING_LENGTH-1-CHAR_ENCODING*3 : CHAR_ENCODING*STRING_LENGTH-CHAR_ENCODING*4] = 'h0B0;// degree sign
    
    str_color[STRING_LENGTH*DATA_WIDTH-1 : STRING_LENGTH*DATA_WIDTH-DATA_WIDTH] = 'hDA3210; // M orange
    str_color[STRING_LENGTH*DATA_WIDTH-1-DATA_WIDTH : STRING_LENGTH*DATA_WIDTH-DATA_WIDTH*2] = 'h003210; // i dark green
    str_color[STRING_LENGTH*DATA_WIDTH-1-DATA_WIDTH*2 : STRING_LENGTH*DATA_WIDTH-DATA_WIDTH*3] = 'h000000; // k black
    str_color[STRING_LENGTH*DATA_WIDTH-1-DATA_WIDTH*3 : STRING_LENGTH*DATA_WIDTH-DATA_WIDTH*4] = 'h0FD210; // r green
//    str_color[STRING_LENGTH*DATA_WIDTH-1-24*4 : STRING_LENGTH*DATA_WIDTH-24*5] = 24'h0F10EE; // o blue
//    str_color[STRING_LENGTH*DATA_WIDTH-1-24*5 : STRING_LENGTH*DATA_WIDTH-24*6] = 24'hEEEEEE; // - white
//    str_color[STRING_LENGTH*DATA_WIDTH-1-24*6 : STRING_LENGTH*DATA_WIDTH-24*7] = 24'h253225; // T grayish green
//    str_color[STRING_LENGTH*DATA_WIDTH-1-24*7 : STRING_LENGTH*DATA_WIDTH-24*8] = 24'h9A0510; // a red
//    str_color[STRING_LENGTH*DATA_WIDTH-1-24*8 : STRING_LENGTH*DATA_WIDTH-24*9] = 24'h777777; // s gray
//    str_color[STRING_LENGTH*DATA_WIDTH-1-24*9 : STRING_LENGTH*DATA_WIDTH-24*10] = 24'h888808; // a yellow
//    str_color[STRING_LENGTH*DATA_WIDTH-1-24*10 : STRING_LENGTH*DATA_WIDTH-24*11] = 24'hFFFFFF; // r white
//    str_color[STRING_LENGTH*DATA_WIDTH-1-24*11 : STRING_LENGTH*DATA_WIDTH-24*12] = 24'h00FF00; // i green
//    str_color[STRING_LENGTH*DATA_WIDTH-1-24*12 : STRING_LENGTH*DATA_WIDTH-24*13] = 24'h0000FF; // m blue

    start_x = 1;
    start_y = 1;
    repeat (16) @(posedge sys_clk);
    rstb = 1'b1;
    repeat (16) @(posedge sys_clk);
    read = 1'b1;
    @(posedge sys_clk);
    read = 1'b0;
    
    #(CLK_PERIOD*1000000*1) // 2 frames
    start_x = 300;
    start_y = 250;
    str[CHAR_ENCODING*STRING_LENGTH-1 : CHAR_ENCODING*STRING_LENGTH-CHAR_ENCODING] = 'hDE; // ? (15E in unicode)
    str[CHAR_ENCODING*STRING_LENGTH-1-CHAR_ENCODING : CHAR_ENCODING*STRING_LENGTH-CHAR_ENCODING*2] = 'hFE; // ? (15F in unicode)
    str[CHAR_ENCODING*STRING_LENGTH-1-CHAR_ENCODING*2 : CHAR_ENCODING*STRING_LENGTH-CHAR_ENCODING*3] = 'h0F6;// ö
    str[CHAR_ENCODING*STRING_LENGTH-1-CHAR_ENCODING*3 : CHAR_ENCODING*STRING_LENGTH-CHAR_ENCODING*4] = 'h0D6;//Ö
    
    #(CLK_PERIOD*1000000*1) // 2 frames
    start_x = 500;
    start_y = 380;
    str[CHAR_ENCODING*STRING_LENGTH-1 : CHAR_ENCODING*STRING_LENGTH-CHAR_ENCODING] = 'hF0; // ? (11F in unicode)
    str[CHAR_ENCODING*STRING_LENGTH-1-CHAR_ENCODING : CHAR_ENCODING*STRING_LENGTH-CHAR_ENCODING*2] = 'hD0; // ? (11E in unicode)
    str[CHAR_ENCODING*STRING_LENGTH-1-CHAR_ENCODING*2 : CHAR_ENCODING*STRING_LENGTH-CHAR_ENCODING*3] = 'h0E7;// ç
    str[CHAR_ENCODING*STRING_LENGTH-1-CHAR_ENCODING*3 : CHAR_ENCODING*STRING_LENGTH-CHAR_ENCODING*4] = 'h0C7;//Ç
 
    #(CLK_PERIOD*1000000*1) // 2 frames
    
   $finish; 

end
always #(CLK_PERIOD/2) sys_clk = ~sys_clk;
always #(CLK_PERIOD/2) pix_clk = ~pix_clk;

endmodule