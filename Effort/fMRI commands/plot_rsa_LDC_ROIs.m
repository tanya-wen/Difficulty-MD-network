%function regression_LDC_ROI()
clear all; close all; clc;

dbstop if error

network = 'reward';

if strcmp(network,'MD')==1
    roi_names = {'AI','aMFG','preSMA','FEF','IPS','mMFG','pMFG','MDnetwork'};
elseif strcmp(network,'DMN')==1
    roi_names = {'aMPFC','PCC','dMPFC','LTC','TPJ','Temp','vMPFC','pIPL','HF','PHC','Rsp'};
elseif strcmp(network,'reward')==1
    roi_names = {'ACC','AI','striatum','thalamus'};
end

addpath(genpath('/media/tw260/X6/Effort'));
addpath(genpath('/media/tw260/X6/software'));


addpath(genpath(strcat('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/',sprintf('%s',network))));
pth = '/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/MD/s31';
load(fullfile(pth,'RDMs','rsa_LDC_RDMs.mat'))
load(fullfile(pth,'RDMs','rsa_LDC_Models.mat'))
load(fullfile(pth,'Details','rsa_LDC_fMRIMaskPreparation_Details.mat'))

subject_list = {'s01','s02','s03','s04','s05','s06','s08','s09','s10','s11','s12','s13','s14','s15','s16','s18','s19','s20','s23','s24','s25','s26','s27','s29','s31'};
nsub = numel(subject_list);

if strcmp(network,'MD')==1
    roi_ind = 1:8;
elseif strcmp(network,'DMN')==1
    roi_ind = 1:11;
elseif strcmp(network,'reward')==1
    roi_ind = 1:4;
end

new_roinames = userOptions.maskNames;
new_roinames=strrep(new_roinames,'_','-');



%% model fits per subject and roi
fig_path = '/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/MD';

model_coefficients=nan(nsub,length(roi_ind), 4);
model_pvals=nan(length(roi_ind),4);

for roiIndex= 1:numel(userOptions.maskNames)
    userOptions.figureIndex = [1 101]; % for stats

    stats_p_r=compareRefRDM2candRDMs_djm(RDMs(roiIndex,:), num2cell(Models(2:3)), userOptions);

    
    figure(1000+roiIndex); 
    set(gcf, 'Position',  [0, 0, 300, 300])
    meanr=mean(stats_p_r.candRelatedness_r);
    errorr = std(stats_p_r.candRelatedness_r)/sqrt(length(stats_p_r.candRelatedness_r));
    bh=bar(meanr,'FaceColor',[1,0,0]);
    hold on
    title(sprintf('%s',userOptions.maskNames{roiIndex}));
    ys=repmat(kron(stats_p_r.ceiling',[1;1]),1,numel(Models(2:3)));
    tempx=1:length(Models(2:3));
    bw=get(bh,'barWidth');
    xs=[tempx+0.5*bw; tempx-0.5*bw; tempx-0.5*bw; tempx+0.5*bw];
    patch(xs,ys,[.7 .7 .7],'facealpha',0.3,'edgecolor','none')
    [jh, p, ci, stats]=ttest(stats_p_r.candRelatedness_r);
    jp1(roiIndex) = p(1);
    jp2(roiIndex) = p(2);
    jt1(roiIndex) = stats.tstat(1);
    jt2(roiIndex) = stats.tstat(2);
    [kh, p, ~, stats]=ttest(stats_p_r.candRelatedness_r(:,1),stats_p_r.candRelatedness_r(:,2));
    kp(roiIndex) = p(1);
    kt(roiIndex) = stats.tstat(1);
    eh=errorbar(tempx,meanr,errorr,'.k');
    ylim([-0.2,1]);
    set(gca,'xtickLabel',{sprintf('context\\newlineindependent'), sprintf('context\\newlinedependent')})
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',6)
    xlabel('models');
    ylabel(sprintf('Correlation with %s RDM',userOptions.maskNames{roiIndex}),'interpreter','none');
    set(gcf,'color','w');
    set(gca,'box','off')
    print(strcat(fig_path,sprintf('/stats_modelRDMs_%s',userOptions.maskNames{roiIndex})),'-dpdf');
end

[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(jp1(1:7),0.05);
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(jp2(1:7),0.05);
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(kp(1:7),0.05);
% %% compute the thresholds and display
% nCond=length(userOptions.conditionLabels);
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
% %return

