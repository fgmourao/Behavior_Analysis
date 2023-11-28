
%% Plot Open Field

% Plots

% - Fillgaps -> Original values (black) and estimated values (red)
% - Tracking map
% - Tracking as a function of probability density estimate
% - Tracking as a function of velocity
% - Tracking as a function of acceleration
% - Displacement as a function of Probablity Density Distribuition
% - Velocity as a function of probability density estimate
% - Acceleration as a function of probability density estimate
% - Accumulated distance over time
% - Velocity over time
% - Acceleration over time
% - Displacenmet heatmap as a function of probability density estimate

% In case of square arena add plots as following

% - Time spent on each arm over time.
% - Number of crossings on each arm over time

% To do
% At square arena add plots for each defined area/quadrant


% by Flavio Mourao. Nucleo de Neurociencias - NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais. 
% Started in:  01/2021
% Last update: 01/2023

%%
fprintf('\n Plotting Open Field data ... \n');

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
    plot(analyse.Arena_Full.vec_x{ii},analyse.Arena_Full.vec_y{ii},'r-','linewidth',3)
    
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

    %pic = repmat(header.last_frame{ii},[1 1 3]);       % simulating RGB to plot colors 
    p = analyse.Arena_probability_density{ii}; % doubling the variable just to shorten the name
    p(1,1) = NaN; % Gabiarra for a perfect plot and Patch's blocks (beginning and end) not to come together
    
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
    
    plot(analyse.Arena_Full.vec_x{ii},analyse.Arena_Full.vec_y{ii},'r-','linewidth',4)

    patch([analyse.Arena_Full.vec_x{ii} nan(size(analyse.Arena_Full.vec_x{ii}))],...
        [analyse.Arena_Full.vec_y{ii} nan(size(analyse.Arena_Full.vec_y{ii}))],[p nan(size(p))],[p nan(size(p))],'EdgeColor','interp','FaceColor','none','LineWidth',4)

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

%% Tracking as a function of velocity
%  Plot where each point is colored by the spatial density of nearby points. 

f4 = figure('WindowState','maximized');
set(gcf,'color','w');

for ii = 1:length(data) 
    
    subplot(str2double(plots_rc{1, 1}),str2double(plots_rc{2, 1}),ii)

    pic = repmat(header.last_frame{ii},[1 1 3]);       % simulating RGB to plot colors 
    v = analyse.Arena_Full.Velocity{ii};       % doubling the variable just to shorten the name

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
    
    plot(analyse.Arena_Full.vec_x{ii},analyse.Arena_Full.vec_y{ii},'r-','linewidth',4)

    patch([analyse.Arena_Full.vec_x{ii} nan(size(analyse.Arena_Full.vec_x{ii}))],...
        [analyse.Arena_Full.vec_y{ii} nan(size(analyse.Arena_Full.vec_y{ii}))],[v nan(size(v))],[v nan(size(v))],'EdgeColor','interp','FaceColor','none','LineWidth',4)

    cb = colorbar();
    cb.Label.String = 'Velocity (cm/s)';
    colormap(jet(4096))   
    caxis([0 max(analyse.Arena_Full.Velocity{ii})*.5])
    
    file = regexprep(header.Filename_csv{ii} ,'.csv','');

    title(file)
    axis square
    axis off
    
    if str2num(plots_rc{1, 1}) > 1 && str2num(plots_rc{2, 1}) > 1
        sgtitle({['Tracking as a function of velocity'];[]})
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

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_tracking_velocity');
saveas(gcf,name,'png')

close all 

%% Tracking as a function of acceleration
%  Plot where each point is colored by the spatial density of nearby points. 

f5 = figure('WindowState','maximized');
set(gcf,'color','w');

for ii = 1:length(data) 
    
    subplot(str2double(plots_rc{1, 1}),str2double(plots_rc{2, 1}),ii)

    pic = repmat(header.last_frame{ii},[1 1 3]);       % simulating RGB to plot colors 
    a = analyse.Arena_Full.Acceleration{ii};       % doubling the variable just to shorten the name

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
    
    plot(analyse.Arena_Full.vec_x{ii},analyse.Arena_Full.vec_y{ii},'r-','linewidth',4)

    patch([analyse.Arena_Full.vec_x{ii} nan(size(analyse.Arena_Full.vec_x{ii}))],...
        [analyse.Arena_Full.vec_y{ii} nan(size(analyse.Arena_Full.vec_y{ii}))],[a nan(size(a))],[a nan(size(a))],'EdgeColor','interp','FaceColor','none','LineWidth',4)

    cb = colorbar();
    cb.Label.String = 'Acceleration (cm/s^2)';
    colormap(jet(4096))   
    caxis([0 max(analyse.Arena_Full.Velocity{ii})])
    
    file = regexprep(header.Filename_csv{ii} ,'.csv','');

    title(file)
    axis square
    axis off
    
    if str2num(plots_rc{1, 1}) > 1 && str2num(plots_rc{2, 1}) > 1
        sgtitle({['Tracking as a function of acceleration'];[]})
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

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_tracking_acceleration');
saveas(gcf,name,'png')

close all 

%% Displacement as a function of Probablity Density Distribuition

f6 = figure('WindowState','maximized');
set(gcf,'color','w');

for ii = 1:length(data)  
    
    subplot(str2double(plots_rc{1, 1}),str2double(plots_rc{2, 1}),ii)
    hold on
    
    d = analyse.Arena_Full.Displacement{ii}; % doubling the variable just to shorten the name

    h = histogram(d(d>0),50,'Normalization','pdf');
    h.FaceColor = [1 1 1];
    h.EdgeColor = 'k';

    y = min(d(d>0)):0.001:max(d(d>0));
    mu = mean(d(d>0));
    sigma = std(d(d>0),0,1);
    f = exp(-(y-mu).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
    plot(y,f,'LineWidth',1.5)
    
    file = regexprep(header.Filename_csv{ii} ,'.csv','');

    title(file)
    axis square
    box off
    
    xlabel('Displacement (cm)')
    ylabel('Probability density function')
    
    sgtitle({['Displacement as a function of Probablity Density Distribuition';[]];})
    
    % plot([0 analyse.Arena_Full.Time_vector{ii}(end)],[0.0200 0.0200]) % threshold

end 

% Save Figure

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_Displacement_Probability');
saveas(gcf,name,'png')

close all 

%% Velocity as a function of Probablity Density Distribuition

f7 = figure('WindowState','maximized');
set(gcf,'color','w');

for ii = 1:length(data)  
    
    subplot(str2double(plots_rc{1, 1}),str2double(plots_rc{2, 1}),ii)
    hold on
    
    v = analyse.Arena_Full.Velocity{ii};% doubling the variable just to shorten the name

    h = histogram(v(v>0),50,'Normalization','pdf');
    h.FaceColor = [1 1 1];
    h.EdgeColor = 'k';

    y = min(v(v>0)):0.001:max(v(v>0));
    mu = mean(v(v>0));
    sigma = std(v(v>0),0,1);
    f = exp(-(y-mu).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
    plot(y,f,'LineWidth',2)
    
    file = regexprep(header.Filename_csv{ii} ,'.csv','');

    title(file)
    axis square
    box off
        
    xlabel('Velocity (cm/s)')
    ylabel('Probability density function')
    
    sgtitle({['Velocity as a function of Probablity Density Distribuition'];[]})
    
    % plot([0 analyse.Arena_Full.Time_vector{ii}(end)],[0.0200 0.0200]) % threshold

end 

% Save Figure

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_Velocity_Probability');
saveas(gcf,name,'png')

close all 

%% Acceleration as a function of Probablity Density Distribuition

f8 = figure('WindowState','maximized');
set(gcf,'color','w');

for ii = 1:length(data)  
    
    subplot(str2double(plots_rc{1, 1}),str2double(plots_rc{2, 1}),ii)
    hold on
    
    a = analyse.Arena_Full.Acceleration{ii};% doubling the variable just to shorten the name

    h = histogram(a(a>0),50,'Normalization','pdf');
    h.FaceColor = [1 1 1];
    h.EdgeColor = 'k';
    
    pd = fitdist(a(a>0),'Kernel','Kernel','epanechnikov');
    
    x_values = linspace(min(h.BinEdges),max(h.BinEdges),200);
    a_pdf = pdf(pd,x_values);
    
    plot(x_values,a_pdf,'LineWidth',2);
    
    file = regexprep(header.Filename_csv{ii} ,'.csv','');

    title(file)
    axis square
    box off
        
    xlabel('Acceleration (cm/s^2)')
    ylabel('Probability density function')
    
    sgtitle({['Acceleration as a function of Probablity Density Distribuition'];[]})
    
    % plot([0 analyse.Arena_Full.Time_vector{ii}(end)],[0.0200 0.0200]) % threshold

end 

% Save Figure

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_Acceleration_Probability');
saveas(gcf,name,'png')

close all 

%% Accumulated distance over time

f9 = figure('WindowState','maximized');
set(gcf,'color','w');

for ii = 1:length(data)  
    
    subplot(str2double(plots_rc{1, 1}),str2double(plots_rc{2, 1}),ii)
    
    plot(analyse.Arena_Full.Time_vector{ii},analyse.Arena_Full.Accumulate_distance{ii}','Color',[0.6, 0.6, 0.6],'linewidth',1.5)
    
    xlim ([0 analyse.Arena_Full.Time_vector{ii}(end)]); 
    %ylim ([0 max(max(Analyze.Arena_Full.Accumulate_distance{ii}))]);
    
    file = regexprep(header.Filename_csv{ii} ,'.csv','');

    title(file)
    axis square
    box off
        
    xlabel('Time (s)')
    ylabel('Accumulated distance (cm)')
    
    sgtitle({['Accumulated Distance over time';[]]})
        
end

% Save Figure

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_Accumulated_Distance');
saveas(gcf,name,'png')

close all 

%% Velocity to each displacement over time 

f10 = figure('WindowState','maximized');
set(gcf,'color','w');

for ii = 1:length(data)  
    
    subplot(str2double(plots_rc{1, 1}),str2double(plots_rc{2, 1}),ii)
    
    plot(analyse.Arena_Full.Time_vector{ii},movmean(analyse.Arena_Full.Velocity{ii},30)','Color',[0.6, 0.6, 0.6],'linewidth',1)
    
    xlim ([0 analyse.Arena_Full.Time_vector{ii}(end)]); 
    %ylim ([0 max(max(Analyze.Arena_Full.Accumulate_distance{ii}))]);
    
    file = regexprep(header.Filename_csv{ii} ,'.csv','');

    title(file)
    axis square
    box off
        
    xlabel('Time (s)')
    ylabel('Velocity (cm/s)')
    
    sgtitle({['Velocity over time. [movmean 30 samples/sec]'];[]})
        
end

% Save Figure

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_Velocity_each_displacement');
saveas(gcf,name,'png')

close all 

%% Acceleration to each displacement over time 

f11 = figure('WindowState','maximized');
set(gcf,'color','w');

for ii = 1:length(data)  
    
    subplot(str2double(plots_rc{1, 1}),str2double(plots_rc{2, 1}),ii)
    
    plot(analyse.Arena_Full.Time_vector{ii},movmean(analyse.Arena_Full.Acceleration{ii},30)','Color',[0.6, 0.6, 0.6],'linewidth',1)
    
    xlim ([0 analyse.Arena_Full.Time_vector{ii}(end)]); 
    %ylim ([0 max(max(Analyze.Arena_Full.Accumulate_distance{ii}))]);
    
    file = regexprep(header.Filename_csv{ii} ,'.csv','');

    title(file)
    axis square
    box off
        
    xlabel('Time (s)')
    ylabel('Acceleration (cm/s^2)')
    
    sgtitle({['Acceleration over time. [movmean 30 samples/sec]'];[]})
        
end

% Save Figure

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_Acceleration_each_displacement');
saveas(gcf,name,'png')

close all 

%% Displacenmet heatmap as a function of probability density estimate

f12 = figure('WindowState','maximized');
set(gcf,'color','w');

for ii = 1:length(data) 
    
    subplot(str2double(plots_rc{1, 1}),str2double(plots_rc{2, 1}),ii)

    pic = repmat(header.last_frame{1},[1 1 3]);       % simulating RGB to plot colors 
    p = analyse.Arena_probability_density{ii}; % doubling the variable just to shorten the name

    % Perform interpolation to smooth the data. Built in Function:'scatteredInterpolant'
    % scatteredInterpolant uses a Delaunay triangulation of the scattered sample points to perform interpolation

    % Create the interpolant.
    F = scatteredInterpolant(analyse.Arena_Full.vec_x{ii},analyse.Arena_Full.vec_y{ii},p/max(p));

    % Optional to increase resolution 
    factor = 1; % change multiplication factor

    newNumberOfRows = factor*(size(header.last_frame{1,1},1));
    newNumberOfCols = factor*(size(header.last_frame{1,1},2));

    % Grid of query points based on Video Resolution
    % [xq, yq] = meshgrid(linspace(1, size(header.last_frame{1,1},2), newNumberOfCols), linspace(1, size(header.last_frame{1,1},1), newNumberOfRows));
    [xq, yq] = meshgrid(linspace(min(analyse.Arena_Full.vec_x{ii}), max(analyse.Arena_Full.vec_x{ii}), newNumberOfCols), linspace(min(analyse.Arena_Full.vec_x{ii}), max(analyse.Arena_Full.vec_x{ii}), newNumberOfRows));

    % Evaluate the interpolant at query locations (xq,yq).
    % Use the 'nearest', 'linear', or 'natural' methods

    F.Method = 'natural';
    F.ExtrapolationMethod = 'none'; % Use the 'nearest', 'linear', or 'none' methods
    
    pq = F(xq,yq);
    %zcor_xnan = bsxfun(@rdivide, bsxfun(@minus, pq, mean(pq,'omitnan')), std(pq,[],'all','omitnan'));
    % Remove negative values
    pq(pq<0.2) = nan;
    
    figure
    imshow(pic) % plot the original picture below just to ensure the correct orientation
    hold on

    ax = newplot;
    surf(xq,yq,pq,...
             'AlphaData',pq,...
             'EdgeColor','none',...
             'FaceColor','interp',...
             'FaceAlpha','interp');    
    colorbar('Location','eastoutside')%,'YTick'),[]);
    view(ax,2);
    grid(ax,'off');
    py_path = "/usr/bin/python3";
    Py_map = getPyPlot_cMap('inferno', [], [], py_path);
    colormap(Py_map)
    %caxis([0.4*10^-5 4*10^-5]) % Be careful here. Set a pattern for all figures
    cb = colorbar();
    cb.Label.String = 'Probability density estimate';
    
    
    file = regexprep(header.Filename_csv{ii} ,'.csv','');

    title(file)
    
    if str2num(plots_rc{1, 1}) > 1 && str2num(plots_rc{2, 1}) > 1
        sgtitle({['Displacenmet heatmap as a function of probability density estimate'];[]})
    end

    % Scale bar location in matlab units
    pos = get(gca, 'Position');
    
    % Scale bar size as function of Matlab units
    unit = pos(3)/size(header.last_frame{1,1},2);   % define size of one unit normalizing by the figure width 
                                                    % default width of the plot within t]he figure in normalized coordinates 
                                                    % (i.e. the figure / the window containing the plot has a width of 1 length units).  
    
                                           
%      NORMALIZATION :                                          
%      0.6910(default width of the plot in units ---  1158(figure size in pixels) ------ 6 (figure size in cm)
%                   x ------------------------------------------ 1 (one fucking pixel) - analyse.factor_w (size in cm of 1 pixels)
%                
%                   x = 5.9672e-04 ( size of 1 unit)
                  

    % define scale bar size in matlab units
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

    %plot([x1 x2],[y y],'k-','linew',3)
end

% Save Figure

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_Displacenmet_heatmap_probability_density');
saveas(gcf,name,'png')

close all 


%% In case of square arena add plots as following

% if str2num(input_settings{2, 1}) == 2
%     
%     % Time spent on each arm over time
%     
%     f13 = figure('WindowState','maximized');
%     set(gcf,'color','w');
%     
%     for ii = 1:length(data)
%         
%         
%         subplot(1,3,1)
%         plot(analyse.quadrants.TS{ii}(:,1),'k','linew',2)
%         ylim([0 1.5])
%         title('Center')
%         
%         subplot(1,3,2)
%         plot(analyse.quadrants.TS{ii}(:,2),'k','linew',2)
%         ylim([0 1.5])
%         title('Middle edge')
%         
%         subplot(1,3,3)
%         plot(analyse.quadrants.TS{ii}(:,3),'k','linew',2)
%         ylim([0 1.5])
%         title('Corners')
%         
%         sgtitle ('Time spent on each arm over time')
%         
%     end
%     
%     % Save Figure
%     
%     name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_Time_each_arm');
%     saveas(gcf,name,'png')
%     
%     close all    
%     
%     
%     
%     % Number of crossings on each arm over time
%     
%     f14 = figure('WindowState','maximized');
%     set(gcf,'color','w');
%     
%     for ii = 1:length(data)
%         
%         
%         subplot(1,3,1)
%         plot(analyse.quadrants.Entries_Q{ii}(:,1),'k','linew',2)
%         ylim([0 1.5])
%         title('Center')
%         
%         subplot(1,3,2)
%         plot(analyse.quadrants.Entries_Q{ii}(:,2),'k','linew',2)
%         ylim([0 1.5])
%         title('Middle edge')
%         
%         subplot(1,3,3)
%         plot(analyse.quadrants.Entries_Q{ii}(:,3),'k','linew',2)
%         ylim([0 1.5])
%         title('Corners')
%         
%         
%         sgtitle ('Number of crossings')
%         
%     end
%     
%     % Save Figure
%     
%     name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'__arms_crossings');
%     saveas(gcf,name,'png')
%     
%     close all
%     
% end

%%

fprintf('\n Done. \n');

%% last update 08/01/2023 - 16:00
% listening: ISIS - Remastered
