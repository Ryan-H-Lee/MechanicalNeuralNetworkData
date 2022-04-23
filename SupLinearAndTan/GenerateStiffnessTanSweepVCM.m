% myPath=uigetdir;
close all
clear all
clc
    
    dataObject = dir(fullfile([pwd,'\Tan_Fan_Chart'],...
        'Specimen_RawData_*.csv'));

    for jj = 1 : length( dataObject )
        temp_data = readtable( fullfile( dataObject(jj).folder, dataObject(jj).name ) );
        temp_cell = table2array( temp_data(2:end,:) );
        if iscell(temp_cell)
            temp_array=zeros(size(temp_cell));
             for(mm=1:size(temp_cell,1))
                 for(nn=1:size(temp_cell,2))
                     temp_array(mm,nn)=str2double(temp_cell{mm,nn});
                 end
             end
        else
            temp_array = temp_cell;
        end
        %temp_array = cell2mat(temp_array);
        %Convert KgF to Newtons
        temp_array( :, 3 ) = temp_array( :, 3 );
        %convert mm to m
        temp_array( :, 2 ) = temp_array( :, 2)./1000;
        
%         %Generate Name for data object
%         name1 = strsplit( dataObject(jj).folder, '\' );
%         name2 = strsplit( name1{4}, '.' );
%         name3 = erase( name2{1},"testRun");
%         pGain = strrep( name3,'N','-');
       
        p1 = polyfit(temp_array(:, 2), temp_array( :, 3),1); %linear fit the data
        temp_array(:,4) = polyval(p1,temp_array(:, 2));

        DM2{jj,1} = temp_array;
        DM2{jj,2} =  jj; %str2double(pGain);
        DM2{jj,3} = p1;
        
        figure(1)
        hold on
        plot(DM2{jj,1}(:,2)*1000,DM2{jj,1}(:,3))
%         plot(DM2{jj,1}(:,2),DM2{jj,1}(:,4))
       
    end
ax = gca;
ax.XLim = [-2.5, 2.5];
ax.YLim = [-3, 3];
ax.Box = 'on';
ax.LineWidth = 2;
ax.FontSize = 28;
axis square;
