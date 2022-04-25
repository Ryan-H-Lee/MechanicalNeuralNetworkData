clear all
chartSixLine =  false
LC = true;

if chartSixLine
    typeArray = [1,2]
    layerArray = [2,4,8]
    caseArray = [1,2:3:20]
else
    typeArray = 1
    layerArray = [1:9]
    caseArray = [1,4:4:20]
end
layerArray = 1:8
caseArray = 2
%%
iter = 1
newSet = true
while newSet
    %
    JoinDataCells
    clear graphCell
    clear zHeight
    %Data Returned in holdCell
    [nPts{iter}, dataPts{iter}]= countPoints(holdCell)
%     [graphCell, zHeight(:,:,:,iter)] = multiGraphFunctionBest(holdCell,typeArray,layerArray, caseArray) 
    [graphCell, zHeight(:,:,:,iter)] = multiGraphFunctionBest(holdCell) 

    newSet = input('Run another set: 1/0?')
    iter = iter + 1;
end

%%
figure(1000)
clf
for ind = 1:size(zHeight,3)
zNew= mean(zHeight(:,:,ind,:),4)
figure(1000)
hold on
[rowList,colList, zMatrix(:,:,ind)] = removeInf(zNew)
surf(colList,rowList,zMatrix(:,:,ind))
% ylabel('Number of behaviors')
% xlabel('Number of layers')
% zlabel('Mean squared error')
maxLayers = max(rowList);
maxCases = max(colList)
ax = gca;
ax.YLim = [1,maxLayers];
ax.XLim = [1,maxCases];
ax.LineWidth = 2;
ax.FontSize = 28
ax.XTick = colList;
ax.YTick = rowList(1:floor(length(rowList)/4):length(rowList));

view(45,45)
end
%%
lWidth = 2
if chartSixLine
    figure(2000)
    clf
    plot(rowList, zMatrix(:,1,2), 'r:', 'LineWidth', lWidth)
    hold on
    plot(rowList, zMatrix(:,2,2), 'r--','LineWidth', lWidth)
    plot(rowList, zMatrix(:,3,2), 'r-','LineWidth', lWidth)
    plot(rowList, zMatrix(:,1,1), 'b:','LineWidth', lWidth)
    plot(rowList, zMatrix(:,2,1), 'b--','LineWidth', lWidth)
    plot(rowList, zMatrix(:,3,1), 'b-','LineWidth', lWidth)
    xlabel('Number of behaviors')
    ylabel('Mean squared error')
    box on
    ax = gca;
    ax.LineWidth = 2.5
    ax.TickLength = [.02,.02]
    ax.FontSize = 24
    ax.XLim = [min(rowList),max(rowList)]
    axYXLim = [min(zMatrix,[],'all'),max(zMatrix,[],'all')]
%     ax.XTick = colList;
    ax.XTick = rowList(1:floor(length(rowList)/4):length(rowList));
    
end
%% Weighted Sum by number of points averaged
sumVal = zeros(size(nPts{1}));
denomenator = sumVal;
for i = 1:iter-1
    sumVal = sumVal(1:size(nPts{i},1), 1:size(nPts{i},2), 1:size(nPts{i},3), 1:size(nPts{i},4)) + min(dataPts{i},[],5).*nPts{i};
    denomenator = denomenator(1:size(nPts{i},1), 1:size(nPts{i},2), 1:size(nPts{i},3), 1:size(nPts{i},4)) + nPts{i};
end
weightedMean = sumVal./denomenator;
filledData = find(~isnan(weightedMean));
[ind1, ind2, ind3, ind4] = ind2sub(size(weightedMean),filledData);
ind1 = unique(ind1)
ind2 = unique(ind2)
ind3 = unique(ind3)
ind4 = unique(ind4)
weightedHeight = squeeze(weightedMean(ind1,ind2,ind3,ind4))
%%
if chartSixLine
    figure(2001)
    clf
    plot(rowList, squeeze(weightedHeight(1,2,:)), 'r:', 'LineWidth', lWidth)
    hold on
    plot(rowList, squeeze(weightedHeight(2,2,:)), 'r--','LineWidth', lWidth)
    plot(rowList, squeeze(weightedHeight(3,2,:)), 'r-','LineWidth', lWidth)
    plot(rowList, squeeze(weightedHeight(1,1,:)), 'b:','LineWidth', lWidth)
    plot(rowList, squeeze(weightedHeight(2,1,:)), 'b--','LineWidth', lWidth)
    plot(rowList, squeeze(weightedHeight(3,1,:)), 'b-','LineWidth', lWidth)
    xlabel('Number of behaviors')
    ylabel('Mean squared error')
    box on
    ax = gca;
    ax.LineWidth = 2.5
    ax.TickLength = [.02,.02]
    ax.FontSize = 24
    ax.XLim = [min(rowList),max(rowList)]
    axYXLim = [min(zMatrix,[],'all'),max(zMatrix,[],'all')]
%     ax.XTick = colList;
    ax.XTick = rowList(1:floor(length(rowList)/4):length(rowList));  
end
if LC
    figure(1001)
    surf(ind2,ind4,squeeze(weightedHeight(:,:))')
    view(45,45)
    maxLayers = max(rowList);
maxCases = max(colList)
ax = gca;
ax.YLim = [1,maxLayers];
ax.XLim = [1,maxCases];
ax.LineWidth = 2;
ax.FontSize = 28
ax.XTick = colList;
ax.YTick = rowList(1:floor(length(rowList)/4):length(rowList));

end
