clear all; close all; clc;

dbstop if error

network = 'MDnetwork';

network_roi = 0;
if strcmp(network,'MD')==1
    roi_names = {'AI','aMFG','preSMA','FEF','IPS','mMFG','pMFG'};
elseif strcmp(network,'DMN')==1
    roi_names = {'aMPFC','PCC','dMPFC','LTC','TPJ','Temp','vMPFC','pIPL','HF','PHC','Rsp'};
elseif strcmp(network,'MDnetwork')==1
    roi_names = 'MDnetwork';
    network_roi = 1;
    network = 'MD';
elseif strcmp(network,'DMNnetwork')==1
    network_roi = 1;
    roi_names = 'DMNnetwork';
    network = 'DMN';
end


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

if network_roi == 1 && strcmp(network,'MD')==1
    roi_ind = 8;
elseif network_roi == 1 && strcmp(network,'DMN')==1
    roi_ind = 12;
elseif strcmp(network,'MD')==1
    roi_ind = 1:7;
elseif strcmp(network,'DMN')==1
    roi_ind = 1:11;
end

new_roinames = userOptions.maskNames;
new_roinames=strrep(new_roinames,'_','-');


for roi = roi_ind
    
    for sub = 1:nsub
        
        ldc_val(roi,sub) = RDMs(roi,sub).RDM(3,4);
        
    end
    
    [H,P(roi),CI,STATS(roi)] = ttest(ldc_val(roi,:),zeros(1,nsub),'tail','right');
    
end

[~, ~, ~, adj_p] = fdr_bh(P,0.05);






