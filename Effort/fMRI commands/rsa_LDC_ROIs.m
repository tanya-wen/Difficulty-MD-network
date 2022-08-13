% function rsa_LDC()
%__________________________________________________________________________
% Copyright (C) 2010 Medical Research Council

%% Initialisation
clear all; close all; clc; dbstop if error;

network = 'MD';

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
userOptions.structuralsPath = fullfile(datadir,'fMRI_BIDS','derivatives','fmriprep','sub-[[subjectName]]','anat');
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
userOptions.RDMrelatednessTest = 'subjectRFXsignedRank'; % each RDM with a null RDM of 0 correlation
userOptions.RDMrelatednessThreshold = 0.05;
userOptions.RDMrelatednessMultipleTesting = 'FDR';
userOptions.candRDMNdifferencesTest = 'subjectRFXsignedRank'; % which candidate RDM better explains the reference RDM
userOptions.candRDMNdifferencesThreshold = 0.05;
userOptions.candRDMNdifferencesMultipleTesting = 'FDR';

% How should figures be outputted?
userOptions.displayFigures = true;
userOptions.saveFiguresPDF = true;
userOptions.saveFiguresFig = false;
userOptions.saveFiguresPS = false;
userOptions.dpi = 300; % Which dots per inch resolution do we output?
userOptions.tightInset = false; % Remove whitespace from PDF/PS files?

userOptions.forcePromptReply = 'r';


%% loop through subject (unfortunately each subject has different model RDM due to reward assignment)
subject_list = {'s01','s02','s03','s04','s05','s06','s08','s09','s10','s11','s12','s13','s14','s15','s16','s18','s19','s20','s23','s24','s25','s26','s27','s29','s31'}; % The list of subjects to be included in the study.

for subIDX = 1:numel(subject_list)
    
    userOptions.subjectNames = subject_list(subIDX);
    
    %% set the output directory:
    userOptions.rootPath = fullfile(sprintf('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/%s/%s',network,userOptions.subjectNames{1}));
    userOptions.analysisName = 'rsa_LDC';
    mkdir(userOptions.rootPath);
    
    %% Data preparation
    if strcmp(network,'MD')==1
        userOptions.maskPath = fullfile(datadir,'ROIs','MD rois','bilateral','[[maskName]].nii');
        userOptions.maskNames = {'AI','aMFG','preSMA','FEF','IPS','mMFG','pMFG','MDnetwork'};
    elseif strcmp(network,'DMN')==1
        userOptions.maskPath = fullfile(datadir,'ROIs','DMN rois','bilateral','[[maskName]].nii');
        userOptions.maskNames = {'aMPFC','PCC','dMPFC','LTC','TPJ','Temp','vMPFC','pIPL','HF','PHC','Rsp'};
    elseif strcmp(network,'reward')==1
        userOptions.maskPath = fullfile(datadir,'ROIs','reward rois','bilateral','[[maskName]].nii');
        userOptions.maskNames = {'ACC','AI','striatum','thalamus'};
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
    
    
    %% ROI RDM calculation
    %% data for pairwise sessions per subject and compute subject-specific LDC RDMs:
    load(sprintf('/media/tw260/X6/Effort/analysis/l1output-Effort-Model1/%s/contrasts/_subject_id_%s/_fwhm_0/SPM.mat',char(userOptions.subjectNames),char(userOptions.subjectNames)));
    X=spm_filter(SPM.xX.K, SPM.xX.W * SPM.xX.X);
    ind_level = find(~cellfun(@isempty,regexp(SPM.xX.name,'level')));
    
    
    for roi = 1:numel(userOptions.maskNames)
        Vroi = binaryMasks_nS.(char(userOptions.subjectNames));
        indx = find(Vroi.(char(userOptions.maskNames(roi)))>0);
        [x,y,z] = ind2sub(size(Vroi.(char(userOptions.maskNames(roi)))),indx);
        XYZ = [x y z]';
        
        
        cnt = 0;
        for ii = 1:5 % 5 runs
            for jj = 1:5 % 5 runs
                if jj <= ii, continue; end
                fprintf(sprintf('\n ii = %d; jj = %d \n',ii,jj));
                cnt = cnt + 1;
                a_col = intersect(ind_level,SPM.Sess(ii).col);
                b_col = intersect(ind_level,SPM.Sess(jj).col);
                a_col_nuisance = setdiff(SPM.Sess(ii).col,a_col);
                b_col_nuisance = setdiff(SPM.Sess(jj).col,b_col);
                Xa=[X(SPM.Sess(ii).row, a_col), X(SPM.Sess(ii).row,a_col_nuisance), ones(numel(SPM.Sess(ii).row),1)];
                Xb=[X(SPM.Sess(jj).row, b_col), X(SPM.Sess(jj).row,b_col_nuisance), ones(numel(SPM.Sess(jj).row),1)];
                
                
                Ys = unique(char(SPM.xY.VY.fname),'rows');
                timevox = spm_get_data(Ys,XYZ);
                timevox(~any(timevox,2),:) = []; %remove rows with 0s
                timevox(:,~any(timevox,1)) = []; %remove columns with all 0s
                timevox(:,any(timevox==0,1)) = []; %remove columns with any 0s
                Y=spm_filter(SPM.xX.K, SPM.xX.W *timevox);
                Ya=Y(SPM.Sess(1).row, :);
                Yb=Y(SPM.Sess(2).row, :);
                
                fprintf('computing LD-t values for subject %d roi %d \n',subIDX, roi)
                RDM_fdtFolded_ltv(cnt,:) = fisherDiscrCRDM_mm(Xa,Ya,Xb,Yb,1:6);
                
            end
        end
        
        RDMs(roi,subIDX).RDM = squareform(mean(RDM_fdtFolded_ltv));% diagonals will contain zeros
        RDMs(roi,subIDX).name = [char(userOptions.maskNames(roi)), ' | subject_',char(userOptions.subjectNames)];
        RDMs(roi,subIDX).color = [1 0 0];
        
        showRDMs(RDMs(roi,subIDX).RDM,roi,0)
        colormap(RDMcolormap);
        handleCurrentFigure([userOptions.rootPath,filesep,sprintf('%s_%s_RDM',char(userOptions.subjectNames),char(userOptions.maskNames(roi)))],userOptions);
        close;
        
        % MDS for one ROI:
        posRDM = RDMs; % MDS only works for non-negative distances
        posRDM(roi,subIDX).RDM = squareform(squareform(posRDM(roi,subIDX).RDM)-min(squareform(posRDM(roi,subIDX).RDM)));
        if userOptions.rubberbands % off-diagonal distances must all be > 0
            posRDM(roi,subIDX).RDM = squareform(squareform(posRDM(roi,subIDX).RDM)+min(posRDM(roi,subIDX).RDM(posRDM(roi,subIDX).RDM>0)));
        end
        MDSConditions(posRDM(roi,subIDX), userOptions); %% matlab_2015a (newer versions figures don't work)
        close;
        
    end
    

end

try mkdir(strcat(userOptions.rootPath,'/RDMs')); end
save(strcat(userOptions.rootPath,'/RDMs/rsa_LDC_RDMs.mat'),'RDMs');




%% compute the subject-averaged LDAtRDM
averageRDMs_LDC = averageRDMs_subjectSession(RDMs, 'subject');

%% display the average LDAtRDM

for subIDX=1:length(userOptions.subjectNames)
    % variability across sessions for one subject:
    figureRDMs(RDMs(:,subIDX), userOptions, struct('fileName', sprintf('singlesession_RoIRDMs_%s',userOptions.subjectNames{subIDX}), 'figureNumber', 1));
    colormap(RDMcolormap);
    close;
    
    for roi = 1:numel(userOptions.maskNames)
        % averageRDMs_LDC.name = 'subject-average LDCRDM';
        %     showRDMs(averageRDMs_LDC(roi).RDM,roi,0)
        
        posRDM = averageRDMs_LDC; % MDS only works for non-negative distances
        posRDM(roi).RDM = squareform(squareform(posRDM(roi).RDM)-min(squareform(posRDM(roi).RDM)));
        if userOptions.rubberbands % off-diagonal distances must all be > 0
            posRDM(roi).RDM = squareform(squareform(posRDM(roi).RDM)+min(posRDM(roi).RDM(posRDM(roi).RDM>0)));
        end
        MDSConditions(posRDM(roi), userOptions);
        handleCurrentFigure([userOptions.rootPath,filesep,sprintf('%s_groupAverageMDS',averageRDMs_LDC(roi).name)],userOptions);
        close;
        dendrogramConditions(posRDM(roi), userOptions);
        handleCurrentFigure([userOptions.rootPath,filesep,sprintf('%s_groupAverageDendrogram',averageRDMs_LDC(roi).name)],userOptions);
        close;
        
        
    end
    
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% statistical inference %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % NOTE BUGS THAT REQUIRE PAIRWISE TESTS, AND DIFFERENCES
% 
% for roiIndex= 1:numel(userOptions.maskNames)
%     userOptions.figureIndex = [1 101]; % for stats
%     %     for m=1:length(models)
%     stats_p_r(m)=compareRefRDM2candRDMs_djm(RDMs(roiIndex,:), num2cell(models), userOptions);
%     %     end
%     figure(99); clf;
%     meanr=mean(stats_p_r.candRelatedness_r);
%     bh=bar(meanr);
%     hold on
%     ys=repmat(kron(stats_p_r.ceiling',[1;1]),1,numel(models));
%     tempx=1:length(models);
%     bw=get(bh,'barWidth');
%     xs=[tempx+0.5*bw; tempx-0.5*bw; tempx-0.5*bw; tempx+0.5*bw];
%     patch(xs,ys,[.7 .7 .7],'facealpha',0.3,'edgecolor','none')
%     [jh, jt, ci]=ttest(stats_p_r.candRelatedness_r);
%     eh=errorbar(tempx,meanr,meanr-ci(1,:),ci(2,:)-meanr,'.');
%     set(gca,'xtickLabel',stats_p_r.orderedCandidateRDMnames)
%     xtickangle(90)
%     xlabel('Models');
%     ylabel(sprintf('Correlation with %s RDM',userOptions.maskNames{roiIndex}),'interpreter','none');
%     print(strcat(userOptions.rootPath,sprintf('/stats_modelRDMs_%s',userOptions.maskNames{roiIndex})),'-dpdf');
% end
% 
% 
% 
% %% compute the thresholds and display
% thresh_uncorr = 0.05;
% nTests = nCond*(nCond-1)/2;
% thresh_fdr_t = FDRthreshold(p_t,thresh_uncorr);
% thresh_fdr_sr = FDRthreshold(p_sr,thresh_uncorr);
% thresh_bnf = thresh_uncorr/nTests;
% selectPlot(5);
% subplot(231);image_thr(p_sr,thresh_uncorr)
% axis square off;
% title('\bf SignRank p < 0.05 (uncorr.)')
% 
% subplot(232);image_thr(p_sr,thresh_fdr_sr)
% axis square off;
% title('\bf SignRank p < 0.05 (FDR)')
% 
% subplot(233);image_thr(p_sr,thresh_bnf)
% axis square off;
% title('\bf SignRank p < 0.05 (Bonferroni)')
% 
% subplot(234);image_thr(p_t,thresh_uncorr)
% axis square off;
% title('\bf Ttest p < 0.05 (uncorr.)')
% 
% subplot(235);image_thr(p_t,thresh_fdr_t)
% axis square off;
% title('\bf Ttest p < 0.05 (FDR)')
% 
% subplot(236);image_thr(p_t,thresh_bnf)
% axis square off;
% title('\bf Ttest p < 0.05 (Bonferroni)')
% 
% % addHeading('random effect analysis, subjects as random effects')
% handleCurrentFigure([userOptions.rootPath,filesep,'LDAtRDM_subjectRFX'],userOptions);
% 
% % return
% 
% 
% 
