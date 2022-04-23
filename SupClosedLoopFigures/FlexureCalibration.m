close all
%% Select file with tensile test Data
if openNewData == 1
disp("Select a file with instron Data");
[file, path] = uigetfile('*.*')
fullPath = strcat( path, "\", file);
insVals2048 = readmatrix(fullPath);
size(insVals2048)
end

%%
xDataColumn = 2;
yDataColumn = 3;

[~,sortIndex]  = sort(insVals2048(:,xDataColumn));
sortedX = insVals2048(sortIndex, xDataColumn);
sortedY = insVals2048(sortIndex, yDataColumn);
%%
minFitOrder = 3;
maxFitOrder = 3;
figure(maxFitOrder + 5)
plot(sortedX,sortedY)
title('Raw data')
xlabel('displacement (mm)')
ylabel('Force (N)')
fitOrder = cell(maxFitOrder-minFitOrder,1);
fitS = fitOrder
    figure(10)
    clf
    plot(sortedX,sortedY,'b','LineWidth',2);
    hold on

for fitOrder = minFitOrder:maxFitOrder
    [fitVals{fitOrder}, fitS{fitOrder}] = polyfit( sortedX, sortedY, fitOrder);
    [fittedY, fittedDelta] = polyval(fitVals{fitOrder}, sortedX, fitS{fitOrder});


    figure(10)
    plot(sortedX, fittedY,'r--','LineWidth',4);
%     title('Flexure Force')
%     xlabel('Displacement (mm)')
%     ylabel('Force (N)')
     ax = gca;
     ax.FontSize = 28;
     ax.TickLength = [0.025,0.025];
     ax.XColor = 'k'
     ax.LineWidth = 2
     xlim([min(sortedX),max(sortedX)])
     ylim([min(sortedY),max(sortedY)])
     axis square

    figure(fitOrder)
    titleString = strcat( 'Order: ', string(fitOrder) );
    plot(sortedX, fittedDelta);
    title( titleString)
end
disp('Data is in fitVals{3}')
A = fitVals{3}