% to plot the descending error trend use the 
clear
close all

load('PartialPattern_At20210916T181524_WithTargets.mat')
mseVect = eHistB;
timeALL = tHistB(1,:);
bestIndex = stepIter;
for ind = 1:size(pHistB,2)
    thisPos = pHistB(:,ind);
    posHolder = reshape(thisPos, 8,2,[]);
    dispHist(:,:,ind) = [squeeze(posHolder([4,8],:,1)); squeeze(posHolder([4,8],:,2))]
end

pf = 1:length(dispHist);

%%
figure(11)
timeStep = datenum(timeALL(pf)- timeALL(1))*24
framesUsed = [1,pf(end)]
eHistWidth = 2
eHistColor = [0 0 1]
eHistStyle = '.-'
eHistMSize = 15

plot(timeStep, mseVect(pf),eHistStyle, 'MarkerSize', eHistMSize, 'LineWidth', eHistWidth, 'Color', eHistColor)
ax = gca
% set(ax, 'XLim', [1, framesUsed(end)])
% set(ax, 'XTick', linspace(1, 16, 4))
set(ax, 'YTick', round(linspace(0, max(mseVect), 4),2))
% set(ax, 'YLim', [-1, 1])
set(ax, 'LineWidth', 2.5)
set(ax, 'FontName', 'Calibri')
set(ax,'FontSize', 32)
set(ax, 'YLim', [0, 0.35])
set(ax,'TickLength', [0.015, 0.05])
set(ax,'YTick', [0, 0.1, 0.2, 0.3])
set(ax,'XColor', [0 0 0])
axis square
errorFigName = ['errorTIMEFig_',num2str(pf(end))];
typeList = {'.fig','.png'};
for ind = 1:length(typeList)
saveas(gca, [errorFigName, typeList{ind}]);
end
% set(ax, 'YTick', linspace(-1, 1, 5))
% grid on
%%
minError = min(mseVect)
startError = mseVect(1)
maxTime = timeStep(end)
%% dispHist seems to be the position of the nodes
numNodes = 2;
numBehs  = 2;
endMarker = 'o'
endMarkerSize = 55
behColor = [1 0 0; 0 1 0];
trajWidth = 1.5;
trajStyle = '.-'
trajMSize = 20
targetStyle = '*'
targetSize = 27
targThk = 2
stepOver = 0.004
framesUsed = [pf, ones(1,3)*pf(end)]
for node = 1:numNodes
    h = figure(node);
    filename = ['trajectoryAnimation','Node_',num2str(node),'.gif'];

    for ind = 1:length(framesUsed)
        frame = framesUsed(ind)
        hold off
        for beh = 1:numBehs
            outInd = (node) + numNodes*(beh - 1)
            xTraj = squeeze(dispHist(outInd, 1, framesUsed(1:ind)));
            yTraj = squeeze(dispHist(outInd, 2, framesUsed(1:ind)));
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
newPos = dispHist;
fStart = 100
for node = 1:numNodes
    h = figure(node + fStart);
    fileNameFig = ['trajectoryStatic','Node_',num2str(node),'.fig'];
    fileNameStatic = ['trajectoryStatic','Node_',num2str(node),'.png'];
    for ind = [1,length(framesUsed)]
        frame = framesUsed(ind)
        hold off
        for beh = 1:numBehs
            outInd = (node) + numNodes*(beh - 1)
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
        saveas(gca,fileNameFig);
        saveas(gca,fileNameStatic);
    end
end