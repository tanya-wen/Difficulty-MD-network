clear all; close all; clc; dbstop if error

% load data
clear all; close all; clc

% plot ROI beta values
%% specify inputs
model_name =  'Model1';

% define ROIs
apriori_rois = 'bilateral_DMN';
roi_color = [1,0,0];

% results folder
resultsfolder = '/media/tw260/X6/Effort/analysis/results/ROI_betavalues';

% load data
load(fullfile(resultsfolder, sprintf('beta_values_%s_%s',model_name,apriori_rois)),'voxel_beta_values');


addpath(genpath('/media/tw260/X6/software'));

nsubj = size(voxel_beta_values,1);
ncon = size(voxel_beta_values,2);
nrois = size(voxel_beta_values,3);

% contrasts
switch model_name
    case 'Model1'
        con = {'level1', 'level2', 'level3','level4', 'level5', 'level6'};
    case 'Model2'
        con = {'easy_stay_at_easy_context', 'hard_switch_to_easy_context', 'hard_stay_at_hard_context', 'easy_switch_to_hard_context', ...
            'cue_easy_easy', 'cue_hard_easy', 'cue_hard_hard', 'cue_easy_hard'};
end

for roi_ind = 1:nrois
    
    for con_ind = 1:ncon
        activation(con_ind, roi_ind) = nanmean([voxel_beta_values(:,con_ind,roi_ind).beta_value]);
        stderror(con_ind,roi_ind) = nanstd([voxel_beta_values(:,con_ind,roi_ind).beta_value])/sqrt(nsubj);
    end

    
    figure;

    bar_input = activation(:,roi_ind);
    errorbar_input = stderror(:,roi_ind);
    bar(bar_input,'FaceColor',roi_color); hold on
    errorbar(bar_input,errorbar_input,'k.');
    title(strrep(strrep(voxel_beta_values(1,1,roi_ind).roiname,'.nii',''),'_','-'));

    set(gcf,'color','w');
    ylabel('beta estimates');
    set(gcf,'position',[1,1,600,300])
    set(gca,'box','off')
    switch model_name
        case 'Model1'
            set(gcf, 'Position',  [0, 0, 300, 300])
        case 'Model2'
            set(gcf, 'Position',  [0, 0, 300, 300])
    end
    
    ylim([-12,12])
    xticklabels(strrep(con,'_','-'))
    xtickangle(90);
%     print(gcf,sprintf('/imaging/tw05/Task_episodes/fMRI_analysis/SecondLevel/SecondLevel_onset_%s_%s_%s.eps','00019',network,roinames{ROIs}),'-depsc2','-painters');
%     saveas(gcf,sprintf('/media/tw260/X6/Effort/analysis/results/ROI_betavalues/%s_%s_%s.png',model_name,apriori_rois,strrep(voxel_beta_values(1,1,roi_ind).roiname,'.nii','')));
end
% saveas(gcf,sprintf('/imaging/tw05/Task_episodes/fMRI_analysis/SecondLevel/SecondLevel_onset_%s_%s.png','00019',network));
% print(sprintf('/imaging/tw05/Task_episodes/fMRI_analysis/SecondLevel/SecondLevel_onset_%s_%s.eps','00019',network),'-depsc2','-painters');
% 



