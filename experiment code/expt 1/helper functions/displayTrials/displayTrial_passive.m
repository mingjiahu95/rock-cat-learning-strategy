function [rocktype_trial,token_trial,resp_trial,corr_trial,rt_decision_trial] = displayTrial_passive(rock_info, window, rect, grid_flag,feedback_flag,varargin)
global n_cat xCenter yCenter ScreenWidth ScreenHeight

% Set text display parameters
feedbackText_correct = 'Correct';
feedbackText_incorrect = 'Incorrect';
RockYOffset = 150;
feedbackYOffset = 150;
feedbackrockYoffset = 300;
time_grid = 1; 

% Compute screen parameters
ScreenWidth = rect(3)-rect(1);
ScreenHeight = rect(4)-rect(2);
xCenter=ScreenWidth/2;
yCenter=ScreenHeight/2;


if grid_flag
    rockGrid_array = varargin{1};
end

% Pre-load rock image file
rockName = rock_info.Name;
rockImage = rock_info.Array;
[rockImageHeight,rockImageWidth,~] = size(rockImage);

% Calculate rock display parameters
imageScale = .8;
if rockImageHeight >= 900
    imageScale = .7;
    RockYOffset = RockYOffset + 20; 
end
rockImageHeight = imageScale * rockImageHeight;
rockImageWidth = imageScale * rockImageWidth;
rockRect = [xCenter - (rockImageWidth / 2), yCenter - (rockImageHeight / 2) - RockYOffset, xCenter + (rockImageWidth / 2), yCenter + (rockImageHeight / 2) - RockYOffset];

% Calculate rock type button layout
rockTypes = {'Andesite', 'Basalt', 'Diorite', 'Gabbro', 'Obsidian', 'Pegmatite', 'Peridotite', 'Pumice'};
buttonRows = 2; 
buttonColumns = 4; 
buttonWidth = 200;
buttonHeight = 120;
buttonGap = 50;
buttonBorderWidth = 4;
buttonPanelYOffset = 50;
buttonPanelWidth = buttonColumns * (buttonWidth + buttonGap) - buttonGap;
% buttonPanelHeight = buttonRows * (buttonHeight + buttonGap) - buttonGap;
buttonPanelX = xCenter - buttonPanelWidth / 2;
buttonPanelY = rockRect(4) + buttonPanelYOffset;


% Pre-compute button rects and label positions
buttonRects = cell(1,n_cat);
labelX = zeros(1,n_cat);
labelY = zeros(1,n_cat);
Textbound_label = cell(1,n_cat);
for row = 1:buttonRows
    for col = 1:buttonColumns
        x = buttonPanelX + (col - 1) * (buttonWidth + buttonGap);
        y = buttonPanelY + (row - 1) * (buttonHeight + buttonGap);
        index = (row - 1) * buttonColumns + col;
        Textbound_label{index} = Screen('TextBounds', window, rockTypes{index});
        buttonRects{index} = [x, y, x + buttonWidth, y + buttonHeight];
        labelX(index) = x + buttonWidth/2 - (Textbound_label{index}(3) - Textbound_label{index}(1))/2;
        labelY(index) = y + buttonHeight/2 - (Textbound_label{index}(4) - Textbound_label{index}(2))/2;
    end
end



% Main experiment loop
trialEnd = false; %trial termination flag
while ~trialEnd   
      
    if grid_flag
        
        % Make sure the mouse is released
        [~,~,buttons] = GetMouse;
        while buttons(1)
            [~,~,buttons] = GetMouse;
            DrawFormattedText(window,'Please release the mouse to continue!','center','center',[255,0,0]);
            Screen('Flip',window);
        end
    
        % Position Mouse in the center
        SetMouse(xCenter, yCenter, window);
        ShowCursor('arrow',window);
        
        % Display grid of rock images
        rockGrid_picture = Screen('MakeTexture',window,rockGrid_array);
        Screen('DrawTexture',window,rockGrid_picture);
        Screen('Flip', window);
        WaitSecs(time_grid);
        
        % display prompt for continuing
        text = 'Click anywhere on the screen to continue!';
        textSize_old = Screen('TextSize',window,30);
        Screen('DrawTexture',window,rockGrid_picture);
        DrawFormattedText(window,text,'center', 'center',[255 0 0]);
        Screen('Flip', window);
        Screen('TextSize',window,textSize_old);
        
        % wait for any mouse click
        buttons = false;
        while ~buttons(1)
            [~,~,buttons] = GetMouse(window);
        end
        HideCursor(window);
    end
%     Screen('Flip',window);

    % Check if Cursor is within the button bounds
    IsChosen = false;
    continuousBoundCount = 0; % Number of continuous frames where the bound condition is met

    % Start the response stage
    startTime = GetSecs();
    rockPicture = Screen('MakeTexture',window,rockImage);
    refresh_count = 0;
    while ~IsChosen
        
        refresh_count = refresh_count + 1;
        
        % Display rock image  
        Screen('DrawTexture',window,rockPicture,[],rockRect);
        
        % display buttons and type labels
        for row = 1:buttonRows
            for col = 1:buttonColumns
                index = (row - 1) * buttonColumns + col;
                Screen('FrameRect', window, 0, buttonRects{index}, buttonBorderWidth);
                DrawFormattedText(window, rockTypes{index}, labelX(index), labelY(index), 0);
            end
        end
        
        % wait for mouse release before showing the cursor
        [mouseX, mouseY,buttons] = GetMouse(window);
        if refresh_count == 1
            Screen('Flip',window); 
            while buttons(1) 
                [~,~,buttons] = GetMouse(window);
            end
            SetMouse(xCenter, yCenter, window); 
            ShowCursor('Arrow');
            continue
        end
        
%         testInstructImage = Screen('GetImage',window,[],'BackBuffer',[],4);
%         imwrite(testInstructImage(:,:,1:3),'instruct_taskImage.png','Alpha',testInstructImage(:,:,4));

        IsInBounds = false(1,n_cat);
        for row = 1:buttonRows
            for col = 1:buttonColumns
                type_index = (row - 1) * buttonColumns + col;
                buttonBound = buttonRects{type_index};
                IsInBounds(type_index) = mouseX >= buttonBound(1) && mouseX <= buttonBound(3) && mouseY >= buttonBound(2) && mouseY <= buttonBound(4);
            end
        end
        
        if ~any(IsInBounds) 
            continuousBoundCount = 0;
            button_index = 0;       
            ShowCursor('Arrow',window); 
        else
            ShowCursor('Hand',window);
            continuousBoundCount = continuousBoundCount + 1;
            button_index = find(IsInBounds);
            Screen('FrameRect', window, [255 0 0], buttonRects{button_index}, buttonBorderWidth);
            DrawFormattedText(window, rockTypes{button_index}, labelX(button_index), labelY(button_index), [255 0 0]);
        end
        Screen('Flip',window);

        
        % Determine classification response
        if buttons(1) && continuousBoundCount > 0
            clickTime = GetSecs();
            chosenType = button_index;
            IsChosen = true;
        end
    end
    decision_time = round((clickTime - startTime) * 1000);
    
    % Hide cursor for the rest of experiment
    HideCursor(window);
    
    % Determine the response and the correct rock type
    Corr_type_name = cell2mat(regexp(rockName,'(?<=_)[A-Z][a-z]+(?=_)','match'));
    rocktype_trial = retrieve_NameKey(rockTypes,Corr_type_name,'IsCaseSensitive',false);
    Token_per_cat_str = cell2mat(regexp(rockName,'(?<=_)\d+(?=\.png)','match'));
    token_trial = str2double(Token_per_cat_str);%per category
    resp_trial = chosenType;
    corr_trial = resp_trial == rocktype_trial;
    rt_decision_trial = decision_time;
    
    % corrective feedback
    if feedback_flag
        % Display clicked rock
        Screen('DrawTexture',window,rockPicture,[],rockRect);
        if corr_trial == 1
            DrawFormattedText(window, feedbackText_correct, 'center', rockRect(4) + feedbackYOffset,[0 255 0]);
        else
            DrawFormattedText(window, feedbackText_incorrect, 'center', rockRect(4) + feedbackYOffset,[255 0 0]);
        end
        feedbackText_rocktype = sprintf('This rock is %s',Corr_type_name);
        DrawFormattedText(window, feedbackText_rocktype, 'center', rockRect(4) + feedbackrockYoffset,0);
        feedbackDuration = 2;
    else
        feedbackText_neutral = 'Okay';
        DrawFormattedText(window, feedbackText_neutral,'center', 'center',0);
        feedbackDuration = .5;
    end
    Screen('Flip', window);
    WaitSecs(feedbackDuration);
    Screen('Flip', window);
    Screen('Close');
    trialEnd = true;    
end
end