clear all; close all; dbstop if error;

addpath('G:/Effort/fMRI commands');
addpath('G:/Effort/analysis');

model_type = 'LDC';
l1dir = sprintf('G:/Effort/analysis/rsa_analysis/%s_distance/Searchlight_10mm/SecondLevel',model_type);

spm('Defaults','FMRI');

analysisdir = sprintf('G:/Effort/analysis/rsa_analysis/%s_distance/Searchlight_10mm/SecondLevel',model_type);
try cd(analysisdir)
catch eval(sprintf('!mkdir %s',analysisdir)); cd(analysisdir);
end


%% contrasts of interest

subject_list = {'s01','s02','s03','s04','s05','s06','s08','s09','s10','s11','s12','s13','s14','s15','s16','s18','s19','s20','s23','s24','s25','s26','s27','s29','s31'}; % The list of subjects to be included in the study.
model_names = {'context','relative','absolute'};

for m = 1:numel(model_names)
    try
        
        S.outdir = fullfile(analysisdir,model_names{m});
        S.imgfiles{1}={};
        

        for s = 1:numel(subject_list)
            V = spm_vol(sprintf('G:/Effort/analysis/rsa_analysis/LDC_distance/Searchlight_10mm/%s/Maps/rsa_LDC_10mm_rMap_rbrainmask_%s_%s.nii',subject_list{s},model_names{m},subject_list{s}));
            vol = spm_read_vols(V);
            
            map_unsmoothed = V.fname;
            try cd(S.outdir)
            catch
                eval(sprintf('!mkdir %s',S.outdir));
                cd(S.outdir);
            end
            spm_smooth(map_unsmoothed,sprintf('%s/s10FWHM_%s',S.outdir,sprintf('rsa_LDC_10mm_rMap_rbrainmask_%s_%s.nii',model_names{m},subject_list{s})),[10,10,10]);
            
            S.imgfiles{1}{s} = fullfile(sprintf('%s/s10FWHM_%s',S.outdir,sprintf('rsa_LDC_10mm_rMap_rbrainmask_%s_%s.nii',model_names{m},subject_list{s})));
            %S.imgfiles{1}{s} = map_unsmoothed;

        end
        
        S.mask = 'G:/Effort/ROIs/rbrainmask.nii';
        
        S.contrasts{1}.name = sprintf('%s',model_names{m});
        S.contrasts{1}.type = 'T';
        S.contrasts{1}.c = 1;
        
     
        % contrasts   - cell array of contrast structures, with fields c
        %                  (matrix) type ('F' or 'T') and name (optional)
        S.uUFp=0.001;
        if ~exist(fullfile(S.outdir,'mask.nii'),'file');
            batch_spm_anova(S);
        end
        
        
        
    catch
    end
    
end
% return