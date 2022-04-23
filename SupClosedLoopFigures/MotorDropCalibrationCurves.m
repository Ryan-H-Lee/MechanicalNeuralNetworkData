
%Time (s) | Displacment (mm) | Force (N)
xColumn = 2;
yColumn = 3;

if openNewData == 1
    %% Open Flexure Data
    disp("Please select the INSTRON file with no Motor Input (2048)")
    [file,path] = uigetfile('*.*');
    fullPath = strcat( path, '\', file);
    insVals2048 = readmatrix(fullPath);

    %% Open Low motor Data
    disp("Please select the INSTRON file with LOW Motor Input (1024)")
    [file,path] = uigetfile('*.*');
    fullPath = strcat( path, '\', file);
    insVals1024 = readmatrix(fullPath);

    %% Open High motor Data
    disp("Please select the INSTRON file with HIGH Motor Input (3072)")
    [file,path] = uigetfile('*.*');
    fullPath = strcat( path, '\', file);
    insVals3072 = readmatrix(fullPath);
end
%% Select Important Columns
nPts = min([length(insVals2048), length(insVals1024), length(insVals3072)])

order = 5;
% Create a fit for the no motor behavior
flexDisp = insVals2048((1+end-nPts:end),xColumn)
flexForce = insVals2048((1+end-nPts:end), yColumn)
[~,index] = sort(flexDisp);
sortedDisp= flexDisp(index);
sortedForce = flexForce(index);
flexN = polyfit(sortedDisp,sortedForce,order);
%%
figure(9)
plot(sortedDisp, sortedForce,'.b')
hold on
plot(sortedDisp,polyval(flexN,sortedDisp),'r')
title('Sorted 2048 (flexture force) Data and fit')
%%
%select nPts then arrange in sorted order from 1024
lowDisp = insVals1024((1+end-nPts:end),xColumn);
lowForce = insVals1024((1+end-nPts:end),yColumn);
[~,index] = sort(lowDisp);
lowDisp = lowDisp(index);
lowForce = lowForce(index);
lowN = polyfit(lowDisp, lowForce, order)

%select nPts then arrange in sorted order from 3072
highDisp = insVals3072((1+end-nPts:end), xColumn);
highForce = insVals3072((1+end-nPts:end), yColumn);
[~,index] = sort(highDisp);
highDisp = highDisp(index);
highForce = highForce(index);
highN = polyfit(highDisp, highForce, order)

d = [-2.8:.005:2.8];
%correction is (ForceTotal - ForceFlex)/(force@0w/motor - force@0w/outmotor)
%ie fMot(x)/fMot(0)
lowCurve = (lowForce - polyval(flexN,lowDisp))/ (polyval(lowN,0)-polyval(flexN,0))
highCurve = (highForce - polyval(flexN,highDisp)) / (polyval(highN,0)-polyval(flexN,0))

figure(1)
subplot(2,1,1)
plot( sortedDisp - lowDisp)
subplot(2,1,2)
plot( sortedDisp - highDisp)

figure(2); clf;
plot(lowDisp, lowCurve)
legend('Low Motor Curve')
xlabel('Displacement (mm)')
ylabel('Fractional Drop in Force')

hold on
plot(highDisp, highCurve)
legend('Low Motor Curve', 'High Motor Curve')
xlabel('Displacement (mm)')
ylabel('Fractional Drop in Force')

figure(30)
clf
plot(d,polyval(flexN,d))
hold on
plot(d,polyval(highN,d))
plot(d,polyval(lowN,d))
%% Inverted Data and Fit 
fitOrder = 4;


highCurveFlip = 1./highCurve;
lowCurveFlip = 1./lowCurve;

[highFlipCal, highFlipS] = polyfit(highDisp, highCurveFlip,fitOrder);
[highFlipVals, highFlipDelta] = polyval(highFlipCal, d, highFlipS);
[lowFlipCal, lowFlipS] = polyfit(lowDisp, lowCurveFlip, fitOrder);
[lowFlipVals, lowFlipDelta] = polyval(lowFlipCal, d, lowFlipS);

figure(3); hold off;
plot(highDisp, highCurveFlip, '.b'); hold on;
plot(lowDisp, lowCurveFlip, '.g')
plot(d,lowFlipVals,'r','LineWidth',2)
plot(d,highFlipVals,'r','LineWidth', 2)
%  plot(d,lowFlipVals + 2*lowFlipDelta,'m--',d,lowFlipVals - 2*lowFlipDelta,'m--')
%  plot(d,highFlipVals + 2*highFlipDelta,'m--', d, highFlipVals - 2*highFlipDelta,'m--')
 ax = gca;
 ax.FontSize = 28;
 ax.TickLength = [0.025,0.025];
 ax.XColor = 'k'
 ax.LineWidth = 2
  ax.LineWidth = 2
  axis square
   xlim([min(d),max(d)])
 ylim([min(highCurveFlip),max(lowCurveFlip)])
figure(4);
plot(d,highFlipDelta,'-'); hold on;
plot(d,lowFlipDelta,'-');

disp("Data is in 'highFlipCal' and 'lowFlipCal'")

%% Fit As Recored
fitOrder = 6;

[~,flexIndex] = sort(flexDisp);
[~,highIndex] = sort(highDisp);
[~,lowIndex] = sort(lowDisp);
dispSorted = flexDisp(flexIndex);
highCurveSort = highCurve(highIndex);
lowCurveSort = lowCurve(lowIndex);

[highCal, highS] = polyfit(dispSorted, highCurveSort,fitOrder);
[highVals, highDelta] = polyval(highCal, dispSorted, highS);
[lowCal, lowS] = polyfit(dispSorted, lowCurveSort, fitOrder);
[lowVals, lowDelta] = polyval(lowCal, dispSorted, lowS);

figure(7); hold off;
plot(dispSorted, highCurveSort, '.y'); hold on;
plot(dispSorted, lowCurveSort, '.g')
plot(dispSorted,lowVals,'r')
plot(dispSorted,highVals,'r')
plot(dispSorted,lowVals + 2*lowDelta,'m--',dispSorted,lowVals - 2*lowDelta,'m--')
plot(dispSorted,highVals + 2*highDelta,'m--', dispSorted, highVals - 2*highDelta,'m--')

figure(8);
plot(dispSorted,highDelta,'--'); hold on;
plot(dispSorted,lowDelta,'--');

