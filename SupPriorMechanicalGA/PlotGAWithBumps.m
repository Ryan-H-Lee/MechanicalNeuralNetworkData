load('GaWithBumpsData.mat')
figure(10)
clf
plot(gaLines(:,1,1),gaLines(:,2,1), '.-','Color',[11 8 209]/255,...
            'MarkerSize',18,...
            'LineWidth', 2)
ax = gca;
ax.FontSize = 15
ax.XLim = [0, 85]
ax.LineWidth = 2.25
ax.Box = 'off'