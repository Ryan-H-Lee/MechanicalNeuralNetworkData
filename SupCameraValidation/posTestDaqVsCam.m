collectNewTestSet = false
if collectNewTestSet
startArdCell

%% Prime Camera
startCamCell

input('Did you check the Camera Exposures?')

fMax            = 1;
minPinPix       = 200;
maxPinEcc       = [0.5, 0.5];
minFidPix       = [253, 291];
minFidEcc       = [0.91, 0.91];
bwThreshold     = 15;
nStable         = 25;
motionThreshold = 2; %this was increaseddue to motion in the links
maxSettlingTime = nStable*8 + 15;
maxTries        = 1;
mmpp            = 1./[176.81, 186.64
                      164.17, 173.46];
typFidCen       = [1167.4, 893.6; 1147.3, 834.3];
fidTipTol       = 3; %std of movement in pixels
scaleForce      = false
plotFSCurves    = true

frameCell{1} = minPinPix;
frameCell{2} = maxPinEcc;
frameCell{3} = typFidCen;   %typFidTip = frameCell{3} %Location of fid Tip
frameCell{4} = typFidCen;   %typFidCen = frameCell{4}
frameCell{5} = fidTipTol;   %fidTipTol = frameCell{5} %allowable spread in pixels of FID Tip
frameCell{6} = minFidPix;   %minFidPix = frameCell{6}%fid Major axis minimum size
frameCell{7} = minFidEcc;   %minFidEcc = frameCell{7} %fid eccentricity
frameCell{8} = bwThreshold; %bwThreshold = frameCell{8} % 0=>255 minimum threshold level
frameCell{9} = mmpp;        %mmpp = frameCell{9} %mm/pp conversion

motionCell{1} = motionThreshold; %motionThreshold = motionCell{1}
motionCell{2} = nStable;    %nStable = motionCell{2}
motionCell{3} = maxSettlingTime;
motionCell{4} = scaleForce;
motionCell{5} = plotFSCurves;
motionCell{6} = fMax;

%% Prime Daq
startDaq
testConversion

%% setup savefile
disp('Enter a file NAME and PATH to SAVE TO')
[file,path] = uiputfile;
%%
ioMag = 3;
testDuration = 10;
roughFPS = 9;
numTests = 25;
daqRate = 1000;
dq.Rate = daqRate;
numCams = 2;

forceCase = 2*rand(numCams,2,numTests) - 1; %-[0 1; 0 1]*fMax;

camOut = cell(numTests, numCams, roughFPS*testDuration);
camZeros = cell( 1    , numCams, roughFPS*testDuration);
dataOut = zeros(daqRate*testDuration,8,numTests);
timestamps = zeros(daqRate*testDuration,numTests);
randomConfigs = 2.2*rand(21,numTests);

disableMotors(ardCell,1);
setInputForce(ardCell(22:25),forceCase(:,:,1)*0)
pause(5)
start(dq, "Duration", seconds(testDuration))
%Apply load to ANN

%Record Images
frameNum = 1
while dq.Running
    for camNum = 1:numCams
        camZeros{1, camNum, frameNum} = snapshot(camCell{camNum});
    end
    frameNum = frameNum + 1;
end
[daqZero, timestampZeros, ~] = read(dq, seconds(testDuration), "OutputFormat", "Matrix");


%enable motors
disableMotors(ardCell,0)
for testNum = 1:numTests
    testNum
    frameNum = 1;
    setInputForce(ardCell(22:25),[1 0; 1 0]*0);
    writeStiffnessToArray(ardCell(1:21),randomConfigs(:,testNum)) %randomize config
    pause(2);
    for camNum = 1:numCams
        camOut{testNum, camNum, frameNum} = snapshot(camCell{camNum});
    end
    frameNum = frameNum + 1;
    %Start record on Daq
    start(dq, "Duration", seconds(testDuration))
    %Apply load to ANN
    setInputForce(ardCell(22:25),forceCase(:,:,testNum)*ioMag)
    %Record Images
    
    while dq.Running
        for camNum = 1:numCams
            camOut{testNum, camNum, frameNum} = snapshot(camCell{camNum});
        end
         frameNum = frameNum + 1;
    end
    [dataOut(:,:,testNum), timestamps(:,testNum), ~] = read(dq, seconds(testDuration), "OutputFormat", "Matrix");
end
%Safe array
setInputForce(ardCell(22:25),[1 0; 1 0]*0);
disableMotors(ardCell,1)

save([path,file],'-v7.3')
save([path,file,'_rawOut'],'dataOut','shiftMat','polyMat','p')

%% Process to DAQ cartesian
figure(10)
% clf
figure(101)
% clf

rawOut = daqZero;
% roughcartesian
testRotation
nodeZero = nList; %These are the cartesian ZEROS
linkZero = lenMat;
daqPosZero = diag(p(:,1))*rawOut' + p(:,2);
outputNodesZero = nodesXYStacked;
daqAvgZero = mean(nodeZero,3);


for testNum = 1:numTests
rawOut = dataOut(:,:,testNum);
rawOut = smoothdata(rawOut,1);
% roughcartesian
testRotation
nodePos(:,:,:,testNum) = nList;
linkLen(:,:,testNum) = lenMat;
daqPos(:,:,testNum) = diag(p(:,1))*rawOut' + p(:,2);
outputNodes(:,:,testNum) = nodesXYStacked;
end

%% Process CAM to cartesian
plotOn = false;
[ pinLoc, pinRad, pinEcc, fidTip, fidLoc, fidAxis, fidEcc] = findGlobalBall_Post(camOut, minPinPix, maxPinEcc, minFidPix, minFidEcc, bwThreshold, maxTries, plotOn);
[ pinLocZero, pinRadZero, pinEccZero, fidTipZero, fidLocZero, fidAxisZero, fidEccZero]...
    = findGlobalBall_Post(camZeros, minPinPix, maxPinEcc, minFidPix, minFidEcc, bwThreshold, maxTries, plotOn);
pinZeros = squeeze( mean(pinLocZero(1,:,:,:),3)) %(test, cam, frame, dim) average across the frame reads

else
    fprintf('Slect the datafile you wish to plot. \n\n')
    load(uigetfile('*.mat'))
end

%% Final graph plots
daqLineType = '-';
daqLineWidth = 2;
daqLineColor = [1 0 0; 0 0 1] ; %[231 60 93; 202 225 137]./255 
minTime = 5;
maxTime = 9.2;
camLineType = {'.--', '.--'};
camLineColor = [ 102/255 0 102/255; 0 1 0 ]; %[140 0 0; 45 115 25]./255
camLineWidth = 2;
camMarkerSize = 15;

titleText = 'Displacement at node '
outputInds = [4,8];
for testNum = 1:numTests
    cnt = 1;
    for camNum = 1:numCams
        %DAQ Timeserries
        figure(100*camNum + testNum)
        clf
        
        set(gca,'ColorOrderIndex',1)
        for dimNum = 1:numDims
            indList = timestampZeros<maxTime;
            yData = squeeze(nodePos(4*(camNum),dimNum,indList,testNum))'- daqAvgZero(4*(camNum),dimNum);
            xData = timestampZeros(indList);
            plot(xData, yData ,daqLineType, 'LineWidth', daqLineWidth,'Color', daqLineColor(dimNum,:))
            hold on
            
            finalInd = find(timestampZeros <= maxTime & timestampZeros >= minTime );
            avgDaq(camNum,dimNum, testNum) = mean(yData(finalInd));
            daqTraj(camNum, dimNum, testNum, 1:length(yData)) = yData;
        end

        %Camera Timeserries
        for dimNum = 1:numDims
            if dimNum == 1
                plotData = (squeeze(pinLoc(testNum,camOrder(camNum),1:end-offset,dimNum))- pinZeros(camOrder(camNum),dimNum) )*mmpp(dimNum,camOrder(camNum));        
            elseif dimNum == 2
                %Y Data must be plotted backwards
                plotData = (squeeze(toImY(pinLoc(testNum,camOrder(camNum),1:end-offset,dimNum)))- toImY(pinZeros(camOrder(camNum), dimNum)) )*mmpp(dimNum,camOrder(camNum));                        
            end
            mmpp(dimNum,camOrder(camNum));
            plot((0 + (0:length(plotData)-1)*(1/7.7)),plotData,camLineType{dimNum}, 'LineWidth', camLineWidth, 'MarkerSize',camMarkerSize, 'Color', camLineColor(dimNum,:))
            hold on
            cnt = cnt + 1;
            
            frameRate = 7.6;
            firstInd = round(minTime*frameRate);
            lastInd = size(pinLoc,3);
            avgCam(camNum,dimNum, testNum) = mean(plotData(firstInd:end));
            camTraj(camNum, dimNum, testNum, 1:length(plotData)) = plotData;
        end
%         title( [titleText,num2str(camNum)]);
        set(gca,'LineWidth',2.5);
        set(gca,'FontSize',32);
        set(gca,'XMinorTick','off');
        set(gca,'YMinorTick','on');
%         set(gca,'XTick',[
        set(gca,'XTickLabelMode', 'auto');
        set(gca,'XTick',[0:9]);
        set(gca,'XLim', [0, maxTime]);
        set(gca,'FontName','Calibri');
       
        
    end
end

%% Plot Daq data
% numDims = 2
% figure(11)
%  clf
% figure(12)
%  clf
% daqLineType = '-'
% outputInds = [4,8];
% for testNum = 1:numTests
%     figure(11)
%     for camNum = outputInds
%         camIndex = find(camNum == outputInds);
% %         subplot(2,1,camIndex)
%         figure(10 + camIndex)
% %         set(gca,'ColorOrderIndex',1) 
%         tempData  = squeeze(nodePos(camNum,:,:,testNum))';
%         tempData = tempData - daqAvgZero(camNum,:);
%         plot(tempData(:,1),tempData(:,2));
%         hold on
%         axis equal
%         grid on
%         title(['Node #', num2str(camIndex)])
%     end
%     figure(20 + testNum)
%     clf
%     for camNum = 1:numCams
%         for dimNum = 1:numDims
% %             subplot(1,2,1)
%             plot(timestampZeros, squeeze(nodePos(4*(camNum),dimNum,:,testNum))'- daqAvgZero(4*(camNum),dimNum),daqLineType)
%             hold on 
%         end
%     end
% end
% %% Camera Plots
% camOrder  = [2,1];
% camType =  '.-';
% offset = 6;
% toImY = @(x) 1024 - x;
% figure(11)
% % clf
% set(gca,'ColorOrderIndex',1)
% figure(12)
% set(gca,'ColorOrderIndex',1)
% for testNum = 1:numTests
%     for camNum = 1:numCams
% %     figure(11)
% %     subplot(numCams,1,camOrder(camNum))
%     %Plot XY Cartesian displacements
%     figure(10 + camOrder(camNum))
%     xData = squeeze(pinLoc(testNum,(camNum),1:end-offset,1));
%     yData = toImY(squeeze(pinLoc(testNum,(camNum),1:end-offset,2)));
%     xData = (xData(xData~=0)- pinZeros(camNum, 1) )*mmpp(1,(camNum));
%     yData = (yData(xData~=0) - toImY(pinZeros(camNum,2)) )*mmpp(2,(camNum));
% 
%    plot(xData,yData,camType,'LineWidth', 2)
%     hold on
%     axis equal
%     grid on
%     title(['Node #', num2str(camOrder(camNum))])
%     end
%     
%     %timeserries graphs
%     figure(20 + testNum)
%     set(gca,'ColorOrderIndex',1) 
%     %pinLoc(testNum,camNum,saveNum,:)
%     cnt = 1;
%     for camNum = 1:numCams
% %         subplot(1,2,2)
%         for dimNum = 1:numDims
%             if dimNum == 1
%                 plotData = (squeeze(pinLoc(testNum,camOrder(camNum),1:end-offset,dimNum))- pinZeros(camOrder(camNum),dimNum) )*mmpp(dimNum,camOrder(camNum));        
%             elseif dimNum == 2
%                 %Y Data must be plotted backwards
%                 plotData = (squeeze(toImY(pinLoc(testNum,camOrder(camNum),1:end-offset,dimNum)))- toImY(pinZeros(camOrder(camNum), dimNum)) )*mmpp(dimNum,camOrder(camNum));                        
%             end
%             mmpp(dimNum,camOrder(camNum));
% %                 yData = (-squeeze(pinLoc(testNum,camNum,1:end-offset,2))+ pinZeros(2))*mmpp(2,camOrder(camNum));          
%             plot((0 + (0:length(plotData)-1)*(1/7.7)),plotData,camType)
%             hold on
%             cnt = cnt + 1;
%         end
% 
%     end
%     legend('c1/n2 dx','c1/n2 dy','c2/n1 dx','c2/n1 dy', 'c1/n2 dx','c1/n2 dy','c2/n1 dx','c2/n1 dy')
% %     plot(([squeeze(pinLoc(testNum,1,:,:)-pinLoc(testNum,1,1,:)),squeeze(pinLoc(testNum,2,:,:)-pinLoc(testNum,2,1,:))]).*[mmpp(:,1);mmpp(:,2)]','.-')
% end
% 
%% Plot on image
% for testNum = 1:numTests
%     figure(30 + testNum)
%     clf
%     for camNum = 1:numCams
%         subplot(numCams, 1, camOrder(camNum))
%         h = imshow(camOut{testNum, camNum, 1})
%         set(h, 'AlphaData', .4)
%         hold on
%         h = imshow(camOut{testNum, camNum, 40})
%         set(h, 'AlphaData', .4)
%         xData = squeeze(pinLoc(testNum,camNum,:,1));
%         yData = squeeze(pinLoc(testNum,camNum,:,2));
%         xData = xData(xData~=0);
%         yData = yData(xData~=0);
%         hold on
%         plot(xData,yData,'.-')
%         title(['Node', num2str(camOrder(camNum))])
%     end
% end


 %%
deltaPos = avgDaq - avgCam;
meanDelta = mean(deltaPos, 3);
stdDelta = std(deltaPos,[],3);
radialDistance = sqrt((sum(deltaPos.^2,2)));
fprintf('Average and STD of Total Distance (mm)\n')
% meanDistance = mean(radialDistance,'all')
% stdDistance = std(reshape(squeeze(radialDistance),1,[]))

meanDistancePaper = mean(sum(radialDistance))
sttDistancePaper = std(sum(radialDistance))
% for cam = 1:numCams
%     for dim = 1:numDims
%         figure(30 + numDims*(cam - 1) + dim)
%         histogram(deltaPos(cam, dim, :))
%     end
% end
%% Plot Overhead trajectory
% for testNum = 1:numTests
% %     testNum = 9
%     figure(1000*camNum + testNum)
%     hold off
%     
%     daqLineType = {'-','-'}
%     daqLineWidth = 2
%     daqLineColor = [1 0 0; 0 0 1] ; %[231 60 93; 202 225 137]./255 
%     minTime = 5;
%     maxTime = 9.2
%     camLineType = {'.--', '.--'}
%     camLineColor = [ 102/255 0 102/255; 0 1 0 ]; %[140 0 0; 45 115 25]./255
%     camLineWidth = 2
%     camMarkerSize = 15
% 
%     for camNum = 1:numCams
% 
%     figure(1000*camNum + testNum)
%     hold off
% 
%         xData = squeeze(daqTraj(camNum,1,testNum,:));
%         yData = squeeze(daqTraj(camNum,2,testNum,:));
%         plot(xData, yData, daqLineType{camNum}, 'Color', daqLineColor(camNum,:),'LineWidth', daqLineWidth)
%         hold on
%         xData = squeeze(camTraj(camNum,1,testNum,:));
%         yData = squeeze(camTraj(camNum,2,testNum,:));
%         plot(xData,yData, camLineType{camNum}, 'Color', camLineColor(camNum,:), 'LineWidth',camLineWidth,'MarkerSize',camMarkerSize)
% 
% 
%     end
% end
% %% Find the mean and std of the changes in sensor 
% minTime = 5;
% maxTime = 9.9
% finalInd = find(timestampZeros <= maxTime & timestampZeros >= minTime );
% finalPosDaq  = squeeze(mean(nodePos([4,8],1:2,finalInd,:),3)) - repmat(daqAvgZero([4,8],:),1,1,numTests);
% finalPosDaq = permute(finalPosDaq, [3,2,1])
% frameRate = 7.6
% firstInd = round(minTime*frameRate)
% lastInd = size(pinLoc,3);
% zeroPosCam = [pinZeros(:,1), toImY(pinZeros(:,2))];
% zeroPosCam = repmat(zeroPosCam,1,1,numTests)
% camAvgPos = squeeze(mean(pinLoc(:,1:2, firstInd:lastInd,:),3))
% camAvgPos = [camAvgPos(:,1,:), toImY(camAvgPos(:,2,:))];
% finalPosCam = permute(( permute(camAvgPos,[3,2,1]) - zeroPosCam).*mmpp,[3,2,1])
% 
% deltaPos = finalPosCam - finalPosDaq
% stdDelta = squeeze(std(deltaPos))
% meanDelta = squeeze(mean(deltaPos))

