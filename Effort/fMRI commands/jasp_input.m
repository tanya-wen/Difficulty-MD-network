clear all; close all; clc; dbstop if error

% results folder
resultsfolder = '/media/tw260/X6/Effort/analysis/results/ROI_betavalues';
addpath(genpath('/media/tw260/X6/software'));


% --- Model 1 ---%
model_name =  'Model1';
%% MD network ROI
apriori_rois = 'MD_network';

% load data
load(fullfile(resultsfolder, sprintf('beta_values_%s_%s',model_name,apriori_rois)),'voxel_beta_values');
nsubj = size(voxel_beta_values,1);
ncon = size(voxel_beta_values,2);
nrois = size(voxel_beta_values,3);


easy_high = [voxel_beta_values(:,3).beta_value]';
hard_low = [voxel_beta_values(:,4).beta_value]';

T = table(easy_high, hard_low,'VariableNames',{'easy_high','hard_low'});

writetable(T,'/media/tw260/X6/Effort/analysis/results/ROI_betavalues/MD_matched.csv','Delimiter',',')


%% 7 MD ROIs

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
    
    for con_ind = 1:ncon
        % get mean and se
        activation(con_ind, roi_ind) = nanmean([voxel_beta_values(:,con_ind,roi_ind).beta_value]);
        stderror(con_ind,roi_ind) = nanstd([voxel_beta_values(:,con_ind,roi_ind).beta_value])/sqrt(nsubj);
        
        sub_activation = [sub_activation, [voxel_beta_values(:,con_ind,roi_ind).beta_value]'];
        
        % we specifically want to look at level 3 vs. level 4
        if con_ind == 3
            sub_activation_3 = [sub_activation_3, [voxel_beta_values(:,con_ind,roi_ind).beta_value]'];
        elseif con_ind == 4
            sub_activation_4 = [sub_activation_4, [voxel_beta_values(:,con_ind,roi_ind).beta_value]'];
        end
    end
    
    roi_cnt = roi_cnt + 1;
end

% for each ROI, compare level 3 vs. level 4
[H,P,CI,STATS] = ttest(sub_activation_3, sub_activation_4);
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(P,0.05);

max_t_idx = find(STATS.tstat == max(STATS.tstat));

T = table(sub_activation_3(:,max_t_idx), sub_activation_4(:,max_t_idx),'VariableNames',{'easy_high','hard_low'});

writetable(T,'/media/tw260/X6/Effort/analysis/results/ROI_betavalues/MD_rois_matched.csv','Delimiter',',')


% --- Model 2 ---%
model_name =  'Model2';
%% MD network ROI
apriori_rois = 'MD_network';

% load data
load(fullfile(resultsfolder, sprintf('beta_values_%s_%s',model_name,apriori_rois)),'voxel_beta_values');
nsubj = size(voxel_beta_values,1);
ncon = size(voxel_beta_values,2);
nrois = size(voxel_beta_values,3);


for con_ind = 5:8 % math phase
    cond_val(:,con_ind-4) = [voxel_beta_values(:,con_ind,1).beta_value];
end

% ANOVA (2 previous) x (2 current)
anova_activation = cond_val; % (2 previous) x (2 current)
varnames = {'EE', 'EH', 'HE', 'HH'};

t = array2table(anova_activation,'VariableNames',varnames);

writetable(t,'/media/tw260/X6/Effort/analysis/results/ROI_betavalues/MD_anova.csv','Delimiter',',')


%% 7 MD ROIs

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

% ANOVA (switch x difficulty level x ROI)
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

writetable(t,'/media/tw260/X6/Effort/analysis/results/ROI_betavalues/MD_rois_anova.csv','Delimiter',',')


% --- RSA analysis --- %

%% MD network ROI
clear all;
roi_names = 'MDnetwork';
network_roi = 1;
network = 'MD';
roi_ind = 8;

addpath(genpath('/media/tw260/X6/Effort'));
addpath(genpath('/media/tw260/X6/software'));
addpath(genpath(strcat('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/',sprintf('%s',network))));
pth = fullfile('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance',sprintf('%s',network),'s31');
load(fullfile(pth,'RDMs','rsa_LDC_RDMs.mat'))
load(fullfile(pth,'RDMs','rsa_LDC_Models.mat'))
load(fullfile(pth,'Details','rsa_LDC_fMRIMaskPreparation_Details.mat'))

subject_list = {'s01','s02','s03','s04','s05','s06','s08','s09','s10','s11','s12','s13','s14','s15','s16','s18','s19','s20','s23','s24','s25','s26','s27','s29','s31'};
nsub = numel(subject_list);

new_roinames = userOptions.maskNames;
new_roinames=strrep(new_roinames,'_','-');

% load suject pixel RDMs
behav_dir = '/media/tw260/X6/Effort/behav';
cum_pixelRDM = zeros(6,6);
for sub = 1:nsub
    load(fullfile(behav_dir,subject_list{sub},'pixelRDM.mat'));
    subjRDM(sub).pixelRDM = subj_rdm;
    
    cum_pixelRDM = cum_pixelRDM + subj_rdm;
end
avg_pixelRDM = cum_pixelRDM/nsub;

% model fits per subject and roi
model_coefficients=nan(nsub,4);
model_pvals=nan(1,4);

for sub = 1:nsub
    regression_table = table(tiedrank(vectorizeRDM(RDMs(roi_ind,sub).RDM))',...
        tiedrank(vectorizeRDM(Models(3).RDM))',...
        tiedrank(vectorizeRDM(Models(2).RDM))',...
        tiedrank(vectorizeRDM(subjRDM(sub).pixelRDM))',...
        'VariableNames',{'data','absolute','relative','pixel'});
    
    %%% fit model
    Model = fitlm(regression_table,'data ~ absolute + relative + pixel');
    
    model_coefficients(sub,1:Model.NumCoefficients) = [Model.Coefficients.Estimate];
    
end % next subject

%%%% t-test
[~, model_pvals(1:size(model_coefficients,2)), ~, stats] = ttest(squeeze(model_coefficients),0,'tail','right');

    
t = array2table(model_coefficients,'VariableNames',{'constant','absolute','relative','pixel'});

writetable(t,'/media/tw260/X6/Effort/analysis/results/ROI_betavalues/MD_RSA.csv','Delimiter',',')




%% 7 ROIs
clear all;
roi_names = 'MD';
network_roi = 1;
network = 'MD';
roi_ind = 1:7;

addpath(genpath('/media/tw260/X6/Effort'));
addpath(genpath('/media/tw260/X6/software'));
addpath(genpath(strcat('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/',sprintf('%s',network))));
pth = fullfile('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance',sprintf('%s',network),'s31');
load(fullfile(pth,'RDMs','rsa_LDC_RDMs.mat'))
load(fullfile(pth,'RDMs','rsa_LDC_Models.mat'))
load(fullfile(pth,'Details','rsa_LDC_fMRIMaskPreparation_Details.mat'))

subject_list = {'s01','s02','s03','s04','s05','s06','s08','s09','s10','s11','s12','s13','s14','s15','s16','s18','s19','s20','s23','s24','s25','s26','s27','s29','s31'};
nsub = numel(subject_list);

new_roinames = userOptions.maskNames;
new_roinames=strrep(new_roinames,'_','-');

% load suject pixel RDMs
behav_dir = '/media/tw260/X6/Effort/behav';
cum_pixelRDM = zeros(6,6);
for sub = 1:nsub
    load(fullfile(behav_dir,subject_list{sub},'pixelRDM.mat'));
    subjRDM(sub).pixelRDM = subj_rdm;
    
    cum_pixelRDM = cum_pixelRDM + subj_rdm;
end
avg_pixelRDM = cum_pixelRDM/nsub;

% model fits per subject and roi
model_coefficients=nan(nsub,length(roi_ind), 4);
model_pvals=nan(length(roi_ind),4);

for roi = roi_ind
    
    for sub = 1:nsub
        regression_table = table(tiedrank(vectorizeRDM(RDMs(roi,sub).RDM))',...
            tiedrank(vectorizeRDM(Models(3).RDM))',...
            tiedrank(vectorizeRDM(Models(2).RDM))',...
            tiedrank(vectorizeRDM(subjRDM(sub).pixelRDM))',...
            'VariableNames',{'data','absolute','relative','pixel'});
        
        %%% fit model
        Model = fitlm(regression_table,'data ~ absolute + relative + pixel');
        
        model_coefficients(sub,roi,1:Model.NumCoefficients) = [Model.Coefficients.Estimate];
        
    end % next subject
    

    %%%% t-test
    [~, model_pvals(roi,1:size(model_coefficients,3)), ~, stats(roi)] = ttest(squeeze(model_coefficients(:,roi,:)),0,'tail','right');
   
end % next roi

tstat_list = reshape([stats.tstat],4,7)';

% context-dependent
max_t_idx = find(tstat_list(:,3) == max(tstat_list(:,3)));
coefficient_list = squeeze(model_coefficients(:,max_t_idx,3));

T = table(coefficient_list,'VariableNames',{'relative'});
writetable(T,'/media/tw260/X6/Effort/analysis/results/ROI_betavalues/MD_rois_RSA_relative.csv','Delimiter',',')

% pixel
max_t_idx = find(tstat_list(:,4) == max(tstat_list(:,4)));
coefficient_list = squeeze(model_coefficients(:,max_t_idx,4));

T = table(coefficient_list,'VariableNames',{'pixel'});
writetable(T,'/media/tw260/X6/Effort/analysis/results/ROI_betavalues/MD_rois_RSA_pixel.csv','Delimiter',',')




% --- LDC for matched conditions --- %
%% MD network
clear all; 
network = 'MD';

addpath(genpath('/media/tw260/X6/Effort'));
addpath(genpath('/media/tw260/X6/software'));
fig_path = sprintf('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/%s',network);

addpath(genpath(strcat('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/',sprintf('%s',network))));
pth = fullfile('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance',sprintf('%s',network),'s31');
load(fullfile(pth,'RDMs','rsa_LDC_RDMs.mat'))
load(fullfile(pth,'RDMs','rsa_LDC_Models.mat'))
load(fullfile(pth,'Details','rsa_LDC_fMRIMaskPreparation_Details.mat'))

subject_list = {'s01','s02','s03','s04','s05','s06','s08','s09','s10','s11','s12','s13','s14','s15','s16','s18','s19','s20','s23','s24','s25','s26','s27','s29','s31'};
nsub = numel(subject_list);

for sub = 1:nsub
    
    ldc_val(sub) = RDMs(8,sub).RDM(3,4);
    
end

[H,P,CI,STATS] = ttest(ldc_val,zeros(1,nsub),'tail','right');

T = table(ldc_val','VariableNames',{'ldc'});
writetable(T,'/media/tw260/X6/Effort/analysis/results/ROI_betavalues/MD_LDC.csv','Delimiter',',')

%% 7 MD ROIs
clear all; 
network = 'MD';
roi_names = {'AI','aMFG','preSMA','FEF','IPS','mMFG','pMFG'};

addpath(genpath('/media/tw260/X6/Effort'));
addpath(genpath('/media/tw260/X6/software'));
fig_path = sprintf('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/%s',network);

addpath(genpath(strcat('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/',sprintf('%s',network))));
pth = fullfile('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance',sprintf('%s',network),'s31');
load(fullfile(pth,'RDMs','rsa_LDC_RDMs.mat'))
load(fullfile(pth,'RDMs','rsa_LDC_Models.mat'))
load(fullfile(pth,'Details','rsa_LDC_fMRIMaskPreparation_Details.mat'))

subject_list = {'s01','s02','s03','s04','s05','s06','s08','s09','s10','s11','s12','s13','s14','s15','s16','s18','s19','s20','s23','s24','s25','s26','s27','s29','s31'};
nsub = numel(subject_list);

roi_ind = 1:7;

for roi = roi_ind
    
    for sub = 1:nsub
        
        ldc_val(roi,sub) = RDMs(roi,sub).RDM(3,4);
        
    end
    
    [H,P(roi),CI,STATS(roi)] = ttest(ldc_val(roi,:),zeros(1,nsub),'tail','right');
    
end

% find max t
tstat_list = [STATS.tstat];
max_t_idx = find(tstat_list == max(tstat_list));
ldc_list = squeeze(ldc_val(max_t_idx,:))';

T = table(ldc_list,'VariableNames',{'ldc'});
writetable(T,'/media/tw260/X6/Effort/analysis/results/ROI_betavalues/MD_rois_LDC.csv','Delimiter',',')


