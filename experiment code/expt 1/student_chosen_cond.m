% ---------- Parameters ----------
clear
clc
rng('Shuffle');
pathLocation = [pwd '\helper functions\'];
addpath(genpath(pathLocation));
global n_cat xCenter yCenter ScreenWidth ScreenHeight 
cond = 2;
n_cat_token_per_testblock = 2;
n_blocks = 9;%10
n_cat = 8;%10
total_train_token_per_cat = 6;
total_test_token_per_cat = 6;%10
n_token_per_cat = total_train_token_per_cat + total_test_token_per_cat;
n_train_trial = 16;%20
n_test_trial = n_cat_token_per_testblock*n_cat;
textsize_default = 20;
fontStyle = 1;


% ---------- Create Stimuli ----------
rng('Shuffle');
dataLocation = [pwd '\rocksall480\'];
% Get PNG files.
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

% ---------- Randomize Category and Token Indices ----------
if rem(n_test_trial,n_cat) > 0
    error('The number of test trials should be a multiple of %i',n_cat);  
end

% create category matrix for blocks and trials
cat_mat_test = repmat(repelem(1:n_cat,n_cat_token_per_testblock),[n_blocks 1]);

% create token order vectors for test blocks (unique vector
% for each category)
token_order_test = zeros(n_cat,n_cat_token_per_testblock*n_blocks);
for icat = 1:n_cat
    token_order_test(icat,:) = randperm_cycle(total_test_token_per_cat,n_cat_token_per_testblock*n_blocks);
end

% create matrices storing token indices
[~,tokens_indices] = randperm_cycle(n_token_per_cat,n_token_per_cat*n_cat);
tokens_indices_train = tokens_indices(:,1:total_train_token_per_cat);
tokens_indices_test = tokens_indices(:,total_train_token_per_cat + (1:total_test_token_per_cat));

% create token matrix for blocks and trials
token_mat_test = zeros(n_blocks,n_test_trial);
for iblock = 1:n_blocks
    tokens_key_idx_test = n_cat_token_per_testblock*(iblock - 1) + (1:n_cat_token_per_testblock);
    for icat = 1:n_cat
        tokens_key_test = token_order_test(icat,tokens_key_idx_test);
        itrials_test = n_cat_token_per_testblock*(icat - 1) + (1:n_cat_token_per_testblock);
        token_mat_test(iblock,itrials_test) = tokens_indices_test(icat,tokens_key_test);
    end
end

% create order matrix for blocks and trials
[~,test_order_indices] = randperm_cycle(n_test_trial,n_test_trial*n_blocks);

% ---------- Open Subject File ---------- 
data_location=[pwd '\data\'];
subID = input(' subject # ');
filename_data = [data_location 'rocks_condSC_subj' num2str(subID) '.txt'];
if ~exist('data','dir') 
    mkdir('data');
end
if exist(filename_data, 'file')
    error('Error: the file already exists!');
end
fID = fopen(filename_data,'wt');

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
            [rockImage, ~, alpha] = imread(rockTokens{row, col});
            rockImage(:,:,4) = alpha(:,:);
            rockArrays{row,col} = rockImage;
        end
    end
    rockSet_info.Name = rockTokens;
    rockSet_info.Array = rockArrays;
    
    % randomize the positions of rocks in the grid for each subject
    rockGrid_info = structfun(@(x) helper_func(x,tokens_indices_train),rockSet_info,'UniformOutput',false);
    rockGrid_info_rand = shuffleND_struct(rockGrid_info);
    
    % save training rock indices as a text file
    subj_vec = repmat(subID,[1 n_cat*total_train_token_per_cat]);
%     cat_test_vec = repelem(1:n_cat,total_train_token_per_cat);
%     token_test_vec = reshape(tokens_indices_train',[1 n_cat*total_train_token_per_cat]);
    rockTypes = {'Andesite', 'Basalt', 'Diorite', 'Gabbro', 'Obsidian', 'Pegmatite', 'Peridotite', 'Pumice'};
    for i = 1:numel(rockGrid_info_rand.Name)
        irow = ceil(i/n_cat);
        icol = rem(i-1, n_cat) + 1;
        tokenName = rockGrid_info_rand.Name{irow,icol};
        Corr_type_name = cell2mat(regexp(tokenName,'(?<=_)[A-Z][a-z]+(?=_)','match'));
        cat_test_vec(i) = retrieve_NameKey(rockTypes,Corr_type_name,'IsCaseSensitive',false);
        Token_per_cat_str = cell2mat(regexp(tokenName,'(?<=_)\d+(?=\.png)','match'));
        token_test_vec(i) = str2double(Token_per_cat_str);
    end

    if ~exist('data\TrainStim','dir')
        mkdir('data\TrainStim');
    end
    filename_trainStim = [data_location 'TrainStim\rocks_condSC_subj' num2str(subID) '.txt'];
    fID_temp = fopen(filename_trainStim,'wt');
    fprintf(fID_temp,'%7d%7d%7d\n', [subj_vec; cat_test_vec; token_test_vec]);
    fclose(fID_temp);
    
    % Calculate grid layout parameters
    gridRows = total_train_token_per_cat;
    gridCols = n_cat;
    imageSize = 150; % Desired image size
    imageGap = 30; % Gap between images
    gridWidth = gridCols * (imageSize + imageGap) - imageGap;
    gridHeight = gridRows * (imageSize + imageGap) - imageGap;
    startX = (ScreenWidth - gridWidth) / 2;
    startY = (ScreenHeight - gridHeight) / 2;
    
    % Pre-compute grid rects
    gridRects = cell(gridRows, gridCols);
    for row = 1:gridRows
        for col = 1:gridCols
            x = startX + (col - 1) * (imageSize + imageGap);
            y = startY + (row - 1) * (imageSize + imageGap);
            gridRects{row, col} = [x, y, x + imageSize, y + imageSize];
        end
    end
    
    % Create the rock grid image in the background  
    for row = 1:gridRows
        for col = 1:gridCols
            rockImage = rockGrid_info_rand.Array{row,col};
            gridRect = gridRects{row,col};
            rockPicture = Screen('MakeTexture',window,rockImage);
            Screen('DrawTexture',window,rockPicture,[],gridRect);
            Screen('Close', rockPicture); 
        end
    end    
    rockGrid_Array = Screen('GetImage',window,[],'BackBuffer',[],4);
    Screen('FillRect', window, [backgroundColor 0]);
    Screen('Flip',window);
    
    % Present training instructions
    trainInstruction(window,rockGrid_Array,'SC');
    final_accuracy = 0;
    for iblock = 1:n_blocks
        
        % display training block starting signal
        newTrainBlock = sprintf('Starting Training Block %i of %i blocks', iblock,n_blocks);
        DrawFormattedText(window,newTrainBlock,'center','center',0);
        Screen('Flip', window);
        WaitSecs(2);
        
        %training phase
        for iTrial = 1:n_train_trial
              HasGrid = true;
              HasFeed = true;
              [rocktype_trial,token_trial,resp_trial,corr_trial,rt_decision_trial,rt_selection_trial] = displayTrial_self_guided(rockGrid_info_rand, rockGrid_Array, window, rect);
              
              %record variables
              phase = 1;             
              fprintf(fID, '%7d', cond,subID,iblock,phase,iTrial,rocktype_trial,token_trial,resp_trial,corr_trial,rt_decision_trial,rt_selection_trial);
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
            
              % select and present stimuli for each trial 
              HasGrid = false;
              HasFeed = false;
              iCat = cat_mat_test(iblock,test_order_indices(iblock,iTrial));
              iToken = token_mat_test(iblock,test_order_indices(iblock,iTrial)); 
              rock_info = structfun(@(x) x{iCat,iToken},rockSet_info,'UniformOutput',false);
              [rocktype_trial,token_trial,resp_trial,corr_trial,rt_decision_trial] = displayTrial_passive(rock_info, window, rect, HasGrid, HasFeed);
              corr_count(iTrial) = corr_trial;
              
              % Record variables
              phase = 2;
              rt_selection_trial = -1;
              fprintf(fID, '%7d', cond,subID,iblock,phase,iTrial,rocktype_trial,token_trial,resp_trial,corr_trial,rt_decision_trial,rt_selection_trial);
              fprintf(fID, '\n'); 
        end
        
        % display end-of-block signal
          endBlock = ['Block ' num2str(iblock) ' End'];
          block_accuracy = mean(corr_count);
          if iblock >= 7
              final_accuracy = mean([block_accuracy,final_accuracy]);
          end
          accuFeed = ['You got ' num2str(round(block_accuracy*100)) '%' ' of trials correct'];
          keyPress = 'Press space bar to continue';
          [~,ny] = DrawFormattedText(window,endBlock,'center','center',0);
          [~,ny] = DrawFormattedText(window,accuFeed,'center',ny + 50,0);
          DrawFormattedText(window,keyPress,'center',ny + 50,[255 0 0]);
          Screen('Flip', window);
          keyboard_wait('Space');
    end
    
    % present debrief report
    debrief = getText([pwd '\text_files\debrief.txt']);
    [~,ny] = DrawFormattedText(window, debrief{1}, 'center', 'center', 0,75,[],[], 1.5);
    Screen('Flip', window);
    
    % save the rock grid image as a png file under the data folder
    dest_folder = [pwd '\input data\'];
    dest_filename = ['rockgrid_condSC_subj' num2str(subID) ' .png'];
    dest_path = fullfile(dest_folder, dest_filename);
    if ~exist(dest_folder,'dir')
        mkdir(dest_folder);
    end
    imwrite(rockGrid_Array(:,:,1:3),dest_path,'Alpha',rockGrid_Array(:,:,4));
    
    % present end-of-exeriment message
    [~,ny] = DrawFormattedText(window, debrief{1}, 'center', 'center', 0,75,[],[], 1.5);
    DrawFormattedText(window, 'Press SPACE to finish the experiment', 'center', ny + 150, [255 0 0]);
    Screen('Flip', window);
    keyboard_wait('Space');
    
    endExpt = 'Experiment End';
    [~,ny] = DrawFormattedText(window,endExpt,'center','center',0);
    if final_accuracy >= .7 % subject to change
        accu_text = 'Good Job! You can ask for a $2 bonus from your experimenter.';
        DrawFormattedText(window, accu_text, 'center', ny + 150, 0,75,[],[], 1.5);
    end
    Screen('Flip', window);
    WaitSecs(2);
    
    fclose(fID);
    copyfile(filename_data,dest_folder); % copy file to the input data folder for the yoked condition
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
