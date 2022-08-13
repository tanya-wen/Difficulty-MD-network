clear all; close all; clc; dbstop if error
% get beta values from ROI
%% specify inputs
model_name =  'Model1';

% get subjects
sub_names =  {'s01','s02','s03','s04','s05','s06','s08','s09','s10','s11','s12','s13','s14','s15','s16','s18','s19','s20','s23','s24','s25','s26','s27','s29','s31'}; % The list of subjects to be included in the study.

% FDR threshold
fdrthreshold = 0.05;

% outputfolder
outputfolder = '/media/tw260/X6/Effort/analysis/results/voxelwise_regression';
if ~exist(outputfolder), mkdir(outputfolder); end

% contrasts
switch model_name
    case 'Model1'
        con = [3,4,5,6,7,8]; %level1-6
end


mask = '/media/tw260/X6/Effort/ROIs/rbrainmask.nii';
mask_V = spm_vol(mask);
mask_vol = spm_read_vols(mask_V);
    
    
%reg_context = [1,1,1,2,2,2]';
reg_absolute = [1,2,3,3,4,5]';
reg_relative = [1,3,5,1,3,5]';

% regression_context_tmap = NaN(size(mask_vol,1),size(mask_vol,2),size(mask_vol,3));
regression_absolute_tmap = NaN(size(mask_vol,1),size(mask_vol,2),size(mask_vol,3));
regression_relative_tmap = NaN(size(mask_vol,1),size(mask_vol,2),size(mask_vol,3));
% regression_context_pmap = NaN(size(mask_vol,1),size(mask_vol,2),size(mask_vol,3));
regression_absolute_pmap = NaN(size(mask_vol,1),size(mask_vol,2),size(mask_vol,3));
regression_relative_pmap = NaN(size(mask_vol,1),size(mask_vol,2),size(mask_vol,3));

for sub_ind = 1:numel(sub_names)
    fprintf('running subject %s \n',sub_names{sub_ind})
    
    for con_ind = 1:length(con)
        
        % contrast nii (used unsmoothed volume)
        V_con{con_ind} = sprintf('/media/tw260/X6/Effort/analysis/l1output-Effort-%s/%s/contrasts/_subject_id_%s/_fwhm_0/con_%04d.nii',model_name,sub_names{sub_ind},sub_names{sub_ind},con(con_ind)); % specific for subject
        vol_con(con_ind) = spm_vol(V_con{con_ind});
    end
    
    [Y,XYZmm] = spm_read_vols(vol_con,mask);
    
    
    %% get the contrasts at each voxel and compare with hypothesized activation
    for xx = 1:size(Y,1)
        for yy = 1:size(Y,2)
            parfor zz = 1:size(Y,3)
                
                activation(xx,yy,zz,:) = squeeze(Y(xx,yy,zz,:));
                
                try
                    regression_table = table(squeeze(activation(xx,yy,zz,:)),...
                        reg_absolute,...
                        reg_relative,...
                        'VariableNames', {'data', 'reg_absolute', 'reg_relative'});
                    
                    % [ones(6,1), reg_context, reg_absolute, reg_relative]
                    % is rank deficient, so we're taking out the context regressor
                    
                    model = fitlme(regression_table, 'data ~ reg_absolute + reg_relative');
                    
                    regression_absolute_tmap(xx,yy,zz) = model.Coefficients.tStat(2);
                    regression_relative_tmap(xx,yy,zz) = model.Coefficients.tStat(3);
                    regression_absolute_pmap(xx,yy,zz) = model.Coefficients.pValue(2);
                    regression_relative_pmap(xx,yy,zz) = model.Coefficients.pValue(3);
                    
                catch
                    regression_absolute_tmap(xx,yy,zz) = NaN;
                    regression_relative_tmap(xx,yy,zz) = NaN;
                    regression_absolute_pmap(xx,yy,zz) = NaN;
                    regression_relative_pmap(xx,yy,zz) = NaN;
                end
                
            end
        end
    end
    
    V = spm_vol(V_con{con_ind});
%     V.fname = sprintf('/media/tw260/X6/Effort/analysis/results/voxelwise_regression/%s_regression_context.nii',sub_names{sub_ind});
%     V = spm_write_vol(V, regression_context_tmap);
    
    V.fname = sprintf('/media/tw260/X6/Effort/analysis/results/voxelwise_regression/%s_regression_absolute.nii',sub_names{sub_ind});
    V = spm_write_vol(V, regression_absolute_tmap);
    
    V.fname = sprintf('/media/tw260/X6/Effort/analysis/results/voxelwise_regression/%s_regression_relative.nii',sub_names{sub_ind});
    V = spm_write_vol(V, regression_relative_tmap);
    

    
end





