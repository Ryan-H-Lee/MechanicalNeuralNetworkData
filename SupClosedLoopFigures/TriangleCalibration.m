if openNewData == 1
    % Open File with DAC Data
    disp('Please select a CSV file with the DAC output data')
    [file,path] = uigetfile('*.*');
    adcPath = strcat(path,"\",file)
    dacVals = readmatrix(adcPath);
    size(dacVals)

    % Open File with INSTRON Data
    disp('Please select CSV with Instron for Force Calibration')
    [file,path] = uigetfile('*.*');
    insPath = strcat(path,'\',file);
    creepVals = readmatrix(insPath);
    size(creepVals)
end

    splitVal = 2048;
    insDataColumn = 3; % Time(s) | Extension (mm) | Load (N)
    espDataColumn = 1; 
    insFitOrder = 1; %Polynomial order to fit insData vs Time
    corrFitOrder = 3; %Polynomial order for INSTRON to ESP-32
    swap = 0
%% Remove any NAN
trimmedAdcVals = dacVals; %adcVals(find( ~isnan(adcVals(:,1)) & ~isnan(adcVals(:,4))),:);
%%  Plot Raw Data THESE GENERATE CAL TABLES
figure(9)
plot(trimmedAdcVals(:,1),trimmedAdcVals(:,4),'.')
title('ADC DROP raw data')
xlabel( 'Motor Input Value')
ylabel( 'Change In Sensor Reading' )

%% Loop through each value and take average of values 
minDac = min(trimmedAdcVals(:,1))
maxDac = max(trimmedAdcVals(:,1))

averageADC = zeros(maxDac-minDac  + 1, 3);
count = 1
for dacVal = [minDac:1:maxDac+1]
    indexSet = find(trimmedAdcVals(:,1) == dacVal);
    if  ~isempty(indexSet)
        set = trimmedAdcVals( indexSet, 4);
        set = rmoutliers( set);
        averageVal = mean( set );
        stdVal = std( set );

        averageADC(count,:) = [dacVal, averageVal, stdVal];
        count = count + 1;
    end
end
polyfit(averageADC(:,1),averageADC(:,2),4)
figure(10)
hold off
plot( averageADC(:,1), averageADC(:,2),'.')
hold on
plot( averageADC(:,1), averageADC(:,2)+averageADC(:,3),'m--',averageADC(:,1), averageADC(:,2)-averageADC(:,3),'m--')
xlabel( 'Motor Input Value')
ylabel( 'Change In Sensor Reading' )
title('ADC drop')
[aveCal, aveS] = polyfit(averageADC(:,1),averageADC(:,2),4)
[aveVal, aveDelta] = polyval(aveCal, averageADC(:,1), aveS)
plot(averageADC(:,1),aveVal,'r')
plot(averageADC(:,1), aveVal + 2*aveDelta, 'm--', averageADC(:,1), aveVal - 2*aveDelta, 'm--')
% %% Print table
% outputString = "long calTable[] = {";
% c = newline;
% calTable = zeros( length(averageADC), 1);
% %Smooth out the offset values to remove jitter from data
% offsetValue = smooth(round(-averageADC(:,2)*1000),80);
% offsetValue = (offsetValue - offsetValue(splitVal)); %subtract from the output Calibration value
% offsetValue = round(offsetValue); %round down to convert into int
% offsetValue(4096) = offsetValue(4095);
% 
% %Pack offsets into a string as C++ array declaration
% for i = 1:length(averageADC)
%     offsetText = string(offsetValue(i)); 
%     outputString = strcat(outputString, offsetText);
%     if i ~= length(averageADC)
%        outputString = strcat(outputString, ', ');
%     else
%         outputString = strcat(outputString, "};");
%     end
% end
% disp(outputString)
% %%
% figure(20)
% hold off
%  plot(offsetValue/1000,'.-')
%  hold on
%  plot((averageADC(splitVal,2)-averageADC(:,2)),'.-')
%  legend('CalTable','AverageData','Location','northwest')
%  
% %  figure(9)
% %  plot(round(smooth(floor(averageADC(:,2)),14,'rloess')),'.-')

%% Fit to these Values
% [~,orderedIndex] = sort( trimmedAdcVals(:,1) );
% ordered = trimmedAdcVals(orderedIndex, [1,4]);
% splitIndex = find(ordered(:,1) > splitVal, 1)
% % Calibrate Lower Half of Data
% [lowDacCal, lowS] = polyfit(ordered(1:splitIndex, 1),...
%                             ordered(1:splitIndex, 2), 2)
% [lowDacVals, deltaLow] = polyval( lowDacCal, [0:splitVal], lowS)
% % Calibrate Upper Half of Data
% [highDacCal, highS] = polyfit(ordered(splitIndex-3:end, 1),...
%                             ordered(splitIndex-3:end, 2), 2)
% [highDacVals, deltaHigh] = polyval( highDacCal, [splitVal+1:maxDac], highS)
% figure(11)
% hold off
% plot(trimmedAdcVals(:,1),trimmedAdcVals(:,4),'b.')
% hold on
% plot( averageADC(:,1), averageADC(:,2),'g.')
% plot( [splitVal+1:maxDac],highDacVals,'r')
% plot([splitVal+1:maxDac],highDacVals+2*deltaHigh,'m--',[splitVal+1:maxDac],highDacVals-2*deltaHigh,'m--')
% plot( [0:splitVal], lowDacVals,'r')
% plot([0:splitVal],lowDacVals+2*deltaLow,'m--',[0:splitVal],lowDacVals-2*deltaLow,'m--')
%% Find peaks in Intron values
insData = creepVals(:,insDataColumn);
trueValues = find( ~isnan(insData) );
insData = insData( trueValues );
insTime = creepVals(trueValues,1);

insMax = max(insData);
insMin = min(insData);
insMean = mean(insData);

[insPosPeaks, insPosLocs] = findpeaks( (insData), 'MinPeakProminence', 0.97*(insMax - insMean));
[insNegPeaks, insNegLocs] = findpeaks(-(insData), 'MinPeakProminence', 0.97*(insMean - insMin));

insPeaks = sort([insPosLocs;insNegLocs]);
nInsPeaks = length(insPeaks)

figure(1); subplot(2,1,1); hold off;
plot(insData); hold on;
plot(insPeaks, insData(insPeaks),'o');
plot([0,length(insData)], [1,1]*insMean);
title('Instron Data Peaks')

%% Find Peaks in ESP-32 Values
espData = dacVals(:, espDataColumn);

espMax = max(espData);
espMin = min(espData);
espMean = mean(espData);

[espPosPeaks, espPosLocs] = findpeaks( espData, 'MinPeakProminence', 0.97*(espMax - espMean),'MinPeakDistance',length(espData)/(nInsPeaks*2+1));
[espNegPeaks, espNegLocs] = findpeaks(-espData, 'MinPeakProminence', 0.97*(espMean - espMin),'MinPeakDistance',length(espData)/(nInsPeaks*2+1));

espPeaks = sort([espPosLocs; espNegLocs]);
nEspPeaks = length(espPeaks)

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

    for segment = 2:nlines
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
            %pause(1)
        else
            [corrFitList{segment}, corrErrorList{segment}] = polyfit(espSection, insY, corrFitOrder);
            disp('correlation for Segment number ')
            disp(segment)
            disp(corrFitList{segment})
            corrDataArray = [ corrDataArray; [espSection, insY'] ];
            
            figure(2); hold on
            plot(insY',espSection)
            %pause(0.01)
        end
        
    end        


       
 
    
%% Fit the Alligned Data
[~, sortedIndex] = sort(corrDataArray(:,1));
corrDataSorted = corrDataArray(sortedIndex,:);
[dacFit, dacS ] = polyfit( corrDataSorted(:,1), corrDataSorted(:,2), corrFitOrder)
[fullVals, fullDelta] = polyval(dacFit,corrDataSorted(:,1), dacS);

figure(3); hold off;
plot(corrDataSorted(:,1), corrDataSorted(:,2),'b','LineWidth',2); hold on;
plot(corrDataSorted(:,1), fullVals,'r--','LineWidth',6)
 ax = gca;
 ax.FontSize = 28;
 ax.TickLength = [0.025,0.025];
 ax.XColor = 'k'
 ax.LineWidth = 2
  ax.LineWidth = 2
  axis square
 xlim([min(corrDataSorted(:,1)),max(corrDataSorted(:,1))])
 ylim([min(corrDataSorted(:,2)),max(corrDataSorted(:,2))])
figure(4); clf
plot(fullDelta)
disp(" the data is in: dacFit")
disp("Data in disp(outputString)")

%% Figure 5
figure(5)
figure(5); hold off;
vFact = 3.3/2^12
plot(corrDataSorted(:,1), corrDataSorted(:,2)*vFact,'b','LineWidth',2); hold on;
plot(corrDataSorted(:,1), fullVals*vFact,'r--','LineWidth',4)
 ax = gca;
 ax.FontSize = 28;
 ax.TickLength = [0.025,0.025];
 ax.XColor = 'k'
 ax.LineWidth = 2
  ax.LineWidth = 2
  axis square
 xlim([min(corrDataSorted(:,1)),max(corrDataSorted(:,1))])
 ylim([min(corrDataSorted(:,2))*vFact,max(corrDataSorted(:,2))*vFact])
