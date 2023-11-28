
%% Behavior Analyse

% Main call

% Files needed:
% - *.csv files from Bonsai software
% - *.png files from Bonsai software

% - Analyse one or more *.csv/*.png files

% - The code relies on the following functions/scripts : -> Video_Analyse.m
%                                                        -> plot_openfield.m
%                                                        -> plot_EPM.m
%                                                        -> ... other desired function
    

% by Flavio Mourao. Nucleo de Neurociencias - NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais. 
% Started in:  09/2021
% Last update: 01/2023

%%
clear
clc

%% Define settings

prompt        = {'Experiment Name';'Experiment (Type (1) to  Open Field / Type (2) to Elevated plus maze) / Type (3) to Odor test):'; ...
    'Plot Figures (Type (1) yes / Type (2) no):';'Frames per second:';'Analysis time (Type (1) to full section / Type time in sec.):';'Arena size -> Width (cm):';'Arena size -> Height (cm):';'Experimental animal (Type (1) to Mouse (C57BL/6) / Type (2) to Rat (Wistar))'};

dlgtitle      = 'Define Settings';
dims         = [1 80];
default_input = {'experiment','1','1','30','1','30','30','1'};

input_settings = inputdlg(prompt,dlgtitle,dims,default_input);

%% Organize path to load data and initialize some variables

% Load datafiles (*.csv)
[FileName,PathName] = uigetfile({'*.*'},'MultiSelect', 'on'); % Define file type *.*

% Filename can be organize as a single char or a group char in a cell depending on the number os files selected

% header              -> files information and parameters to analyse
% header.last_frame   -> image of the last frame to take the resolution parameters and plot 

% data                  = raw values / each cell corresponds to data from 1 experiment

header.last_frame = cell(size(FileName));
data = cell(size(FileName));

for ii = 1:length(FileName)
    
    if length(FileName) == 1 % condition for a single file selected 
       header.FilePattern = dir(fullfile(PathName, char(FileName)));
       [~, ~, fExt] = fileparts(FileName);
        
       switch lower(fExt)

       case '.csv' 
       output = readtable([PathName '/' FileName],'Delimiter',',');
       data{1,ii} = table2array(output);
       
       % condition to set analysis time
       if str2num(input_settings{5, 1}) ~= 1
          timeidxstop = str2num(input_settings{4, 1}) * str2num(input_settings{5, 1});
          data{1,ii}(timeidxstop+1:1:end,:) = [];
       end
       
       header.Filename_csv(ii) = FileName{ii};
       fprintf(1, 'Reading %s\n', FileName{ii});

       case '.png' 
       header.last_frame{ii} = imread([PathName '/' FileName]);
       header.Filename_png(ii) = FileName{ii};
       fprintf(1, 'Reading %s\n', FileName{ii});
       
       end

    else      % condition for multiple files selected
        header.FilePattern = dir(fullfile(PathName, char(FileName{ii})));
        [~, ~, fExt] = fileparts(FileName{ii});

        switch lower(fExt)

        case '.csv' 
        output = readtable([PathName '/' FileName{ii}],'Delimiter',',');
        data{1,ii} = table2array(output);
        
         % condition to set analysis time
        if str2num(input_settings{5, 1}) ~= 1
            timeidxstop = str2num(input_settings{4, 1}) * str2num(input_settings{5, 1});
            data{1,ii}(timeidxstop+1:1:end,:) = [];
        end
       
        header.Filename_csv{ii} = FileName{ii};
        fprintf(1, 'Reading %s\n', FileName{ii});

        case '.png' 
        header.last_frame{ii} = rgb2gray(imread([PathName '/' FileName{ii}])); % open image and convert to grey scale
        header.Filename_png{ii} = FileName{ii};
        fprintf(1, 'Reading %s\n', FileName{ii});
        
        end
   end
end 

% Remove empty cells
data = data(~cellfun('isempty',data));
header.last_frame = header.last_frame(~cellfun('isempty',header.last_frame));
header.Filename_csv = header.Filename_csv(~cellfun('isempty',header.Filename_csv));
header.Filename_png = header.Filename_png(~cellfun('isempty',header.Filename_png));

%    val_name = FileName(1:regexp(FileName,'.csv')-1);
%    assignin('base',val_name, data);

%% Define Figures Organization

if str2num(input_settings{3, 1}) == 1
    
   prompt1        = {'Number of Rows:','Number of Columns:'};
   text_          = ['Figures Organization. It has been loaded ' num2str(length(header.Filename_csv)) ' file(s)'];
   dlgtitle1      = text_;
   dims1          = [1 80];
   default_input1 = {'1','1'};

   plots_rc = inputdlg(prompt1,dlgtitle1,dims1,default_input1);
    
end

%% Set deafult values
set(0,'DefaultFigureWindowStyle','normal')
set(groot,'DefaultFigureColormap',jet)

%% Call functions

if     str2num(input_settings{2, 1}) == 3
    [analyse,header,data] = Video_Analyse_odor(input_settings,header,data);
    plot_openfield;
else    
    [analyse,header,data] = Video_Analyse(input_settings,header,data);
end


if     str2num(input_settings{2, 1}) == 1 && str2num(input_settings{3, 1}) == 1
    plot_openfield;
    
elseif str2num(input_settings{2, 1}) == 2 && str2num(input_settings{3, 1}) == 1
    plot_EPM;
    
end

%%
clear ('fExt','FileName','ii','output','PathName','text_','a', 'aa', 'a_pdf', 'ans', 'ax', 'cb', 'd', 'default_input1', 'dims1', 'dlgtitle1', 'f', 'F', 'f1', 'f10', 'f11', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'factor', 'file', ' file2save', 'h', 'ii', 'mu', 'name', 'newNumberOfCols', 'newNumberOfRows', 'p', 'pd', 'pic', 'plots_rc', 'pos', 'pq', 'prompt1', 'sb', 'scale_size', 'sigma', 'unit', 'v', 'x1', 'x2', 'x_values', 'xq', 'y', 'yq');

%% last update 08/01/2023 - 16:13
% listening: ISIS - So Did We
