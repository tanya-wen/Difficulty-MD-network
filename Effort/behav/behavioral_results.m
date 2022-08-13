clear all; close all; clc;

%% prepare to load  and store data
addpath(genpath('G:/Effort'))
behav_dir = 'G:/Effort/behav';
addpath(genpath('G:/software'));


sub_code = {'s01','s02','s03','s04','s05','s06','nan','s08','s09','s10','s11','s12','s13','s14','s15','s16','nan',...
    's18','s19','s20','nan','nan','s23','s24','s25','s26','s27','s28','s29','s30','s31'};

sub_num = [1,2,3,4,5,6,8,9,10,11,12,13,14,15,16,18,19,20,23,24,25,26,27,28,29,30,31];

nsubj = numel(sub_num);
bad_subj_list = [];
subj_ind = 1;

%% loop through subjects and get data
for sub = 1:nsubj
    
    subject_is_good = 1;

    % see if subject is good
    for run = 1:5
        data_name = dir(fullfile(behav_dir, sprintf('%s',sub_code{sub_num(sub)}), sprintf('sub_%02d_run%d_*.mat',sub_num(sub), run)));
        data_orig = load(fullfile(behav_dir, sprintf('%s',sub_code{sub_num(sub)}), data_name.name));
        subject_acc(sub,run) = mean(data_orig.variables.response_acc);
    end
    
    % mark bad subjects
    if any(subject_acc(sub,:) < 0.7)
        bad_subj_list = [bad_subj_list, sub];
        subject_is_good = 0;
    end

    % load data from each run of each subject
    while subject_is_good
        for run = 1:5
            
            data_name = dir(fullfile(behav_dir, sprintf('%s',sub_code{sub_num(sub)}), sprintf('sub_%02d_run%d_*.mat',sub_num(sub), run)));
            data_orig = load(fullfile(behav_dir, sprintf('%s',sub_code{sub_num(sub)}), data_name.name));
            data = data_orig.variables;
            
            % response time
            acc_ind = find(data.response_acc == 1);
            response_time = data.response_time(acc_ind);
            [group, id] = findgroups(data.seq_order(acc_ind));
            func = @(x) median(x);
            rt_median(subj_ind,run,:) = splitapply(func, response_time, group);
            
            % accuracy
            response_acc = data.response_acc;
            [group, id] = findgroups(data.seq_order);
            func = @(x) mean(x);
            acc_mean(subj_ind,run,:) = splitapply(func, response_acc, group);
            
        end
        subj_ind = subj_ind + 1;
        break
    end
    

end


fig_path = 'G:/Effort/behav';
%% reaction time

xx = 1:6;
figure(1); hold on
set(gcf, 'Position',  [0, 0, 900, 600])
bar(xx,squeeze(mean(mean(rt_median,2),1)),'FaceColor',[200, 200, 200]/255);
errorbar(xx,squeeze(mean(mean(rt_median,2),1)),squeeze(std(mean(rt_median,2),1))/sqrt(subj_ind-1), 'k.')
xticks(xx)
xticklabels({'least', 'intermediate', 'most', 'least', 'intermediate', 'most'})
ylabel('reaction time (s)')
xlabel('difficulty level')
ax = gca;
ax.FontSize = 16;
ax.XLim = [0 7];
ax.YLim = [0.5, 4.5];
set(gcf,'color','w');
set(gca,'box','off')
print(gcf,fullfile(fig_path,'behav_RT.eps'),'-depsc2','-painters');
comparisons_between_bars(xx, squeeze(mean(rt_median,2)))

%% accuracy

xx = 1:6;
figure(2); hold on
set(gcf, 'Position',  [0, 0, 900, 600])
bar(xx,squeeze(mean(mean(acc_mean,2),1)),'FaceColor',[200, 200, 200]/255);
errorbar(xx,squeeze(mean(mean(acc_mean,2),1)),squeeze(std(mean(acc_mean,2),1))/sqrt(subj_ind-1), 'k.')

xticks(xx)
xticklabels({'low', 'medium', 'high', 'low', 'medium', 'high'})
ylabel('accuracy')
xlabel('difficulty level')
ax = gca;
ax.FontSize = 16;
ax.XLim = [0 7];
ax.YLim = [0.65, 1];
set(gcf,'color','w');
set(gca,'box','off')
print(gcf,fullfile(fig_path,'behav_ACC.eps'),'-depsc2','-painters');
comparisons_between_bars(xx, squeeze(mean(acc_mean,2)))
