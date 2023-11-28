
%% Plot elevated plus maze

% Plots

% - Fillgaps -> Original values (black) and estimated values (red)
% - Single tracking map
% - Tracking as a function of probability density estimate
% - Displacenmet heatmap as a function of probability density estimate (need to be fixed)
% - Time spent on each arm over time.
% - Number of crossings on each arm over time


% by Flavio Mourao. Nucleo de Neurociencias - NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais. 
% Started in:  01/2021
% Last update: 01/2023

%%
fprintf('\n Plotting Elevated Plus Maze data ... \n');

%% Check fill gapes

f1 = figure('WindowState','maximized');
set(gcf,'color','w');
    
for ii = 1:length(data) 
    
    subplot(str2double(plots_rc{1, 1}),str2double(plots_rc{2, 1}),ii)
    plot(analyse.data_fillgaps{ii}(:,1),analyse.data_fillgaps{ii}(:,2),'r-','linew',2)
    hold
    plot(data{ii}(:,1),data{ii}(:,2),'k-','linew',2)
    
    file = regexprep(header.Filename_csv{ii} ,'.csv','');

    title(file)
    axis square
    axis off
    
    sgtitle({['Signal Reconstruction. Autoregressive modeling. "Fillgaps" matlab function'];[]})

    legend('Estimated values','location','southoutside')
end   

% Save Figure

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_Estimated_values');
saveas(gcf,name,'png')

close all 

%% Single track at the full arena

f2 = figure('WindowState','maximized');
set(gcf,'color','w');

for ii = 1:length(data)  
    
    subplot(str2double(plots_rc{1, 1}),str2double(plots_rc{2, 1}),ii)
    imshow(header.last_frame{ii})
    hold on
    plot(analyse.Arena_Full.vec_x{ii},analyse.Arena_Full.vec_y{ii},'r-','linewidth',2)
    
    if str2num(plots_rc{1, 1}) > 1 && str2num(plots_rc{2, 1}) > 1
        sgtitle({['Single Tracking']})
    end
    
    file = regexprep(header.Filename_csv{ii} ,'.csv','');

    title(file)
    axis square
    axis off
    

    
%     xlim ([0 header.Arena_width]);  % in cm
%     ylim ([0 header.Arena_height]); % in cm

%     % Scale bar size
%     sb = 100; % mm
%     
%     % Scale bar location
%     x1 = size(header.last_frame{1,1},2) - 150;
%     x2 = x1 + sb;
%     y = size(header.last_frame{1,1},2) - 150;
%     
%     plot([x1 x2],[y y],'k-','linew',3)

end 

% Save Figure

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_Single_Tracking');
saveas(gcf,name,'png')

close all 

%% Tracking as a function of probability density estimate
%  Plot where each point is colored by the spatial density of nearby points. 

f3 = figure('WindowState','maximized');
set(gcf,'color','w');

for ii = 1:length(data) 
    
    subplot(str2double(plots_rc{1, 1}),str2double(plots_rc{2, 1}),ii)

    pic = repmat(header.last_frame{ii},[1 1 3]);       % simulating RGB to plot colors 
    p = analyse.Arena_probability_density{ii};         % doubling the variable just to shorten the name
    p(1,1) = NaN;                                      % Gabiarra for a perfect plot and Patch's blocks (beginning and end) not to come together

    imshow(pic)
    hold on
    % plot3(a(:,1),a(:,2),c,'linew',10)

    % plot3 only supports a single color.
    % You can use other graphics functions. The "traditional" one for this purpose 
    % is actually rather surprising. It's the patch function, which is designed for drawing filled polygons.
    
    % What's going on here is the following:
    % - The 4th arg says to use Z for color data
    % - The EdgeColor=interp says to interpolate the color data as the edge color
    % - The FaceColor=none says to not fill the polygon. Just draw the edges
    % - The nans say not to connect the last point to the first point.

    % Solution from here: https://www.mathworks.com/matlabcentral/answers/267468-change-colour-of-points-in-plot3-with-increasing-z-value

    patch([analyse.Arena_Full.vec_x{ii} nan(size(analyse.Arena_Full.vec_x{ii}))],...
        [analyse.Arena_Full.vec_y{ii} nan(size(analyse.Arena_Full.vec_y{ii}))],[p nan(size(p))],[p nan(size(p))],'EdgeColor','interp','FaceColor','none','LineWidth',2)

    cb = colorbar();
    cb.Label.String = 'Probability density estimate';
    colormap(jet(4096))
    
    file = regexprep(header.Filename_csv{ii} ,'.csv','');

    title(file)
    axis square
    axis off
    
    if str2num(plots_rc{1, 1}) > 1 && str2num(plots_rc{2, 1}) > 1
        sgtitle({['Tracking as a function of probability density estimate';[]]})
    end
    
    %     % Scale bar size in pixels
%     scale_size = 0.5; %(cm)
%     sb = round(scale_size / analyse.factor_w(1,ii)); % 5 mm
%     
%     %           1(one ficking pixel) - analyse.factor_w (size in cm of 1 pixel)
%     %                    x  ----------      0.5 (cm)
%     
    % Scale bar location
%     x1 = size(last_frame{1,1},2) - 150;
%     x2 = x1 + sb;
%     y = size(last_frame{1,1},2) - 150;
%     
%     plot([x1 x2],[y y],'k-','linew',3)

end

% Save Figure

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_tracking_probability');
saveas(gcf,name,'png')

close all 

%% Displacenmet heatmap as a function of probability density estimate

% tidy up the figure drawing

% f4 = figure('WindowState','maximized');
% set(gcf,'color','w');
% 
% for ii = 1:length(data) 
%     
%     %subplot(str2double(plots_rc{1, 1}),str2double(plots_rc{2, 1}),ii)
% 
%     pic = repmat(header.last_frame{1},[1 1 3]);       % simulating RGB to plot colors 
%     p = analyse.Arena_probability_density{ii}; % doubling the variable just to shorten the name
% 
%     % Perform interpolation to smooth the data. Built in Function:'scatteredInterpolant'
%     % scatteredInterpolant uses a Delaunay triangulation of the scattered sample points to perform interpolation
% 
%     % Create the interpolant.
%     F = scatteredInterpolant(analyse.Arena_Full.vec_x{1},analyse.Arena_Full.vec_y{1},p);
% 
%     % Optional to increase resolution 
%     factor = 1; % change multiplication factor
% 
%     newNumberOfRows = factor*(size(header.last_frame{1,1},1));
%     newNumberOfCols = factor*(size(header.last_frame{1,1},2));
% 
%     % Grid of query points based on Video Resolution
%     [xq, yq] = meshgrid(linspace(1, size(header.last_frame{1,1},2), newNumberOfCols), linspace(1, size(header.last_frame{1,1},1), newNumberOfRows));
% 
%     % Evaluate the interpolant at query locations (xq,yq).
%     % Use the 'nearest', 'linear', or 'natural' methods
% 
%     F.Method = 'natural';
%     pq = F(xq,yq);
% 
%     % Remove negative values
%     pq(pq<0) = 0;
%     
%     imshow(pic) % plot the original picture below just to ensure the correct orientation
%     hold on
% 
%     ax = newplot;
%     surf(xq,yq,pq,...
%              'EdgeColor','none',...
%              'FaceColor','interp');    
%     colorbar('Location','eastoutside')%,'YTick'),[]);
%     view(ax,2);
%     grid(ax,'off');
%     colormap jet
%     %caxis([0.4*10^-5 4*10^-5]) % Be careful here. Set a pattern for all figures
%     cb = colorbar();
%     cb.Label.String = 'Probability density estimate';
%     
%     
%     file = regexprep(header.Filename_csv{ii} ,'.csv','');
% 
%     title(file)
%     
%     if str2num(plots_rc{1, 1}) > 1 && str2num(plots_rc{2, 1}) > 1
%         sgtitle({['Displacenmet heatmap as a function of probability density estimate'];[]})
%     end
% 
%     % Scale bar location in matlab units
%     pos = get(gca, 'Position');
%     
%     % Scale bar size as function of Matlab units
%     unit = pos(3)/size(header.last_frame{1,1},2); % define size of one unit normalizing by the figure width 
%                                            % default width of the plot within t]he figure in normalized coordinates 
%                                            % (i.e. the figure / the window containing the plot has a width of 1 length units).  
%     
%                                            
% %      NORMALIZATION :                                          
% %      0.6910(default width of the plot in units ---  1158(figure size in pixels) ------ 6 (figure size in cm)
% %                   x ------------------------------------------ 1 (one fucking pixel) - analyse.factor_w (size in cm of 1 pixels)
% %                
% %                   x = 5.9672e-04 ( size of 1 unit)
%                   
% 
%     % define scale bar size in matlab units
%     scale_size = 10; %(cm)
%     sb = (scale_size * unit) / analyse.factor_w(1,ii); % 5 mm
%  
% %         unit - analyse.factor_w
% %           x  -      10
%     
%     x1 = pos(3) - sb;
%     x2 = pos(3);
%     y = 1 - pos(4);
%     
%     annotation('line',[x1 x2],...
%     [y y],'Color',[0 0 0],'LineWidth',3);
% 
%     %plot([x1 x2],[y y],'k-','linew',3)
% end

% Save Figure

% name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_Displacenmet_heatmap_probability_density');
% saveas(gcf,name,'png')
% 
% close all 

%% Time spent on each arm over time

f5 = figure('WindowState','maximized');
set(gcf,'color','w');

for ii = 1:length(data)
    
        
    subplot(3,3,2)
    plot(analyse.quadrants.TS{ii}(:,1),'k','linew',2)
    ylim([0 1.5])
    title('upper arm')

    subplot(3,3,4)
    plot(analyse.quadrants.TS{ii}(:,3),'k','linew',2)
    ylim([0 1.5])
    title('left  arm')

    subplot(3,3,5)
    plot(analyse.quadrants.TS{ii}(:,5),'k','linew',2)
    ylim([0 1.5])
    title('center')

    subplot(3,3,6)
    plot(analyse.quadrants.TS{ii}(:,4),'k','linew',2)
    ylim([0 1.5])
    title('right arm')

    subplot(3,3,8)
    plot(analyse.quadrants.TS{ii}(:,2),'k','linew',2)
    ylim([0 1.5])
    title('lower arm')
    
    sgtitle ('Time spent on each arm over time')
    
end

% Save Figure

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_Time_each_arm');
saveas(gcf,name,'png')

close all 
    
%% Number of crossings on each arm over time

f6 = figure('WindowState','maximized');
set(gcf,'color','w');

for ii = 1:length(data)
    
        
    subplot(3,3,2)
    plot(analyse.quadrants.Entries_Q{ii}(:,1),'k','linew',2)
    ylim([0 1.5])
    title('upper arm')

    subplot(3,3,4)
    plot(analyse.quadrants.Entries_Q{ii}(:,3),'k','linew',2)
    ylim([0 1.5])
    title('left  arm')

    subplot(3,3,5)
    plot(analyse.quadrants.Entries_Q{ii}(:,5),'k','linew',2)
    ylim([0 1.5])
    title('center')

    subplot(3,3,6)
    plot(analyse.quadrants.Entries_Q{ii}(:,4),'k','linew',2)
    ylim([0 1.5])
    title('right arm')

    subplot(3,3,8)
    plot(analyse.quadrants.Entries_Q{ii}(:,2),'k','linew',2)
    ylim([0 1.5])
    title('lower arm')
    
    sgtitle ('Number of crossings')
    
end

% Save Figure

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'__arms_crossings');
saveas(gcf,name,'png')

close all 
    
%%

fprintf('\n Done. \n');

%% last update 08/01/2023 - 16:00
% listening: bedhead - bedside table
