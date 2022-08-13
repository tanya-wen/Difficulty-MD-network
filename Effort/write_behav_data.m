% write behavioral data into .tsv file

% *Note: fMRIprep uses middle slice as reference, thus shifting data by 1/2 TRs (https://github.com/nipreps/fmriprep/issues/2477)

clear all; clc; dbstop if error;
addpath(genpath('/media/tw260/X6/Effort'))
%% convert Duke BIAC output to BIDS format
behav_dir = '/media/tw260/X6/Effort/behav';
bids_dir = '/media/tw260/X6/Effort/fMRI_BIDS';

% sub_folder = {'s01_03152022','s02_03292022','s03_04042022','s04_04052022','nan','s06_04082022'};
sub_code = {'s01','s02','s03','s04','s05','s06','nan','s08','s09','s10','s11','s12','s13','s14','s15','s16','nan',...
    's18','s19','s20','nan','nan','s23','s24','s25','s26','s27','nan','s29','nan','s31'};

sub_output = sub_code;

sub_num = [1,2,3,4,5,6,8,9,10,11,12,13,14,15,16,18,19,20,23,24,25,26,27,29,31];


%% write behavioral data (Tree Task)
TRshift = 1; % (https://github.com/nipreps/fmriprep/issues/2477)
for sub = 1:numel(sub_num)
    
    for run = 1:5
        data_name = dir(fullfile(behav_dir, sprintf('%s',sub_code{sub_num(sub)}), sprintf('sub_%02d_run%d_*.mat',sub_num(sub), run)));
        data_orig = load(fullfile(behav_dir, sprintf('%s',sub_code{sub_num(sub)}), data_name.name));

        %% Model 1: model each level of difficulty (epoch)
        fid = fopen(sprintf('/media/tw260/X6/Effort/behav/%s/Effort_run-%02d_events_Model1.csv',sub_code{sub_num(sub)},run),'w');
        fprintf(fid,'onset,duration,weight,trial_type\n');
        
        if ~any(data_orig.variables.response_acc==0)
            fprintf(fid,'%.2f,%.2f,%d,%s\n',0,0,0,'error');
        end

        seq_order = data_orig.variables.seq_order;
        for trial = 1:data_orig.ntrials
            if seq_order(trial) <= 3
                cue = 'cue-easy';
            elseif seq_order(trial) > 3
                cue = 'cue-hard';
            end
            cueonset = data_orig.variables.cueonset(trial) + TRshift;
            duration = 3.5;
            weight = 1;
            fprintf(fid,'%.2f,%.2f,%d,%s\n',cueonset,duration,weight,cue);
            
            trialonset = data_orig.variables.trialonset(trial) + TRshift;
            duration = data_orig.variables.response_time(trial);
            weight = 1;
            if data_orig.variables.response_acc(trial) == 0 && trial ~= 1
                fprintf(fid,'%.2f,%.2f,%d,%s\n',trialonset,duration,weight,'error');
            else
                fprintf(fid,'%.2f,%.2f,%d,%s\n',trialonset,duration,weight,sprintf('level%d',seq_order(trial)));
            end
        end
            
        fid = fclose(fid);
        
        
        %% Model 2: model switch and stay
        fid = fopen(sprintf('/media/tw260/X6/Effort/behav/%s/Effort_run-%02d_events_Model2.csv',sub_code{sub_num(sub)},run),'w');
        fprintf(fid,'onset,duration,weight,trial_type\n');
        
        if ~any(data_orig.variables.response_acc==0)
            fprintf(fid,'%.2f,%.2f,%d,%s\n',0,0,0,'error');
        end
        
        seq_order = data_orig.variables.seq_order;
        
        for trial = 1:data_orig.ntrials
            if trial == 1
                cue = 'cue-first';
            elseif seq_order(trial-1) <= 3 && seq_order(trial) <= 3
                cue = 'cue-easy_easy';
            elseif seq_order(trial-1) > 3 && seq_order(trial) > 3
                cue = 'cue-hard_hard';
            elseif seq_order(trial-1) > seq_order(trial)
                cue = 'cue-hard_easy';
            elseif seq_order(trial-1) < seq_order(trial)
                cue = 'cue-easy_hard';
            end
            cueonset = data_orig.variables.cueonset(trial) + TRshift;
            duration = 3.5;
            weight = 1;
            fprintf(fid,'%.2f,%.2f,%d,%s\n',cueonset,duration,weight,cue);
            
            
            if trial == 1
                trialtype = 'task-first';
            elseif seq_order(trial-1) <= 3 && seq_order(trial) <= 3
                trialtype = 'task-easy_easy';
            elseif seq_order(trial-1) > 3 && seq_order(trial) > 3
                trialtype = 'task-hard_hard';
            elseif seq_order(trial-1) > seq_order(trial)
                trialtype = 'task-hard_easy';
            elseif seq_order(trial-1) < seq_order(trial)
                trialtype = 'task-easy_hard';
            end
            trialonset = data_orig.variables.trialonset(trial) + TRshift;
            duration = data_orig.variables.response_time(trial);
            weight = 1;
            if data_orig.variables.response_acc(trial) == 0 && trial ~= 1
                fprintf(fid,'%.2f,%.2f,%d,%s\n',trialonset,duration,weight,'error');
            else
                fprintf(fid,'%.2f,%.2f,%d,%s\n',trialonset,duration,weight,trialtype);
            end

        end
            
        fid = fclose(fid);
        
    end
    
end

