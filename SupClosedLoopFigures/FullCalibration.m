clear
ID = input('Please type in link number being calibrated')
%% Get array from file
pathStart = 'D:\Documents\Lab\ESP32_MATLAB\MNN_Control_Code_2020_09_19_1122'
name = 'LinkCalibrationValues.mat' %Contains the default ESP32 Settings
fullName = [pathStart,'\',name]
load(fullName)

%% Open serial port
a = seriallist
num = input( 'Which serial port do you want to calibrate? 1,2,3,...');
ard = serialport(a(num), 500000)
flush(ard)
%%
poffset = 0;
kp = 0;
kd = 650;
forceOffset = 0;
holdVelocity = 0.1;
floatArray(1:5,ID) = [ kp, kd,poffset, forceOffset, holdVelocity];
%% 
%Changes behavior of calibration files to use values in workspace NOT open new files
openNewData = 0; 

% Open File with DAC Data
disp('select CSV for DAC output data')
[file,MainPath] = uigetfile('*.*', 'PickAFile');
adcPath = strcat(MainPath,"\",file)
dacVals = readmatrix(adcPath);
size(dacVals)

% Open File with CREEP INSTRON Data
disp('Select INSTRON creep file')
[file,path] = uigetfile('*.*','PickAnotherFile',MainPath);
insPath = strcat(path,'\',file);
creepVals = readmatrix(insPath);
size(creepVals)  

% Open Esp-32 Infromation from file
disp('select FILE with ESP-32 DAC information in COLUMN 1')
[file,path] = uigetfile('*.*','PickAnotherFile',MainPath);
espPath = strcat(path,"\",file)
espVals2048 = readmatrix(espPath);
size(espVals2048)

% Open INSTRON information from file
disp('select FILE with INSTRON data')
[file,path] = uigetfile('*.*','PickAnotherFile',MainPath);
insPath = strcat(path,'\',file)
insVals2048 = readmatrix(insPath);
size(insVals2048)

% Open INSTRON information for LOW
disp("Please select the INSTRON file with LOW Motor Input (1024)")
[file,path] = uigetfile('*.*','PickAnotherFile',MainPath);
fullPath = strcat( path, '\', file);
insVals1024 = readmatrix(fullPath);

% Open INSTRON information for HIGH
disp("Please select the INSTRON file with HIGH Motor Input (3072)")
[file,path] = uigetfile('*.*','PickAnotherFile',MainPath);
fullPath = strcat( path, '\', file);
insVals3072 = readmatrix(fullPath);
%%
disp('Calibrating DAC')
TriangleCalibration
for index = 1:length(dacFit)
    floatArray(5 + index,ID) = dacFit(index)
end
input('Please check data and graphs. Press enter to continue:')
%%
disp('Calibrating ADC')
MutiCycleADCCalibration
for index = 1:length(adcFit)
    floatArray(9 + index,ID) = adcFit(index)
end
input('Please check data and graphs. Press enter to continue:')
%%
disp('Calibrating Flexures')
FlexureCalibration
for index = 1:length(A)
    floatArray(13 + index,ID) =A(index)
end
input('Please check data and graphs. Press enter to continue:')
%%
close all
disp('Calibrating mFactor')
MotorDropCalibrationCurves
for index = 1:length(highFlipCal)
    floatArray(17 + index,ID) = highFlipCal(index)
    floatArray(22 + index,ID) = lowFlipCal(index)
end
floatArray(:,27)= 0
%% P offset
% floatArray(28) = 0;

%%
write(ard,uint8([255,255,02,3,0,1,1,1]),'uint8')
write(ard,uint8([255,255,02,2,0,1,1,1]),'uint8')
if ard.NumBytesAvailable > 0
    read(ard, ard.NumBytesAvailable, "char")
end

for index = 1:length(floatArray)
    writeToArduino(ard,0,1,index-1,floatArray(index,ID),255);
end
intArrayTemp = [ ID,0,0, 2048, 0];
for index = 1:length(intArrayTemp)
    writeToArduino(ard,0,0,index-1,intArrayTemp(index),255);
end
boolArrayTemp = [ 0, 0, 0, 0];
for index = 1:length(boolArrayTemp)
    writeToArduino(ard,0,2,index-1,boolArrayTemp(index),255);
end
write(ard,uint8([255,255,02,3,1,1,1,1]),'uint8')
write(ard,uint8([255,255,02,2,1,1,1,1]),'uint8'); pause(0.2);
if ard.NumBytesAvailable > 0
    read(ard, ard.NumBytesAvailable, "char")
end
write(ard,uint8([255,255,02,3,0,1,1,1]),'uint8')
write(ard,uint8([255,255,02,2,0,1,1,1]),'uint8')
pause(0.1);
if ard.NumBytesAvailable > 0
    read(ard, ard.NumBytesAvailable, "char")
end
%%
time = datetime('now','Format','yyyy-MM-dd''T''HH_mm_ss')
archiveName = [pathStart,char(time),(name)]
save(fullName, 'floatArray', 'intArray', 'boolArray')
save(archiveName, 'floatArray', 'intArray', 'boolArray')
%%
clear ard
