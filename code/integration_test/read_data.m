% read_data.m
% Kavi Dey (kdey@hmc.edu)
% 1/22/24

function [rollIMU,pitchIMU,headingIMU,accelX,accelY,accelZ,magX,magY,magZ,lat,lon,nsats,x,y,u,uL,uR,yaw,yaw_des,motorA,motorB,motorC,Current_Sense,A00,A01,A02,A03,A10,A11,A12,A13,A14,A15,A16,A17,A18,A19,A20,ErrorFlagA,ErrorFlagB,ErrorFlagC] = read_data(file_name, folder)
% read_data
% Imports data from paired .txt and .bin file from teensy into matlab
%
% Arguments:
%   file_name: the name of the .txt and .bin file (both files need to have
%       the same name)
%   folder: the folder that the data is in (optional)
arguments
    file_name
    folder = ""
end
if folder ~= ""
    folder = folder + "/";
end
infofile = strcat(folder, file_name, '.TXT');
datafile = strcat(folder, file_name, '.BIN');

% map from datatype to length in bytes
dataSizes.('float') = 4;
dataSizes.('ulong') = 4;
dataSizes.('int') = 4;
dataSizes.('int32') = 4;
dataSizes.('uint8') = 1;
dataSizes.('uint16') = 2;
dataSizes.('char') = 1;
dataSizes.('bool') = 1;

% read from info file to get log file structure
fileID = fopen(infofile);
items = textscan(fileID,'%s','Delimiter',',','EndOfLine','\r\n');
fclose(fileID);
[ncols,~] = size(items{1});
ncols = ncols/2;
varNames = items{1}(1:ncols)';
varTypes = items{1}(ncols+1:end)';
varLengths = zeros(size(varTypes));
colLength = 256;
for i = 1:numel(varTypes)
    varLengths(i) = dataSizes.(varTypes{i});
end
R = cell(1,numel(varNames));

% read column-by-column from datafile
fid = fopen(datafile,'rb');
for i=1:numel(varTypes)
    %# seek to the first field of the first record
    fseek(fid, sum(varLengths(1:i-1)), 'bof');
    
    %# % read column with specified format, skipping required number of bytes
    R{i} = fread(fid, Inf, ['*' varTypes{i}], colLength-varLengths(i));
    eval(strcat(varNames{i},'=','R{',num2str(i),'};'));
end
fclose(fid);
end