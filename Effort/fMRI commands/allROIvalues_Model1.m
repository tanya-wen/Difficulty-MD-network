clear all; close all; clc; dbstop if error
% plot ROI beta values

% results folder
resultsfolder = '/media/tw260/X6/Effort/analysis/results/ROI_betavalues';
addpath(genpath('/media/tw260/X6/software'));


%% Model 1

% specify model
model_name =  'Model1';

% contrasts
con = {'low', 'medium', 'high', 'low', 'medium', 'high'};
ncons = numel(con);


%%% ----- Model1 MD ROIs plot ----- %%%

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
sub_activation_3 = [];
sub_activation_4 = [];


for roi_ind = 1:nrois
    sub_activation = [];
    
    for con_ind = 1:ncon
        % get mean and se
        activation(con_ind, roi_ind) = nanmean([voxel_beta_values(:,con_ind,roi_ind).beta_value]);
        stderror(con_ind,roi_ind) = nanstd([voxel_beta_values(:,con_ind,roi_ind).beta_value])/sqrt(nsubj);
        
        sub_activation = [sub_activation, [voxel_beta_values(:,con_ind,roi_ind).beta_value]'];
        
    end
    
    
    %% perform t-test on each pairwise condition
    con_cnt = 1;
    for a1 = 1:ncon
        for a2 = 1:ncon
            if a1<a2
                [h,pvalues(roi_cnt,con_cnt),ci, stats] = ttest(sub_activation(:,a1),sub_activation(:,a2));
                tval(roi_cnt,con_cnt) = stats.tstat;
                con_cnt = con_cnt + 1;
            end
        end
    end
    
    roi_cnt = roi_cnt +1;
    
end
  

%% correct for multiple comparisons
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(pvalues,0.05);


%% write to table
roi_cnt = 1;
for roi_ind = 1:nrois
    
    tval_table = zeros(6,6);
    pval_table = zeros(6,6);
    adj_pval_table = zeros(6,6);
    con_cnt = 1;
    
    for a1 = 1:ncon
        for a2 = 1:ncon
            if a1<a2
                tval_table(a1,a2) = tval(roi_cnt,con_cnt);
                pval_table(a1,a2) = pvalues(roi_cnt,con_cnt);
                adj_pval_table(a1,a2) = adj_p(roi_cnt,con_cnt);
                con_cnt = con_cnt + 1;
            end
        end
    end
    
    tval_T = array2table(tval_table,'VariableNames',{'EasyLow','EasyMedium','EasyHigh','HardLow','HardMedium','HardHigh'});
    pval_T = array2table(pval_table,'VariableNames',{'EasyLow','EasyMedium','EasyHigh','HardLow','HardMedium','HardHigh'});
    adj_pval_table = array2table(adj_pval_table,'VariableNames',{'EasyLow','EasyMedium','EasyHigh','HardLow','HardMedium','HardHigh'});

    roi_cnt = roi_cnt +1;
    
end
    


