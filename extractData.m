%% !!! ASSUMPTIONS !!!
% UTF-8, from U+0000 to U+00FF, for Latin + Latin Supplement
% max. char id = 255, min. char id = 32 (decimal ASCII numbers)
% Heights are equal.
%% !!! PARAMETERS !!!
% .png file size (Width & Height)
% common line height
%%
function [configMatrix] = extractData(sourceName,destiNameD,destiNameP,destiNameC)

fileID = fopen(sourceName);

% Creates the configuration matrix. Contains the values of parameters for the font: lineHeight, scaleW, scaleH, pages, char count.   
config = textscan(fileID, '%*s lineHeight=%d %*s scaleW=%d scaleH=%d pages=%d %*s %*s %*s %*s', 'headerLines', 1);
configMatrix = zeros(1,5);
configMatrix(1,1:4) = cell2mat(config);
pages = configMatrix(1,4); % amount of .png files
scaleWidth = configMatrix(1,2);
scaleHeight = configMatrix(1,3);


% Creates the pattern matrix from .png files of that font.
patternMatrix = zeros(pages*scaleHeight,scaleWidth);
pngName = textscan(fileID, 'page id= %*d file=%q');
for k=1:pages 
    p = imread(pngName{1,1}{k,1});
    patternMatrix((k-1)*scaleHeight+1:k*scaleHeight,1:scaleWidth) = p(:,:,1);
end

% Creates an HEX file for the pattern matrix.
patternMatrix = patternMatrix(:,:,1);
patternMatrix = dec2hex((patternMatrix)',2);
dlmwrite(destiNameP,patternMatrix,'delimiter',''); % use 'writematrix' for releases upon 2019a
configMatrix(1,5) = cell2mat(textscan(fileID, 'chars count=%d'));    
    

% Creates the data matrix of the characters. 
% Contains the values of parameters for each char: char id, x, y, width, height, page.
maxCharCount = 255 - 32 + 1; % since it's UTF-8
dataMatrix=zeros(maxCharCount,6);
C = textscan(fileID,'char id=%d x=%d y=%d width=%d height=%d %*s %*s %*s page=%d %*s');
temporary = cell2mat(C);
for i=1:configMatrix(1,5)
    % Detects the missing characters. Places them into the matrix accordingly.
    if (temporary(i,1) ~= i+31)
        dataMatrix(temporary(i,1)-31,:) = temporary(i,:); % cell2mat(C);
    else
        dataMatrix(i,:) = temporary(i,:);    
    end
end


 % Creates an HEX file for the data matrix.
 dataMatrix=dataMatrix';
 dataMatrix=dec2hex(dataMatrix,2);
 dlmwrite(destiNameD,dataMatrix,'delimiter',''); % use 'writematrix' for releases upon 2019a
 
 
% Creates an HEX file for the configuration matrix.
configMatrix = dec2hex((configMatrix)',2);
dlmwrite(destiNameC,configMatrix,'delimiter',''); % use 'writematrix' for releases upon 2019a

 fclose(fileID);
end