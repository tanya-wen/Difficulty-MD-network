clear all; close all; clc; dbstop if error
% get beta values from ROI
%% specify inputs
analysis_name = 'Model2';

% define ROIs
apriori_rois = 'MD_network';

% get subjects
sub_names =  {'s01','s02','s03','s04','s05','s06','s08','s09','s10','s11','s12','s13','s14','s15','s16','s18','s19','s20','s23','s24','s25','s26','s27','s29','s31'}; % The list of subjects to be included in the study.

% subjects who performed > 70% on both easy contexts and hard contexts
% sub_names =  {'s01','s02','s03','s04','s05','s06','s09','s10','s11','s12','s13','s14','s15','s18','s19','s20','s23','s25','s26','s31'}; % The list of subjects to be included in the study.

% FDR threshold
fdrthreshold = 0.05;

% directories for ROIs

if strcmp(apriori_rois,'unilateral_MD')==1
    roi_dir = 'G:/Effort/ROIs/MD rois/unilateral';
    roinames = {'L_AI.nii','R_AI.nii','L_aMFG.nii','R_aMFG.nii','L_preSMA.nii','R_preSMA.nii',...
        'L_FEF.nii','R_FEF.nii','L_IPS.nii','R_IPS.nii','L_mMFG.nii','R_mMFG.nii','L_pMFG.nii','R_pMFG.nii'};
elseif strcmp(apriori_rois,'bilateral_MD')==1
    roi_dir = 'G:/Effort/ROIs/MD rois/bilateral';
    roinames = {'AI.nii','aMFG.nii','preSMA.nii','FEF.nii','IPS.nii','mMFG.nii','pMFG.nii'};
elseif strcmp(apriori_rois,'MD_network')==1
    roi_dir = 'G:/Effort/ROIs/MD rois';
    roinames = {'MDnetwork.nii'};
elseif strcmp(apriori_rois,'unilateral_DMN')==1
    roi_dir = 'G:/Effort/ROIs/DMN rois/unilateral';
    roinames = {'L_aMPFC.nii','R_aMPFC.nii','L_PCC.nii','R_PCC.nii','dMPFC.nii','L_LTC.nii','R_LTC.nii',...
        'L_TPJ.nii','R_TPJ.nii','L_TempP.nii','R_TempP.nii','vMPFC.nii','L_pIPL.nii','R_pIPL.nii','L_HF.nii',...
        'R_HF.nii','L_PHC.nii','R_PHC.nii','L_Rsp.nii','R_Rsp.nii'};
elseif strcmp(apriori_rois,'bilateral_DMN')==1
    roi_dir = 'G:/Effort/ROIs/DMN rois/bilateral';
    roinames = {'aMPFC.nii','PCC.nii','dMPFC.nii','LTC.nii','TPJ.nii','Temp.nii','vMPFC.nii','pIPL.nii','HF.nii','PHC.nii','Rsp.nii'};
elseif strcmp(apriori_rois,'DMN_network')==1
    roi_dir = 'G:/Effort/ROIs/DMN rois';
    roinames = {'DMNnetwork.nii'};
elseif strcmp(apriori_rois,'unilateral_reward')==1
    roi_dir = 'G:/Effort/ROIs/reward rois/unilateral';
    roinames = {'ACC.nii','L_AI.nii','R_AI.nii','L_striatum.nii','R_striatum.nii','L_thalamus.nii','R_thalamus.nii'};
elseif strcmp(apriori_rois,'bilateral_reward')==1
    roi_dir = 'G:/Effort/ROIs/reward rois/bilateral';
    roinames = {'ACC.nii','AI.nii','striatum.nii','thalamus.nii'};
elseif strcmp(apriori_rois,'reward_network')==1
    roi_dir = 'G:/Effort/ROIs/reward rois';
    roinames = {'rewardnetwork.nii'};
end



% outputfolder
outputfolder = 'G:/Effort/analysis/results/ROI_betavalues';
if ~exist(outputfolder), mkdir(outputfolder); end

% contrasts
switch analysis_name
    case 'Model1'
        con = [3,4,5,6,7,8]; %level1-6
    case 'Model2'
        con = [1,2,3,4, 13,14,15,16];
end

for sub_ind = 1:numel(sub_names)
    
    nrois = numel(roinames);
    
    for con_ind = 1:length(con)
        
        % contrast nii (used unsmoothed volume)
        V_con = sprintf('G:/Effort/analysis/l1output-Effort-%s/%s/contrasts/_subject_id_%s/_fwhm_0/con_%04d.nii',analysis_name,sub_names{sub_ind},sub_names{sub_ind},con(con_ind)); % specific for subject
        
        %% get the percentage of voxels in the ROIs
        for roi_ind = 1:nrois

            % extract ROI
            V_roi = spm_vol([roi_dir,'/',roinames{roi_ind}]); 
            Y = spm_read_vols(V_roi);
            indx = find(Y>0);
            [x,y,z] = ind2sub(size(Y),indx);
            XYZ = [x y z]';
            
            try
                beta_value = spm_get_data(V_con,XYZ);
                voxel_beta_values(sub_ind,con_ind,roi_ind).beta_value = nanmean(beta_value); 
                voxel_beta_values(sub_ind,con_ind,roi_ind).roiname = roinames{roi_ind};
                voxel_beta_values(sub_ind,con_ind,roi_ind).total_voxels_in_roi = length(XYZ);
            catch % if the ROI is empty
                voxel_beta_values(sub_ind,con_ind,roi_ind).beta_value = NaN;
                voxel_beta_values(sub_ind,con_ind,roi_ind).roiname = roinames{roi_ind};
                voxel_beta_values(sub_ind,con_ind,roi_ind).total_voxels_in_roi = 0;
            end
        end
        
    end
    
end
save(fullfile(outputfolder, sprintf('beta_values_%s_%s',analysis_name,apriori_rois)),'voxel_beta_values');

