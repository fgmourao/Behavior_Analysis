
%% Set behaviour_timestamps

% by Flavio Mourao. Nucleo de Neurociencias - NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de Minas Gerais.
% Started in:  01/2023
% Last update: 02/2023

%% Define frame index to each crossing

position = [analyse.quadrants.TS{ii}(:,1) + analyse.quadrants.TS{ii}(:,2) analyse.quadrants.TS{ii}(:,3) + analyse.quadrants.TS{ii}(:,4) analyse.quadrants.TS{ii}(:,5)];

% Column 1 --> label 1 - open     
% Column 2 --> label 2 - closed
% Column 3 --> label 3 - center
position_labes  = position.*[1 2 3];
position_labes = sum(position_labes,2);

crossings      = diff(position_labes);
transitions    = crossings(crossings ~= 0);

count1 = length(strfind(b', [2 -2])) % Open   to center to open   arm
count2 = length(strfind(b', [2 -1])) % Open   to center to closed arm
count3 = length(strfind(b', [1 -1])) % Closed to center to closed arm
count4 = length(strfind(b', [1 -2])) % Closed to center to open   arm

%% last update 06/02/2023 - 14:31
% listening: Mogwai - Yes. I`m long way from home...
