clear importData;
clear line;
xColumn = 2;
yColumn = 3;

finalPlot = true
if finalPlot
    path = pwd;
    file = 'Specimen_RawData_1.csv';
else
    [file, path] = uigetfile('*.*');
end
fullpath = strcat( path,'\', file);
importData = readmatrix(fullpath);
%% Break Data up by Cycles

xData = importData(:,xColumn);
yData = importData(:,yColumn);
amplitude = (max(yData) - min(yData))/2
figure(100)
clf
plot(yData)
[peaks, locs] = findpeaks(yData, 'MinPeakProminence', 0.95*amplitude)
[lows, lowLocs] = findpeaks(-yData, 'MinPeakProminence', 0.95*amplitude)
hold on;
plot(locs, yData(locs),'o')
plot(lowLocs, yData(lowLocs),'o')

cycleEndPts = round((locs(2:end) - lowLocs(1:end-1))/2) + lowLocs(1:end-1)
cyclePts = [ 1; cycleEndPts; length(yData)]

plot(cyclePts, yData(cyclePts),'+')

%%
figureNumber = 1;
figure(figureNumber)
clf
hold on;
for index = [1,4]
    index
   startPt = cyclePts(index);
   endPt = cyclePts(index + 1);
   vect = [startPt:endPt];
   lines{index} = plot( xData(vect), yData(vect),'.-', 'Linewidth',1, 'MarkerSize',10)
  
end
 ax = gca;
 ax.TickDir = 'in';
 ax.FontSize = 28;
 set(gca,'TickDir','out');
xlim([-0.045,0.05])
ylim([-0.04,0.065])
ax.LineWidth = 2
ax.Box = 'on'
lines{1}.Color = [1 0 0];
lines{1}.LineStyle = '--'
lines{4}.Color = [0 0 1];


%%
xColumn = 2;
yColumn = 3;
figureNumber = 3;
% selectMatrix = [1,2,3,4,5];
figure(figureNumber);
clf
importData = {importData}
line = cell(length(importData),1);
for index = 1:length(importData)
    dataSet = importData{index};
    xVals = dataSet(:,xColumn);
    yVals = dataSet(:,yColumn);
    line{index} = plot(xVals, yVals);
      hold on;
      %pause(1);
end
 ax = gca;
 %ax.TicDir = 'out';
 ax.FontSize = 28;
 set(gca,'TickDir','out');
 pbaspect([1 1 1])
% set(gca, 'FontSize', 
%legend('1', '2', '3', '4', '5','6','7')

%
xName = 'Displacment (mm)';
yName = 'Force (N)';
titleText = 'Effect of Proportional Gain on Stiffness';
xlabel(xName)
ylabel(yName)
title(titleText)
% fig = gcf;
% set(findall(fig,'-property','FontSize'),'FontSize',28)