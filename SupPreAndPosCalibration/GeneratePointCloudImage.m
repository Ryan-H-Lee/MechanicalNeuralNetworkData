clear all
close all
clc

%% set UI
finalPlots = true;

if finalPlots
    %Use the uploaded data
    fprintf('Plotting data from saved files.\n')
    postPath = pwd;
    prePath = pwd;
    postFile = 'PostCalibrationDisplacements.mat';
    preFile = 'PreCalibrationDisplacements.mat';
else
    %Select files using GUI
    disp('Selecte the file POST CALIBRATION')
    [postFile, postPath ] = uigetfile;
    disp('Select the fil PRE calibration')
    [preFile, prePath] = uigetfile
end

%Load Pre Calibration Data
load([prePath,'\',preFile])
posOutPre = posOut;

%Load Post Calibration Data
load([postPath,'\',postFile])
posOutPost = posOut;

%%
markerType = '.';
markerSize = 10;
colorMatrixPost = [1 0 0; 1 0 0];% [255, 96, 47;50 214 70 ]/255;
colorMatrixPre = [0 0 1; 0 0 1]; % [246, 188, 48; 71 128 52]/255;

preDisp = squeeze(reshape(posOutPost([4,8],:,:),4,1,[]) - zeroPos);
postDisp = squeeze(reshape(posOutPre([4,8],:,:),4,1,[]) - zeroPos);
preMean = mean(posOutPost([4,8],:,:),3);
postMean = mean(posOutPre([4,8],:,:),3);
deltaPre = posOutPost([4,8],:,:) - preMean;
deltaPost = posOutPre([4,8],:,:) - postMean;
stdPre = mean(sqrt(sum(deltaPre.^2,2)),3);
stdPost = mean(sqrt(sum(deltaPost.^2,2)),3);
stdPreA = mean(sqrt(sum(deltaPre.^2,2)),'all');
stdPostA = mean(sqrt(sum(deltaPost.^2,2)),'all');

figStart = 10;
numBehs = 2;
for beh = 1:numBehs
    figure(figStart + beh)
    hold off
    
    line = 1 + (beh-1)*numBehs;
    plot( preDisp(line,:)', preDisp(line+1,:)', markerType, 'MarkerSize', markerSize*1.25, 'Color', colorMatrixPre(beh,:))
    hold on
    line = 1 + (beh-1)*numBehs;
    plot( postDisp(line,:)', postDisp(line+1,:)', markerType, 'MarkerSize', markerSize, 'Color', colorMatrixPost(beh,:))
    
    ax = gca;
    set(ax, 'LineWidth', 2)
    set(ax,'FontSize', 32)
    set(ax, 'FontName', 'Calibri')
    set(ax,'FontSize', 32)
%     set(ax, 'XTick', linspace(min(preDisp(line,:)), max(preDisp(line,:)), 4) )
%     set(ax, 'YTick', linspace(min(preDisp(line+1,:)), max(preDisp(line+1,:)), 4) )
    grid on
    axis square
    axis equal

end
 