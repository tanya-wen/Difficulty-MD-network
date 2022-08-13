%% Func
% get dicom
dcm_file = 'C:/Users/Tanya Wen/Box/Pro00101414/Effort/03152022/EFFORT_01.MR.FMRI_testing_Mo.3.1.2022.03.15.10.20.58.872.41540586.dcm';
X = dicominfo(dcm_file);

% nifti info
nifti_file = 'C:/Users/Tanya Wen/Box/Pro00101414/Effort/03152022/effort01_run01.nii';
V = niftiread(nifti_file);
N = niftiinfo(nifti_file);

n = size(V,3);
slice_order = [1:2:n 2:2:n-1];
slice_order*(2/n)


%% Anat
% get dicom
dcm_file = 'C:/Users/Tanya Wen/Box/Pro00101414/Effort/03152022/EFFORT_01.MR.FMRI_testing_Mo.1.1.2022.03.15.10.20.58.872.41540432.dcm';
X = dicominfo(dcm_file);

% nifti info
nifti_file = 'C:/Users/Tanya Wen/Box/Pro00101414/Effort/03152022/motvisbreath_anat.nii';
N = niftiinfo(nifti_file);