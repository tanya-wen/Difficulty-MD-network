function [variables, switchtype] = create_trials()

%% counterbalance

% ntasks * ntasks matrix where row number corresponds to the previous
% task number and column number the current task number. Matrix values
% show the amount of each task transition left.
test_mat = ones(6,6);

nlevels = 6;
fragment = 0;
clear temp
while sum(sum(test_mat))>0 % while there are still numbers of task transitions left
    row = randi(nlevels); % start by chosing a random row
    while sum(test_mat(row,:))==0 % if row chosen is empty (vaules sum to 0) chose again
        row = randi(nlevels);
    end
    fragment = fragment + 1; % add 1 to the fragment count for each time new loop
    count = 0;
    while sum(test_mat(row,:))>0 % while there are transitions left from the previous task
        count = count + 1;
        col = randi(nlevels); % chose the column number
        while test_mat(row,col)==0 % If there aren't any transitions left between that row and coulmn then chose again
            col=randi(nlevels);
        end
        test_mat(row,col) = test_mat(row,col) - 1; % Take 1 away from the chosen transition value
        temp(fragment,count) = row; % add the previous task number to the temporary variable of run order fragments
        row = col; % make the current task number the previous task number
    end
    temp(fragment,count+1) = col; % after the fragment ends add the current task number to the end of the run order fragment
end

% Combine the run-order fragments such that numbers of each sequence-change
% conditions aren't disrupted. By insterting them after the same number the
% fragment begins and ends with
seq_order = temp(1,:);
seq_order = seq_order(seq_order~=0);
count = 1;
while size(temp,1)>count
    count = count + 1;
    lead = temp(count,1);
    point = datasample(find(seq_order==lead),1);
    insert = temp(count,2:end);
    insert = insert(insert~=0);
    seq_order = [seq_order(1:point) insert seq_order(point+1:end)];
end

variables.seq_order = seq_order;

%% obtain switch type
for i = 2:numel(variables.seq_order) % record the previous task and current task
    
    if variables.seq_order(i-1) == 1 
        preceding_level{i-1} = '1';
        preceding_context{i-1} = 'easy';
    elseif variables.seq_order(i-1) == 2 
        preceding_level{i-1} = '2';
        preceding_context{i-1} = 'easy';
    elseif variables.seq_order(i-1) == 3 
        preceding_level{i-1} = '3';
        preceding_context{i-1} = 'easy'; 
    elseif variables.seq_order(i-1) == 4
        preceding_level{i-1} = '4';
        preceding_context{i-1} = 'hard';
    elseif variables.seq_order(i-1) == 5
        preceding_level{i-1} = '5';
        preceding_context{i-1} = 'hard';
    elseif variables.seq_order(i-1) == 6
        preceding_level{i-1} = '6';
        preceding_context{i-1} = 'hard';
    end
    
    if variables.seq_order(i) == 1 
        current_level{i} = '1';
        current_context{i} = 'easy';
    elseif variables.seq_order(i) == 2 
        current_level{i} = '2';
        current_context{i} = 'easy';
    elseif variables.seq_order(i) == 3 
        current_level{i} = '3';
        current_context{i} = 'easy';
    elseif variables.seq_order(i) == 4
        current_level{i} = '4';
        current_context{i} = 'hard';
    elseif variables.seq_order(i) == 5
        current_level{i} = '5';
        current_context{i} = 'hard';
    elseif variables.seq_order(i) == 6
        current_level{i} = '6';
        current_context{i} = 'hard';
    end
    
end

for i = 2:numel(current_level)
    
    if i == 1
        switchtype.switch_context{i} = '';
        switchtype.switch_level{i} = '';
        switchtype.switch_condition{i} = '';
    else
        
        switchtype.switch_category{i} = sprintf('%s-%s',preceding_context{i-1},current_context{i});
        switchtype.switch_level{i} = sprintf('%s-%s',preceding_level{i-1},current_level{i});
        
        if strcmp(preceding_level{i-1},current_level{i}) == 1
            switchtype.switch_condition{i} = 'stay';
        else
            switchtype.switch_condition{i} = 'switch';
        end
    end
    
end
switchtype.switch_condition{1} = 'x';


end