close all
clear all
clc

%% Initialize Globals for Plotting Solution
global Nbeams coord_initial DOF Final F DOFnodes R6 RT6 Degrees_per_element k_base Ncases Ncoord DOFFinal DOI NinputANDoutput
global connectivity Nlayers mymap2 Ncolorstep Kaxial Target Outputline L1 L2 L3 dx Elongation_max Lend Plot_exaggerate Plot_cmap
global maxStiffness minStiffness
global kVals


addpath([pwd,'\HelperFunctions'])
plotPaperFigures = true;

if plotPaperFigures
    configurationNumber = 0; % Plot Initial Condition static lattice
    %configurationNumber = input('Which Shape Morphing Solution do you want to plot?\n Enter: 0, 1, 2 \n')
    switch configurationNumber
        case 1
            load('8x8_Configuration1.mat')
        case 2
            load('8x8_Configuration2.mat')
        case 0
            load('8x8_Configuration2.mat')
        otherwise
            error('Please enter: 0, 1, or 2')
    end

else
    fprintf('Select a file to load:\n')
    [fileName,pathName] = uigetfile('*.mat');
    configurationNumber = 1; %make sure that the system plots
end
figNum = 1;
%% Calculate Displacements
[finalPos,finalError, c] = DEFandERROR(x);

%% Build Color Map
kVals = [min(lb), max(ub)];
caseType = 1; %sinusoidal;
sinsin = [-2 2];

%Blue_Blue
color4 = [0  30  90]/255;
color3 = [0   0 255]/255;
color2 = [0 153 255]/255;
color1 = [102 255 255]/255;

Ncolorstep = 5000;
nSeg1 = round(50/40);
nSeg2 = Ncolorstep - nSeg1;
sysPar.mymap2 = [linspace(color1(1), color3(1), nSeg1)',linspace(color1(2), color3(2), nSeg1)',linspace(color1(3), color3(3), nSeg1)'];
sysPar.mymap2 = [sysPar.mymap2; [linspace(color3(1), color2(1), nSeg2)',linspace(color3(2), color2(2), nSeg2)',linspace(color3(3), color2(3), nSeg2)']];
colorVect = [[1, .55, .3, 0]', [color1; color2; color3; color4]];
sysPar.mymap2 = color1;

for i = 1:size(colorVect,1)-1
    nSeg2 =abs(ceil(Ncolorstep.*(colorVect(i+1,1)  - colorVect(i,1))));
    sysPar.mymap2 = [sysPar.mymap2; [linspace(colorVect(i,2), colorVect(i+1,2), nSeg2)',linspace(colorVect(i,3), colorVect(i+1,3), nSeg2)',linspace(colorVect(i,4), colorVect(i+1,4), nSeg2)']];
end
mymap2 = sysPar.mymap2;
Plot_exaggerate = 25
minStiffness    = kVals(1);
maxStiffness    = kVals(2);
%% Plot
if configurationNumber ~=0
    %Plot configuration -
    for i = 1:Ncases
        figure(figNum +i-1)
        clf
        if caseType == 1
            PlotFunctionFig(figNum+i-1,'AdjK_C1',finalPos(:,:,i),x,Target(:,:,i),[],[],sinsin(i));
        else
            PlotFunctionFig(figNum+i-1,'AdjK_C1',finalPos(:,:,i),x,Target(:,:,i),[],[],0);
        end
        pause(0.01)
    end
else
    % Plot intial Conditions
    minStiffness    = kVals(1);
    maxStiffness    = kVals(2);
    Plot_cmap = false;
    PlotFunctionFig(figNum + 10, 'Initial Positions', coord_initial, ones(size(x))*4000/6,[],[],[],0)
end


%
