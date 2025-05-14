function [rocktype_trial,token_trial,resp_trial,corr_trial,rt_decision_trial,rt_selection_trial] = displayTrial_self_guided(rockGrid_info, rockGrid_array, window, rect)
global xCenter yCenter ScreenWidth ScreenHeight 
% Set routine parameters
radiusThreshold = 70; % Radius threshold for cursor proximity to rock center 

% Compute screen parameters
ScreenWidth = rect(3)-rect(1);
ScreenHeight = rect(4)-rect(2);
xCenter = ScreenWidth/2;
yCenter = ScreenHeight/2;

% Calculate grid layout parameters
gridRows = size(rockGrid_info.Name,1);
gridColumns = size(rockGrid_info.Name,2);
thumbSize = 150; % Desired image size
imageGap = 30; % Gap between images
gridWidth = gridColumns * (thumbSize + imageGap) - imageGap;
gridHeight = gridRows * (thumbSize + imageGap) - imageGap;
startX = (ScreenWidth - gridWidth) / 2;
startY = (ScreenHeight - gridHeight) / 2;

% Main experiment loop
trialEnd = false; %trial termination flag
while ~trialEnd   
    
    % Make sure the mouse is released
    [~,~,buttons] = GetMouse;
    while buttons(1)
        [~,~,buttons] = GetMouse;
        DrawFormattedText(window,'Please release the mouse to continue!','center','center',[255,0,0]);
        Screen('Flip',window);
    end
              
    % Display grid of rock images
    rockGrid_Picture = Screen('MakeTexture',window,rockGrid_array);
    Screen('DrawTexture',window,rockGrid_Picture);
    
    % display prompt for continuing
    text = 'Select the rock to study by clicking on one!';
    textSize_old = Screen('TextSize',window,30);
    DrawFormattedText(window,text,'center', 'center',[255 0 0]);
    Screen('TextSize',window,textSize_old);
    Screen('Flip', window);
    
    % Set up Mouse
    HideCursor(window);
    SetMouse(xCenter, yCenter, window);
    ShowCursor('arrow',window);
    
    % Check for cursor proximity to rocks
    continuousRadiusCount = 0; % Number of continuous frames where the radius condition is met
    IsSelected = false;
    
    startTime = GetSecs();
    while ~IsSelected
        
        [mouseX, mouseY,buttons] = GetMouse(window);
        
        distance = zeros(gridRows,gridColumns);
        for row = 1:gridRows
            for col = 1:gridColumns
                rockCenterX = startX + (col - 0.5) * thumbSize + (col - 1) * imageGap;
                rockCenterY = startY + (row - 0.5) * thumbSize + (row - 1) * imageGap;
                distance(row,col) = sqrt((mouseX - rockCenterX)^2 + (mouseY - rockCenterY)^2);
            end
        end
        
        if any(distance(:) <= radiusThreshold)
            ShowCursor('Hand',window);
            continuousRadiusCount = continuousRadiusCount + 1;
            min_distance = min(distance(:));
            [exploredRockRow,exploredRockCol] = find(distance == min_distance);
        else
            ShowCursor('Arrow',window);
            continuousRadiusCount = 0;
            exploredRockRow = 0;
            exploredRockCol = 0;
        end
        % Determine clicked rock
        if buttons(1) && continuousRadiusCount > 0
            clickTime = GetSecs();
            clickedRow = exploredRockRow;
            clickedCol = exploredRockCol;
            clickedRock_info = structfun(@(x) x{clickedRow,clickedCol},rockGrid_info,'UniformOutput',false);
            IsSelected = true;
        end
    end
    selection_time = round((clickTime - startTime) * 1000);
    HideCursor(window);   
    
    % Proceed to the classification task 
    HasGrid = false;
    HasFeed = true;
    [rocktype_trial,token_trial,resp_trial,corr_trial,rt_decision_trial] = displayTrial_passive(clickedRock_info,window,rect,HasGrid,HasFeed);%last argument is set to true for training blocks
    trialEnd = true;
    rt_selection_trial = selection_time;
    Screen('Close');
end
end