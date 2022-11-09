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


%% CUE PHASE
%%% ----- Model2 MD ROIs plot ----- %%%
%             CUE PHASE              %
%%% ----- ------------------- ----- %%%
% define ROIs
apriori_rois = 'bilateral_MD';
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
    
    roi_cnt = roi_cnt + 1;
end

% ANOVA 
anova_activation = sub_activation; % (2 previous) x (2 current) x (7 ROIs) 
roi_names = {'AI','aMFG','preSMA','FEF','IPS','mMFG','pMFG'};
cond_names = {'EE', 'EH', 'HE', 'HH'};
varnames = {};
for roi = 1:7
    for c = 1:4
        varnames{end+1} = strcat(roi_names{roi},'_',cond_names{c});
    end
end
t = array2table(anova_activation,'VariableNames',varnames);

within = table(repelem(['A','B','C','D','E','F','G']',4), repmat(['x','x','y','y']',7,1),repmat(['X','Y','X','Y']',7,1), 'VariableNames',{'roi','previous','current'});
rm = fitrm(t,'AI_EE-pMFG_HH ~1','WithinDesign', within);
ranovatable = ranova(rm,'WithinModel','roi*previous*current');


r = 1;
for beta = 1:4:28
    
    roi_names{r}

    roi_anova_activation = sub_activation(:,beta:beta+3);
    
    % ANOVA (2 previous) x (2 current)
    anova_activation = roi_anova_activation; % (2 previous) x (2 current)
    varnames = {'EE', 'EH', 'HE', 'HH'};
    
    t = array2table(anova_activation,'VariableNames',varnames);
    
    within = table(['x','x','y','y']',['X','Y','X','Y']','VariableNames',{'previous','current'});
    rm = fitrm(t,'EE,HE,EH,HH ~1','WithinDesign', within);
    ranovatable = ranova(rm,'WithinModel','previous*current');
    fvals(r,:) = [ranovatable.F(1:2:end)];
    pvals(r,:) = [ranovatable.pValueGG(1:2:end)];
    r = r + 1;
end


fvals = fvals([2,6,7,4,5,1,3],:);
pvals = pvals([2,6,7,4,5,1,3],:);

%% correct for multiple comparisons
[h, crit_p, adj_ci_cvrg, adj_p_previous]=fdr_bh(pvals(:,2),0.05);
[h, crit_p, adj_ci_cvrg, adj_p_current]=fdr_bh(pvals(:,3),0.05);
[h, crit_p, adj_ci_cvrg, adj_p_interaction]=fdr_bh(pvals(:,4),0.05);



%% MATH PHASE
%%% ----- Model2 MD ROIs plot ----- %%%
%             MATH PHASE              %
%%% ----- ------------------- ----- %%%
% define ROIs
apriori_rois = 'bilateral_MD';
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
    
    roi_cnt = roi_cnt + 1;
end

% ANOVA 
anova_activation = sub_activation; % (2 previous) x (2 current) x (7 ROIs) 
roi_names = {'AI','aMFG','preSMA','FEF','IPS','mMFG','pMFG'};
cond_names = {'EE', 'EH', 'HE', 'HH'};
varnames = {};
for roi = 1:7
    for c = 1:4
        varnames{end+1} = strcat(roi_names{roi},'_',cond_names{c});
    end
end
t = array2table(anova_activation,'VariableNames',varnames);

within = table(repelem(['A','B','C','D','E','F','G']',4), repmat(['x','x','y','y']',7,1),repmat(['X','Y','X','Y']',7,1), 'VariableNames',{'roi','previous','current'});
rm = fitrm(t,'AI_EE-pMFG_HH ~1','WithinDesign', within);
ranovatable = ranova(rm,'WithinModel','roi*previous*current');


r = 1;
for beta = 1:4:28
    
    roi_names{r}

    roi_anova_activation = sub_activation(:,beta:beta+3);
    
    % ANOVA (2 previous) x (2 current)
    anova_activation = roi_anova_activation; % (2 previous) x (2 current)
    varnames = {'EE', 'EH', 'HE', 'HH'};
    
    t = array2table(anova_activation,'VariableNames',varnames);
    
    within = table(['x','x','y','y']',['X','Y','X','Y']','VariableNames',{'previous','current'});
    rm = fitrm(t,'EE,HE,EH,HH ~1','WithinDesign', within);
    ranovatable = ranova(rm,'WithinModel','previous*current');
    fvals(r,:) = [ranovatable.F(1:2:end)];
    pvals(r,:) = [ranovatable.pValueGG(1:2:end)];
    r = r + 1;
end


fvals = fvals([2,6,7,4,5,1,3],:);
pvals = pvals([2,6,7,4,5,1,3],:);

%% correct for multiple comparisons
[h, crit_p, adj_ci_cvrg, adj_p_previous]=fdr_bh(pvals(:,2),0.05);
[h, crit_p, adj_ci_cvrg, adj_p_current]=fdr_bh(pvals(:,3),0.05);
[h, crit_p, adj_ci_cvrg, adj_p_interaction]=fdr_bh(pvals(:,4),0.05);

