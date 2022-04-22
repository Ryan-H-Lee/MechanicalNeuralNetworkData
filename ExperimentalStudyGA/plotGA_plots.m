clear
close all
load('2021_06_07_1937_repastedRestarted.mat')

eType = 1;
mSize = 20;
lSize = 2;
fomtSize = 32;
for gen = 2:testNum/1000
    sInd = (gen-1)*1000;
    eInd = gen*1000 - 1;
    genInd = sInd:eInd;
    [genMin(gen-1), thisIter] = min(errorHist(genInd, eType));
    genMean(gen-1) = mean(errorHist(genInd, eType));
%     figure(1)
%     clf
%     plot(errorHist(genInd, eType))
%     input('Press ENTER to continue')
    minIter(gen-1) = sInd + thisIter -1;
end
[bestVal,bestGen] = min(genMin);

figure(3)
clf
plot(1:length(genMin), genMin, '.b-', 'MarkerSize', mSize, 'LineWidth', lSize)
hold on
plot(1:length(genMean), genMean, '.k', 'MarkerSize', mSize)
plot([1,1]*bestGen, [0, max(genMean)],'--')
figAx = gca;
figAx.XLim = [1, testNum/1000 - 1];
figAx.YLim = [0,max(genMean)];

figAx.FontSize = fomtSize;
figAx.FontName = 'Calibri';
% xlabel('Generation')
% ylabel('Mean Squared Error (mm^{2})')
figAx.LineWidth = 2.5;
figAx.XLim = [1, 40];
grid off
axis square


figure(4)
clf
plot(1:length(genMin), genMin, '.b-', 'MarkerSize', mSize, 'LineWidth', lSize)
hold on
plot([1,1]*bestGen, [0, max(genMean)],'--')
figAx = gca;
figAx.XLim = [1, testNum/1000 - 1];
figAx.YLim = [0,max(genMin)];

figAx.FontSize = fomtSize;
figAx.FontName = 'Calibri';
% xlabel('Generation')
% ylabel('Mean Squared Error (mm^{2})')
figAx.XLim = [1, 40];
figAx.LineWidth = 2.5;
grid off
axis square

%% get times
ind  = find(timeHist(:,1) ~= 0);
indVect = timeHist(ind, :);
deltaT = indVect;
timeHrs  = (datenum(deltaT))*24;
sampledList = timeHrs(1:1000:end) - timeHrs(1);
 sampledVect = deltaT(1:1000:end,:);
 
% %  sampledVect(1:length(yVals),:)
% yVals = genMin(1:40);
% yVals2 = genMean(1:40);
% [bestVal,bestGen] = min(genMin);
% figure(5)
% clf
% plot(sampledList(1:length(yVals)), yVals, '.b', 'MarkerSize', mSize)
% hold on
% plot(sampledList(1:length(yVals)), yVals2, '.k', 'MarkerSize', mSize)
% % plot([1,1]*bestGen, [0, max(genMean)],'--')
% figAx = gca;
% % figAx.XLim = [1, testNum/1000 - 1]
% figAx.YLim = [0,max(genMean)];
% 
% figAx.FontSize = fomtSize;
% % xlabel('Time (hr)')
% % ylabel('Mean Squared Error (mm^{2})')
% figAx.FontSize = fomtSize;
% figAx.FontName = 'Calibri';
% % figAx.XTick = [0, 20,40,60];
% figAx.LineWidth = 2.5;
% grid off
% axis square

figure(6)
clf
plot(sampledList(1:length(yVals)), yVals, '.b-', 'MarkerSize', mSize, 'LineWidth',lSize)
hold on
% plot([1,1]*bestGen, [0, max(genMean)],'--')
figAx = gca;
% figAx.XLim = [1, testNum/1000 - 1]
figAx.YLim = [0,max(yVals)];

figAx.FontSize = fomtSize;
% xlabel('Time (hr)')
% ylabel('Mean Squared Error (mm^{2})')
figAx.FontSize = fomtSize;
figAx.FontName = 'Calibri';
% figAx.XTick = [0,20,40,60];
figAx.LineWidth = 2.5;
grid off;
axis square
%% Repack data into 8x2xGEN
genList = 1:40;
%Since the reshape behavior takes a 16x2x2 matrix  and sqishes it into a
%vector
indVect = [ 0 1; 2 3; 4 5; 6 7; 8 9; 10 11; 12 13; 14 15] + 1;
indVect(:,:,2) = indVect(:,:,1)+ 100;

reshape(indVect, 1, [])
% We want elements [7, 8; 15, 16; 107, 108; 115 116 ]
%these are element [4, 12, 
trimmedPos = zeros(4, 2, length(genList));
for gen = genList
    thisPos = dispHist(minIter(gen),:);
    posHolder = reshape(thisPos, 8,2,[]);
    trimmedPos(:,:,gen) = [squeeze(posHolder([4,8],:,1)); squeeze(posHolder([4,8],:,2))];
end
newPos = trimmedPos;

%% Plot the  XY plots
tailLength = inf;
numNodes = 2;
numBehs  = 2;
endMarker = 'o';
endMarkerSize = 30;
behColor = [0 1 0; 1 0 0];
trajWidth = 1.5;
trajStyle = '.-';
trajMSize = 22;
targetStyle = '*';
targetSize = 15;
targThk = 2;
stepOver = 0.004;
framesUsed = [genList, genList(end), genList(end),genList(end) genList(end),genList(end)];
target = testPar.targets;
for node = 1:numNodes
    h = figure(node);
    filename = ['trajectoryAnimationGA','Node_',num2str(node),'Tail_',num2str(tailLength),'.gif'];

    for ind = 1:length(framesUsed)
        frame = framesUsed(ind);
        hold off
        for beh = 1:numBehs
            outInd = (node) + numNodes*(beh - 1);
            xTraj = squeeze(newPos(outInd, 1, framesUsed(1:ind)));
            yTraj = squeeze(newPos(outInd, 2, framesUsed(1:ind)));
            if ind > tailLength
                xTraj = xTraj((end-tailLength):end);
                yTraj = yTraj((end-tailLength):end);
            end
    %         traj
            % Draw plot for y = x.^n

            plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh)), targetStyle,'MarkerSize', targetSize, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            hold on
%             plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh)), 'o','MarkerSize', targetSize/2, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
%             plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh)), 'o','MarkerSize', targetSize/4*3, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh)), 'o','MarkerSize', targetSize+2, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh)), 'o','MarkerSize', targetSize+1, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh)), 'o','MarkerSize', targetSize, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))

            plot(squeeze(target(node , 1,beh))+stepOver, squeeze(target(node , 2,beh)), targetStyle,'MarkerSize', targetSize, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            plot(squeeze(target(node , 1,beh))-stepOver, squeeze(target(node , 2,beh)), targetStyle,'MarkerSize', targetSize, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh))+stepOver, targetStyle,'MarkerSize', targetSize, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh))-stepOver, targetStyle,'MarkerSize', targetSize, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))

            plot(xTraj,yTraj, trajStyle, 'MarkerSize', trajMSize,'LineWidth', trajWidth, 'Color', behColor(beh,:))
            plot(xTraj(end),yTraj(end), endMarker, 'MarkerSize', endMarkerSize, 'Color', behColor(beh,:))
            plot(xTraj(end),yTraj(end), endMarker, 'MarkerSize', endMarkerSize-1, 'Color', behColor(beh,:))
            plot(xTraj(end),yTraj(end), endMarker, 'MarkerSize', endMarkerSize-2, 'Color', behColor(beh,:)) 
%             LineHandle.NodeChildren.LineWidth = 10
            ax = gca;
            set(ax, 'XLim', [-1, 1])
            set(ax, 'YLim', [-1, 1])
            set(ax, 'LineWidth', 2)
            set(ax,'FontSize', 32)
            set(ax, 'YTick', linspace(-1, 1, 5))
            set(ax, 'XTick', linspace(-1, 1, 5))
%             set(ax, 'YTickLabel',{})
%             set(ax, 'XTickLabel',{})
            set(ax, 'color', [1 1 1]);
            set(gcf, 'Color', [1 1 1]);
            axis square
            grid on
%             axis tight manual % this ensures that getframe() returns a consistent size
        end
        drawnow
        pause(0.01)
        % Capture the plot as an image 
        thisFrame = getframe(h); 
        im = frame2im(thisFrame); 
        [imind,cm] = rgb2ind(im,256); 
        % Write to the GIF File 
        if frame == 1 
            imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
        else 
            imwrite(imind,cm,filename,'gif','WriteMode','append'); 
        end 
    end
end

%%
fStart = 100
for node = 1:numNodes
    h = figure(node + fStart);
    fileName = ['trajectoryStaticGA','Node_',num2str(node),'.fig'];

    for ind = [1,length(framesUsed)]
        frame = framesUsed(ind);
        hold off
        for beh = 1:numBehs
            outInd = (node) + numNodes*(beh - 1);
            xTraj = squeeze(newPos(outInd, 1, framesUsed(1:ind)));
            yTraj = squeeze(newPos(outInd, 2, framesUsed(1:ind)));
    %         traj
            % Draw plot for y = x.^n

            plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh)), targetStyle,'MarkerSize', targetSize, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            hold on
%             plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh)), 'o','MarkerSize', targetSize/2, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
%             plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh)), 'o','MarkerSize', targetSize/4*3, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh)), 'o','MarkerSize', targetSize+2, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh)), 'o','MarkerSize', targetSize+1, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh)), 'o','MarkerSize', targetSize, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))

            plot(squeeze(target(node , 1,beh))+stepOver, squeeze(target(node , 2,beh)), targetStyle,'MarkerSize', targetSize, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            plot(squeeze(target(node , 1,beh))-stepOver, squeeze(target(node , 2,beh)), targetStyle,'MarkerSize', targetSize, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh))+stepOver, targetStyle,'MarkerSize', targetSize, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))
            plot(squeeze(target(node , 1,beh)), squeeze(target(node , 2,beh))-stepOver, targetStyle,'MarkerSize', targetSize, 'defaultLineMarkerSize', targThk,'Color', behColor(beh,:))

            plot(xTraj([1,end]),yTraj([1,end]), trajStyle, 'MarkerSize', trajMSize,'LineWidth', trajWidth, 'Color', behColor(beh,:))
            plot(xTraj(end),yTraj(end), endMarker, 'MarkerSize', endMarkerSize, 'Color', behColor(beh,:))
            plot(xTraj(end),yTraj(end), endMarker, 'MarkerSize', endMarkerSize-1, 'Color', behColor(beh,:))
            plot(xTraj(end),yTraj(end), endMarker, 'MarkerSize', endMarkerSize-2, 'Color', behColor(beh,:)) 
%             LineHandle.NodeChildren.LineWidth = 10
            ax = gca;
            set(ax, 'XLim', [-1, 1])
            set(ax, 'YLim', [-1, 1])
            set(ax, 'LineWidth', 2)
            set(ax,'FontSize', 32)
            set(ax, 'YTick', linspace(-1, 1, 5))
            set(ax, 'XTick', linspace(-1, 1, 5))
%             set(ax, 'YTickLabel',{})
%             set(ax, 'XTickLabel',{})
            set(ax, 'color', [1 1 1]);
            set(gcf, 'Color', [1 1 1]);
            axis square
            grid on
%             axis tight manual % this ensures that getframe() returns a consistent size
        end
        drawnow
        saveas(gca,fileName);
    end
end


    