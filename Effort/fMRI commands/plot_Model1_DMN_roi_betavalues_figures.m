clear all; close all; clc; dbstop if error
% plot ROI beta values

% results folder
resultsfolder = '/media/tw260/X6/Effort/analysis/results/ROI_betavalues';
addpath(genpath('/media/tw260/X6/software'));

% resultsfolder = '/media/tw260/X6/Effort/analysis/results/ROI_betavalues';
% addpath(genpath('/media/tw260/X6/software'));

%% Model 1

% specify model
model_name =  'Model1';

% contrasts
con = {'low', 'medium', 'high', 'low', 'medium', 'high'};
ncons = numel(con);

%%% ----- Model1 DMN ROIs stats ----- %%%

% define ROIs
apriori_rois = 'bilateral_DMN';

% load data
load(fullfile(resultsfolder, sprintf('beta_values_%s_%s',model_name,apriori_rois)),'voxel_beta_values');

nsubj = size(voxel_beta_values,1);
ncon = size(voxel_beta_values,2);
nrois = size(voxel_beta_values,3);

pvalues = nan(1,nrois);

roi_cnt = 1;
for roi_ind = 1:nrois
    
    con_cnt = 1;
    for c1 = 1:ncon
        for c2 = 1:ncon
            if c1<c2
                % perform t-test
                [h,pvalues(con_cnt, roi_cnt)] = ttest([voxel_beta_values(:,c1,roi_ind).beta_value], [voxel_beta_values(:,c2,roi_ind).beta_value]);
                con_cnt = con_cnt + 1;
            end
        end
    end
    
    roi_cnt = roi_cnt + 1;
end


%%% ----- correct for multiple comparisons ----- %%%
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(pvalues,0.05);



%%% ----- Model1 DMN ROIs plot ----- %%%

% define ROIs
apriori_rois = 'bilateral_DMN';
roi_color = [1,0,0];

% load data
load(fullfile(resultsfolder, sprintf('beta_values_%s_%s',model_name,apriori_rois)),'voxel_beta_values');

nsubj = size(voxel_beta_values,1);
ncon = size(voxel_beta_values,2);
nrois = size(voxel_beta_values,3);

roi_cnt = 1;
sub_activation = [];
sub_activation_3 = [];
sub_activation_4 = [];
for roi_ind = 1:nrois
    
    for con_ind = 1:ncon
        % get mean and se
        activation(con_ind, roi_ind) = nanmean([voxel_beta_values(:,con_ind,roi_ind).beta_value]);
        stderror(con_ind,roi_ind) = nanstd([voxel_beta_values(:,con_ind,roi_ind).beta_value])/sqrt(nsubj);
        
        sub_activation = [sub_activation, [voxel_beta_values(:,con_ind,roi_ind).beta_value]'];
        
        % we specifically want to look at level 3 vs. level 4
        if con_ind == 3
            sub_activation_3 = [sub_activation_3, [voxel_beta_values(:,con_ind,roi_ind).beta_value]'];
        elseif con_ind == 4
            sub_activation_4 = [sub_activation_4, [voxel_beta_values(:,con_ind,roi_ind).beta_value]'];
        end
    end
    
    
    figure(100+roi_cnt);
    
    bar_input = activation(:,roi_ind);
    errorbar_input = stderror(:,roi_ind);
    bar(bar_input,'FaceColor',roi_color); hold on
    errorbar(bar_input,errorbar_input,'k.');
    ylim([-6,2])
    
    title(strrep(strrep(voxel_beta_values(1,1,roi_ind).roiname,'.nii',''),'_','-'));
    
    set(gcf, 'Position',  [0, 0, 300, 300])
    set(gcf,'color','w');
    ylabel('beta estimates');
    set(gca,'box','off')
    
    xticklabels(con);
    xtickangle(90);
    
    
%     con_cnt = 1;
%     count = 0;
%     for a1 = 1:ncons
%         for a2 = 1:ncons
%             if a1<a2
%                 
%                 ymax = max(bar_input); ymin = min(bar_input);
%                 
%                 if adj_p(con_cnt,roi_cnt) < 0.05
%                     count = count + 1/3*(ymax-ymin);
%                     line([a1,a2],[ymax+(count),ymax+(count)],'Color','k');
%                     if adj_p(con_cnt,roi_cnt) < 0.001
%                         text((a1+a2)/2,ymax+(count), '***','HorizontalAlignment','center');
%                     elseif adj_p(con_cnt,roi_cnt) < 0.01
%                         text((a1+a2)/2,ymax+(count), '**','HorizontalAlignment','center');
%                     else
%                         text((a1+a2)/2,ymax+(count), '*','HorizontalAlignment','center');
%                     end
%                 end
%                 
%                 con_cnt = con_cnt + 1;
%                 xlim([0,ncons+1]);
%             end
%         end
%     end
    print(sprintf('/media/tw260/X6/Effort/analysis/results/ROI_betavalues/%s_%s_%s.eps',model_name,apriori_rois,strrep(voxel_beta_values(1,1,roi_ind).roiname,'.nii','')),'-depsc2','-painters');
    
    roi_cnt = roi_cnt + 1;
end

% ANOVA (difficulty level x ROI)
anova_activation = sub_activation; % (11 ROIs) x (2 contexts) x (3 levels)
roi_names = {'aMPFC','PCC','dMPFC','LTC','TPJ','Temp','vMPFC','pIPL','HF','PHC','Rsp'};
varnames = {};
for roi = 1:11
    for context = {'easy', 'hard'}
        for level = 1:3
            varnames{end+1} = strcat(roi_names{roi},'_',context{1},'_',num2str(level));
        end
    end
end
t = array2table(anova_activation,'VariableNames',varnames);

within = table(repelem(['A','B','C','D','E','F','G','H','I','J','K']',6),repmat(['e','e','e','h','h','h']',11,1), repmat(['L','M','H','L','M','H']',11,1),'VariableNames',{'roi', 'context', 'level'});
rm = fitrm(t,'aMPFC_easy_1-Rsp_hard_3 ~1','WithinDesign', within);
ranovatable = ranova(rm,'WithinModel','roi*context*level');

% for each ROI, compare level 3 vs. level 4
[H,P,CI,STATS] = ttest(sub_activation_3, sub_activation_4);
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(P,0.05);

%%% ----- Model1 DMN network ----- %%%
clear pvalues

% define ROIs
apriori_rois = 'DMN_network';
roi_color = [1,0,0];

% load data
load(fullfile(resultsfolder, sprintf('beta_values_%s_%s',model_name,apriori_rois)),'voxel_beta_values');

nsubj = size(voxel_beta_values,1);
ncon = size(voxel_beta_values,2);
nrois = size(voxel_beta_values,3);

for con_ind = 1:ncon
    % get mean and se
    cond_val(:,con_ind) = [voxel_beta_values(:,con_ind,1).beta_value];
    bar_input(con_ind) = nanmean([voxel_beta_values(:,con_ind,1).beta_value]);
    errorbar_input(con_ind) = nanstd([voxel_beta_values(:,con_ind,1).beta_value])/sqrt(nsubj);

end

figure(1000);

bar(bar_input,'FaceColor',roi_color); hold on
errorbar(bar_input,errorbar_input,'k.');
ylim([-6,2])

title(strrep(strrep(voxel_beta_values(1,1,1).roiname,'.nii',''),'_','-'));

set(gcf, 'Position',  [0, 0, 300, 300])
set(gcf,'color','w');
ylabel('beta estimates');
set(gca,'box','off')

xticklabels(con);
xtickangle(90);

print(sprintf('/media/tw260/X6/Effort/analysis/results/ROI_betavalues/%s_%s_%s.eps',model_name,apriori_rois,strrep(voxel_beta_values(1,1,1).roiname,'.nii','')),'-depsc2','-painters');
comparisons_between_bars(1:6, cond_val)

% ANOVA (difficulty level)
anova_activation = cond_val; % (6 levels) 
varnames = {'easy1','easy2','easy3','hard1','hard2','hard3'};

t = array2table(anova_activation,'VariableNames',varnames);

within = table(['e','e','e','h','h','h']', ['L','M','H','L','M','H']', 'VariableNames',{'context', 'level'});
rm = fitrm(t,'easy1-hard3 ~1','WithinDesign', within);
ranovatable = ranova(rm,'WithinModel','context*level');

    
% we specifically want to look at level 3 vs. level 4
[H,P,CI,STATS] = ttest(cond_val(:,3), cond_val(:,4));

