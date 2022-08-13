%%% --- possible outcomes --- %%%
clear all; close all; clc;
fig_path = '/media/tw260/X6/Effort/analysis/results/hypothetical';
%% Univariate
xx = 1:6;

% context-independent
activation_absolute = [1,2,3,3,4,5];

figure(1); hold on
set(gcf, 'Position',  [0, 0, 600, 600])
bar(activation_absolute,'FaceColor',[1,0,0])
xticks(xx)
xticklabels({'low', 'medium', 'high', 'low', 'medium', 'high'})
ylabel('activation (a.u.)')
xlabel('difficulty level')
ax = gca;
ax.FontSize = 16;
ax.XLim = [0 7];
ax.YLim = [0 6];
set(gcf,'color','w');
set(gca,'box','off')
print(gcf,fullfile(fig_path,'hypothetical_absolute.eps'),'-depsc2','-painters');

% context-dependent
activation_relative = [1,3,5,1,3,5];

figure(2); hold on
set(gcf, 'Position',  [0, 0, 600, 600])
bar(activation_relative,'FaceColor',[1,0,0])
xticks(xx)
xticklabels({'low', 'medium', 'high', 'low', 'medium', 'high'})
ylabel('activation (a.u.)')
xlabel('difficulty level')
ax = gca;
ax.FontSize = 16;
ax.XLim = [0 7];
ax.YLim = [0 6];
set(gcf,'color','w');
set(gca,'box','off')
print(gcf,fullfile(fig_path,'hypothetical_relative.eps'),'-depsc2','-painters');

% intermediate 
activation_intermediate = 0.5*activation_absolute + 0.5*activation_relative;

figure(3); hold on
set(gcf, 'Position',  [0, 0, 600, 600])
bar(activation_intermediate,'FaceColor',[1,0,0])
xticks(xx)
xticklabels({'low', 'medium', 'high', 'low', 'medium', 'high'})
ylabel('activation (a.u.)')
xlabel('difficulty level')
ax = gca;
ax.FontSize = 16;
ax.XLim = [0 7];
ax.YLim = [0 6];
set(gcf,'color','w');
set(gca,'box','off')
print(gcf,fullfile(fig_path,'hypothetical_intermediate.eps'),'-depsc2','-painters');


%% Multivariate

%relative difficulty
figure(4);
color_map = [255,255,255; 255,255,178; 253,141,60; 189,0,38] ./ 255;
colormap(color_map);
rdm_mod = [-1, 1, 2, 0, 1, 2;
    1, -1, 1, 1, 0, 1;
    2, 1, -1, 2, 1, 0;
    0, 1, 2, -1, 1, 2;
    1, 0, 1, 1, -1, 1;
    2, 1, 0, 2, 1, -1];
mymodelRDMs.relative = rdm_mod;
imagesc(mymodelRDMs.relative)
set(gcf,'color','w');
axis equal
axis tight
print(gcf,fullfile(fig_path,'hypothetical_RDM_relative.eps'),'-depsc2','-painters');

figure(5)
color_map = [255,255,178; 253,141,60; 189,0,38] ./ 255;
colormap(color_map);
colorbar
caxis([0,2])
print(gcf,fullfile(fig_path,'hypothetical_RDM_relative_colorbar.eps'),'-depsc2','-painters');

%absolute difficulty
figure(6)
color_map = [255,255,255; 255,255,178; 254,204,92; 253,141,60; 240,59,32; 189,0,38] ./ 255;
colormap(color_map);
rdm_mod = [-1, 1, 2, 2, 3, 4;
    1, -1, 1, 1, 2, 3;
    2, 1, -1, 0, 1, 2;
    2, 1, 0, -1, 1, 2;
    3, 2, 1, 1, -1, 1;
    4, 3, 2, 2, 1, -1];
mymodelRDMs.absolute = rdm_mod;
imagesc(mymodelRDMs.absolute)
set(gcf,'color','w');
axis equal
axis tight
print(gcf,fullfile(fig_path,'hypothetical_RDM_absolute.eps'),'-depsc2','-painters');
    
figure(7)
color_map = [255,255,178; 254,204,92; 253,141,60; 240,59,32; 189,0,38] ./ 255;
colormap(color_map);
colorbar
caxis([0,4])
print(gcf,fullfile(fig_path,'hypothetical_RDM_absolute_colorbar.eps'),'-depsc2','-painters');
