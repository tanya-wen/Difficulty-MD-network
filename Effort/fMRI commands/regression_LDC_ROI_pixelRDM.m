%function regression_LDC_ROI()
clear all; close all; clc;

dbstop if error

network = 'DMN';

network_roi = 0;
if strcmp(network,'MD')==1
    roi_names = {'AI','aMFG','preSMA','FEF','IPS','mMFG','pMFG'};
elseif strcmp(network,'DMN')==1
    roi_names = {'aMPFC','PCC','dMPFC','LTC','TPJ','Temp','vMPFC','pIPL','HF','PHC','Rsp'};
elseif strcmp(network,'reward')==1
    roi_names = {'ACC','AI','striatum','thalamus'};
elseif strcmp(network,'MDnetwork')==1
    roi_names = 'MDnetwork';
    network_roi = 1;
    network = 'MD';
elseif strcmp(network,'DMNnetwork')==1
    network_roi = 1;
    roi_names = 'DMNnetwork';
    network = 'DMN';
end

addpath(genpath('/media/tw260/X6/Effort'));
addpath(genpath('/media/tw260/X6/software'));
fig_path = sprintf('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/%s',network);


addpath(genpath(strcat('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance/',sprintf('%s',network))));
pth = fullfile('/media/tw260/X6/Effort/analysis/rsa_analysis/LDC_distance',sprintf('%s',network),'s31');
load(fullfile(pth,'RDMs','rsa_LDC_RDMs.mat'))
load(fullfile(pth,'RDMs','rsa_LDC_Models.mat'))
load(fullfile(pth,'Details','rsa_LDC_fMRIMaskPreparation_Details.mat'))

subject_list = {'s01','s02','s03','s04','s05','s06','s08','s09','s10','s11','s12','s13','s14','s15','s16','s18','s19','s20','s23','s24','s25','s26','s27','s29','s31'};
nsub = numel(subject_list);

if network_roi == 1 && strcmp(network,'MD')==1
    roi_ind = 8;
elseif network_roi == 1 && strcmp(network,'DMN')==1
    roi_ind = 12;
elseif strcmp(network,'MD')==1
    roi_ind = 1:7;
elseif strcmp(network,'DMN')==1
    roi_ind = 1:11;
elseif strcmp(network,'reward')==1
    roi_ind = 1:4;
end

new_roinames = userOptions.maskNames;
new_roinames=strrep(new_roinames,'_','-');

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

%% model fits per subject and roi
model_coefficients=nan(nsub,length(roi_ind), 4);
model_pvals=nan(length(roi_ind),4);

for roi = roi_ind
    
    for sub = 1:nsub
        regression_table = table(tiedrank(vectorizeRDM(RDMs(roi,sub).RDM))',...
            tiedrank(vectorizeRDM(Models(3).RDM))',...
            tiedrank(vectorizeRDM(Models(2).RDM))',...
            tiedrank(vectorizeRDM(subjRDM(sub).pixelRDM))',...
            'VariableNames',{'data','absolute','relative','pixel'});
        
        %%% fit model
        Model = fitlm(regression_table,'data ~ absolute + relative + pixel');
        % Model = fitlm(regression_table,'linear','responsevar','data','RobustOpts',struct('RobustWgtFun','fair'));
        % 'fair' was designed to have low sensitivity to tuning parameter
        
        model_coefficients(sub,roi,1:Model.NumCoefficients) = [Model.Coefficients.Estimate];
        
    end % next subject
    

    %%%% plot coefficents from model fit
    [~, model_pvals(roi,1:size(model_coefficients,3)), ~, stats(roi)] = ttest(squeeze(model_coefficients(:,roi,:)),0,'tail','right');
    [~, model_pvals_2vs3(roi), ~, stats_2vs3(roi)] = ttest(squeeze(model_coefficients(:,roi,2)),squeeze(model_coefficients(:,roi,3)),'tail','right');
    [~, model_pvals_2vs4(roi), ~, stats_2vs4(roi)] = ttest(squeeze(model_coefficients(:,roi,2)),squeeze(model_coefficients(:,roi,4)),'tail','right');

    
    figure(1000+roi); hold on;
    set(gcf, 'Position',  [0, 0, 300, 300])
    y=squeeze(mean(model_coefficients(:,roi,2:end),1));
    se=squeeze(std(model_coefficients(:,roi,2:end),[],1))/sqrt(nsub);
    tempx=1:3;
    xticks(tempx)
    bh=bar(tempx,y,'FaceColor',[1,0,0]);
    eh=errorbar(tempx,y,se,'.k');

    title(sprintf('%s',userOptions.maskNames{roi}));
   
    ylim([-0.1,0.8]);
    set(gca,'xtickLabel',{sprintf('context\\newlineindependent'), sprintf('context\\newlinedependent'), sprintf('pixelwise\\newlinedissimilarity')})
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',6)
    xlabel('models');
    ylabel('beta coefficients','interpreter','none');
    set(gcf,'color','w');
    set(gca,'box','off')
    print(strcat(fig_path,sprintf('/regression_modelRDMs_%s',userOptions.maskNames{roi})),'-dpdf');
    pause(2)

end % next roi



% djm: FDR correction per information type; this is probably best but
% could consider correcting across everything at once. Also, note that
% adjusted p-values can be selected from empirical p-values, so ties can be
% introduced.
% Done separately for network and ROI analyses within each network.

% within network
[~, ~, ~, adj_p2(roi_ind,:)]=fdr_bh(model_pvals(roi_ind,2),0.05);
[~, ~, ~, adj_p3(roi_ind,:)]=fdr_bh(model_pvals(roi_ind,3),0.05);
[~, ~, ~, adj_p4(roi_ind,:)]=fdr_bh(model_pvals(roi_ind,4),0.05);


[~, ~, ~, adj_p_2vs3(roi_ind)]=fdr_bh(model_pvals_2vs3(roi_ind),0.05);
[~, ~, ~, adj_p_3vs4(roi_ind)]=fdr_bh(model_pvals_2vs4(roi_ind),0.05);
%return

