%
clear
%import data from collection file
load([pwd,'\TVS_Data\TvSHolder.mat'])
%%
figure(10)
clf
colorSet = [0 0 1;
            1 0 0];
lineSet = {'-','--',':'};
rowList = [1:23];
colList = [2,4,8];

for row = 1:size(averageSurf,4)
    for col = 1:size(averageSurf,3)
%         fprintf('ind| %i   type| %i\n', row, col)
        plot(averageSurf(:,1,col, row), averageSurf(:,2,col,row),...
            'LineStyle',lineSet{col}, 'Color',colorSet(row,:),'LineWidth', 2)
        hold on
    end
end
%% Format Plots
xlabel('Number of behaviors')
ylabel('Mean squared error')

ax = gca;
ax.LineWidth = 2.5;
ax.TickLength = [.02,.02];
ax.FontSize = 24;
ax.XLim = [min(rowList),max(rowList)];
axYXLim = [min(averageSurf,[],'all'),max(averageSurf,[],'all')];
ax.XTick = rowList(1:floor(length(rowList)/4):length(rowList));  
box on
