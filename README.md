# On-Screen-Display
Customizable text displaying on video frames

On Screen Display is designed to enrich the content of a video frame in terms of the text displaying and pixel modification within each frame. 
The edibility of the text context mapped out to the screen and the customizability of the text font and color are the main concerns of the design.
This customization is mainly achieved with an initial font generation which is completely left to the user’s preferences. 
An open-source software BMFont is used for this purpose. It enables the user to specify the font settings so that each character to be displayed on the screen is determined in terms of its bit-depth, width, length, channel values used in vector/bit mapping and its inclusion to the whole character set.

After this initial customization, a parsing process begins to analyse the generated font and produces a raw data. MATLAB 2018b is chosen for this purpose due to its built-in functions facilitating the file parsing and writing.
The rest of the job is run as an HDL project. Vivado 2019.1 is used as the development and test environment. The modules are written in Verilog and SystemVerilog HDLs.

The project is designed to be compatible with any character set available in BMFont. It contains both Unicode and OEM encodings such as for Turkish, Russian and Greek, which have their own encodings apart from the Unicode. It also allows the user to choose any font type available or to add any True-Type font file they desire.

The only limitation may be due to the non-existing character sets in BM-Font. The user must pay attention to the encoding of the string that is about be written, i.e. they have to be matched. For instance, if OEM Turkish character set is chosen, then the input string has to be provided as in Windows-1254, depending on the way it is given e.g. through keyboard or a text file.
