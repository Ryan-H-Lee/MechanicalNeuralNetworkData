%This code correlates peaks in data between the instron and some other
%source it ASSUMES EVENLY SPACED DATA POINTS from nonInstron

% clear
% close all
insDataColumn = 2; % Time(s) | Extension (mm) | Load (N)
espDataColumn = 1; 
insFitOrder = 1; %Polynomial order to fit insData vs Time
corrFitOrder = 3; %Polynomial order for INSTRON to ESP-32
swap = 1
if openNewData == 1
    %% Open Esp-32 Infromation from file
    disp('select FILE with ESP-32 DAC information in COLUMN 1')
    [file,path] = uigetfile('*.*');
    espPath = strcat(path,"\",file)
    espVals2048 = readmatrix(espPath);
    size(espVals2048)
    %% Open INSTRON information from file
    disp('select FILE with INSTRON data')
    [file,path] = uigetfile('*.*');
    insPath = strcat(path,'\',file)
    insVals2048 = readmatrix(insPath);
    size(insVals2048)
end
%% Find peaks in Intron values
insData = insVals2048(:,insDataColumn);
trueValues = find( ~isnan(insData) );
insData = insData( trueValues );
insTime = insVals2048(trueValues,1);

insMax = max(insData);
insMin = min(insData);
insMean = mean(insData);

[insPosPeaks, insPosLocs] = findpeaks( (insData), 'MinPeakProminence', 0.4*(insMax - insMean));
[insNegPeaks, insNegLocs] = findpeaks(-(insData), 'MinPeakProminence', 0.4*(insMean - insMin));

insPeaks = sort([insPosLocs;insNegLocs]);
nInsPeaks = length(insPeaks)

% Triangle Peak Checking Graph
figure(1); subplot(2,1,1); hold off;
plot(insData); hold on;
plot(insPeaks, insData(insPeaks),'o');
plot([0,length(insData)], [1,1]*insMean);
title('Instron Data Peaks')

%% Find Peaks in ESP-32 Values
espData = espVals2048(:, espDataColumn);

espMax = max(espData);
espMin = min(espData);
espMean = (espMax + espMin)/2

[espPosPeaks, espPosLocs] = findpeaks( (espData), 'MinPeakProminence', 0.5*(espMax - espMean),'MinPeakDistance',length(espData)/(nInsPeaks*2+1));
[espNegPeaks, espNegLocs] = findpeaks(-(espData), 'MinPeakProminence', 0.5*(espMean - espMin),'MinPeakDistance',length(espData)/(nInsPeaks*2+1));

espPeaks = sort([espPosLocs; espNegLocs]);
nEspPeaks = length(espPeaks)

%Triangle Peak Checking Graph
figure(1); subplot(2,1,2); hold off
plot(espData); hold on
plot(espPeaks,espData(espPeaks),'o')
title('ESP Data Peaks')


%% Generate Insron Data for each ESP point using Fit and ASSUMING CONSTANT PERIOD 
corrDataArray = [];

nlines = min([nEspPeaks, nInsPeaks]) - 1; %Number of segments that will be checked
insFitList = cell(nlines,1);
insErrorList = insFitList;
corrFitList = cell( nlines, 1);
corrErrorList =cell( nlines, 1);
figure(2); clf;
if nlines == 1
    segStart = 1
else
    segStart = 2
end

    for segment = segStart:nlines
        espStart = espPeaks(segment);
        espEnd = espPeaks(segment + 1);
        insStart = insPeaks(segment);
        insEnd = insPeaks(segment + 1);

        insSection =  insData( insStart:insEnd);
        insSectionTime = insTime( insStart:insEnd);
        espSection = espData( espStart:espEnd);

        [insFitList{segment}, insErrorList{segment}] = polyfit( insSectionTime, insSection, insFitOrder);
        insX = [0:length(espSection)-1]/length(espSection) * (insSectionTime(end)-insSectionTime(1)) + insSectionTime(1);
        [insY, insDelta] = polyval( insFitList{segment}, insX, insErrorList{segment});
        
        if swap == 0
            [corrFitList{segment}, corrErrorList{segment}] = polyfit(insY, espSection, corrFitOrder);
            disp('correlation for Segment number ')
            disp(segment)
            disp(corrFitList{segment})
            corrDataArray = [ corrDataArray; [insY', espSection] ];
            
            figure(2); hold on
            plot(insY',espSection)
            pause(1)
        else
            [corrFitList{segment}, corrErrorList{segment}] = polyfit(espSection, insY, corrFitOrder);
            disp('correlation for Segment number ')
            disp(segment)
            disp(corrFitList{segment})
            corrDataArray = [ corrDataArray; [espSection, insY'] ];
            
            figure(2); hold on
            plot(insY',espSection)
            pause(1)
        end
        
    end        


       
 
    
%% Fit the Alligned Data
[~, sortedIndex] = sort(corrDataArray(:,1));
corrDataSorted = corrDataArray(sortedIndex,:);
[adcFit, adcS ] = polyfit( corrDataSorted(:,1), corrDataSorted(:,2), corrFitOrder)
[fullVals, fullDelta] = polyval(adcFit,corrDataSorted(:,1), adcS);
%%
figure(3); hold off;
% win = 
plot(corrDataSorted(:,1), corrDataSorted(:,2),'b','LineWidth',2); hold on;
plot(corrDataSorted(:,1), fullVals,'r--','LineWidth',6)
 ax = gca;
 ax.FontSize = 28;
 ax.TickLength = [0.025,0.025];
 ax.XColor = 'k'
 ax.LineWidth = 2
 axis square
 xlim([min(corrDataSorted(:,1)),max(corrDataSorted(:,1))])
 ylim([min(corrDataSorted(:,2)),max(corrDataSorted(:,2))])
 axis square
 %%
figure(4); clf
plot(fullDelta)
disp(" the data is in: adcFit")

%%
figure(5)
 hold off;
% win = 
vFactor = 1.1/2^12/7
plot(corrDataSorted(:,1)*vFactor, corrDataSorted(:,2),'b','LineWidth',2); hold on;
plot(corrDataSorted(:,1)*vFactor, fullVals,'r--','LineWidth',4)
 ax = gca;
 ax.FontSize = 28;
 ax.TickLength = [0.025,0.025];
 ax.XColor = 'k'
 ax.LineWidth = 2
 axis square
 xlim([min(corrDataSorted(:,1))*vFactor,max(corrDataSorted(:,1))*vFactor])
 ylim([min(corrDataSorted(:,2)),max(corrDataSorted(:,2))])
 axis square
