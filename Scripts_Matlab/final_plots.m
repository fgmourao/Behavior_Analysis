%% Displacenmet heatmap as a function of probability density estimate

Untitled = fillgaps(EPMF2N30A(:,1:2));
pic      = 255+zeros(size(EPM_F2N30A)); % simulating RGB to plot colors

%%

%x = x;
x = Untitled(:,1);
%y = y;
y = Untitled(:,2);


p = ksdensity([x,y],[x,y]);


% Perform interpolation to smooth the data. Built in Function:'scatteredInterpolant'
% scatteredInterpolant uses a Delaunay triangulation of the scattered sample points to perform interpolation

% Create the interpolant.
F = scatteredInterpolant(x,y,p/max(p));

% Optional to increase resolution
factor = 1; % change multiplication factor

%newNumberOfRows = factor*(size(header.last_frame{1,1},1));
newNumberOfRows = factor*(size(pic,1));

%newNumberOfCols = factor*(size(header.last_frame{1,1},2));
newNumberOfCols = factor*(size(pic,2));

% Grid of query points based on Video Resolution
[xq, yq] = meshgrid(linspace(1, size(pic,2), newNumberOfCols), linspace(1, size(pic,1), newNumberOfRows));
%[xq, yq] = meshgrid(linspace(min(x), max(x), newNumberOfCols), linspace(min(x), max(x), newNumberOfRows));

% Evaluate the interpolant at query locations (xq,yq).
% Use the 'nearest', 'linear', or 'natural' methods

F.Method = 'natural';
F.ExtrapolationMethod = 'none'; % Use the 'nearest', 'linear', or 'none' methods

pq = F(xq,yq);
%pq = bsxfun(@rdivide, bsxfun(@minus, pq, mean(pq,'omitnan')), std(pq,[],'all','omitnan'));
% Remove negative values
%pq(pq<0.3) = 0;

%%
figure
set(gcf,'color','w');
imagesc(pic) % plot the original picture below just to ensure the correct orientation
hold on
plot(x,y,'Color',[0 0 0 0.3],'linewidth',1.5)


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
cb = colorbar();
cb.Label.String = 'Probability density estimate';

axis off

clim([0.2 1])

%file = regexprep(header.Filename_csv{ii} ,'.csv','');

%title(file)
%      title('14__2__onlyTrack')
%      title('14__2')

%%
figure
set(gcf,'color','w');
imagesc(pic) % plot the original picture below just to ensure the correct orientation
hold on
plot(x,y,'Color',[0 0 0 0.3],'linewidth',3)

patch([x nan(size(x))],...
    [y nan(size(y))],[p./max(p) nan(size(p))],[p./max(p) nan(size(p))],'EdgeColor','interp','FaceColor','none','FaceAlpha',.1,'LineWidth',3)

colorbar('Location','eastoutside')%,'YTick'),[]);
py_path = "/usr/bin/python3";
Py_map = getPyPlot_cMap('inferno', [], [], py_path);
colormap(Py_map)
cb = colorbar();
cb.Label.String = 'Probability density estimate';

axis off


%%
zq = interp2(round(x)',round(y)',p./max(p),xq,yq,"cubic",0);

ax = newplot;
surf(xq,yq,zq,...
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
cb = colorbar();
cb.Label.String = 'Probability density estimate';

axis off

%%

% Save Figure

name = strcat(header.FilePattern.folder,'\',input_settings{1, 1},'_Displacenmet_heatmap_probability_density');
saveas(gcf,name,'png')

close all
