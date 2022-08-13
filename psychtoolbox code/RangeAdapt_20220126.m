% Each run requires 518 seconds + 2 extra (beginning) + 6 extra (end)

% setup psychtoolbox
% addpath('D:\Programs\MATLAB\PsychToolbox\3.0.16');
% run('D:\Programs\MATLAB\PsychToolbox\3.0.16\SetupPsychtoolbox.m')

clear all; close all; clc; dbstop if error
% to quite psychtoolbox screen in Mac: control+C, command+tab, sca

addpath(genpath('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code'));
% addpath(genpath('//Munin/Users/tw260/Desktop/fMRI'));

%% input subject information
prompt = {'Enter subject ID', 'Enter run number'};
defaults = {'01', '1'};
answer = inputdlg(prompt, 'Experimental Setup Information', 1, defaults);
[SubjID, RunID] = deal(answer{:});
c = clock; %Current date and time as date vector. [year month day hour minute seconds]
time =strcat(num2str(c(1)),'_',num2str(c(2)),'_',num2str(c(3)),'_',num2str(c(4)),'_',num2str(c(5))); %makes unique filename
rand('seed', str2num(SubjID)*str2num(RunID));


%% Set screen parameters
AssertOpenGL;
Screen('Preference', 'SkipSyncTests', 1);
screens = Screen('Screens');
whichscreen = max(screens);
[windowPtr, rect] = Screen('OpenWindow',whichscreen,[255 255 255]);
Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Priority(MaxPriority(windowPtr));
FontSize = Screen(windowPtr,'TextSize',28);
FontName = Screen(windowPtr,'TextFont','Arial');
HideCursor;
ListenChar(2);

KbName('UnifyKeyNames');
ans_left = KbName('1!'); 
ans_mid = KbName('2@');
ans_right = KbName('3#');
spacebar = KbName('space');
trigger = KbName('s');

%% create sequence order

[variables, switchtype] = create_trials();
ntrials = numel(variables.seq_order);

% prepare jitters [2.5, 4, 5.5]
jitter_list = shuffle([4, repmat([2.5, 4, 5.5], 1, 12)]);


%% load images
nrepetitions_per_level = 6; 

%%% cues %%%
blue_doors = 'C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/blue_doors.png';
red_doors = 'C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/red_doors.png';

cue_list = {blue_doors, red_doors};
if mod(str2double(SubjID),2) == 0
    which_cue = [1,2];
elseif mod(str2double(SubjID),2) == 1
    which_cue = [2,1];
end
easy_cue = imread(cue_list{which_cue(1)});
hard_cue = imread(cue_list{which_cue(2)});

%%% choice doors %%%
if contains(cue_list{which_cue(1)},'blue') % if blue is easy
    easy_door_left = imread('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/blue_door_left.png');
    easy_door_mid = imread('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/blue_door_mid.png');
    easy_door_right = imread('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/blue_door_right.png');
    hard_door_left = imread('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/red_door_left.png');
    hard_door_mid = imread('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/red_door_mid.png');
    hard_door_right = imread('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/red_door_right.png');
elseif contains(cue_list{which_cue(1)},'red') % if red is easy
    hard_door_left = imread('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/blue_door_left.png');
    hard_door_mid = imread('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/blue_door_mid.png');
    hard_door_right = imread('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/blue_door_right.png');
    easy_door_left = imread('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/red_door_left.png');
    easy_door_mid = imread('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/red_door_mid.png');
    easy_door_right = imread('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/stimuli/red_door_right.png');
end

stim_width = 1100;
stim_height = 620;

stimPos = [rect(3)/2 - stim_width/2, rect(4)/2 - stim_height/2, rect(3)/2 + stim_width/2, rect(4)/2 + stim_height/2];



%% run experiment
RestrictKeysForKbCheck([trigger]);
DrawFormattedText(windowPtr,'Wait for experimenter to begin','center','center',[0,0,0]);
Screen('Flip',windowPtr);
% wait for keypress to start exp
keyisdown = 0;
while ~keyisdown
    [keyisdown,secs,keycode] = KbCheck;
end
count = 1;
while count < 6 % ten second dummies
    DrawFormattedText(windowPtr,strcat('Starting in...',num2str(6-count)),'center','center',[0,0,0]);
    Screen('Flip',windowPtr);
    WaitSecs(2);
    count = count + 1;
end

% START
RestrictKeysForKbCheck([ans_right ans_mid ans_left]);
starttime = GetSecs;

Screen(windowPtr,'TextSize',28);
DrawFormattedText(windowPtr,'+','center','center',[0,0,0]);
Screen('Flip',windowPtr);
WaitSecs(2);

for trial = 1:ntrials
    
    % present cue
    switch variables.seq_order(trial)
        case {1,2,3}
            cue_MakeTexture = Screen('MakeTexture', windowPtr, easy_cue);
        case {4,5,6}
            cue_MakeTexture = Screen('MakeTexture', windowPtr, hard_cue);
    end
    Screen('DrawTexture', windowPtr, cue_MakeTexture,[],stimPos);
    Screen(windowPtr,'TextSize',48);
    DrawFormattedText(windowPtr,'Choose a door to enter','center',150,[0,0,0]);
    cuetime = Screen('Flip',windowPtr);
    variables.cueonset(trial) = cuetime-starttime;

    variables.choice_time(trial) = NaN;
    % get subject response
    keyisdown = 0;
    while ~keyisdown
        [keyisdown,secs,keycode] = KbCheck;
        if keycode(ans_left) == 1 || keycode(ans_mid) == 1 || keycode(ans_right) == 1
            variables.choice_time(trial) = GetSecs-cuetime;
            if keycode(ans_left) == 1
                variables.choice{trial} = 'left';
            elseif keycode(ans_mid) == 1
                variables.choice{trial} = 'mid';
            elseif keycode(ans_right) == 1
                variables.choice{trial} = 'right';
            end
            keyisdown = 1;
        elseif GetSecs - cuetime > 2.5
            keyisdown = 1;
            variables.choice_time(trial) = 2.5;
            rand_choice = randperm(3);
            choices = {'right','mid','left'};
            variables.choice{trial} = choices{rand_choice};
        end
    end

    % highlight the door chosen
    switch variables.seq_order(trial)
        case {1,2,3}
            switch variables.choice{trial}
                case 'left'
                    choice_MakeTexture = Screen('MakeTexture', windowPtr, easy_door_left);
                case 'mid'
                    choice_MakeTexture = Screen('MakeTexture', windowPtr, easy_door_mid);
                case 'right'
                    choice_MakeTexture = Screen('MakeTexture', windowPtr, easy_door_right);
            end
        case {4,5,6}
            switch variables.choice{trial}
                case 'left'
                    choice_MakeTexture = Screen('MakeTexture', windowPtr, hard_door_left);
                case 'mid'
                    choice_MakeTexture = Screen('MakeTexture', windowPtr, hard_door_mid);
                case 'right'
                    choice_MakeTexture = Screen('MakeTexture', windowPtr, hard_door_right);
            end
    end
    Screen('DrawTexture', windowPtr, choice_MakeTexture,[],stimPos);
    DrawFormattedText(windowPtr,'Chosen!','center',150,[0,0,0]);
    Screen('Flip',windowPtr);
    addtime = 3 - variables.choice_time(trial); % guarantee at least 1 s show choice before fixation
    WaitSecs(0.5 + addtime);

    % fixation
    Screen(windowPtr,'TextSize',28);
    DrawFormattedText(windowPtr,'+','center','center',[0,0,0]);
    Screen('Flip',windowPtr);
    WaitSecs(1.5); % 1.5 second fixation

    % prepare to record response
    variables.trialonset(trial) = NaN;
    variables.response_time(trial) = NaN;
    variables.response(trial) = NaN;
    variables.response_acc(trial) = NaN;
    
    % display math questions:
    [question, answer, choices] = question_generator(variables.seq_order(trial));
    variables.question(trial) = question;
    variables.answer(trial) = answer;
    variables.choices{trial} = choices;

    Screen(windowPtr,'TextSize',78);
    DrawFormattedText(windowPtr,char(question),'center',rect(4)/2 - 100,[0,0,0]); % question
    DrawFormattedText(windowPtr,num2str(choices(1)),rect(3)/2 - 400, rect(4)/2 + 200,[0,0,0]); % left choice
    DrawFormattedText(windowPtr,num2str(choices(2)),'center', rect(4)/2 + 200,[0,0,0]); % mid choice
    DrawFormattedText(windowPtr,num2str(choices(3)),rect(3)/2 + 350', rect(4)/2 + 200,[0,0,0]); % right choice
    Screen(windowPtr,'TextSize',28);

    displaytime = Screen('Flip',windowPtr);
    variables.trialonset(trial) = displaytime-starttime;
    
    % get subject response
    keyisdown = 0;
    while ~keyisdown
        [keyisdown,secs,keycode] = KbCheck;
        if keycode(ans_left) == 1 || keycode(ans_mid) == 1 || keycode(ans_right) == 1
            variables.response_time(trial) = GetSecs-displaytime; 
            if keycode(ans_left) == 1
                variables.response(trial) = choices(1);
            elseif keycode(ans_mid) == 1
                variables.response(trial) = choices(2);
            elseif keycode(ans_right) == 1
                variables.response(trial) = choices(3);
            end
            if isequaln(variables.response(trial),variables.answer(trial))
                variables.response_acc(trial) = 1;
            else  variables.response_acc(trial) = 0;
            end
            keyisdown = 1;
        elseif GetSecs - displaytime > 6
            keyisdown = 1;
            variables.response_time(trial) = 6;
            variables.response_acc(trial) = 0;
        end
    end
    
    DrawFormattedText(windowPtr,'+','center','center',[0,0,0]);
    Screen('Flip',windowPtr);
    addtime = 6 - variables.response_time(trial);
    WaitSecs(3 + addtime);
    
end

Screen(windowPtr,'TextSize',28);
DrawFormattedText(windowPtr,'+','center','center',[0,0,0]);
Screen('Flip',windowPtr);
WaitSecs(6);
runtime = GetSecs - starttime;

save(strcat('C:\Users\tw260\Desktop\psychtoolbox code\psychtoolbox code/data/','sub_',SubjID,'_run',RunID,'_',time,'.mat'));

%% feedback on accuracy
WaitSecs(5)

Screen(windowPtr,'TextSize',78);
DrawFormattedText(windowPtr,sprintf('accuracy %2.2f %% \n\n press spacebar to exit',100*nansum(variables.response_acc)/ntrials),'center','center',[0,0,0]);
Screen('Flip',windowPtr);
RestrictKeysForKbCheck([spacebar]);
keyisdown = 0;
while ~keyisdown
    [keyisdown,secs,keycode] = KbCheck;
end

%% Close window
Screen('CloseAll');
ShowCursor;
ListenChar(0);
Priority(0);
