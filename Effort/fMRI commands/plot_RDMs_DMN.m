% plot RDMs
clear all; close all; clc;
fig_path = '/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/DMN';

% color map
t = readmatrix('/media/tw260/X6/software/YlOrRd.csv');
cMap = t(:,1:3);
colormap(cMap)

%% pixel RDM
subject_list = {'s01','s02','s03','s04','s05','s06','s08','s09','s10','s11','s12','s13','s14','s15','s16','s18','s19','s20','s23','s24','s25','s26','s27','s29','s31'};
nsub = numel(subject_list);
behav_dir = '/media/tw260/X6/Effort/behav';
cum_pixelRDM = zeros(6,6);
for sub = 1:nsub
    load(fullfile(behav_dir,subject_list{sub},'pixelRDM.mat'));
    subjRDM(sub).pixelRDM = subj_rdm;
    
    cum_pixelRDM = cum_pixelRDM + subj_rdm;
end
avg_pixelRDM = cum_pixelRDM/nsub;
avg_pixelRDM(1,1) = NaN;
avg_pixelRDM(2,2) = NaN;
avg_pixelRDM(3,3) = NaN;
avg_pixelRDM(4,4) = NaN;
avg_pixelRDM(5,5) = NaN;
avg_pixelRDM(6,6) = NaN;
imAlpha=ones(size(avg_pixelRDM));
imAlpha(isnan(avg_pixelRDM))=0;
imagesc(avg_pixelRDM,'AlphaData',imAlpha);
colorbar;
set(gcf,'color','w');
axis equal
axis tight
print(gcf,fullfile(fig_path,'RDM_pixel.eps'),'-depsc2','-painters');

%% empirical RDMs of DMN ROIs
addpath(genpath('/media/tw260/X6/Effort'));
addpath(genpath('/media/tw260/X6/software'));
network = 'DMN';

addpath(genpath(strcat('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/',sprintf('%s',network))));
pth = fullfile('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance',sprintf('%s',network),'s31');
load(fullfile(pth,'RDMs','rsa_LDC_RDMs.mat'))
load(fullfile(pth,'RDMs','rsa_LDC_Models.mat'))
load(fullfile(pth,'Details','rsa_LDC_fMRIMaskPreparation_Details.mat'))

roi_names = {'aMPFC.nii','PCC.nii','dMPFC.nii','LTC.nii','TPJ.nii','Temp.nii','vMPFC.nii','pIPL.nii','HF.nii','PHC.nii','Rsp.nii','DMNnetwork'};
roi_ind= 1:12;

for roi = roi_ind
    
    figure(100+roi)
    colormap(cMap)
    
    % get # of voxels per ROI
    if roi < 11
        apriori_rois = 'bilateral_DMN';
        load(fullfile('/media/tw260/X6/Effort/analysis/results/ROI_betavalues', sprintf('beta_values_%s_%s','Model1',apriori_rois)),'voxel_beta_values');
        vox_num = voxel_beta_values(1,1,roi).total_voxels_in_roi;
    else
        apriori_rois = 'DMN_network';
        load(fullfile('/media/tw260/X6/Effort/analysis/results/ROI_betavalues', sprintf('beta_values_%s_%s','Model1',apriori_rois)),'voxel_beta_values');
        vox_num = voxel_beta_values(1,1).total_voxels_in_roi;
    end
    
    avg_RDM = averageRDMs_subjectSession(RDMs(roi,:),'subject');
    avg_empirical_RDM = avg_RDM.RDM /vox_num;
    avg_empirical_RDM(1,1) = NaN;
    avg_empirical_RDM(2,2) = NaN;
    avg_empirical_RDM(3,3) = NaN;
    avg_empirical_RDM(4,4) = NaN;
    avg_empirical_RDM(5,5) = NaN;
    avg_empirical_RDM(6,6) = NaN;
    imAlpha=ones(size(avg_empirical_RDM));
    imAlpha(isnan(avg_empirical_RDM))=0;
    imagesc(avg_empirical_RDM,'AlphaData',imAlpha);
    colorbar;
    caxis([0,0.25])
    set(gcf,'color','w');
    axis equal
    axis tight
    print(gcf,fullfile(fig_path,sprintf('RDM_%s.eps',roi_names{roi})),'-depsc2','-painters');
    
end




