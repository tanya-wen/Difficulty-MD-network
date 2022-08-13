% function rsa_LDC()
%__________________________________________________________________________
% Copyright (C) 2010 Medical Research Council


%% Initialisation 
clear all; close all; clc; dbstop if error;

network = 'Searchlight_10mm';

% add paths to toolbox:
here=fileparts(which(mfilename));
addpath(fileparts(here));
addpath(genpath('/media/tw260/X6/Effort'));
addpath(genpath('/media/tw260/X6/software'));


% details of data:

% Should information about the experimental design be automatically acquired from SPM metadata?
% If this option is set to true, the entries in userOptions.conditionLabels MUST correspond to the names of the conditions as specified in SPM.
userOptions.getSPDMNata = true;
userOptions.conditionLabels={};

for level = 1:6
    userOptions.conditionLabels{end+1} = sprintf('level%d',level);
end

nCond=length(userOptions.conditionLabels);

% The path leading to where the scans are stored (not including subject-specific identifiers).
% "[[subjectName]]" should be used as a placeholder to denote an entry in userOptions.subjectNames
% "[[betaIdentifier]]" should be used as a placeholder to denote an output of betaCorrespondence.m if SPM is not being used; or an arbitrary filename if SPM is being used.
datadir='/media/tw260/X6/Effort';

userOptions.betaPath = fullfile(datadir,'analysis','l1output-Effort-Model1','[[subjectName]]','model','_subject_id_[[subjectName]]','_fwhm_0','[[betaIdentifier]]');

userOptions.structuralsPath = fullfile(datadir,'fMRI_BIDS','derivatives','fmriprep',strrep('sub-[[subjectName]]','_',''),'anat');
userOptions=rmfield(userOptions,'structuralsPath'); % this is used for normalisation; remove the field if we don't want to do this!

userOptions.voxelSize = [2 2 2]; % dimensions (in mm) of the voxels in the scans
userOptions.searchlightRadius = 10; % radius of searchlight (mm)

% visualisation options:
userOptions.RoIColor = [0 0 1]; % colour for ROI RDMs
userOptions.ModelColor = [0 1 0]; % colour for model RDMs
userOptions.conditionColours = kron(hsv(6),1); % colours for conditions
userOptions.rankTransform = false; %true; % Should RDMs' entries be rank transformed into [0,1] before they're displayed?
userOptions.criterion = 'metricstress'; % What criterion shoud be minimised in MDS display?
userOptions.rubberbands = true; % Should rubber bands be shown on the MDS plot?
userOptions.colourScheme = RDMcolormap(); % What is the colourscheme for the RDMs?
userOptions.plotpValues = '=';

% (dis)similarity measures:
userOptions.distance = 'Correlation'; % distance measure to calculate first-order RDMs.
userOptions.distanceMeasure = 'Kendall_taua'; % similarity-measure used for the second-order comparison
userOptions.RDMcorrelationType=userOptions.distanceMeasure; % different names for same thing, depending on function??

% stats options:
userOptions.significanceTestPermutations = 1000; % (10,000 recommended)
userOptions.nResamplings = 1000; % for bootstrapping
userOptions.resampleSubjects = true; % for bootstrapping
userOptions.resampleConditions = false; % for bootstrapping
userOptions.RDMrelatednessTest = 'none'; % because single subject and <8 conditions
userOptions.RDMrelatednessThreshold = 0.05;
userOptions.RDMrelatednessMultipleTesting = 'FWE';
userOptions.candRDDMNifferencesTest = 'none'; % single subject and <20 conditions in this demo?
userOptions.candRDDMNifferencesThreshold = 0.05;
userOptions.candRDDMNifferencesMultipleTesting = 'none';

% How should figures be outputted?
userOptions.displayFigures = true;
userOptions.saveFiguresPDF = true;
userOptions.saveFiguresFig = false;
userOptions.saveFiguresPS = false;
userOptions.dpi = 300; % Which dots per inch resolution do we output?
userOptions.tightInset = false; % Remove whitespace from PDF/PS files?

userOptions.forcePromptReply = 'r';



%% loop through subject
subject_list = {'s01','s02','s03','s04','s05','s06','s08','s09','s10','s11','s12','s13','s14','s15','s16','s18','s19','s20','s23','s24','s25','s26','s27','s29','s31'}; % The list of subjects to be included in the study.

for subIDX = 1:numel(subject_list)
    
    userOptions.subjectNames = subject_list(subIDX);
    
    %% set the output directory:
    userOptions.rootPath = fullfile(sprintf('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/%s/%s',network,userOptions.subjectNames{1}));
    userOptions.analysisName = 'rsa_LDC_10mm';
    mkdir(userOptions.rootPath);
    
    %% Data preparation
    if strcmp(network,'MD')==1
        userOptions.maskPath = fullfile(datadir,'ROIs','MD rois','bilateral','[[maskName]].nii');
        userOptions.maskNames = {'AI.nii','aMFG.nii','preSMA.nii','FEF.nii','IPS.nii','mMFG.nii','pMFG.nii'};
    elseif strcmp(network,'DMN')==1
        userOptions.maskPath = fullfile(datadir,'ROIs','DMN rois','bilateral','[[maskName]].nii');
        userOptions.maskNames = {'aMPFC.nii','PCC.nii','dMPFC.nii','LTC.nii','TPJ.nii','Temp.nii','vMPFC.nii','pIPL.nii','HF.nii','PHC.nii','Rsp.nii'};
    else
        userOptions.maskPath = fullfile(datadir,'ROIs','[[maskName]].nii');
        userOptions.maskNames = {'rbrainmask'}; % just the wholebain mask!
    end
    binaryMasks_nS = fMRIMaskPreparation(userOptions); % .subject.mask([x y z])
    
    %% Model RDM definition
    clear mymodelRDMs;
    
    % context
    rdm_mod = [NaN, 0, 0, 1, 1, 1;
               0, NaN, 0, 1, 1, 1;
               0, 0, NaN, 1, 1, 1;
               1, 1, 1, NaN, 0, 0;
               1, 1, 1, 0, NaN, 0;
               1, 1, 1, 0, 0, NaN];
    mymodelRDMs.context = rdm_mod;
    imagesc(mymodelRDMs.context)
    
    %relative difficulty
    rdm_mod = [NaN, 1, 2, 0, 1, 2;
               1, NaN, 1, 1, 0, 1;
               2, 1, NaN, 2, 1, 0;
               0, 1, 2, NaN, 1, 2;
               1, 0, 1, 1, NaN, 1;
               2, 1, 0, 2, 1, NaN];
    mymodelRDMs.relative = rdm_mod;
    imagesc(mymodelRDMs.relative)
    
    %absolute difficulty
    rdm_mod = [NaN, 1, 2, 2, 3, 4;
               1, NaN, 1, 1, 2, 3;
               2, 1, NaN, 0, 1, 2;
               2, 1, 0, NaN, 1, 2;
               3, 2, 1, 1, NaN, 1;
               4, 3, 2, 2, 1, NaN];
    mymodelRDMs.absolute = rdm_mod;
    imagesc(mymodelRDMs.absolute)
    
    
    models = constructModelRDMs(mymodelRDMs, userOptions);
    showRDMs(models,98,false,[],false);
    print(strcat(userOptions.rootPath,'/modelRDMs'),'-dpdf');
    
    
    %% Searchlight
    
    % NOTE BUGFIX FOR MISSING FUNCTION spacesToUnderscores.m
    % (also a bug with returned arguments)
    
    tempoptions=userOptions;
    tempoptions.maskNames={'rbrainmask'}; % just the wholebain mask!
    binaryMasks_nS_wholebrain = fMRIMaskPreparation(tempoptions);
    fullBrainVols = fMRIDataPreparation('SPM', userOptions); % .subject([vox x cond x session])
    %%%%% by default averages RDMs across sessions:
    fMRISearchlight_LDC_Effort_Kendall(fullBrainVols, binaryMasks_nS_wholebrain, models, 'SPM', tempoptions);
    %%%%%
    
    % Now view .../Maps/...nii.
    
end
