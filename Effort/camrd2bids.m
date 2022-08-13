% Tanya Wen 2020/05/21
clear all; clc; dbstop if error;
%% convert Duke BIAC output to BIDS format
camrd_dir = 'C:/Users/Tanya Wen/Box/Pro00101414/Effort';
bids_dir = 'F:/Effort/fMRI_BIDS';

sub_folder = {'s01_03152022','s02_03292022','s03_04042022','s04_04052022','s05_04132022','s06_04082022','nan',...
    's08_04142022','s09_04182022','s10_04212022','s11_05062022','s12_05092022','s13_05092022','s14_05092022',...
    's15_05102022','s16_05122022','nan','s18_05162022','s19_05162022','s20_05172022','nan','nan','s23_05312022',...
    's24_06012022','s25_06022022','s26_06082022','s27_06092022','s28_06102022','s29_06132022','s30_06142022','s31_06142022'};
sub_code = {'s01','s02','s03','s04','s05','s06','nan','s08','s09','s10','s11','s12','s13','s14','s15','s16','nan',...
    's18','s19','s20','nan','nan','s23','s24','s25','s26','s27','s28','s29','s30','s31'};

sub_output = sub_code;

sub_num = [28,29,30,31];


%% Make subject folder1
for sub = sub_num
    if ~exist(fullfile(bids_dir,sprintf('sub-%s',sub_output{sub})),'dir')
        mkdir(fullfile(bids_dir,sprintf('sub-%s',sub_output{sub})));
        mkdir(fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'anat'));
        mkdir(fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'func'));
    end
end

%% Anat
for sub = sub_num
    % Prepare the CAMRD filename (get the first T1 for each subject).
    camrdAnatFile = 'anatomical_T1.nii.gz'; %'motvisbreath_anat.nii.gz'; %'anatomical_T1.nii.gz';
    camrdAnatJSON = 'anatomical_T1.json'; %'motvisbreath_anat.json'; %'anatomical_T1.json';
    % Prepare the BIDS filename.
    bidsAnat = sprintf('sub-%s_T1w.nii.gz', sub_output{sub});
    bidsJSON = sprintf('sub-%s_T1w.json', sub_output{sub});
    % Do the copying and renaming of the file into BIDS folder.
    if not(exist(fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'anat'),'dir'))
        mkdir(fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'anat'))
    end
    copyfile(fullfile(camrd_dir,sub_folder{sub},camrdAnatFile),fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'anat',bidsAnat));
    copyfile(fullfile(camrd_dir,sub_folder{sub},camrdAnatJSON),fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'anat',bidsJSON));
end

%% Func
for sub = sub_num
    % Prepare the BIAC filename (get the functional runs for each subject: 4 runs).
    camrdFuncDir = dir(fullfile(camrd_dir,sub_folder{sub}));
    camrdFuncFiles = find(~cellfun(@isempty,regexp({camrdFuncDir.name},'.*run\d\d.nii')));
    camrdFuncFiles = camrdFuncFiles(1:end);
    camrdFuncJSONs = find(~cellfun(@isempty,regexp({camrdFuncDir.name},'.*run\d\d.json')));
    camrdFuncJSONs = camrdFuncJSONs(1:end);
    
        for run = 1:5
            scan = 'effort';
            runNo = run;
            camrdFuncFile = camrdFuncDir(camrdFuncFiles(run)).name;
            camrdFuncJSON = camrdFuncDir(camrdFuncJSONs(run)).name;
            
            % add TaskName to JSON
            jsonfile = jsondecode(fileread(fullfile(camrd_dir,sub_folder{sub},camrdFuncJSON))); %convert JSON file to Matlab
            jsonfile.TaskName = "Effort"; %add TaskName
            jsonfile = jsonencode(jsonfile); %Convert to JSON text
            fid = fopen(fullfile(camrd_dir,sub_folder{sub},camrdFuncJSON), 'w'); % Write to JSON file
            fprintf(fid, '%s', jsonfile);
            fclose(fid);
            
            % Prepare the BIDS filename.
            bidsFunc = sprintf('sub-%s_task-%s_run-%02d_bold.nii.gz', sub_output{sub}, scan, runNo);
            bidsJSON = sprintf('sub-%s_task-%s_run-%02d_bold.json', sub_output{sub}, scan, runNo);

            % Do the copying and renaming of the file into BIDS folder.
            if not(exist(fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'func'),'dir'))
                mkdir(fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'func'))
            end
            copyfile(fullfile(camrd_dir,sub_folder{sub},camrdFuncFile),fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'func',bidsFunc));
            copyfile(fullfile(camrd_dir,sub_folder{sub},camrdFuncJSON),fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'func',bidsJSON));
        end
    
end

%% fmap (pepolar)
for sub = sub_num
    % Prepare the BIAC filename (get the reverse phase encoding fieldmaps for each subject).
    camrdFmapFile = 'Field_Map_P_A.nii.gz';
    camrdFmapJSON = 'Field_Map_P_A.json';
    
    % add IntendedFor to json file
    jsonText = fileread(fullfile(camrd_dir,sub_folder{sub},camrdFmapJSON));
    jsonData = jsondecode(jsonText); 
    jsonData.IntendedFor = {sprintf('func/sub-%s_task-effort_run-01_bold.nii.gz',sub_output{sub}),...
        sprintf('func/sub-%s_task-effort_run-02_bold.nii.gz',sub_output{sub}),...
        sprintf('func/sub-%s_task-effort_run-03_bold.nii.gz',sub_output{sub}),...
        sprintf('func/sub-%s_task-effort_run-04_bold.nii.gz',sub_output{sub}),...
        sprintf('func/sub-%s_task-effort_run-05_bold.nii.gz',sub_output{sub})
        };
    jsonText2 = jsonencode(jsonData); %jsonencode(jsonData,'PrettyPrint',true); Not available in 2019a
    
    % Prepare the BIDS filename.
    bidsFmap = sprintf('sub-%s_dir-%s_epi.nii.gz', sub_output{sub},'PA');
    bidsJSON = sprintf('sub-%s_dir-%s_epi.json', sub_output{sub},'PA');
    % Do the copying and renaming of the file into BIDS folder.
    if not(exist(fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'fmap'),'dir'))
        mkdir(fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'fmap'))
    end
    copyfile(fullfile(camrd_dir,sub_folder{sub},camrdFmapFile),fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'fmap',bidsFmap));
    %copyfile(fullfile(camrd_dir,sub_folder{sub},camrdFmapJSON),fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'fmap',bidsJSON));
    fid = fopen(fullfile(bids_dir,sprintf('sub-%s',sub_output{sub}),'fmap',bidsJSON), 'w');
    fprintf(fid, '%s', jsonText2);
    fclose(fid);
end
