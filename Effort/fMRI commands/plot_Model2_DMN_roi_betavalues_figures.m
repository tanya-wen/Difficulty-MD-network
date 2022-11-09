clear all; close all; clc; dbstop if error
% plot ROI beta values

% results folder
resultsfolder = '/media/tw260/X6/Effort/analysis/results/ROI_betavalues';
addpath(genpath('/media/tw260/X6/software'));

%% Model 2

% specify model
model_name =  'Model2';

% contrasts
con = {'cue_easy_easy', 'cue_easy_hard', 'cue_hard_easy', 'cue_hard_hard', ...
    'task_easy_easy', 'task_easy_hard', 'task_hard_easy', 'task_hard_hard'};
label_names = {'EE', 'EH', 'HE', 'HH', 'EE', 'EH', 'HE', 'HH'};
ncons = numel(con);

%%% ----- Model2 DMN ROIs stats ----- %%%

% define ROIs
apriori_rois = 'bilateral_DMN';

% load data
load(fullfile(resultsfolder, sprintf('beta_values_%s_%s',model_name,apriori_rois)),'voxel_beta_values');

nsubj = size(voxel_beta_values,1);
ncon = size(voxel_beta_values,2);
nrois = size(voxel_beta_values,3);

%% CUE PHASE
%%% ----- Model2 DMN ROIs plot ----- %%%
%             CUE PHASE              %
%%% ----- ------------------- ----- %%%
% define ROIs
apriori_rois = 'bilateral_DMN';
roi_color = [1,0,0];

% load data
load(fullfile(resultsfolder, sprintf('beta_values_%s_%s',model_name,apriori_rois)),'voxel_beta_values');

nsubj = size(voxel_beta_values,1);
ncon = size(voxel_beta_values,2);
nrois = size(voxel_beta_values,3);

roi_cnt = 1;
sub_activation = [];
for roi_ind = 1:nrois
    
    for con_ind = 1:4 % cue only
        % get mean and se
        activation(con_ind, roi_ind) = nanmean([voxel_beta_values(:,con_ind,roi_ind).beta_value]);
        stderror(con_ind,roi_ind) = nanstd([voxel_beta_values(:,con_ind,roi_ind).beta_value])/sqrt(nsubj);
        
        sub_activation = [sub_activation, [voxel_beta_values(:,con_ind,roi_ind).beta_value]'];
    end
    
    
    figure(100+roi_cnt);
    
    bar_input = activation(:,roi_ind);
    errorbar_input = stderror(:,roi_ind);
    bar(bar_input,'FaceColor',roi_color); hold on
    errorbar(bar_input,errorbar_input,'k.');
    ylim([-3,3])
    
    title(strrep(strrep(voxel_beta_values(1,1,roi_ind).roiname,'.nii',''),'_','-'));
    
    set(gcf, 'Position',  [0, 0, 300, 300])
    set(gcf,'color','w');
    ylabel('beta estimates');
    set(gca,'box','off')
    
    xticklabels(label_names)
    
    print(sprintf('/media/tw260/X6/Effort/analysis/results/ROI_betavalues/%s_cue_%s_%s.eps',model_name,apriori_rois,strrep(voxel_beta_values(1,1,roi_ind).roiname,'.nii','')),'-depsc2','-painters');
    
    roi_cnt = roi_cnt + 1;
    pause(2)
end

% ANOVA 
anova_activation = sub_activation; % (2 previous) x (2 current) x (11 ROIs) 
roi_names = {'aMPFC','PCC','dMPFC','LTC','TPJ','Temp','vMPFC','pIPL','HF','PHC','Rsp'};
cond_names = {'EE', 'EH', 'HE', 'HH'};
varnames = {};
for roi = 1:11
    for c = 1:4
        varnames{end+1} = strcat(roi_names{roi},'_',cond_names{c});
    end
end
t = array2table(anova_activation,'VariableNames',varnames);

within = table(repelem(['A','B','C','D','E','F','G','H','I','J','K']',4), repmat(['x','x','y','y']',11,1),repmat(['X','Y','X','Y']',11,1), 'VariableNames',{'roi','previous','current'});
rm = fitrm(t,'aMPFC_EE-Rsp_HH ~1','WithinDesign', within);
ranovatable = ranova(rm,'WithinModel','roi*previous*current');


r = 1;
for beta = 1:4:44
    
    roi_names{r}
    r = r + 1;
    roi_anova_activation = sub_activation(:,beta:beta+3);
    
    % ANOVA (2 previous) x (2 current)
    anova_activation = roi_anova_activation; % (2 previous) x (2 current)
    varnames = {'EE', 'EH', 'HE', 'HH'};
    
    t = array2table(anova_activation,'VariableNames',varnames);
    
    within = table(['x','x','y','y']',['X','Y','X','Y']','VariableNames',{'previous','current'});
    rm = fitrm(t,'EE,HE,EH,HH ~1','WithinDesign', within);
    ranovatable = ranova(rm,'WithinModel','previous*current')
    
end


%% MATH PHASE
%%% ----- Model2 DMN ROIs plot ----- %%%
%             MATH PHASE              %
%%% ----- ------------------- ----- %%%
% define ROIs
apriori_rois = 'bilateral_DMN';
roi_color = [1,0,0];

% load data
load(fullfile(resultsfolder, sprintf('beta_values_%s_%s',model_name,apriori_rois)),'voxel_beta_values');

nsubj = size(voxel_beta_values,1);
ncon = size(voxel_beta_values,2);
nrois = size(voxel_beta_values,3);

roi_cnt = 1;
sub_activation = [];
for roi_ind = 1:nrois
    
    for con_ind = 5:8 % math only
        % get mean and se
        activation(con_ind-4, roi_ind) = nanmean([voxel_beta_values(:,con_ind,roi_ind).beta_value]);
        stderror(con_ind-4,roi_ind) = nanstd([voxel_beta_values(:,con_ind,roi_ind).beta_value])/sqrt(nsubj);
        
        sub_activation = [sub_activation, [voxel_beta_values(:,con_ind,roi_ind).beta_value]'];
    end
    
    
    figure(200+roi_cnt);
    
    bar_input = activation(:,roi_ind);
    errorbar_input = stderror(:,roi_ind);
    bar(bar_input,'FaceColor',roi_color); hold on
    errorbar(bar_input,errorbar_input,'k.');
    ylim([-6,3])
    
    title(strrep(strrep(voxel_beta_values(1,1,roi_ind).roiname,'.nii',''),'_','-'));
    
    set(gcf, 'Position',  [0, 0, 300, 300])
    set(gcf,'color','w');
    ylabel('beta estimates');
    set(gca,'box','off')
    
    xticklabels(label_names)
    
    print(sprintf('/media/tw260/X6/Effort/analysis/results/ROI_betavalues/%s_task_%s_%s.eps',model_name,apriori_rois,strrep(voxel_beta_values(1,1,roi_ind).roiname,'.nii','')),'-depsc2','-painters');
    
    roi_cnt = roi_cnt + 1;
    pause(2)
end

% ANOVA (switch x difficulty level x ROI)
anova_activation = sub_activation; % (2 previous) x (2 current) x (11 ROIs) 
roi_names = {'aMPFC','PCC','dMPFC','LTC','TPJ','Temp','vMPFC','pIPL','HF','PHC','Rsp'};
cond_names = {'EE', 'EH', 'HE', 'HH'};
varnames = {};
for roi = 1:11
    for c = 1:4
        varnames{end+1} = strcat(roi_names{roi},'_',cond_names{c});
    end
end
t = array2table(anova_activation,'VariableNames',varnames);

within = table(repelem(['A','B','C','D','E','F','G','H','I','J','K']',4), repmat(['x','x','y','y']',11,1),repmat(['X','Y','X','Y']',11,1), 'VariableNames',{'roi','previous','current'});
rm = fitrm(t,'aMPFC_EE-Rsp_HH ~1','WithinDesign', within);
ranovatable = ranova(rm,'WithinModel','roi*previous*current');



r = 1;
for beta = 1:4:44
    
    roi_names{r}
    r = r + 1;
    roi_anova_activation = sub_activation(:,beta:beta+3);
    
    % ANOVA (2 previous) x (2 current)
    anova_activation = roi_anova_activation; % (2 previous) x (2 current)
    varnames = {'EE', 'EH', 'HE', 'HH'};
    
    t = array2table(anova_activation,'VariableNames',varnames);
    
    within = table(['x','x','y','y']',['X','Y','X','Y']','VariableNames',{'previous','current'});
    rm = fitrm(t,'EE,HE,EH,HH ~1','WithinDesign', within);
    ranovatable = ranova(rm,'WithinModel','previous*current')
    
end


%% CUE PHASE
%%% ----- Model2 DMN network  ----- %%%
%             CUE PHASE              %
%%% ----- ------------------- ----- %%%
clear pvalues

% define ROIs
apriori_rois = 'DMN_network';
roi_color = [1,0,0];

% load data
load(fullfile(resultsfolder, sprintf('beta_values_%s_%s',model_name,apriori_rois)),'voxel_beta_values');

nsubj = size(voxel_beta_values,1);
ncon = size(voxel_beta_values,2);
nrois = size(voxel_beta_values,3);

for con_ind = 1:4 %cue only
    % get mean and se
    cond_val(:,con_ind) = [voxel_beta_values(:,con_ind,1).beta_value];
    bar_input(con_ind) = nanmean([voxel_beta_values(:,con_ind,1).beta_value]);
    errorbar_input(con_ind) = nanstd([voxel_beta_values(:,con_ind,1).beta_value])/sqrt(nsubj);
end

figure(1000);

bar(bar_input,'FaceColor',roi_color); hold on
errorbar(bar_input,errorbar_input,'k.');
ylim([-3,3])

title(strrep(strrep(voxel_beta_values(1,1,1).roiname,'.nii',''),'_','-'));

set(gcf, 'Position',  [0, 0, 300, 300])
set(gcf,'color','w');
ylabel('beta estimates');
set(gca,'box','off')

xticklabels(label_names)

print(sprintf('/media/tw260/X6/Effort/analysis/results/ROI_betavalues/%s_cue_%s_%s.eps',model_name,apriori_rois,strrep(voxel_beta_values(1,1,1).roiname,'.nii','')),'-depsc2','-painters');
comparisons_between_bars(1:4, cond_val)

% ANOVA (2 previous) x (2 current)
anova_activation = cond_val; % (2 previous) x (2 current)
varnames = {'EE', 'EH', 'HE', 'HH'};

t = array2table(anova_activation,'VariableNames',varnames);

within = table(['x','x','y','y']',['X','Y','X','Y']','VariableNames',{'previous','current'});
 rm = fitrm(t,'EE,HE,EH,HH ~1','WithinDesign', within);
ranovatable = ranova(rm,'WithinModel','previous*current');


%% MATH PHASE
%%% ----- Model2 DMN network  ----- %%%
%             MATH PHASE              %
%%% ----- ------------------- ----- %%%
clear pvalues

% define ROIs
apriori_rois = 'DMN_network';
roi_color = [1,0,0];

% load data
load(fullfile(resultsfolder, sprintf('beta_values_%s_%s',model_name,apriori_rois)),'voxel_beta_values');

nsubj = size(voxel_beta_values,1);
ncon = size(voxel_beta_values,2);
nrois = size(voxel_beta_values,3);

for con_ind = 5:8 % math phase
    % get mean and se
    cond_val(:,con_ind-4) = [voxel_beta_values(:,con_ind,1).beta_value];
    bar_input(con_ind-4) = nanmean([voxel_beta_values(:,con_ind,1).beta_value]);
    errorbar_input(con_ind-4) = nanstd([voxel_beta_values(:,con_ind,1).beta_value])/sqrt(nsubj);
end

figure(200);

bar(bar_input,'FaceColor',roi_color); hold on
errorbar(bar_input,errorbar_input,'k.');
ylim([-6,3])

title(strrep(strrep(voxel_beta_values(1,1,1).roiname,'.nii',''),'_','-'));

set(gcf, 'Position',  [0, 0, 300, 300])
set(gcf,'color','w');
ylabel('beta estimates');
set(gca,'box','off')

xticklabels(label_names)

print(sprintf('/media/tw260/X6/Effort/analysis/results/ROI_betavalues/%s_task_%s_%s.eps',model_name,apriori_rois,strrep(voxel_beta_values(1,1,1).roiname,'.nii','')),'-depsc2','-painters');
comparisons_between_bars(1:4, cond_val)

% ANOVA (2 previous) x (2 current)
anova_activation = cond_val; % (2 previous) x (2 current)
varnames = {'EE', 'EH', 'HE', 'HH'};

t = array2table(anova_activation,'VariableNames',varnames);

within = table(['x','x','y','y']',['X','Y','X','Y']','VariableNames',{'previous','current'});
 rm = fitrm(t,'EE,HE,EH,HH ~1','WithinDesign', within);
ranovatable = ranova(rm,'WithinModel','previous*current');


