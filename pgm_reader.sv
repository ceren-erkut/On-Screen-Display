

module pgm_reader #(
    parameter string FILE_PREFIX = "img",
    parameter string FILE_EXT = ".pgm",
    parameter WIDTH=640,
    parameter HEIGHT=512,
    parameter BPP=12
    ) (
    input rstb,
    input clk,
    input read,
    input [$clog2(HEIGHT):0] row,
    input [$clog2(WIDTH):0] column,
    output [BPP-1:0] data_out

);





// Image data
reg[BPP-1:0] pixelarray[0:HEIGHT - 1][0:WIDTH - 1];


enum {IDLE, OPENFILE, CHKFORMAT, READIMG, IMGOUT, WAIT2MOVE, WRITEIMG, CLOSEFILE} state, nextstate;

logic file_exists;
int w;
int h;
int bpp;
real bpp_r;
int counter;
integer j;

integer input_file;
integer r;
integer curr_loc;
integer file_index;
string file_number;

string line_format;
string line_res;
string line_bpp;

parameter BUFF_SZ = (WIDTH * HEIGHT * ((BPP + 7) / 8));
byte unsigned buffer[0:BUFF_SZ-1];

string path;

assign data_out = pixelarray[row][column];

always @(posedge clk or negedge rstb) begin
	if(!rstb) begin
		file_exists = 0;
		r = 0;
        j = 0;
		input_file = 1;
        file_index = 0;
		curr_loc = 0;
		counter = 0;
        file_number = "";
	end else begin
	case(state)
		IDLE: begin
            if(read) begin
			   state = OPENFILE;
            end
		end

		OPENFILE: begin
            file_number.itoa(file_index);
			if(input_file == 1) input_file = $fopen("C:/Users/ceyda/project_2/img0.pgm", "rb");

		    #1 r = $fgets(line_format, input_file);
            #1 r = $fgets(line_res,  input_file);
            #1 r = $fgets(line_bpp, input_file);
            curr_loc = $ftell(input_file);
			state = READIMG;
		end



		READIMG: begin
			counter = 0;
			//buffer = new[(w * h * $clog2(bpp + 1) / 8)];
			r = $fread(buffer, input_file);
			state = IMGOUT;
		end

		IMGOUT: begin
			foreach(buffer[i]) begin
                j = i/2;
                //display("Values: %d", i);
                //$display(" %d", j);
                //$display(" %h\n", buffer[i]);

                //$display("i = %d, Y:%5d X:%5d", i, j/WIDTH, j%WIDTH);
                if(i[0])
                    pixelarray[(j/WIDTH)][(j%WIDTH)][7:0] = buffer[i][7:0];
                else
                    pixelarray[(j/WIDTH)][(j%WIDTH)][BPP-1:8] = buffer[i][BPP-1-8:0];
			end
			state = CLOSEFILE;

		end

		CLOSEFILE: begin
			$fclose(input_file);
            input_file = 1;
            file_index = file_index + 1;
            state = IDLE;
		end

	endcase
	end
end



endmodule
