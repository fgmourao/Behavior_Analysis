function [analyse,header,data] = Video_Analyse(input_settings,header,data)

% Analysis of behavioral
%  Open Field and Elevated plus maze

% X and Y coordinates (pixels) related to displacement and quadrants entries (value 1) are extracted from the bonsai software
%   - https://bonsai-rx.org/
%   - https://doi.org/10.3389/fninf.2015.00007

% - Common *.csv files organization.
%        first  columns -> x coordinates (pixels)
%        second columns -> y coordinates (pixels)
%           3th column  -> first quadrant
%           4th column  -> second quadrant
%           4th column  -> third quadrant
%           4th column  -> etc...

% - Along the trajectory some values may fail so,
%   the empty spaces are filled through a autoregressive modeling.
%   'Fillgaps' built function


% Outputs:

% Variables :

% Analyse

% Arena_full -> in each variable each cell corresponds to one *.csv file download

%            ANALYSED DATA                          VARIABLE
%   - x and y coordinates in pixels              -> vec_y/x
%   - x and y coordinates in cm                  -> vec_y/x_cm
%   - x / y first derivative in cm               -> d_vec_y/x_cm
%   - Displacement in cm                         -> Displacement in cm above threshold
%   - Accumulated distance over time in cm       -> Accumulate_distance
%   - Total distance covered in cm               -> Total_distance
%   - Time vector                                -> Time_vector
%   - Velocity for each movement over time       -> Velocity
%   - Mean Velocity for each experiment          -> Mean_Velocity
%   - Acceleration for each movement over time   -> Acceleration
%   - Total number of movements                  -> Movements
%   - Total time in movement                     -> Time_Movement
%   - Total time in resting                      -> Time_Resting

%   --------

% Quadrants -> each cell corresponds to one *.csv file download

%            ANALYSED DATA                              VARIABLE
%   - Number of entries (crossings) in each quadrant     -> Q ((raw values)

%     Obs. When the animal is at the intersection its presence may appear in more than one quadrant
%     ...then to normalize:

%   1) Number of crossings between the quadrants     -> colDif
%      was sequentially subtracted
%      Q1 - Q2 - Q3 - Q4 - Q5

%   2) only full entries were considered                 -> idx(index)
%      == 1

%   3) Crossings and "time" spent in each quadrant over time   -> TS
%   4) Crossings in each quadrant  over time                   -> Entries_q
%   5) Total time spent in seconds (pixels/frame rate)         -> Total_TS
%      in each quadrant
%   6) Total crossings in each quadrant                        -> Total_Entries_Q

%   --------

% Export: - *.mat file with all analyses
%         - *.xls with main analyses



% by Flavio Mourao. Nucleo de Neurociencias - NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais.
% Started in:  01/2021
% Last update: 01/2023

%% Running data

analyse.data_fillgaps = cell(size(data));

for ii = 1:length(data)
    
    %  just calling ...
    file = regexprep(header.Filename_csv{ii} ,'.csv','...');
    fprintf(1, 'Analyzing %s\n', file);
    
    %% Fill empty spaces using autoregressive modeling.
    
    % Fillgaps
    analyse.data_fillgaps{ii} = fillgaps(data{ii}(:,1:2));
    
    %% Analysis
    
    % Frame Rate
    header.Num_frames(ii)   = str2double(input_settings{4, 1});
    
    % Pixels area (check the bonsai values defined)
    header.Video_width(ii)  = size(header.last_frame{ii},2);
    header.Video_height(ii) = size(header.last_frame{ii},1);
    
    % Arena Dimensions
    header.Arena_width(ii)  = str2num(input_settings{6, 1}); % in cm
    header.Arena_height(ii) = str2num(input_settings{7, 1}); % in cm
    
    % Define conversion Analyse.factor (1 pixel in cm)
    analyse.factor_w(ii) = header.Arena_width(ii)/header.Video_width(ii);   % width
    analyse.factor_h(ii) = header.Arena_height(ii)/header.Video_height(ii); % height
    
    % NORMALIZATION :
    % Size in cm of one fucking pixel
    % Header.Arena_width (in cm) ------- Header.Video_width (in pixels)
    %          x -------------------------------- 1 pixel
    
    %% Analyse considering the entire arena
    
    % Extracting parameters
    
    analyse.numFrames = length(analyse.data_fillgaps{ii}(:,1));
    
    analyse.Arena_Full.vec_y{ii} = analyse.data_fillgaps{ii}(:,2); % y axis - in pixels
    analyse.Arena_Full.vec_x{ii} = analyse.data_fillgaps{ii}(:,1); % x axis - in pixels
    
    
    % Optional: Gauss filter - to remove noise
    
    %     sigma = 10;
    %     sz = 90;    % length of gaussFilter vector
    %     x = linspace(-sz / 2, sz / 2, sz);
    
    %     gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
    %     gaussFilter = gaussFilter / sum (gaussFilter); % normalize
    %
    %     analyse.Arena_Full.vec_y{1, 1} = conv(analyse.Arena_Full.vec_y{1, 1},gaussFilter,'same');
    %     analyse.Arena_Full.vec_y{1, 1} = conv(analyse.Arena_Full.vec_x{1, 1},gaussFilter,'same');
    %
    
    analyse.Arena_Full.vec_y_cm{ii} = analyse.Arena_Full.vec_y{ii}.* analyse.factor_h(1,ii); % y axis - convert y values to cm from pixels
    analyse.Arena_Full.vec_x_cm{ii} = analyse.Arena_Full.vec_x{ii}.* analyse.factor_w(1,ii); % x axis - convert x values to cm from pixels
    
    analyse.Arena_Full.d_vec_y_cm{ii} = [0 ; diff(analyse.Arena_Full.vec_y{ii})].* analyse.factor_h(1,ii); % convert y Displacement to cm from pixels
    analyse.Arena_Full.d_vec_x_cm{ii} = [0 ; diff(analyse.Arena_Full.vec_x{ii})].* analyse.factor_w(1,ii); % convert x Displacement to cm from pixels
    
    analyse.Arena_Full.Displacement_raw_values{ii} = sqrt(analyse.Arena_Full.d_vec_x_cm{ii} .^2 + analyse.Arena_Full.d_vec_y_cm{ii} .^2); % Displacement in cm
    
    %     if ii == 1
    %
    %         % Considering that the average mouse body length is equal to ~7 to ~9 cm (10.1097/OPX.0000000000001036),
    %         % one single movement can be defined when the mouse displacement was greater
    %         % than 0.8 cm/s (10 % total mouse body length).
    %
    %         figure('WindowState','maximized');
    %         set(gcf,'color','w');
    %
    %         h = histogram(analyse.Arena_Full.Displacement_raw_values{ii},400,'LineWidth',2);
    %         title('Motion detection threshold (cm/frame)')
    %         h.FaceColor = 'w';
    %         h.EdgeColor = 'r';
    %
    %         for bb = 1:length(h.Values)
    %             text(h.BinEdges(1,bb+1),h.Values(1,bb),[' ' num2str(h.BinEdges(1,bb+1))])
    %         end
    %
    %         warndlg('To exclude motion artifacts that can be considered as real displacements check the smallest numbers of the distribution and multiply it by the number of frames per second. Choose a value that is close to 10 % of the total animal body length and enter the value in the checkbox. i.e: the average mouse body length is equal to ~7 to ~9 cm (10.1097/OPX.0000000000001036), one single movement can be defined when the mouse displacement was greater than 0.8 cm/s (0.0267 cm/frame)',...
    %         'Motion detection threshold')
    %         warning('To exclude motion artifacts that can be considered as real displacements check the smallest numbers of the distribution and multiply it by the number of frames per second. Choose a value that is close to 10 % of the total animal body length and enter the value in the checkbox. i.e: the average mouse body length is equal to ~7 to ~9 cm (10.1097/OPX.0000000000001036), one single movement can be defined when the mouse displacement was greater than 0.8 cm/s (0.0267 cm/frame)')
    %
    %         prompt        = {'Motion detection threshold (cm/frame):'};
    %
    %         dlgtitle      = 'Threshold';
    %         dims         = [1 40];
    %         default_input = {'0'};
    %
    %         threshold = inputdlg(prompt,dlgtitle,dims,default_input);
    %
    %         % Motion detection threshold - considering the average size of a animal
    %         analyse.Mov_threshold(ii) = str2num(threshold{1, 1}); % in cm
    %
    %         close all
    %         close hidden
    %
    %     end
    
    if str2num(input_settings{8, 1}) == 1
        
        % Motion detection threshold - considering the average size of a animal
        analyse.Mov_threshold(ii) = 1./str2double(input_settings{4, 1}); % mice - in cm/s
        
    else
        analyse.Mov_threshold(ii) = 2/str2double(input_settings{4, 1}); % rats - in cm/s
        
    end
    
    analyse.Arena_Full.Displacement{ii}        = analyse.Arena_Full.Displacement_raw_values{ii};
    analyse.Arena_Full.Displacement{ii}(analyse.Arena_Full.Displacement{ii} < analyse.Mov_threshold(ii)) = 0;                                               % Displacement in cm above threshold
    
    analyse.Arena_Full.Accumulate_distance{ii} = cumsum(analyse.Arena_Full.Displacement{ii});                                                               % Accumulated distance in cm
    analyse.Arena_Full.Total_distance{ii}      = max(analyse.Arena_Full.Accumulate_distance{ii});                                                           % Total distance in cm
    analyse.Arena_Full.Time_vector{ii}         = linspace(0,length(analyse.data_fillgaps{ii})/header.Num_frames(1,ii),length(analyse.data_fillgaps{ii}));   % Time vector in sec.
    
    analyse.Arena_Full.Velocity{ii}            = analyse.Arena_Full.Displacement{ii}./[0 diff(analyse.Arena_Full.Time_vector{ii})]';                        % Velocity in cm/s
    analyse.Arena_Full.Mean_Velocity{ii}       = nanmean(analyse.Arena_Full.Velocity{ii});                                                                  % Mean Velocity
    
    analyse.Arena_Full.Acceleration{ii}        = [0;diff(analyse.Arena_Full.Velocity{ii})]./[0 diff(analyse.Arena_Full.Time_vector{ii})]';                  % Acceleration in cm/sˆ2
    
    analyse.Arena_Full.Movements{ii}           =  sum(analyse.Arena_Full.Displacement{ii}>0);                                                               % Total number of movements
    analyse.Arena_Full.Time_Movement{ii}       =  sum(analyse.Arena_Full.Displacement{ii}>0)*(1/header.Num_frames(ii));                                     % Total time in movement
    analyse.Arena_Full.Time_Resting{ii}        =  sum(analyse.Arena_Full.Displacement{ii}==0)*(1/header.Num_frames(ii));                                    % Total time in resting
    
    % Kernel smoothing function to compute the probability density estimate (PDE) for each point.
    analyse.Arena_probability_density{ii}      = ksdensity([analyse.Arena_Full.vec_x{ii},analyse.Arena_Full.vec_y{ii}],...
        [analyse.Arena_Full.vec_x{ii},analyse.Arena_Full.vec_y{ii}]);
    
    % Extracting parameters and analize entries in each defined quadrant
    
    for jj = 1:size(data{ii},2)-2
        analyse.quadrants.Q{ii}(:,jj) = data{ii}(:,jj + 2);
    end
    
    % Normalized Entries
    
    analyse.quadrants.colDif{ii} = abs(analyse.quadrants.Q{ii}(:,1) - sum(analyse.quadrants.Q{ii}(:,2:end),2));
    analyse.quadrants.idx{ii}    = analyse.quadrants.colDif{ii} == 1; % index for only full entries were considered
    
    analyse.quadrants.TS{ii}         = analyse.quadrants.Q{ii}(analyse.quadrants.idx{ii},:); % Crossings and "time" spent in each quadrant over time
    
    analyse.quadrants.Entries_Q{ii}  = [zeros(1, size(analyse.quadrants.TS{ii},2));diff(analyse.quadrants.TS{ii}) > 0]; % Crossings in each quadrant over time (in)
    analyse.quadrants.Went_out_Q{ii} = [zeros(1, size(analyse.quadrants.TS{ii},2));diff(analyse.quadrants.TS{ii}) < 0]; % Crossings in each quadrant over time (out)
    
    analyse.quadrants.Total_TS{ii}        =  sum(analyse.quadrants.TS{ii})./header.Num_frames(1,ii);    % Total time spent in each quadrant (pixels/frame rate)
    analyse.quadrants.Total_Entries_Q{ii} =  sum(analyse.quadrants.Entries_Q{ii}>0);                    % Total crossings in each quadrant
    
    
    % Transiton between quadrants. It works better to the elevated plus maze
    
    if  str2num(input_settings{2, 1}) == 2
        position = [analyse.quadrants.TS{ii}(:,1) + analyse.quadrants.TS{ii}(:,2) analyse.quadrants.TS{ii}(:,3) + analyse.quadrants.TS{ii}(:,4) analyse.quadrants.TS{ii}(:,5)];
        
        % Column 1 --> label 1 - open
        % Column 2 --> label 2 - closed
        % Column 3 --> label 3 - center
        
        position_labes  = position.*[1 2 3];
        position_labes = sum(position_labes,2);
        
        crossings      = diff(position_labes);
        transitions    = crossings(crossings ~= 0);
        
        analyse.quadrants.Total_transitions{ii}(1,1) = length(strfind(transitions', [2 -2])); % Open   to center to open   arm
        analyse.quadrants.Total_transitions{ii}(1,2) = length(strfind(transitions', [2 -1])); % Open   to center to closed arm
        analyse.quadrants.Total_transitions{ii}(1,3) = length(strfind(transitions', [1 -1])); % Closed to center to closed arm
        analyse.quadrants.Total_transitions{ii}(1,4) = length(strfind(transitions', [1 -2])); % Closed to center to open   arm
    end
    
end

%% Spreadsheet with all analysed data

if str2num(input_settings{2, 1}) == 1
    
    % Number of quadrants analysed
    
    prompt2        = {'Type the number of Open Field quadrants to analysis (2,3 or 4) based on Bonsai pipeline'};
    
    dlgtitle2      = 'Define Settings';
    dims2         = [1 90];
    default_input2 = {'4'};
    
    input_settings2 = inputdlg(prompt2,dlgtitle2,dims2,default_input2);
    
    if str2num(input_settings2{1, 1}) == 2 % Open-Field 2 quadrants
        
        variables2save = {'Total distance (cm)','Mean_Velocity (cm/s)','Movements','Time Movement (s)','Time Resting(s)','Total Time at the center (s)', 'Total Time at the edge (s)','Crossings to the center','Crossings to the edge'};
        spreadsheet = nan(length(header.Filename_csv),length(variables2save));
        
        for kk = 1:length(header.Filename_csv)
            spreadsheet(kk,1) = analyse.Arena_Full.Total_distance{1, kk};
            spreadsheet(kk,2) = analyse.Arena_Full.Mean_Velocity{1, kk};
            spreadsheet(kk,3) = analyse.Arena_Full.Movements{1, kk};
            spreadsheet(kk,4) = analyse.Arena_Full.Time_Movement{1, kk};
            spreadsheet(kk,5) = analyse.Arena_Full.Time_Resting{1, kk};
            spreadsheet(kk,6:7) = analyse.quadrants.Total_TS{1, kk};
            spreadsheet(kk,8:9) = analyse.quadrants.Total_Entries_Q{1, kk};
        end
        
    end
    
    
    if str2num(input_settings2{1, 1}) == 3 % Open-Field 3 quadrants
        
        variables2save = {'Total distance (cm)','Mean_Velocity (cm/s)','Movements','Time Movement (s)','Time Resting(s)','Total Time at the center (s)', 'Total Time at the middle edge (s)', 'Total Time at the corners (s)','Crossings to the center','Crossings to the middle edge','Crossings to the corners'};
        spreadsheet = nan(length(header.Filename_csv),length(variables2save));
        
        for kk = 1:length(header.Filename_csv)
            spreadsheet(kk,1) = analyse.Arena_Full.Total_distance{1, kk};
            spreadsheet(kk,2) = analyse.Arena_Full.Mean_Velocity{1, kk};
            spreadsheet(kk,3) = analyse.Arena_Full.Movements{1, kk};
            spreadsheet(kk,4) = analyse.Arena_Full.Time_Movement{1, kk};
            spreadsheet(kk,5) = analyse.Arena_Full.Time_Resting{1, kk};
            spreadsheet(kk,6:8) = analyse.quadrants.Total_TS{1, kk};
            spreadsheet(kk,9:11) = analyse.quadrants.Total_Entries_Q{1, kk};
        end
        
    end
    
    if str2num(input_settings2{1, 1}) == 4 % Open-Field 4 quadrants
        
        variables2save = {'Total distance (cm)','Mean_Velocity (cm/s)','Movements','Time Movement (s)','Time Resting(s)','Total Time at the center (s)', 'Total Time at the periphery (s)','Total Time at the  edge (s)', 'Total Time at the corners (s)','Crossings to the center','Crossings to the periphery','Crossings to the  edge','Crossings to the corners'};
        spreadsheet = nan(length(header.Filename_csv),length(variables2save));
        
        for kk = 1:length(header.Filename_csv)
            spreadsheet(kk,1) = analyse.Arena_Full.Total_distance{1, kk};
            spreadsheet(kk,2) = analyse.Arena_Full.Mean_Velocity{1, kk};
            spreadsheet(kk,3) = analyse.Arena_Full.Movements{1, kk};
            spreadsheet(kk,4) = analyse.Arena_Full.Time_Movement{1, kk};
            spreadsheet(kk,5) = analyse.Arena_Full.Time_Resting{1, kk};
            spreadsheet(kk,6:9) = analyse.quadrants.Total_TS{1, kk};
            spreadsheet(kk,10:13) = analyse.quadrants.Total_Entries_Q{1, kk};
        end
        
    end
    
    
elseif str2num(input_settings{2, 1}) == 2 % Elevated Plus Maze
    
    variables2save = {'Total distance (cm)','Mean_Velocity (cm/s)','Movements','Time Movement (s)','Time Resting(s)','Total Time at the upper open arm (s)','Total Time at botton open arm (s)','Total Time at left closed arm (s)', 'Total Time at right closed arm (s)','Total Time at center (s)','Crossings: Open to Open arm','Crossings: Open to closed arm','Crossings: Closed to closed arm','Crossings: Closed to open arm'};
    spreadsheet = nan(length(header.Filename_csv),length(variables2save));
    
    for kk = 1:length(header.Filename_csv)
        spreadsheet(kk,1) = analyse.Arena_Full.Total_distance{1, kk};
        spreadsheet(kk,2) = analyse.Arena_Full.Mean_Velocity{1, kk};
        spreadsheet(kk,3) = analyse.Arena_Full.Movements{1, kk};
        spreadsheet(kk,4) = analyse.Arena_Full.Time_Movement{1, kk};
        spreadsheet(kk,5) = analyse.Arena_Full.Time_Resting{1, kk};
        spreadsheet(kk,6:10) = analyse.quadrants.Total_TS{1, kk};
        spreadsheet(kk,11:14) = analyse.quadrants.Total_transitions {1, kk};
    end
    
end

spreadsheet = array2table(spreadsheet,'VariableNames',variables2save','RowNames',header.Filename_csv);

%% Save *.xls

fprintf('\n Saving spreadsheet ...\n');

spreadsheet2save = strcat(header.FilePattern.folder,'/', strcat(input_settings{1, 1},'.xls'));
writetable(spreadsheet,spreadsheet2save,'WriteRowNames',true);

%% Save *.mat

fprintf('\n Saving *.mat ...\n');

name = strcat(header.FilePattern.folder,'/',input_settings{1, 1});
save(name,'data','analyse','header','-v7.3')

%%

fprintf('\n Done. \n');

end

%% last update 08/01/2023 - 16:00
% listening: bedhead - bedside table
