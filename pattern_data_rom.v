`timescale 1ns / 1ps
module pattern_data_rom #(
    parameter PAGES = 2,
    parameter PNG_W = 64,
    parameter PNG_H = 64,
    parameter MSB_BPP = 8,
    parameter LAST_CHAR = 383,
    parameter CHAR_ENCODING = 12
    ) (   
    input [$clog2((LAST_CHAR-31)*6)-1:0] data_addr,
    input [$clog2(PAGES*PNG_W*PNG_H)-1:0] pattern_addr,
    output [5*CHAR_ENCODING-1:0] data_out,
    output [MSB_BPP-1:0] pattern_out
);
     
reg [MSB_BPP-1:0] pattern_rom [0:(PAGES*PNG_W*PNG_H-1)]; 
reg [CHAR_ENCODING-1:0] data_rom [0:((LAST_CHAR-31)*6-1)];

assign data_out[CHAR_ENCODING-1:0] = data_rom[data_addr+5]; // char_page
assign data_out[2*CHAR_ENCODING-1:CHAR_ENCODING] = data_rom[data_addr+4]; // char_length
assign data_out[3*CHAR_ENCODING-1:2*CHAR_ENCODING] = data_rom[data_addr+3]; // char_width
assign data_out[4*CHAR_ENCODING-1:3*CHAR_ENCODING] = data_rom[data_addr+2]; // char_y
assign data_out[5*CHAR_ENCODING-1:4*CHAR_ENCODING] = data_rom[data_addr+1]; // char_x

assign pattern_out = pattern_rom[pattern_addr];

initial begin
    $readmemh("C:/Users/ceyda/project_2/project_2.ip_user_files/mem_init_files/denP6.txt", pattern_rom);
    $readmemh("C:/Users/ceyda/project_2/project_2.ip_user_files/mem_init_files/denD6.txt", data_rom);    
end        

endmodule

