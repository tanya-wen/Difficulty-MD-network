clear all; close all; dbstop if error;

addpath('/media/tw260/X6/Effort/fMRI commands');
addpath('/media/tw260/X6/Effort/analysis');
addpath(genpath('/media/tw260/X6/software'));
load('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/MD/s01/RDMs/rsa_LDC_Models.mat')



spm('Defaults','FMRI');

analysisdir = '/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/Searchlight_10mm/Regression';
try cd(analysisdir)
catch eval(sprintf('!mkdir %s',analysisdir)); cd(analysisdir);
end


%% info

subject_list = {'s01','s02','s03','s04','s05','s06','s08','s09','s10','s11','s12','s13','s14','s15','s16','s18','s19','s20','s23','s24','s25','s26','s27','s29','s31'}; % The list of subjects to be included in the study.
model_names = {'absolute','relative','pixel'};

nsub = numel(subject_list);

%% set up variables
mask_V = spm_vol('/media/tw260/X6/Effort/ROIs/rbrainmask.nii');
mask_vol = spm_read_vols(mask_V);

mask_V.dt = [16,0];
mask_V.pinfo = [1;0;352];

%% load suject pixel RDMs
behav_dir = '/media/tw260/X6/Effort/behav';
cum_pixelRDM = zeros(6,6);
for sub = 1:nsub
    load(fullfile(behav_dir,subject_list{sub},'pixelRDM.mat'));
    subjRDM(sub).pixelRDM = subj_rdm;
    
    cum_pixelRDM = cum_pixelRDM + subj_rdm;
end
avg_pixelRDM = cum_pixelRDM/nsub;
%imagesc(avg_pixelRDM);


%% model fits per subject
for s = 1:numel(subject_list)
    fprintf('running subject %s \n',subject_list{s})
    model_coefficients=nan(size(mask_vol,1), size(mask_vol,2), size(mask_vol,3),4);
    
    load(sprintf('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/Searchlight_10mm/%s/RDMs/rsa_LDC_10mm_fMRISearchlight_RDMs.mat',subject_list{s}));
    searchlight = eval(['searchlightRDMs.' subject_list{s}]);
    
    for i = 1:size(mask_vol,1)
        
        for j = 1:size(mask_vol,2)
            
            for k = 1:size(mask_vol,3)
                
                if any(isnan(squeeze(searchlight(i,j,k,:))))
                    
                    model_coefficients(i,j,k,:) = nan(4,1);
                    
                else
                    
                    regression_table = table(tiedrank(squeeze(searchlight(i,j,k,:))),...
                        tiedrank(vectorizeRDM(Models(3).RDM))',...
                        tiedrank(vectorizeRDM(Models(2).RDM))',...
                        tiedrank(vectorizeRDM(subjRDM(sub).pixelRDM))',...
                        'VariableNames',{'data','absolute','relative','pixel'});

                    
                    %%% fit model
                    Model = fitlm(regression_table,'data ~ absolute + relative + pixel');
                    
                    model_coefficients(i,j,k,:) = [Model.Coefficients.Estimate];
                    
                end
                
            end
            
        end
        
    end
    
    
    %%% write into individual subject's nii file
    mask_V.fname =fullfile(analysisdir, sprintf('%s_rsa_regression_absolute.nii',subject_list{s}));
    spm_write_vol(mask_V, model_coefficients(:,:,:,2));
    
    mask_V.fname =fullfile(analysisdir, sprintf('%s_rsa_regression_relative.nii',subject_list{s}));
    spm_write_vol(mask_V, model_coefficients(:,:,:,3));
    
    mask_V.fname =fullfile(analysisdir, sprintf('%s_rsa_regression_pixel.nii',subject_list{s}));
    spm_write_vol(mask_V, model_coefficients(:,:,:,4));
            
end


% %% statistical testing
% 
% for i = 1:size(mask_vol,1)
%     
%     for j = 1:size(mask_vol,2)
%         
%         for k = 1:size(mask_vol,3)
%             
%             [~, model_pvals_context(i,j,k), ~, stats] = ttest(squeeze(model_coefficients(:,i,j,k,2)),0,'tail','right');
%             stats_context(i,j,k) = stats.tstat;
%             
%             [~, model_pvals_relative(i,j,k), ~, stats] = ttest(squeeze(model_coefficients(:,i,j,k,3)),0,'tail','right');
%             stats_relative(i,j,k) = stats.tstat;
%             
%             [~, model_pvals_absolute(i,j,k), ~, stats] = ttest(squeeze(model_coefficients(:,i,j,k,4)),0,'tail','right');
%             stats_absolute(i,j,k) = stats.tstat;
%             
%         end
%         
%     end
%     
% end
% 
% V = spm_vol('/media/tw260/X6/Effort/ROIs/rbrainmask.nii');
% V.fname =fullfile(analysisdir, 'rsa_regression_context_tmap.nii');
% V = spm_write_vol(V, stats_context);
% 
% V.fname =fullfile(analysisdir, 'rsa_regression_context_pmap.nii');
% V = spm_write_vol(V, model_pvals_context);
% 
% V.fname =fullfile(analysisdir, 'rsa_regression_relative_tmap.nii');
% V = spm_write_vol(V, stats_relative);
% 
% V.fname =fullfile(analysisdir, 'rsa_regression_relative_pmap.nii');
% V = spm_write_vol(V, model_pvals_relative);
% 
% V.fname =fullfile(analysisdir, 'rsa_regression_absolute_tmap.nii');
% V = spm_write_vol(V, stats_absolute);
% 
% V.fname =fullfile(analysisdir, 'rsa_regression_absolute_pmap.nii');
% V = spm_write_vol(V, model_pvals_absolute);
%             