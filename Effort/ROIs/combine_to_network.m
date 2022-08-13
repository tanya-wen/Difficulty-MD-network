% combine left and right

%% MD
V_AI = spm_vol('/media/tw260/X6/Effort/ROIs/MD rois/bilateral/AI.nii');
vol_AI = spm_read_vols(V_AI);

V_aMFG = spm_vol('/media/tw260/X6/Effort/ROIs/MD rois/bilateral/aMFG.nii');
vol_aMFG = spm_read_vols(V_aMFG);

V_FEF = spm_vol('/media/tw260/X6/Effort/ROIs/MD rois/bilateral/FEF.nii');
vol_FEF = spm_read_vols(V_FEF);

V_IPS = spm_vol('/media/tw260/X6/Effort/ROIs/MD rois/bilateral/IPS.nii');
vol_IPS = spm_read_vols(V_IPS);

V_mMFG = spm_vol('/media/tw260/X6/Effort/ROIs/MD rois/bilateral/mMFG.nii');
vol_mMFG = spm_read_vols(V_mMFG);

V_pMFG = spm_vol('/media/tw260/X6/Effort/ROIs/MD rois/bilateral/pMFG.nii');
vol_pMFG = spm_read_vols(V_pMFG);

V_preSMA = spm_vol('/media/tw260/X6/Effort/ROIs/MD rois/bilateral/preSMA.nii');
vol_preSMA = spm_read_vols(V_preSMA);

vol = vol_AI + vol_aMFG + vol_FEF + vol_IPS + vol_mMFG + vol_pMFG + vol_preSMA;
V_AI.fname = '/media/tw260/X6/Effort/ROIs/MD rois/MDnetwork.nii';
V = spm_write_vol(V_AI, vol);



