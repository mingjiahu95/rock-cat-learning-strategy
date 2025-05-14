function trainInstruction(window,rockGrid_Array,cond)

%% Prepare instruction material
global xCenter yCenter ScreenWidth ScreenHeight

% Read in text and image files
Texts_general = getText([pwd '\text_files\trainInstruction.txt']);
Text_SC = getText([pwd '\text_files\sent_SC_cond.txt']);
Text_R = getText([pwd '\text_files\sent_R_cond.txt']);
Text_Y = getText([pwd '\text_files\sent_Y_cond.txt']);
text_press_space = 'Press SPACE to proceed';
text_click_mouse = 'CLICK THE MOUSE anywhere on the screen\nto start the first training block';
[taskImage,~,alpha] = imread([pwd '\text_files\instruct_taskImage.png']);
taskImage(:,:,4) = alpha;
gridImage = rockGrid_Array;

% Determine the sample image size to display
ImageWidth = ScreenWidth;
ImageHeight = ScreenHeight;
imageScale = .7;
ImageWidth = imageScale * ImageWidth;
ImageHeight = imageScale * ImageHeight;
ImageRect = [xCenter - (ImageWidth / 2), yCenter - (ImageHeight / 2), xCenter + (ImageWidth / 2), yCenter + (ImageHeight / 2)];

% Set text offset values
response_text_offset = 150;
Image_prompt_offset_upper = 60;
Image_prompt_offset_lower = 20;
text_spacing = 1.3;


%% Present instructions
[~,ny] = DrawFormattedText(window, Texts_general{1}, 'center', 'center', 0,[],[],[], text_spacing);
DrawFormattedText(window, text_press_space, 'center', ny + response_text_offset, [255 0 0]);
Screen('Flip', window);
keyboard_wait('Space');

[~,ny] = DrawFormattedText(window, Texts_general{2}, 'center', 'center', 0,[],[],[], text_spacing);
DrawFormattedText(window, text_press_space, 'center', ny + response_text_offset, [255 0 0]);
Screen('Flip', window);
keyboard_wait('Space');

Picture = Screen('MakeTexture',window,gridImage);
Screen('DrawTexture',window,Picture,[],ImageRect);
DrawFormattedText(window, Texts_general{3}, 'center', ImageRect(2) - Image_prompt_offset_upper, 0,[],[],[], text_spacing);
switch cond
    case  'SC'
        Text_cond = Text_SC{1};
    case  'R'
        Text_cond = Text_R{1};
    case  'Y'
        Text_cond = Text_Y{1};
    otherwise
        error('Invalid condition for instruction!')
end
[~,ny] = DrawFormattedText(window, Text_cond, 'center', ImageRect(4) + Image_prompt_offset_lower, 0,[],[],[], text_spacing);
DrawFormattedText(window, text_press_space, 'center', ny + response_text_offset/3, [255 0 0]);
Screen('Flip', window);
keyboard_wait('Space');


Picture = Screen('MakeTexture',window,taskImage);
Screen('DrawTexture',window,Picture,[],ImageRect);
DrawFormattedText(window, Texts_general{4}, 'center', ImageRect(2) - Image_prompt_offset_upper, 0,[],[],[], text_spacing);
[~,ny] = DrawFormattedText(window, Texts_general{5}, 'center', ImageRect(4) + Image_prompt_offset_lower, 0,[],[],[], text_spacing);
DrawFormattedText(window, text_press_space, 'center', ny + response_text_offset/3, [255 0 0]);
Screen('Flip', window);
keyboard_wait('Space');

[~,ny] = DrawFormattedText(window, Texts_general{6}, 'center', 'center', 0,[],[],[], text_spacing);
DrawFormattedText(window, text_press_space, 'center', ny + response_text_offset, [255 0 0]);
Screen('Flip', window);
keyboard_wait('Space');

[~,ny] = DrawFormattedText(window, Texts_general{7}, 'center', 'center', 0,[],[],[], text_spacing);
DrawFormattedText(window, text_press_space, 'center', ny + response_text_offset, [255 0 0]);
Screen('Flip', window);
keyboard_wait('Space');

[~,ny] = DrawFormattedText(window, Texts_general{8}, 'center', 'center', 0,[],[],[], text_spacing);
DrawFormattedText(window, text_click_mouse, 'center', ny + response_text_offset, [255 0 0],[],[],[],text_spacing);
Screen('Flip', window);
% wait for any click and release
ShowCursor('arrow', window);
buttons = false;
while ~buttons(1)
    [~,~,buttons] = GetMouse(window);
end
while buttons(1)
    [~,~,buttons] = GetMouse(window);
end
HideCursor;

end
