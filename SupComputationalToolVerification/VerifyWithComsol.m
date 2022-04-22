%This code compares results generated using the simultion tool to the
% structure modeled in COMSOL high detail with equivalent loading.
%% Clean workspace
clear
close all
clc

%% Set Utility
testNewSet = false;
finalPlots = true;

%% Add helper functions
addpath([pwd,'\helperFunctions'])
%% Import or Generate Force Combinations

if testNewSet
    % Create random force cases
    numCases = 24;
    forceCase = (round(rand(4, numCases)*2 - 1, 4))
    forceCase = [[0 1 1 0]',forceCase]
else
    %Open a preexisting set list
    if finalPlots
        mainPath = pwd;
        forceCaseFile = 'randomBehaviors_1N_rand_and_10_01.txt';
    else
        [forceCaseFile, mainPath] = uigetfile('*.txt');
    end
    opts = detectImportOptions([mainPath, '\', forceCaseFile]);
    opts.Delimiter = {',', '"'};
    opts = setvartype(opts, 'double');
 
    forceCase = readmatrix([mainPath, '\', forceCaseFile], opts);
    %remove name and units column
    forceCase = forceCase(:,2:end-1);
    
end

%% Simulate Force Combinations
numCases = length(forceCase);% 25 +1
%Create simulation
endI = 2;
buildSimNG
%Simulate the force cases using the light simulation
posAll = zeros(12,3,numCases);
Fn = zeros(size(F,1),1);
firstInd = [7,8, 22, 23]; %[7,8, 22, 23];

for ind = 1:numCases
    thisBeh = ones(21,1)*2150.2; %1812.8*ones(21,1); %randomConfigs(:,ind)*1000
    thisForce = reshape(forceCase(:,ind),2,2)';

    Fn(firstInd) = reshape(thisForce',[],1);%*ioMag
    sysPar.F = Fn;
    %set the force cases to be correct
    posAll(:,:,ind) = FEM_NG(thisBeh, sysPar);
%Plot the simulation agianst the experimental system
end

% Plot only the interesting Nodes
outputNodes = [5,10];
knownNodes = [5,10]; %[4,5, 9,10]
origins = coord_initial(knownNodes, 1:2);

%Daq final Positions
transPosAll = zeros(2,2,numCases);
for ind = 1:numCases
    transPosAll(:, :, ind) = (posAll(knownNodes, 1:2, ind) -origins)*1000;
end

%% Save Force Condition List To .txt File
if testNewSet
    %Transfer behaviors to file
    fileName = 'randomBehaviors_1N_rand_and_10_01.txt';
    vn = {'F1x', 'F1y', 'F2x', 'F2y'}
    units = {'[N]', '[N]', '[N]','[N]'}
    ts = []
    for varName = 1:length(vn)
        ts = [ts, vn{varName},' "'];
        for caseNum = 1:numCases
             ts = [ts,num2str(forceCase(varName, caseNum))];
             if caseNum < numCases
                 ts = [ts,', '];
             end
        end
        ts = [ts, '" ',units{varName},newline]
    end

    fid = fopen(fileName,'wt');
    fprintf(fid,'%s',ts);
    fclose(fid);
end
%% Run Comsol
%Open up COMSOL '2D Simulation_Smooth_1N.mph'
%import the randomBehaviors_1N_rand_and_10_01.txt file to parameter sweep
%save out the Derived Values table 1 and import it
%% Import Consol Results

if finalPlots
    mainPath = pwd;
    listFile = 'randomBehaviors_1N_rand_and_10_01_output.txt';
else
    [listFile, mainPath] = uigetfile('*.txt')
end

opts = detectImportOptions([mainPath, '\', listFile]);
BehaviorsDisp = readmatrix([mainPath, '\', listFile]);
%% Plot Calculated Displacements
smallSimBlock = reshape(pagetranspose(transPosAll),4,[]);
ComsolDisp = BehaviorsDisp(:,5:8)';

deltaPos =  pagetranspose(reshape( smallSimBlock - ComsolDisp, 2,2,[]));
meanDelta = mean(deltaPos, 3);
stdDelta = std(deltaPos,[],3);
radialDistance = sqrt((sum(deltaPos.^2,2)));
meanDistance = mean(radialDistance,'all');
stdDistance = std(reshape(squeeze(radialDistance),1,[]));


warning('Remember that the simulation and paper callouts are switched for clarity i.e. x1 => x2')

forPaper = true;
figure(100)
clf
yTitle = {'X1','Y1', 'X2', 'Y2'};
xTitle = 'Behavior Number';
lThk = 2.5;
sMkr = 10;
lineColor = [ [112, 48, 160]/255 ;  [0, 176, 80]/255];
for ind = 1:4
    figure(10+ind)
    clf
    plot(ComsolDisp(ind,:), 'o-', 'LineWidth',1*lThk, 'MarkerSize', sMkr,'Color', lineColor(2,:)','MarkerFaceColor',lineColor(2,:)')
    hold on
    plot(smallSimBlock(ind,:), 'o--', 'LineWidth', 1.2*lThk, 'MarkerSize', sMkr, 'Color', lineColor(1,:)','MarkerFaceColor',lineColor(1,:)')

    ax = gca;
    if ~forPaper 
        yTitle{ind};
        title(yTitle{ind})
        ylabel( 'Position(mm)')
        xlabel(xTitle)
    end
    ub = ceil(max([ComsolDisp(ind,:), smallSimBlock(ind,:)],[],'all')*10)/10;
    lb = floor(min([ComsolDisp(ind,:), smallSimBlock(ind,:)],[],'all')*10)/10;
    ax.XLim = [1,numCases];
    ax.YLim = [lb,ub];
    ax.FontName ='Calibri';
    ax.FontSize = 20;
    ax.LineWidth = 3;
    ax.TickLength = [0.02 0.05];
    
end

figure(20)
clf

    plot(ComsolDisp(ind,:), 'o-', 'LineWidth',1*lThk, 'MarkerSize', sMkr,'Color', lineColor(2,:)','MarkerFaceColor',lineColor(2,:)')
    hold on
    plot(smallSimBlock(ind,:), 'o--', 'LineWidth', 1.2*lThk, 'MarkerSize', sMkr, 'Color', lineColor(1,:)','MarkerFaceColor',lineColor(1,:)')

    ax = gca;
    if ~forPaper 
        yTitle{ind}
        title(yTitle{ind})
        ylabel( 'Position(mm)')
        xlabel(xTitle)
    end
    ax.XLim = [1,numCases];
    ax.YLim = [-.6,0.6];
    ax.FontName ='Calibri';
    ax.FontSize = 20;
    ax.LineWidth = 3;
    ax.TickLength = [0.02 0.05];
    
legend( 'FEA', 'Simulation')

% XY-Plots
figure(12)
