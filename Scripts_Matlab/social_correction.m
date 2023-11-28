%% Correct BinaryRegionExtremes from Bonsai

% Flavio Mourao. Nucleo de Neurociencias NNC.
% email: mourao.fg@gmail.com
% Universidade Federal de pwnas Gerais
% Started in:  04/2013
% Last update: 04/2023

% BinaryRegionExtremes from bonsai can give a reasonable guess about shape extremes, 
% but still get head/tail ambiguity. To work around that, the easiest way is then to 
% get the two head/tail position marker candidates, track the closest pairs and calculate the displacement 
% over time (X*X + Y*Y). Don't even bother with square root, since for comparison purposes 
% ordering is maintained.

%%
clear('data_frame','data');
ii = 5;

%% Load
data_frame = rgb2gray(imread([PathName '/' FileName{1,ii+6}]));

% Load
data = fillgaps(raw{1,ii}(:,1:4));

%% 

% define head and tail transition 
displac_diff = [0 0 0 0;diff(data)];
displac_item1 = abs((displac_diff(:,1).*displac_diff(:,1))+(displac_diff(:,2).*displac_diff(:,2))); % probable head/tail coordinate
displac_item2 = abs((displac_diff(:,3).*displac_diff(:,3))+(displac_diff(:,4).*displac_diff(:,4))); % probable head/tail coordinate

displac_      = displac_item1 .* displac_item2; % to amplify peaks

% Plot to check and define bin

figure;
set(gcf,'color','w');

subplot(131)
h = histogram(displac_,400,'LineWidth',1);
title('Motion detection between extremes')
h.FaceColor = 'w';
h.EdgeColor = 'k';


% Take the desired displacement bin to find the acute transitions between
% head/tail position marker index
Acute_transitions = find(displac_ > h.BinEdges(5));


% Flipping head and tail to corrected position
correct = data;

for jj = 1:2:length(Acute_transitions)
    
    if jj == length(Acute_transitions)
        correct(Acute_transitions(jj):length(correct),1:2:3) = flip(data(Acute_transitions(jj):end,1:2:3),2);
        correct(Acute_transitions(jj):length(correct),2:2:4) = flip(data(Acute_transitions(jj):end,2:2:4),2);
    else        
        correct(Acute_transitions(jj):Acute_transitions(jj+1)-1,1:2:3) = flip(data(Acute_transitions(jj):Acute_transitions(jj+1)-1,1:2:3),2);
        correct(Acute_transitions(jj):Acute_transitions(jj+1)-1,2:2:4) = flip(data(Acute_transitions(jj):Acute_transitions(jj+1)-1,2:2:4),2);
    end
end

% to check if its work

displac_diff_c = [0 0 0 0;diff(correct)];
displac_item1_c = abs((displac_diff_c(:,1).*displac_diff_c(:,1))+(displac_diff_c(:,2).*displac_diff_c(:,2))); % probable head/tail coordinate
displac_item2_c = abs((displac_diff_c(:,3).*displac_diff_c(:,3))+(displac_diff_c(:,4).*displac_diff_c(:,4))); % probable head/tail coordinate

displac_2      = displac_item1_c .* displac_item2_c; % to amplify peaks


% Plot to check changes

% Remember that 
% - even indexes marker 1 (Head or Tail)
% - odd indices marker 2 (head or Tail)

subplot(132)
plot(displac_,'k')
hold
plot(Acute_transitions(1:2:end),displac_(Acute_transitions(1:2:end)),'ro')
plot(Acute_transitions(2:2:end),displac_(Acute_transitions(2:2:end)),'go')
legend('displacement','Acute Transition 1','Acute Transition 2')


subplot(133)
plot(displac_2,'r')
hold
plot(Acute_transitions(1:2:end),displac_(Acute_transitions(1:2:end)),'ro')
plot(Acute_transitions(2:2:end),displac_(Acute_transitions(2:2:end)),'go')
legend('displacement','Acute Transition 1','Acute Transition 2')


% Plot to check head and tail position fixed

figure
hold on

subplot(2,2,[1 2])
imshow(data_frame)
hold on
plot(correct(end,1),correct(end,2),'ro','linew',2)
plot(correct(end,3),correct(end,4),'go','linew',2)

subplot(223)
imshow(data_frame)
hold
plot(correct(:,1),correct(:,2),'r','linew',1.5)
title('first and second column')

subplot(224)
imshow(data_frame)
hold
plot(correct(:,3),correct(:,4),'g','linew',1.5)
title('third and fourth column')

%% Gravador

% v = VideoReader('/Users/flavio/Desktop/Untitled.m4v');
% vidFrame = read(v,1);

figure
set(gcf,'color','w');
frame_v = imshow(data_frame);
hold on
coord_xy_1 = plot(correct(1,1),correct(1,2),'ro','linew',2);
coord_xy_2 = plot(correct(1,3),correct(1,4),'go','linew',2);

f = 0;

for ll = 2:length(correct)
    
    % atualiza os plots
    set(coord_xy_1,'XData',correct(ll+f,1),'YData',correct(ll+f,2));
    set(coord_xy_2,'XData',correct(ll+f,3),'YData',correct(ll+f,4));
    title(num2str(ll+f))
   
    pause(0.05)
end


% parar o registro - ctrl+c
%stop(auddat);

%% Save
spreadsheet = array2table(correct(:,1:2));

spreadsheet2save = strcat('/Users/flavio/Files/Arquivos/Academico/Projetos/PNPD_Neurociencias/Colaboracoes/Leo/Projeto_2/Representativas_pilo/Social/Corrected','/',FileName{1,ii});
writetable(spreadsheet,spreadsheet2save);

%% last update 28/04/2023 - 15:57
%  listening: E a terra Nunca Me Pareceu Tão Distante - Se a Resposta Gera Dúvida, Então Não É a Solução


   
   
   