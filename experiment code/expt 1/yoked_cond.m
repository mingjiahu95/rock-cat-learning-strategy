% ---------- Parameters ----------
clear
clc
rng('Shuffle');
pathLocation = [pwd '\helper functions\'];
addpath(genpath(pathLocation));
global n_cat xCenter yCenter ScreenWidth ScreenHeight
cond = 3;
n_blocks = 9;%10
n_cat = 8;%10
total_train_token_per_cat = 6;
total_test_token_per_cat = 6;%10
n_token_per_cat = total_train_token_per_cat + total_test_token_per_cat;
n_train_trial = 16;%20
n_test_trial = 16;%20
textsize_default = 20;
fontStyle = 1;

% ---------- Create Stimuli ----------
rng('Shuffle');
subID = input(' subject # ');
dataLocation = [pwd '\rocksall480\'];

% Create PNG files.
filePattern = sprintf('%s/I_*.png', dataLocation);
FileNames = dir(filePattern);
numberOfFiles = length(FileNames);
rockTokens_filenames = cell(n_cat,n_token_per_cat);
rockTokens = rockTokens_filenames;
for i_file = 1 : numberOfFiles
    i_cat = fix((i_file-1)/n_token_per_cat) + 1;
    i_token = rem(i_file-1,n_token_per_cat) + 1;
    rockTokens_filenames{i_cat,i_token} = FileNames(i_file).name;
    rockTokens{i_cat,i_token} = fullfile(dataLocation, FileNames(i_file).name);
end

% Read in rock grid image
image_filename = [pwd '\input_data\' 'rockgrid_condSC_subj' num2str(subID) '.png'];
if ~exist(image_filename,'file')
    error('Error: Rock Image file is missing for the yoked subject %i', subID);
end

[rockGrid_Array,~,alpha] = imread(image_filename);
rockGrid_Array(:,:,4) = alpha(:,:);

% Read in category and token indices
indices_filename = [pwd '\input_data\' 'rocks_condSC_subj' num2str(subID) '.txt'];
if ~exist(image_filename,'file')
    error('Error: Rock Sequence file is missing for the yoked subject %i', subID);
end

fID = fopen(indices_filename, 'r');
formatSpec = repmat('%7d', [1, 11]);
data = textscan(fID, formatSpec);
cat_indices = data{6};
token_indices = data{7};
fclose(fID);

% ---------- Open Subject File ----------
data_location=[pwd '\data\'];
filename = [data_location 'rocks_condY_subj' num2str(subID) '.txt'];
if ~exist('data','dir')
    mkdir('data');
end
if exist(filename,'file')
    error('Error: the file already exists!');
end
fID = fopen(filename,'wt');

% ---------- Turn on the Experiment Screen ----------
try
    % oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
    % oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
    Screen('Preference', 'SkipSyncTests', 1);
    PsychDefaultSetup(0);
    KbName('UnifyKeyNames');
    ListenChar(2);
    HideCursor;
    screenNumber = max(Screen('Screens'));
    backgroundColor = [255 255 255];
    [window, rect] = PsychImaging('OpenWindow', screenNumber, backgroundColor);
    xCenter = (rect(1) + rect(3))/2;
    yCenter = (rect(2) + rect(4))/2;
    ScreenWidth = rect(3)-rect(1);
    ScreenHeight = rect(4)-rect(2);
    Screen('TextSize', window, textsize_default);
    Screen('TextStyle',window, fontStyle);
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Pre-load rock image files
    rockSet_info = struct();
    rockArrays = cell(n_cat,n_token_per_cat);
    for row = 1:n_cat
        for col = 1:n_token_per_cat
            [rockImage,~,alpha] = imread(rockTokens{row, col});
            rockImage(:,:,4) = alpha(:,:);
            rockArrays{row,col} = rockImage;
        end
    end
    rockSet_info.Name = rockTokens;
    rockSet_info.Array = rockArrays;
    
    % Present training instructions
    trainInstruction(window,rockGrid_Array,'Y');
    
    % start the main experiment
    for iblock = 1:n_blocks
        
        % display training block starting signal
        newTrainBlock = sprintf('Starting Training Block %i of %i blocks', iblock,n_blocks);
        DrawFormattedText(window,newTrainBlock,'center','center',0);
        Screen('Flip', window);
        WaitSecs(2);
        
        %training phase
        for iTrial = 1:n_train_trial
            
            trial_idx = (iblock - 1)*(n_train_trial + n_test_trial) + iTrial;
            % select and present stimuli for each trial
            HasGrid = true;
            HasFeed = true;
            iCat = cat_indices(trial_idx);
            iToken = token_indices(trial_idx);
            rock_info = structfun(@(x) x{iCat,iToken},rockSet_info,'UniformOutput',false);
            [rocktype_trial,token_trial,resp_trial,corr_trial,rt_decision_trial] = displayTrial_passive(rock_info, window, rect, HasGrid, HasFeed, rockGrid_Array);
            
            %record variables
            phase = 1;
            fprintf(fID, '%7d', cond,subID,iblock,phase,iTrial,rocktype_trial,token_trial,resp_trial,corr_trial,rt_decision_trial);
            fprintf(fID, '\n');
        end
        
        % display test block starting signal
        newTestBlock = sprintf('Starting Test Block %i of %i blocks', iblock,n_blocks);
        DrawFormattedText(window,newTestBlock,'center','center',0);
        Screen('Flip', window);
        WaitSecs(2);
        
        % Present the instructions for the first test block
        if iblock == 1
            testInstruction(window);
        end
        
        % Test phase
        corr_count = zeros(1,n_test_trial);
        for iTrial = 1:n_test_trial
            
            trial_idx = (iblock - 1)*(n_train_trial + n_test_trial) + n_train_trial + iTrial;
            % select and present stimuli for each trial
            HasGrid = false;
            HasFeed = false;
            iCat = cat_indices(trial_idx);
            iToken = token_indices(trial_idx);
            rock_info = structfun(@(x) x{iCat,iToken},rockSet_info,'UniformOutput',false);
            [rocktype_trial,token_trial,resp_trial,corr_trial,rt_decision_trial] = displayTrial_passive(rock_info, window, rect, HasGrid, HasFeed);
            corr_count(iTrial) = corr_trial;
            
            % Record variables
            phase = 2;
            fprintf(fID, '%7d', cond,subID,iblock,phase,iTrial,rocktype_trial,token_trial,resp_trial,corr_trial,rt_decision_trial);
            fprintf(fID, '\n');
        end
        
        % display end-of-block signal
        endBlock = ['Block ' num2str(iblock) ' End'];
        block_accuracy = mean(corr_count);
        accuFeed = ['You got ' num2str(round(block_accuracy*100)) '%' ' of trials correct'];
        keyPress = 'Press space bar to continue';
        [~,ny] = DrawFormattedText(window,endBlock,'center','center',0);
        [~,ny] = DrawFormattedText(window,accuFeed,'center',ny + 50,0);
        DrawFormattedText(window,keyPress,'center',ny + 50,[255 0 0]);
        Screen('Flip', window);
        keyboard_wait('Space');
    end
    
    debrief = getText([pwd '\text_files\debrief.txt']);
    [~,ny] = DrawFormattedText(window, debrief{1}, 'center', 'center', 0,75,[],[], 1.5);
    DrawFormattedText(window, 'Press SPACE to finish the experiment', 'center', ny + 150, [255 0 0]);
    Screen('Flip', window);
    keyboard_wait('Space');
    
    endExpt = 'Experiment End';
    DrawFormattedText(window,endExpt,'center','center', 0);
    Screen('Flip', window);
    WaitSecs(2);
    
    fclose(fID);
    Screen('CloseAll');
    ShowCursor;
    ListenChar(0);
    % ---------- Error Handling ----------
catch
    fclose(fID);
    Screen('CloseAll');
    ShowCursor;
    ListenChar(0);
    psychrethrow(psychlasterror);
end

