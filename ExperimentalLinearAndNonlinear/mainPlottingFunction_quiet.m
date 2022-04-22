%{
This code is for processing large ish data sets with multiple runs of
multiple types. It will run twice once for linear and again for nonlinear
data.
%}
clear
close all
clc
%%
fprintf('Generating Linear vs Nonlinear Plot\n\n')
maxProfile = 2;

profileName = {'LINEAR', 'NONLINEAR'};
defaultPath = [''];
simplePlot = true;
addpath([pwd,'\HelperFunctions'])
for profile = 1:maxProfile
    if ~simplePlot
        display(profileName{profile});
        display('Select the list file for the input dataset')
        [listFile, mainPath] = uigetfile({'*.xlsx'}, 'Select a file', defaultPath);
        defaultPath = mainPath;
        opts = detectImportOptions([mainPath,listFile]);
        opts.DataRange = 'A1';
        fileList_local{profile} = readmatrix([mainPath, listFile], opts);
    else
        indexFiles = {'FileIndex_LinearSets.xlsx','FileIndex_NonlinearSets.xlsx'};    
        opts = detectImportOptions(indexFiles{profile});
        opts.DataRange = 'A1';
        fileList_local{profile} = readmatrix(indexFiles{profile}, opts);
        mainPath = pwd;
    end
    
end
%%
nSets = size(fileList_local{profile},1);
nRuns = size(fileList_local{profile},2);
%Inintalize the holding matrices
tHolder_local = nan(nSets, nRuns, 1);
aeHolder_local = nan(nSets, nRuns, 1);
mseIter = cell(nSets*maxProfile,1);
mseTime = cell(nSets*maxProfile,1);
timeRuns = cell(nSets*maxProfile,1);
timeFull = cell(nSets*maxProfile, 1);

for profile = 1:maxProfile %Linear and Nonlinear
%Ask the user for an output file location
%This is the location that the GRAPHS AND DATA SETS WILL BE SAVED TO
%local variables will have a 

%Get CSV file with list of files to open
%the CSV files will have, each run of a particular data set on a row
%   Each new data set will be seperated out onto a single line.
%   The file search will use the directory of THIS SAVE FILE as a start pt

%%

for ind = 1:nSets*maxProfile
    timeFull{ind} = [1];
end
%Loop through each set of behaviors
for behSet = 1:nSets
    %Loop through the data sets on one set of behaviors
    for runNum = 1:nRuns
        %Load a data set from the list
        currentName = fileList_local{profile}{behSet, runNum};
        testString = 'EMPTY';
        if  currentName(1:length(testString)) == testString;
            break
        end
        load([mainPath,'\', currentName]);
        
        %Determine length of holding matrix and Length of new data set
        %Prep data for processing
        if exist('eHistB', 'var')
            mseVect = eHistB;
%             timeBest = timeVect';
            timeBest = tHistB(1,:);
            timeALL = tHistA(1,:);
            %To compensate for timeALL(intit to 0)
            if timeALL(1) == 0
                timeALL(1) = timeALL(2) - mean(diff(timeALL));
            end

            bestIndex = stepIter;
            %Convert the 32xN position vecotor into a 2x8x2xN Position matrix
            for ind = 1:size(pHistB,2)
                thisPos = pHistB(:,ind);
                posHolder = reshape(thisPos, 8,2,[]);
                dispHist(:,:,ind) = [squeeze(posHolder([4,8],:,1)); squeeze(posHolder([4,8],:,2))];
            end

            %Set stopping point for the data plots.
            FixedStops = true;
            if FixedStops
                stopInd = length(mseVect);
            else
                %
                figure(21)
                clf
                plot(mseVect)
                stopInd = input('what index do you want to stop at? ')
                %Extend shorter data set with the last value so that they are the same
                %length
                if stopInd > length(mseVect)
                    stopInd = length(mseVect);
                end
                if isempty(stopInd )
                    stopInd = length(mseVect);
                end
            end

            stopSet = 1:stopInd;
            %Create a vector with each index filled this will be used for averaging
            mseFull = fillStepVector(bestIndex(stopSet), mseVect(stopSet), length(timeALL));

            
            %Add mseFull as new row in mseRuns{profile}
            mseIter{behSet + (profile-1)*nSets} = stackData(mseFull, mseIter{behSet + (profile-1)*nSets});
            %Get a time vector with the time assumed at each index. 
            %(NOTE) This will replace the times for ALL of the trajectories with the
            %longest time vector

            if length(timeALL) > length(timeRuns{behSet + (profile-1)*nSets})
                timeRuns{behSet + (profile-1)*nSets} =  timeALL;
            end
            % For time averaging instead create a time vector, with a step size
            % of 1 second and a largest absolute time displacement
            %Then fillStepVector from 0 to tLargest
            %Convert time for this data set into seconds elapsed
            elapsedTime = tHistB(stopSet) - tHistA(1,2); %Frist iteteration is at 2
            elapsedTime = round(elapsedTime*60*60); %elapsed time at each pt in sec
            if timeFull{behSet + (profile-1)*nSets}(end) < elapsedTime(end)
                timeFull{behSet + (profile-1)*nSets} = elapsedTime(end);
            end
            mseTimeData = fillStepVector(elapsedTime, mseVect(stopSet), elapsedTime(end));
            mseTime{behSet + (profile-1)*nSets} = stackData(mseTimeData, mseTime{behSet + (profile-1)*nSets});
        end

    %End of loop through Data sets
    end
%End of loop through behaviors
end

end 
%%
%Pack cells into array %rng#, ind, time
msePackedIter = PackArray(mseIter);
msePackedTime = PackArray(mseTime);
%These values hold the average and best run for each condition
meanIter = mean(msePackedIter,3);
minIter = min(msePackedIter,[],3);
meanTime = mean(msePackedTime, 3);
minTime = min(msePackedTime, [],3);
%Group each set by profile
for ind = 1:maxProfile
    pInd = (maxProfile)*(ind-1) + (1:nSets);
    meanPlotInds(:,ind) = mean(meanIter(pInd,:)',2);
    minPlotInds(:,ind)  = mean( minIter(pInd,:)',2);
    meanPlotTime(:,ind) = mean(meanTime(pInd,:)',2);
    minPlotTime(:,ind)  = mean( minTime(pInd,:)',2);
    
end
%% Plot that  Calculate Data
%Plot each of the 4 charts
colorList = [[ 0; 0 ; 1],[0, 0, 1]'];
indexX = [1:length(meanPlotInds)]';
styleList = {'-',':'};
% title('minIndsLines')
timeX = [(1:length(minPlotTime))/60]';
meanTimeLines = plotFunction(timeX, meanPlotTime, colorList,styleList, 30);
ax = gca;
ax.XLim = [0, 35]; %trim constant Data

legend('Linear','Nonlinear')

%%  The function used to plot each data set
function lineCell = plotFunction(xValues, yValues, colorList, styleList, figNum)
% colorList = [[ 1; 0 ; 0],[0, 0, 1]'];
% yValues = minPlotInds
dec = 2;

if size(xValues,2) < size(yValues,2)
    xPlot = repmat(xValues, 1, size(yValues,2));
else
    xPlot = xValues;
end

if nargin < 4
    figure
else
    figure(figNum)
    clf
end

for ind = 1:size(yValues,2)
    lineCell{ind} = plot(xPlot(:,ind), yValues(:,ind), 'Color', colorList(:,ind), 'LineStyle', styleList{ind}, 'LineWidth',2.5);
    hold on
end

ax = gca;
ax.LineWidth = 2.5;
ax.XLim = [min(xValues(:,1)), max(xValues(:,1))];
ax.YLim = [floor(min(yValues, [], 'all')*10^(dec))/10^dec, ceil(max(yValues,[],'all')*10^(dec))/10^dec];
ax.FontSize = 25;

ax.FontName = 'Calibri';
end
% Copy data from local vaiables

    % Clear local variables

    % Determine the minimum value for each set of runs (The best run)
    
    % Take the average of all of the data sets
    
    % Plot this curve
