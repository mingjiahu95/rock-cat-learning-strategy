function testInstruction(window)

%% Prepare test instruction material

% Read in text and image files
Texts = getText([pwd '\text_files\testInstruction.txt']);
text_press_space = 'Press SPACE to proceed';
text_click_mouse = 'CLICK THE MOUSE anywhere on the screen\nto start the first test block';

% Set text offset values
response_text_offset = 150;
text_spacing = 1.3;


%% Present test instructions
[~,ny] = DrawFormattedText(window, Texts{1}, 'center', 'center', 0,[],[],[], text_spacing);
DrawFormattedText(window, text_press_space, 'center', ny + response_text_offset, [255 0 0]);
Screen('Flip', window);
keyboard_wait('Space');

[~,ny] = DrawFormattedText(window, Texts{2}, 'center', 'center', 0,[],[],[], text_spacing);
DrawFormattedText(window, text_press_space, 'center', ny + response_text_offset, [255 0 0]);
Screen('Flip', window);
keyboard_wait('Space');

[~,ny] = DrawFormattedText(window, Texts{3}, 'center', 'center', 0,[],[],[], text_spacing);
DrawFormattedText(window, text_click_mouse, 'center', ny + response_text_offset, [255 0 0],[],[],[], text_spacing);
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
