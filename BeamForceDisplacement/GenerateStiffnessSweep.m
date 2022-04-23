% myPath=uigetdir;
% listings=dir(myPath)
clear all
close all
%     dataObject = dir(fullfile('E:\testRun_1Sweep20by5V3.4.is_tcyclic_RawData','Specimen_RawData_*.csv'));
    dataObject = dir(fullfile('D:\Documents\Lab\MetalLink\Metal Link Calibration\Demo2_11V\Demo2_11Volt_ADC_mFact.is_tcyclic_RawData\Demo2_11Volt_TangentSweep.is_tcyclic_RawData',...
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
        temp_array( :, 3 ) = 9.80665* temp_array( :, 3 );
        %convert mm to m
        temp_array( :, 2 ) = temp_array( :, 2)./1000;
        
%         %Generate Name for data object
%         name1 = strsplit( dataObject(jj).folder, '\' );
%         name2 = strsplit( name1{4}, '.' );
%         name3 = erase( name2{1},"testRun");
%         pGain = strrep( name3,'N','-');
       
        p1 = polyfit(temp_array(:, 2), temp_array( :, 3),1) %linear fit the data
        temp_array(:,4) = polyval(p1,temp_array(:, 2));

        DM2{jj,1} = temp_array;
        DM2{jj,2} =  jj; %str2double(pGain);
        DM2{jj,3} = p1;
        
        figure(1)
        hold on
        plot(DM2{jj,1}(:,2),DM2{jj,1}(:,3))
        plot(DM2{jj,1}(:,2),DM2{jj,1}(:,4))
       
    end
    
 Legend2 = cell(length(DM2),1);
 stiffnessCell2= {-20, -3, -15, -10, -5, 0, 5, 10, 15, 20}; %{-5, 4, 5, -4, -3, -2, -1, 0, 1, 2, 3};
 for iter=1:length(DM2)
   gain2(iter) = stiffnessCell2{iter}
   stiffness2(iter,2:3) = DM2{iter,3}
   gS2(iter,:) = [stiffnessCell2{iter},DM2{iter,3}]
   Legend2{iter}=strcat('P = ', num2str(stiffnessCell2{iter}));
 end
 legend(Legend2)
 xlabel( 'Displacement (mm)')
 ylabel( 'Force (N)')
 title( 'Force vs Displacment for Single Link')
 
 %%
 figure(2) 
 hold on
 plot(gain2,stiffness2(:,2),'*')
 
 %%
 figure(3)
 hold on
 for n = 1:length(DM2)
    plot(DM2{n,1}(:,2),DM2{n,1}(:,4))
 end
 %%
 figure(4)
 printArray = [5, 2, 6, 7, 8, 9]
%  colorArray = [ 46, 29, 220
%                 120, 89, 228
%                 160, 119, 233
%                   190, 140, 220
%                   220, 160, 230
%                   255, 160, 240]./255
%                   
                
 
 for n = 1:length(printArray)
     printVal = printArray(n)
     plot(DM2{printVal,1}(:,2),DM2{printVal,1}(:,3),'.-' )
     hold on
 end
 hold off
 legend( 'P = -5','P = -3', 'P = 0','P = 5', 'P = 10', 'P = 15','Location','NorthWest')
 xlim([-6e-4 6e-4])
 ylim([-2 2])
 
 
 