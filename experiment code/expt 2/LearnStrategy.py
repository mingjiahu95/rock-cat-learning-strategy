#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy3 Experiment Builder (v2023.2.3),
    on May 12, 2024, at 22:18
If you publish work using this script the most relevant publication is:

    Peirce J, Gray JR, Simpson S, MacAskill M, Höchenberger R, Sogo H, Kastman E, Lindeløv JK. (2019) 
        PsychoPy2: Experiments in behavior made easy Behav Res 51: 195. 
        https://doi.org/10.3758/s13428-018-01193-y

"""

# --- Import packages ---
from psychopy import locale_setup
from psychopy import prefs
from psychopy import plugins
plugins.activatePlugins()
prefs.hardware['audioLib'] = 'ptb'
prefs.hardware['audioLatencyMode'] = '3'
from psychopy import sound, gui, visual, core, data, event, logging, clock, colors, layout
from psychopy.tools import environmenttools
from psychopy.constants import (NOT_STARTED, STARTED, PLAYING, PAUSED,
                                STOPPED, FINISHED, PRESSED, RELEASED, FOREVER, priority)

import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import (sin, cos, tan, log, log10, pi, average,
                   sqrt, std, deg2rad, rad2deg, linspace, asarray)
from numpy.random import random, randint, normal, shuffle, choice as randchoice
import os  # handy system and path functions
import sys  # to get file system encoding

import psychopy.iohub as io
from psychopy.hardware import keyboard

# Run 'Before Experiment' code from function_def
import random
import numpy as np
import os
import psychopy.event as eventfun
import math

def shuffle_nested_list(nested_list):
    # Convert nested list to numpy array
    arr = np.array(nested_list)
    
    # Flatten the array, shuffle it, and then reshape
    flattened_arr = arr.flatten()
    np.random.shuffle(flattened_arr)
    reshaped_arr = flattened_arr.reshape(arr.shape)
    
    # Convert reshaped array back to a nested list
    shuffled_list = reshaped_arr.tolist()
    return shuffled_list
    
def extract_rock_info(fileName):
    # Split by underscores and get the middle part (rock type)
    rock_type = fileName.split("_")[1]
    
    # Split by dot to remove file extension and get the token part
    token = fileName.split(".")[0].split("_")[-1]
    
    # Check if rock_type starts with uppercase and token is two-digit
    if rock_type[0].isupper() and rock_type[1:].islower() and token.isdigit():
        rock_info = {'type':rock_type,'token':token}
        return rock_info
    return None

def prop_to_count(proportions, target_sum):
    
    # Step 1: Calculate raw values and round them
    raw_values = [prop * target_sum for prop in proportions]
    rounded_values = [round(value) for value in raw_values]

    # Step 2: Calculate the difference from the target sum
    current_sum = sum(rounded_values)
    difference = target_sum - current_sum

    # Step 3 & 4: Adjust the numbers to reach the target sum
    while difference != 0:
        for i in range(len(rounded_values)):
            if difference == 0:
                break
            # Find if we need to increment or decrement
            if difference > 0 and raw_values[i] - rounded_values[i] > 0:
                # Increment the value if it was rounded down
                rounded_values[i] += 1
                difference -= 1
            elif difference < 0 and raw_values[i] - rounded_values[i] < 0:
                # Decrement the value if it was rounded up and is greater than 0
                if rounded_values[i] > 0:
                    rounded_values[i] -= 1
                    difference += 1

    return rounded_values


            
            
            
        

# Run 'Before Experiment' code from end_expt_var
end_message = ' After you click "ok", you will be redirected to a short survey.'
redirect_url = 'https://iu.co1.qualtrics.com/jfe/form/SV_cBXYDpPQBCfKI2G?participant=' + expInfo['participant'] + '&condition=' + expInfo['condition']
# --- Setup global variables (available in all functions) ---
# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__))
# Store info about the experiment session
psychopyVersion = '2023.2.3'
expName = 'LearnStrategy'  # from the Builder filename that created this script
expInfo = {
    'participant': '',
    'condition': ["SCN","SCR","TCN","TCR"],
    'date': data.getDateStr(),  # add a simple timestamp
    'expName': expName,
    'psychopyVersion': psychopyVersion,
}


def showExpInfoDlg(expInfo):
    """
    Show participant info dialog.
    Parameters
    ==========
    expInfo : dict
        Information about this experiment, created by the `setupExpInfo` function.
    
    Returns
    ==========
    dict
        Information about this experiment.
    """
    # temporarily remove keys which the dialog doesn't need to show
    poppedKeys = {
        'date': expInfo.pop('date', data.getDateStr()),
        'expName': expInfo.pop('expName', expName),
        'psychopyVersion': expInfo.pop('psychopyVersion', psychopyVersion),
    }
    # show participant info dialog
    dlg = gui.DlgFromDict(dictionary=expInfo, sortKeys=False, title=expName)
    if dlg.OK == False:
        core.quit()  # user pressed cancel
    # restore hidden keys
    expInfo.update(poppedKeys)
    # return expInfo
    return expInfo


def setupData(expInfo, dataDir=None):
    """
    Make an ExperimentHandler to handle trials and saving.
    
    Parameters
    ==========
    expInfo : dict
        Information about this experiment, created by the `setupExpInfo` function.
    dataDir : Path, str or None
        Folder to save the data to, leave as None to create a folder in the current directory.    
    Returns
    ==========
    psychopy.data.ExperimentHandler
        Handler object for this experiment, contains the data to save and information about 
        where to save it to.
    """
    
    # data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
    if dataDir is None:
        dataDir = _thisDir
    filename = u'data/%s_%s_%s' % (expInfo['participant'], expName, expInfo['date'])
    # make sure filename is relative to dataDir
    if os.path.isabs(filename):
        dataDir = os.path.commonprefix([dataDir, filename])
        filename = os.path.relpath(filename, dataDir)
    
    # an ExperimentHandler isn't essential but helps with data saving
    thisExp = data.ExperimentHandler(
        name=expName, version='',
        extraInfo=expInfo, runtimeInfo=None,
        originPath='C:\\Users\\super\\Desktop\\lab\\LearnStrategy\\experiment folder\\PsychoJS\\LearnStrategy.py',
        savePickle=True, saveWideText=True,
        dataFileName=dataDir + os.sep + filename, sortColumns='priority'
    )
    thisExp.setPriority('participant', priority.CRITICAL)
    thisExp.setPriority('condition', priority.CRITICAL)
    thisExp.setPriority('block', priority.CRITICAL)
    thisExp.setPriority('phase', priority.CRITICAL)
    thisExp.setPriority('trial', priority.CRITICAL)
    thisExp.setPriority('cat', priority.CRITICAL)
    thisExp.setPriority('token', priority.CRITICAL)
    thisExp.setPriority('row', priority.CRITICAL)
    thisExp.setPriority('col', priority.CRITICAL)
    thisExp.setPriority('resp', priority.CRITICAL)
    thisExp.setPriority('corr', priority.CRITICAL)
    thisExp.setPriority('t_resp', priority.CRITICAL)
    thisExp.setPriority('t_select', priority.CRITICAL)
    thisExp.setPriority('cat_rec', priority.CRITICAL)
    thisExp.setPriority('token_rec', priority.CRITICAL)
    # return experiment handler
    return thisExp


def setupLogging(filename):
    """
    Setup a log file and tell it what level to log at.
    
    Parameters
    ==========
    filename : str or pathlib.Path
        Filename to save log file and data files as, doesn't need an extension.
    
    Returns
    ==========
    psychopy.logging.LogFile
        Text stream to receive inputs from the logging system.
    """
    # this outputs to the screen, not a file
    logging.console.setLevel(logging.WARNING)


def setupWindow(expInfo=None, win=None):
    """
    Setup the Window
    
    Parameters
    ==========
    expInfo : dict
        Information about this experiment, created by the `setupExpInfo` function.
    win : psychopy.visual.Window
        Window to setup - leave as None to create a new window.
    
    Returns
    ==========
    psychopy.visual.Window
        Window in which to run this experiment.
    """
    if win is None:
        # if not given a window to setup, make one
        win = visual.Window(
            size=[1280, 720], fullscr=True, screen=0,
            winType='pyglet', allowStencil=False,
            monitor='testMonitor', color='white', colorSpace='rgb',
            backgroundImage='', backgroundFit='none',
            blendMode='avg', useFBO=True,
            units='height'
        )
        if expInfo is not None:
            # store frame rate of monitor if we can measure it
            expInfo['frameRate'] = win.getActualFrameRate()
    else:
        # if we have a window, just set the attributes which are safe to set
        win.color = 'white'
        win.colorSpace = 'rgb'
        win.backgroundImage = ''
        win.backgroundFit = 'none'
        win.units = 'height'
    win.mouseVisible = True
    win.hideMessage()
    return win


def setupInputs(expInfo, thisExp, win):
    """
    Setup whatever inputs are available (mouse, keyboard, eyetracker, etc.)
    
    Parameters
    ==========
    expInfo : dict
        Information about this experiment, created by the `setupExpInfo` function.
    thisExp : psychopy.data.ExperimentHandler
        Handler object for this experiment, contains the data to save and information about 
        where to save it to.
    win : psychopy.visual.Window
        Window in which to run this experiment.
    Returns
    ==========
    dict
        Dictionary of input devices by name.
    """
    # --- Setup input devices ---
    inputs = {}
    ioConfig = {}
    
    # Setup iohub keyboard
    ioConfig['Keyboard'] = dict(use_keymap='psychopy')
    
    ioSession = '1'
    if 'session' in expInfo:
        ioSession = str(expInfo['session'])
    ioServer = io.launchHubServer(window=win, **ioConfig)
    eyetracker = None
    
    # create a default keyboard (e.g. to check for escape)
    defaultKeyboard = keyboard.Keyboard(backend='iohub')
    # return inputs dict
    return {
        'ioServer': ioServer,
        'defaultKeyboard': defaultKeyboard,
        'eyetracker': eyetracker,
    }

def pauseExperiment(thisExp, inputs=None, win=None, timers=[], playbackComponents=[]):
    """
    Pause this experiment, preventing the flow from advancing to the next routine until resumed.
    
    Parameters
    ==========
    thisExp : psychopy.data.ExperimentHandler
        Handler object for this experiment, contains the data to save and information about 
        where to save it to.
    inputs : dict
        Dictionary of input devices by name.
    win : psychopy.visual.Window
        Window for this experiment.
    timers : list, tuple
        List of timers to reset once pausing is finished.
    playbackComponents : list, tuple
        List of any components with a `pause` method which need to be paused.
    """
    # if we are not paused, do nothing
    if thisExp.status != PAUSED:
        return
    
    # pause any playback components
    for comp in playbackComponents:
        comp.pause()
    # prevent components from auto-drawing
    win.stashAutoDraw()
    # run a while loop while we wait to unpause
    while thisExp.status == PAUSED:
        # make sure we have a keyboard
        if inputs is None:
            inputs = {
                'defaultKeyboard': keyboard.Keyboard(backend='ioHub')
            }
        # check for quit (typically the Esc key)
        if inputs['defaultKeyboard'].getKeys(keyList=['escape']):
            endExperiment(thisExp, win=win, inputs=inputs)
        # flip the screen
        win.flip()
    # if stop was requested while paused, quit
    if thisExp.status == FINISHED:
        endExperiment(thisExp, inputs=inputs, win=win)
    # resume any playback components
    for comp in playbackComponents:
        comp.play()
    # restore auto-drawn components
    win.retrieveAutoDraw()
    # reset any timers
    for timer in timers:
        timer.reset()


def run(expInfo, thisExp, win, inputs, globalClock=None, thisSession=None):
    """
    Run the experiment flow.
    
    Parameters
    ==========
    expInfo : dict
        Information about this experiment, created by the `setupExpInfo` function.
    thisExp : psychopy.data.ExperimentHandler
        Handler object for this experiment, contains the data to save and information about 
        where to save it to.
    psychopy.visual.Window
        Window in which to run this experiment.
    inputs : dict
        Dictionary of input devices by name.
    globalClock : psychopy.core.clock.Clock or None
        Clock to get global time from - supply None to make a new one.
    thisSession : psychopy.session.Session or None
        Handle of the Session object this experiment is being run from, if any.
    """
    # mark experiment as started
    thisExp.status = STARTED
    # make sure variables created by exec are available globally
    exec = environmenttools.setExecEnvironment(globals())
    # get device handles from dict of input devices
    ioServer = inputs['ioServer']
    defaultKeyboard = inputs['defaultKeyboard']
    eyetracker = inputs['eyetracker']
    # make sure we're running in the directory for this experiment
    os.chdir(_thisDir)
    # get filename from ExperimentHandler for convenience
    filename = thisExp.dataFileName
    frameTolerance = 0.001  # how close to onset before 'same' frame
    endExpNow = False  # flag for 'escape' or other condition => quit the exp
    # get frame duration from frame rate in expInfo
    if 'frameRate' in expInfo and expInfo['frameRate'] is not None:
        frameDur = 1.0 / round(expInfo['frameRate'])
    else:
        frameDur = 1.0 / 60.0  # could not measure, so guess
    
    # Start Code - component code to be run after the window creation
    
    # --- Initialize components for Routine "load_image_info" ---
    
    # --- Initialize components for Routine "instPrep" ---
    # Run 'Begin Experiment' code from instrPrecode
    cur_row_train = 0
    show_instructions_train = 1
    if expInfo['condition'] in ['TCN', 'TCR']:
        max_slides_train = 7 - 1
    elif expInfo['condition'] == 'SCN':
        max_slides_train = 8 - 1
    elif expInfo['condition'] == 'SCR':
        max_slides_train = 9 - 1
    
    instruct_filename = 'stimuli/train_instructions' + expInfo['condition'] + '.xlsx'
    arrowSize = (0.15, 0.15)
    arrowPos_back = (-0.5,-0.38)
    arrowPos_next = (0.5,-0.38)
    
    # --- Initialize components for Routine "train_instructions" ---
    instruction_image_train = visual.ImageStim(
        win=win,
        name='instruction_image_train', 
        image='default.png', mask=None, anchor='center',
        ori=0.0, pos=(0, 0), size=(1.1, 0.62),
        color='white', colorSpace='rgb', opacity=None,
        flipHoriz=False, flipVert=False,
        texRes=128.0, interpolate=True, depth=0.0)
    leftArrow = visual.ImageStim(
        win=win,
        name='leftArrow', 
        image='img/leftarrow.png', mask=None, anchor='center',
        ori=0.0, pos=arrowPos_back, size=arrowSize,
        color='white', colorSpace='rgb', opacity=None,
        flipHoriz=False, flipVert=False,
        texRes=128.0, interpolate=True, depth=-1.0)
    rightArrow = visual.ImageStim(
        win=win,
        name='rightArrow', 
        image='img/rightarrow.png', mask=None, anchor='center',
        ori=0.0, pos=arrowPos_next, size=arrowSize,
        color='white', colorSpace='rgb', opacity=None,
        flipHoriz=False, flipVert=False,
        texRes=128.0, interpolate=True, depth=-2.0)
    instruct_mouse_train = event.Mouse(win=win)
    x, y = [None, None]
    instruct_mouse_train.mouseClock = core.Clock()
    instruct_counter_train = visual.TextStim(win=win, name='instruct_counter_train',
        text='',
        font='Open Sans',
        pos=(0, -.45), height=0.05, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-4.0);
    
    # --- Initialize components for Routine "expt_setup" ---
    # Run 'Begin Experiment' code from function_def
    next_buttonSize = [0.24, 0.08]
    # Run 'Begin Experiment' code from def_rock_params
    # define experiment parameters
    gridSize = (0.11,0.11)
    gridSize_large = [dim * 1.3 for dim in gridSize]
    rockSize_large = [dim * 1.2 for dim in rockSize]
    category_names = ["Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice"]
    substring_map = {
        'Basalt': [('14', '16')],
        'Gabbro': [('03', '12'), ('14', '15')],
        'Pegmatite': [('09', '10')]
    }
    num_cats = len(category_names)
    nblock = 9
    num_rows = 6
    num_cols = num_cats
    
    # define grid display parameters
    x_bound = (-.55,.55)
    y_bound = (-.39,.39)
    y_padding = 0.02
    grid_image_pos = []
    for irow in range(num_rows):
        grid_image_row = []
        for icol in  range(num_cols):
            x_pos = x_bound[0] + icol * (x_bound[1] - x_bound[0])/(num_cols - 1)
            y_pos = y_bound[0] + irow * (y_bound[1] - y_bound[0])/(num_rows - 1)
            if y_pos > 0:
                y_pos = y_pos + y_padding
            else:
                y_pos = y_pos - y_padding
            grid_image_row.append([x_pos,y_pos])
        grid_image_pos.append(grid_image_row)
    
    # --- Initialize components for Routine "start_of_trainingProcess" ---
    block_prompt_train = visual.TextStim(win=win, name='block_prompt_train',
        text='',
        font='Open Sans',
        pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=0.0);
    
    # --- Initialize components for Routine "fixation" ---
    fix_text = visual.TextStim(win=win, name='fix_text',
        text='move your mouse to the dot at the center to continue',
        font='Open Sans',
        pos=(0, 0.1), height=0.05, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-1.0);
    fix_circle = visual.ShapeStim(
        win=win, name='fix_circle',
        size=(0.03, 0.03), vertices='circle',
        ori=0.0, pos=(0, 0), anchor='center',
        lineWidth=1.0,     colorSpace='rgb',  lineColor='black', fillColor='black',
        opacity=None, depth=-2.0, interpolate=True)
    fix_mouse = event.Mouse(win=win)
    x, y = [None, None]
    fix_mouse.mouseClock = core.Clock()
    
    # --- Initialize components for Routine "fixation_cross" ---
    fix_wait = visual.TextStim(win=win, name='fix_wait',
        text='loading...',
        font='Open Sans',
        pos=(0, 0), height=0.1, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=0.0);
    
    # --- Initialize components for Routine "condition_switch" ---
    
    # --- Initialize components for Routine "Selection_train" ---
    rock_grid_text = visual.TextStim(win=win, name='rock_grid_text',
        text='Click on the rock you want to study next',
        font='Open Sans',
        pos=(0, 0), height=0.04, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-2.0);
    learn_mouse = event.Mouse(win=win)
    x, y = [None, None]
    learn_mouse.mouseClock = core.Clock()
    
    # --- Initialize components for Routine "Sampling_train" ---
    rock_grid_text_2 = visual.TextStim(win=win, name='rock_grid_text_2',
        text='Click anywhere on the screen to continue',
        font='Open Sans',
        pos=(0, 0), height=0.04, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-1.0);
    learn_mouse_2 = event.Mouse(win=win)
    x, y = [None, None]
    learn_mouse_2.mouseClock = core.Clock()
    
    # --- Initialize components for Routine "Classification_train" ---
    # Run 'Begin Experiment' code from prog_bar_train
    n_trials_total = 16*2
    
    # Run 'Begin Experiment' code from buttons_config
    buttons_nrow = 2
    buttons_ncol = 4
    buttons_ntotal = buttons_nrow * buttons_ncol
    xbound = [-0.4, 0.4]
    ybound = [-0.25, -0.4]
    buttonSize = (0.22,0.08)
    xPos = []
    yPos = []
    buttonPos = []
    for i_button in range(buttons_ntotal):
        i_button_x = i_button % buttons_ncol
        i_button_y = i_button // buttons_ncol
        xPos = xbound[0] + abs(xbound[0] - xbound[1])/(buttons_ncol - 1)*i_button_x
        yPos = ybound[0] - abs(ybound[0] - ybound[1])/(buttons_nrow - 1)*i_button_y
        buttonPos.append([xPos,yPos])
    # Run 'Begin Experiment' code from draw_button_panel
    cat_button_clickable = []
    cat_button_text = []
    Button_rect =  []
    Button_txt = []
    for i_button in range(buttons_ntotal):
        cat_name = category_names[i_button]
        Button_rect = visual.TextBox(
             win, text=None, placeholder='Type here...', font='Arial',
             pos=buttonPos[i_button],letterHeight=0.03,
             size=buttonSize, borderWidth=4.0,
             color=None, colorSpace='rgb',
             opacity=None,
             bold=False, italic=False,
             lineSpacing=1.0, speechPoint=None,
             padding=0.0, alignment='center',
             anchor='center', overflow='visible',
             fillColor=None, borderColor='black',
             flipHoriz=False, flipVert=False, languageStyle='LTR',
             editable=False,
             name=cat_name + '_rect',
             depth=-6, autoLog=False)
        Button_txt = visual.TextStim(
            win=win, name=cat_name + '_txt',
            text=cat_name,
            font='Open Sans',
            pos=buttonPos[i_button], height=0.04, wrapWidth=None, ori=0.0, 
            color='black', colorSpace='rgb', opacity=None, 
            languageStyle='LTR',
            depth=-7.0)
        cat_button_clickable.append(Button_rect) 
        cat_button_text.append(Button_txt) 
    trial_rock_train = visual.ImageStim(
        win=win,
        name='trial_rock_train', 
        image='default.png', mask=None, anchor='center',
        ori=0.0, pos=(0, 0.1), size=1.0,
        color=[1,1,1], colorSpace='rgb', opacity=None,
        flipHoriz=False, flipVert=False,
        texRes=128.0, interpolate=True, depth=-5.0)
    cat_mouse_l = event.Mouse(win=win)
    x, y = [None, None]
    cat_mouse_l.mouseClock = core.Clock()
    progress_bar_text = visual.TextStim(win=win, name='progress_bar_text',
        text='Progress',
        font='Open Sans',
        pos=(-0.55, 0.42), height=0.05, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-7.0);
    train_trial_counter = visual.TextStim(win=win, name='train_trial_counter',
        text='',
        font='Open Sans',
        pos=(0.55, 0.42), height=0.05, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-8.0);
    prog_bar_border = visual.Rect(
        win=win, name='prog_bar_border',
        width=(0.8, 0.03)[0], height=(0.8, 0.03)[1],
        ori=0.0, pos=(-0.4, 0.42), anchor='center-left',
        lineWidth=4.0,     colorSpace='rgb',  lineColor='black', fillColor='white',
        opacity=None, depth=-9.0, interpolate=True)
    prog_bar_rect = visual.Rect(
        win=win, name='prog_bar_rect',
        width=[1.0, 1.0][0], height=[1.0, 1.0][1],
        ori=0.0, pos=(-0.4, 0.42), anchor='center-left',
        lineWidth=4.0,     colorSpace='rgb',  lineColor='black', fillColor='black',
        opacity=None, depth=-10.0, interpolate=True)
    
    # --- Initialize components for Routine "feedback_corrective" ---
    trial_rock_train_2 = visual.ImageStim(
        win=win,
        name='trial_rock_train_2', 
        image='default.png', mask=None, anchor='center',
        ori=0.0, pos=(0, 0.1), size=1.0,
        color=[1,1,1], colorSpace='rgb', opacity=None,
        flipHoriz=False, flipVert=False,
        texRes=128.0, interpolate=True, depth=-1.0)
    fb_text_l = visual.TextStim(win=win, name='fb_text_l',
        text='',
        font='Open Sans',
        pos=(0, -0.22), height=0.05, wrapWidth=None, ori=0.0, 
        color='white', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-2.0);
    fb_text_l_2 = visual.TextStim(win=win, name='fb_text_l_2',
        text='',
        font='Open Sans',
        pos=(0, -0.28), height=0.05, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-3.0);
    next = visual.ImageStim(
        win=win,
        name='next', 
        image='img/next.png', mask=None, anchor='center',
        ori=0.0, pos=(0, -0.4), size=next_buttonSize,
        color='white', colorSpace='rgb', opacity=None,
        flipHoriz=False, flipVert=False,
        texRes=128.0, interpolate=True, depth=-4.0)
    fb_mouse = event.Mouse(win=win)
    x, y = [None, None]
    fb_mouse.mouseClock = core.Clock()
    
    # --- Initialize components for Routine "end_of_trainingProcess" ---
    
    # --- Initialize components for Routine "test_instrPrep" ---
    # Run 'Begin Experiment' code from instrPrecode_test
    cur_row_test = 0
    show_instructions_test = 1
    max_slides_test = 3 -1
    
    
    # --- Initialize components for Routine "test_instructions" ---
    instruction_image_test = visual.ImageStim(
        win=win,
        name='instruction_image_test', 
        image='default.png', mask=None, anchor='center',
        ori=0.0, pos=(0, 0), size=(1.1, 0.62),
        color='white', colorSpace='rgb', opacity=None,
        flipHoriz=False, flipVert=False,
        texRes=128.0, interpolate=True, depth=0.0)
    leftArrow_2 = visual.ImageStim(
        win=win,
        name='leftArrow_2', 
        image='img/leftarrow.png', mask=None, anchor='center',
        ori=0.0, pos=arrowPos_back, size=arrowSize,
        color='white', colorSpace='rgb', opacity=None,
        flipHoriz=False, flipVert=False,
        texRes=128.0, interpolate=True, depth=-1.0)
    rightArrow_2 = visual.ImageStim(
        win=win,
        name='rightArrow_2', 
        image='img/rightarrow.png', mask=None, anchor='center',
        ori=0.0, pos=arrowPos_next, size=arrowSize,
        color='white', colorSpace='rgb', opacity=None,
        flipHoriz=False, flipVert=False,
        texRes=128.0, interpolate=True, depth=-2.0)
    instruct_mouse_test = event.Mouse(win=win)
    x, y = [None, None]
    instruct_mouse_test.mouseClock = core.Clock()
    instruct_counter_test = visual.TextStim(win=win, name='instruct_counter_test',
        text='',
        font='Open Sans',
        pos=(0, -.45), height=0.05, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-4.0);
    
    # --- Initialize components for Routine "start_of_testProcess" ---
    block_prompt_test = visual.TextStim(win=win, name='block_prompt_test',
        text='',
        font='Open Sans',
        pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=0.0);
    
    # --- Initialize components for Routine "Classification_test" ---
    trial_rock_test = visual.ImageStim(
        win=win,
        name='trial_rock_test', 
        image='default.png', mask=None, anchor='center',
        ori=0.0, pos=(0, 0.1), size=1.0,
        color='white', colorSpace='rgb', opacity=None,
        flipHoriz=False, flipVert=False,
        texRes=128.0, interpolate=True, depth=-4.0)
    progress_bar_text_3 = visual.TextStim(win=win, name='progress_bar_text_3',
        text='Progress',
        font='Open Sans',
        pos=(-0.55, 0.42), height=0.05, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-5.0);
    test_trial_counter = visual.TextStim(win=win, name='test_trial_counter',
        text='',
        font='Open Sans',
        pos=(0.55, 0.42), height=0.05, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-6.0);
    prog_bar_border_2 = visual.Rect(
        win=win, name='prog_bar_border_2',
        width=(0.8, 0.03)[0], height=(0.8, 0.03)[1],
        ori=0.0, pos=(-0.4, 0.42), anchor='center-left',
        lineWidth=4.0,     colorSpace='rgb',  lineColor='black', fillColor='white',
        opacity=None, depth=-7.0, interpolate=True)
    prog_bar_rect_2 = visual.Rect(
        win=win, name='prog_bar_rect_2',
        width=[1.0, 1.0][0], height=[1.0, 1.0][1],
        ori=0.0, pos=(-0.4, 0.42), anchor='center-left',
        lineWidth=2.0,     colorSpace='rgb',  lineColor='black', fillColor='black',
        opacity=None, depth=-8.0, interpolate=True)
    cat_mouse_t = event.Mouse(win=win)
    x, y = [None, None]
    cat_mouse_t.mouseClock = core.Clock()
    
    # --- Initialize components for Routine "feedback_neutral" ---
    fb_text_t = visual.TextStim(win=win, name='fb_text_t',
        text='Okay',
        font='Open Sans',
        pos=(0, 0), height=0.04, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=0.0);
    
    # --- Initialize components for Routine "end_of_testProcess" ---
    # Run 'Begin Experiment' code from format_accuracy_summary
    prc_corr_block_last3 = []
    
    end_block_msg_2 = visual.TextStim(win=win, name='end_block_msg_2',
        text='',
        font='Open Sans',
        pos=(0, 0), height=0.05, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-1.0);
    feedbackSC1 = visual.TextStim(win=win, name='feedbackSC1',
        text='Summary of classification accuracy for each category:\n',
        font='Open Sans',
        pos=(0, 0.4), height=0.05, wrapWidth=1.0, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-2.0);
    feedbackSC2 = visual.TextStim(win=win, name='feedbackSC2',
        text='',
        font='Open Sans',
        pos=(0, -0.05), height=0.04, wrapWidth=None, ori=0.0, 
        color='red', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-3.0);
    feedbackTC1 = visual.TextStim(win=win, name='feedbackTC1',
        text='',
        font='Open Sans',
        pos=(0, 0), height=0.04, wrapWidth=None, ori=0.0, 
        color='black', colorSpace='rgb', opacity=None, 
        languageStyle='LTR',
        depth=-4.0);
    next_block_fb = visual.ImageStim(
        win=win,
        name='next_block_fb', 
        image='img/next.png', mask=None, anchor='center',
        ori=0.0, pos=(0, -0.4), size=next_buttonSize,
        color='white', colorSpace='rgb', opacity=None,
        flipHoriz=False, flipVert=False,
        texRes=128.0, interpolate=True, depth=-5.0)
    next_mouse_block_fb = event.Mouse(win=win)
    x, y = [None, None]
    next_mouse_block_fb.mouseClock = core.Clock()
    # Run 'Begin Experiment' code from compute_diff_indices
    PS_dict_blocks = {};
    for cat_name in category_names:
        PS_dict_blocks[cat_name] = []
    
    # --- Initialize components for Routine "debrief" ---
    debrief_report = visual.ImageStim(
        win=win,
        name='debrief_report', 
        image='Instructions/debrief.png', mask=None, anchor='center',
        ori=0.0, pos=(0, 0), size=(1.4, 0.8),
        color='white', colorSpace='rgb', opacity=None,
        flipHoriz=False, flipVert=False,
        texRes=128.0, interpolate=True, depth=0.0)
    next_end_expt = visual.ImageStim(
        win=win,
        name='next_end_expt', 
        image='img/next.png', mask=None, anchor='center',
        ori=0.0, pos=(0, -0.4), size=next_buttonSize,
        color='white', colorSpace='rgb', opacity=None,
        flipHoriz=False, flipVert=False,
        texRes=128.0, interpolate=True, depth=-1.0)
    next_mouse_end_expt = event.Mouse(win=win)
    x, y = [None, None]
    next_mouse_end_expt.mouseClock = core.Clock()
    
    # create some handy timers
    if globalClock is None:
        globalClock = core.Clock()  # to track the time since experiment started
    if ioServer is not None:
        ioServer.syncClock(globalClock)
    logging.setDefaultClock(globalClock)
    routineTimer = core.Clock()  # to track time remaining of each (possibly non-slip) routine
    win.flip()  # flip window to reset last flip timer
    # store the exact time the global clock started
    expInfo['expStart'] = data.getDateStr(format='%Y-%m-%d %Hh%M.%S.%f %z', fractionalSecondDigits=6)
    
    # set up handler to look after randomisation of conditions etc
    preload_trials = data.TrialHandler(nReps=1.0, method='sequential', 
        extraInfo=expInfo, originPath=-1,
        trialList=data.importConditions('stimuli/rock_image_info.xlsx'),
        seed=None, name='preload_trials')
    thisExp.addLoop(preload_trials)  # add the loop to the experiment
    thisPreload_trial = preload_trials.trialList[0]  # so we can initialise stimuli with some values
    # abbreviate parameter names if possible (e.g. rgb = thisPreload_trial.rgb)
    if thisPreload_trial != None:
        for paramName in thisPreload_trial:
            globals()[paramName] = thisPreload_trial[paramName]
    
    for thisPreload_trial in preload_trials:
        currentLoop = preload_trials
        thisExp.timestampOnFlip(win, 'thisRow.t')
        # pause experiment here if requested
        if thisExp.status == PAUSED:
            pauseExperiment(
                thisExp=thisExp, 
                inputs=inputs, 
                win=win, 
                timers=[routineTimer], 
                playbackComponents=[]
        )
        # abbreviate parameter names if possible (e.g. rgb = thisPreload_trial.rgb)
        if thisPreload_trial != None:
            for paramName in thisPreload_trial:
                globals()[paramName] = thisPreload_trial[paramName]
        
        # --- Prepare to start Routine "load_image_info" ---
        continueRoutine = True
        # update component parameters for each repeat
        # keep track of which components have finished
        load_image_infoComponents = []
        for thisComponent in load_image_infoComponents:
            thisComponent.tStart = None
            thisComponent.tStop = None
            thisComponent.tStartRefresh = None
            thisComponent.tStopRefresh = None
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        # reset timers
        t = 0
        _timeToFirstFrame = win.getFutureFlipTime(clock="now")
        frameN = -1
        
        # --- Run Routine "load_image_info" ---
        routineForceEnded = not continueRoutine
        while continueRoutine:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # check for quit (typically the Esc key)
            if defaultKeyboard.getKeys(keyList=["escape"]):
                thisExp.status = FINISHED
            if thisExp.status == FINISHED or endExpNow:
                endExperiment(thisExp, inputs=inputs, win=win)
                return
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineForceEnded = True
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in load_image_infoComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        # --- Ending Routine "load_image_info" ---
        for thisComponent in load_image_infoComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        # the Routine "load_image_info" was not non-slip safe, so reset the non-slip timer
        routineTimer.reset()
    # completed 1.0 repeats of 'preload_trials'
    
    
    # set up handler to look after randomisation of conditions etc
    TrainInstructions_controller = data.TrialHandler(nReps=9999.0, method='random', 
        extraInfo=expInfo, originPath=-1,
        trialList=[None],
        seed=None, name='TrainInstructions_controller')
    thisExp.addLoop(TrainInstructions_controller)  # add the loop to the experiment
    thisTrainInstructions_controller = TrainInstructions_controller.trialList[0]  # so we can initialise stimuli with some values
    # abbreviate parameter names if possible (e.g. rgb = thisTrainInstructions_controller.rgb)
    if thisTrainInstructions_controller != None:
        for paramName in thisTrainInstructions_controller:
            globals()[paramName] = thisTrainInstructions_controller[paramName]
    
    for thisTrainInstructions_controller in TrainInstructions_controller:
        currentLoop = TrainInstructions_controller
        thisExp.timestampOnFlip(win, 'thisRow.t')
        # pause experiment here if requested
        if thisExp.status == PAUSED:
            pauseExperiment(
                thisExp=thisExp, 
                inputs=inputs, 
                win=win, 
                timers=[routineTimer], 
                playbackComponents=[]
        )
        # abbreviate parameter names if possible (e.g. rgb = thisTrainInstructions_controller.rgb)
        if thisTrainInstructions_controller != None:
            for paramName in thisTrainInstructions_controller:
                globals()[paramName] = thisTrainInstructions_controller[paramName]
        
        # --- Prepare to start Routine "instPrep" ---
        continueRoutine = True
        # update component parameters for each repeat
        # Run 'Begin Routine' code from instrPrecode
        if(instruct_mouse_test.isPressedIn(rightArrow)):
            cur_row_train += 1
        elif(instruct_mouse_test.isPressedIn(leftArrow)):
            cur_row_train -= 1
        
        if(cur_row_train < 0):
            cur_row_train = 0
        
        if(cur_row_train > max_slides_train):
            TrainInstructions_controller.finished = 1
            show_instructions_train = 0
            
            cur_row_train = max_slides_train - 1
        
        cur_row_train_string = str(cur_row_train)
        
        # keep track of which components have finished
        instPrepComponents = []
        for thisComponent in instPrepComponents:
            thisComponent.tStart = None
            thisComponent.tStop = None
            thisComponent.tStartRefresh = None
            thisComponent.tStopRefresh = None
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        # reset timers
        t = 0
        _timeToFirstFrame = win.getFutureFlipTime(clock="now")
        frameN = -1
        
        # --- Run Routine "instPrep" ---
        routineForceEnded = not continueRoutine
        while continueRoutine:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # check for quit (typically the Esc key)
            if defaultKeyboard.getKeys(keyList=["escape"]):
                thisExp.status = FINISHED
            if thisExp.status == FINISHED or endExpNow:
                endExperiment(thisExp, inputs=inputs, win=win)
                return
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineForceEnded = True
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in instPrepComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        # --- Ending Routine "instPrep" ---
        for thisComponent in instPrepComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        # the Routine "instPrep" was not non-slip safe, so reset the non-slip timer
        routineTimer.reset()
        
        # set up handler to look after randomisation of conditions etc
        TrainInstruction_trials = data.TrialHandler(nReps=show_instructions_train, method='sequential', 
            extraInfo=expInfo, originPath=-1,
            trialList=data.importConditions(instruct_filename, selection=cur_row_train_string),
            seed=None, name='TrainInstruction_trials')
        thisExp.addLoop(TrainInstruction_trials)  # add the loop to the experiment
        thisTrainInstruction_trial = TrainInstruction_trials.trialList[0]  # so we can initialise stimuli with some values
        # abbreviate parameter names if possible (e.g. rgb = thisTrainInstruction_trial.rgb)
        if thisTrainInstruction_trial != None:
            for paramName in thisTrainInstruction_trial:
                globals()[paramName] = thisTrainInstruction_trial[paramName]
        
        for thisTrainInstruction_trial in TrainInstruction_trials:
            currentLoop = TrainInstruction_trials
            thisExp.timestampOnFlip(win, 'thisRow.t')
            # pause experiment here if requested
            if thisExp.status == PAUSED:
                pauseExperiment(
                    thisExp=thisExp, 
                    inputs=inputs, 
                    win=win, 
                    timers=[routineTimer], 
                    playbackComponents=[]
            )
            # abbreviate parameter names if possible (e.g. rgb = thisTrainInstruction_trial.rgb)
            if thisTrainInstruction_trial != None:
                for paramName in thisTrainInstruction_trial:
                    globals()[paramName] = thisTrainInstruction_trial[paramName]
            
            # --- Prepare to start Routine "train_instructions" ---
            continueRoutine = True
            # update component parameters for each repeat
            instruction_image_train.setImage(train_slide)
            # setup some python lists for storing info about the instruct_mouse_train
            instruct_mouse_train.clicked_name = []
            gotValidClick = False  # until a click is received
            instruct_counter_train.setText(str(cur_row_train + 1) + '/' + str(max_slides_train + 1))
            # keep track of which components have finished
            train_instructionsComponents = [instruction_image_train, leftArrow, rightArrow, instruct_mouse_train, instruct_counter_train]
            for thisComponent in train_instructionsComponents:
                thisComponent.tStart = None
                thisComponent.tStop = None
                thisComponent.tStartRefresh = None
                thisComponent.tStopRefresh = None
                if hasattr(thisComponent, 'status'):
                    thisComponent.status = NOT_STARTED
            # reset timers
            t = 0
            _timeToFirstFrame = win.getFutureFlipTime(clock="now")
            frameN = -1
            
            # --- Run Routine "train_instructions" ---
            routineForceEnded = not continueRoutine
            while continueRoutine:
                # get current time
                t = routineTimer.getTime()
                tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                
                # *instruction_image_train* updates
                
                # if instruction_image_train is starting this frame...
                if instruction_image_train.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    instruction_image_train.frameNStart = frameN  # exact frame index
                    instruction_image_train.tStart = t  # local t and not account for scr refresh
                    instruction_image_train.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(instruction_image_train, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    instruction_image_train.status = STARTED
                    instruction_image_train.setAutoDraw(True)
                
                # if instruction_image_train is active this frame...
                if instruction_image_train.status == STARTED:
                    # update params
                    pass
                
                # *leftArrow* updates
                
                # if leftArrow is starting this frame...
                if leftArrow.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    leftArrow.frameNStart = frameN  # exact frame index
                    leftArrow.tStart = t  # local t and not account for scr refresh
                    leftArrow.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(leftArrow, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    leftArrow.status = STARTED
                    leftArrow.setAutoDraw(True)
                
                # if leftArrow is active this frame...
                if leftArrow.status == STARTED:
                    # update params
                    pass
                
                # *rightArrow* updates
                
                # if rightArrow is starting this frame...
                if rightArrow.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    rightArrow.frameNStart = frameN  # exact frame index
                    rightArrow.tStart = t  # local t and not account for scr refresh
                    rightArrow.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(rightArrow, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    rightArrow.status = STARTED
                    rightArrow.setAutoDraw(True)
                
                # if rightArrow is active this frame...
                if rightArrow.status == STARTED:
                    # update params
                    pass
                # *instruct_mouse_train* updates
                
                # if instruct_mouse_train is starting this frame...
                if instruct_mouse_train.status == NOT_STARTED and t >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    instruct_mouse_train.frameNStart = frameN  # exact frame index
                    instruct_mouse_train.tStart = t  # local t and not account for scr refresh
                    instruct_mouse_train.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(instruct_mouse_train, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    instruct_mouse_train.status = STARTED
                    instruct_mouse_train.mouseClock.reset()
                    prevButtonState = instruct_mouse_train.getPressed()  # if button is down already this ISN'T a new click
                if instruct_mouse_train.status == STARTED:  # only update if started and not finished!
                    buttons = instruct_mouse_train.getPressed()
                    if buttons != prevButtonState:  # button state changed?
                        prevButtonState = buttons
                        if sum(buttons) > 0:  # state changed to a new click
                            # check if the mouse was inside our 'clickable' objects
                            gotValidClick = False
                            clickableList = environmenttools.getFromNames([leftArrow,rightArrow], namespace=locals())
                            for obj in clickableList:
                                # is this object clicked on?
                                if obj.contains(instruct_mouse_train):
                                    gotValidClick = True
                                    instruct_mouse_train.clicked_name.append(obj.name)
                            if gotValidClick:  
                                continueRoutine = False  # end routine on response
                
                # *instruct_counter_train* updates
                
                # if instruct_counter_train is starting this frame...
                if instruct_counter_train.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    instruct_counter_train.frameNStart = frameN  # exact frame index
                    instruct_counter_train.tStart = t  # local t and not account for scr refresh
                    instruct_counter_train.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(instruct_counter_train, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    instruct_counter_train.status = STARTED
                    instruct_counter_train.setAutoDraw(True)
                
                # if instruct_counter_train is active this frame...
                if instruct_counter_train.status == STARTED:
                    # update params
                    pass
                
                # check for quit (typically the Esc key)
                if defaultKeyboard.getKeys(keyList=["escape"]):
                    thisExp.status = FINISHED
                if thisExp.status == FINISHED or endExpNow:
                    endExperiment(thisExp, inputs=inputs, win=win)
                    return
                
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    routineForceEnded = True
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in train_instructionsComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
                
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            # --- Ending Routine "train_instructions" ---
            for thisComponent in train_instructionsComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            # store data for TrainInstruction_trials (TrialHandler)
            # the Routine "train_instructions" was not non-slip safe, so reset the non-slip timer
            routineTimer.reset()
        # completed show_instructions_train repeats of 'TrainInstruction_trials'
        
    # completed 9999.0 repeats of 'TrainInstructions_controller'
    
    
    # --- Prepare to start Routine "expt_setup" ---
    continueRoutine = True
    # update component parameters for each repeat
    # Run 'Begin Routine' code from def_rock_params
    # partition token indices into training and test sets
    cat_token_index_train = []
    cat_token_index_test = []
    for cat_name in category_names:
        file_names_cat = [file.name for file in rockInfo_dict if cat_name in file.name]
        separatePairs = []
        if cat_name in substring_map:
            for substrings in substring_map[cat_name]:
                rockIndex = [None, None]
                rockIndex[0] = [index for index, file in enumerate(file_names_cat) if substrings[0] in file.name]
                rockIndex[1] = [index for index, file in enumerate(file_names_cat) if substrings[1] in file.name]
                separatePairs.append(rockIndex)
    
        IndexList = list(range(12))
        [part1, part2] = partitionList(IndexList, separatePairs)
        cat_token_index_train.append(part1)
        cat_token_index_test.append(part2)
    
    # define grid image files
    image_files_ordered = []
    for irow in range(num_rows):
        row_image_files = []
        for icat in range(num_cats):
            cat_name = category_names[icat]
            rockInfo_dict_cat = [file for file in rockInfo_dict if cat_name in file.name]
            token_idx = cat_token_index_train[icat][irow]
            row_image_files.append(rockInfo_dict_cat[token_idx])
        image_files_ordered.append(row_image_files)
         
    grid_image_files = shuffle_nested_list(image_files_ordered)
    # Run 'Begin Routine' code from def_rock_grid
    rock_grid = []
    rock_rect_grid = []
    rock_rows = []
    rock_cols = []
    rock_pos = []
    image_file = []
    rock_info = []
    rock_name = []
    rock_rect_name = []
    rock_image = []
    rock_rect = []
    for irow in range(num_rows):
        for icol in range(num_cols):
            rock_pos = grid_image_pos[irow][icol]
            image_file = grid_image_files[irow][icol]
            rock_info = extract_rock_info(image_file)
            rock_name = rock_info["type"] + "_" + rock_info["token"]
            rock_rect_name = rock_name + "_" + "rect"
            rock_image = visual.ImageStim(
                            win=win,
                            name=rock_name, 
                            image=directory_path+'/'+image_file, mask=None, anchor='center',
                            ori=0.0, pos=rock_pos, size = gridSize,
                            color=[1,1,1], colorSpace='rgb', opacity=None,
                            flipHoriz=False, flipVert=False,
                            texRes=128.0, interpolate=True, depth=-1.0)
            rock_rect = visual.Rect(
                            win=win, name=rock_rect_name,
                            width=0.15, height=0.15,
                            ori=0.0, pos=rock_pos, anchor='center',
                            lineWidth=4.0, colorSpace='rgb', lineColor=[0.5,0.5,0], fillColor=None,
                            opacity=1, depth=-5.0, interpolate=True)
            rock_grid.append(rock_image)
            rock_rect_grid.append(rock_rect)
            rock_rows.append(irow)
            rock_cols.append(icol)
    
    
    # Run 'Begin Routine' code from sample_rocks_train
    if expInfo['condition'] in ['TCR', 'TCN', 'SCR']:
        logical_order = []
        for icat in range(num_cats):
            logical_cat = []
            for irep in range(3):
                permutation = np.random.permutation(num_rows)
                logical_cat.extend(permutation)
        logical_order.append(logical_cat)
    
        train_images = []
        for iblock in range(nblock):
            seq_idx = []
            seq_idx.append(iblock*2)
            seq_idx.append(iblock*2 + 1)
            block_images = []
            for icat in range(num_cats):
                logical_idx1 = logical_order[icat][seq_idx[0]]
                logical_idx2 = logical_order[icat][seq_idx[1]]
                cat_name = category_names[icat]
                file_names_cat = [item for item in file_names if cat_name in item]
                tokens_idx1 = cat_token_index_train[icat][logical_idx1]
                tokens_idx2 = cat_token_index_train[icat][logical_idx2]
                block_images.append(file_names_cat[tokens_idx1])
                block_images.append(file_names_cat[tokens_idx2])
            block_images = shuffleListElement(block_images)
            train_images.append(block_images)
    
    
    
    # Run 'Begin Routine' code from sample_rocks_test
    logical_order = []
    for _ in range(num_cats):
        logical_cat = []
        for _ in range(3):
            permutation = np.random.permutation(num_rows)
            logical_cat.extend(permutation)
        logical_order.append(logical_cat)
    
    test_images = []
    for iblock in range(nblock):
        seq_idx = []
        seq_idx.append(iblock*2)
        seq_idx.append(iblock*2 + 1)
        block_images = []
        for icat in range(num_cats):
            logical_idx1 = logical_order[icat][seq_idx[0]]
            logical_idx2 = logical_order[icat][seq_idx[1]]
            cat_name = category_names[icat]
            file_names_cat = [item for item in file_names if cat_name in item]
            tokens_idx1 = cat_token_index_test[icat][logical_idx1]
            tokens_idx2 = cat_token_index_test[icat][logical_idx2]
            block_images.append(file_names_cat[tokens_idx1])
            block_images.append(file_names_cat[tokens_idx2])
        block_images = shuffleListElement(block_images)
        test_images.append(block_images)
    # keep track of which components have finished
    expt_setupComponents = []
    for thisComponent in expt_setupComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "expt_setup" ---
    routineForceEnded = not continueRoutine
    while continueRoutine:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # check for quit (typically the Esc key)
        if defaultKeyboard.getKeys(keyList=["escape"]):
            thisExp.status = FINISHED
        if thisExp.status == FINISHED or endExpNow:
            endExperiment(thisExp, inputs=inputs, win=win)
            return
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in expt_setupComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "expt_setup" ---
    for thisComponent in expt_setupComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # the Routine "expt_setup" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    
    # set up handler to look after randomisation of conditions etc
    blocks = data.TrialHandler(nReps=3.0, method='random', 
        extraInfo=expInfo, originPath=-1,
        trialList=[None],
        seed=None, name='blocks')
    thisExp.addLoop(blocks)  # add the loop to the experiment
    thisBlock = blocks.trialList[0]  # so we can initialise stimuli with some values
    # abbreviate parameter names if possible (e.g. rgb = thisBlock.rgb)
    if thisBlock != None:
        for paramName in thisBlock:
            globals()[paramName] = thisBlock[paramName]
    
    for thisBlock in blocks:
        currentLoop = blocks
        thisExp.timestampOnFlip(win, 'thisRow.t')
        # pause experiment here if requested
        if thisExp.status == PAUSED:
            pauseExperiment(
                thisExp=thisExp, 
                inputs=inputs, 
                win=win, 
                timers=[routineTimer], 
                playbackComponents=[]
        )
        # abbreviate parameter names if possible (e.g. rgb = thisBlock.rgb)
        if thisBlock != None:
            for paramName in thisBlock:
                globals()[paramName] = thisBlock[paramName]
        
        # --- Prepare to start Routine "start_of_trainingProcess" ---
        continueRoutine = True
        # update component parameters for each repeat
        block_prompt_train.setText('Starting Training Block ' + str(blocks.thisN + 1) +  ' of ' + str(blocks.nTotal))
        # Run 'Begin Routine' code from adjust_rocks_train_block
        if expInfo['condition'] in ['SCR', 'TCR']:
            train_block_images = []
            if blocks.thisN == 0:
                train_block_images = train_images[blocks.thisN]
            else:
                prc_list_thisblock = list(prc_dict_thisblock.values())
                num_items_cats = prop_to_count(prc_list_thisblock,2*num_cats)
                cat_name = []
                file_namesizes_cat = []
                file_sampled_cat = []
                for icat in range(num_cats):
                    cat_name = category_names[icat]
                    file_namesizes_cat = [file for file in file_namesizes if cat_name in file.name]
                    file_sampled_cat = getRandomSample(file_namesizes_cat,num_items_cats[icat])
                    train_block_images.extend(file_sampled_cat)
                train_block_images = shuffleListElement(train_block_images)
        elif expInfo['condition'] === 'TCN':
            train_block_images = train_images[blocks.thisN]
        # keep track of which components have finished
        start_of_trainingProcessComponents = [block_prompt_train]
        for thisComponent in start_of_trainingProcessComponents:
            thisComponent.tStart = None
            thisComponent.tStop = None
            thisComponent.tStartRefresh = None
            thisComponent.tStopRefresh = None
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        # reset timers
        t = 0
        _timeToFirstFrame = win.getFutureFlipTime(clock="now")
        frameN = -1
        
        # --- Run Routine "start_of_trainingProcess" ---
        routineForceEnded = not continueRoutine
        while continueRoutine and routineTimer.getTime() < 1.0:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *block_prompt_train* updates
            
            # if block_prompt_train is starting this frame...
            if block_prompt_train.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                block_prompt_train.frameNStart = frameN  # exact frame index
                block_prompt_train.tStart = t  # local t and not account for scr refresh
                block_prompt_train.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(block_prompt_train, 'tStartRefresh')  # time at next scr refresh
                # update status
                block_prompt_train.status = STARTED
                block_prompt_train.setAutoDraw(True)
            
            # if block_prompt_train is active this frame...
            if block_prompt_train.status == STARTED:
                # update params
                pass
            
            # if block_prompt_train is stopping this frame...
            if block_prompt_train.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > block_prompt_train.tStartRefresh + 1.0-frameTolerance:
                    # keep track of stop time/frame for later
                    block_prompt_train.tStop = t  # not accounting for scr refresh
                    block_prompt_train.frameNStop = frameN  # exact frame index
                    # update status
                    block_prompt_train.status = FINISHED
                    block_prompt_train.setAutoDraw(False)
            
            # check for quit (typically the Esc key)
            if defaultKeyboard.getKeys(keyList=["escape"]):
                thisExp.status = FINISHED
            if thisExp.status == FINISHED or endExpNow:
                endExperiment(thisExp, inputs=inputs, win=win)
                return
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineForceEnded = True
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in start_of_trainingProcessComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        # --- Ending Routine "start_of_trainingProcess" ---
        for thisComponent in start_of_trainingProcessComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
        if routineForceEnded:
            routineTimer.reset()
        else:
            routineTimer.addTime(-1.000000)
        
        # set up handler to look after randomisation of conditions etc
        train_trials = data.TrialHandler(nReps=2*num_cats, method='random', 
            extraInfo=expInfo, originPath=-1,
            trialList=[None],
            seed=None, name='train_trials')
        thisExp.addLoop(train_trials)  # add the loop to the experiment
        thisTrain_trial = train_trials.trialList[0]  # so we can initialise stimuli with some values
        # abbreviate parameter names if possible (e.g. rgb = thisTrain_trial.rgb)
        if thisTrain_trial != None:
            for paramName in thisTrain_trial:
                globals()[paramName] = thisTrain_trial[paramName]
        
        for thisTrain_trial in train_trials:
            currentLoop = train_trials
            thisExp.timestampOnFlip(win, 'thisRow.t')
            # pause experiment here if requested
            if thisExp.status == PAUSED:
                pauseExperiment(
                    thisExp=thisExp, 
                    inputs=inputs, 
                    win=win, 
                    timers=[routineTimer], 
                    playbackComponents=[]
            )
            # abbreviate parameter names if possible (e.g. rgb = thisTrain_trial.rgb)
            if thisTrain_trial != None:
                for paramName in thisTrain_trial:
                    globals()[paramName] = thisTrain_trial[paramName]
            
            # --- Prepare to start Routine "fixation" ---
            continueRoutine = True
            # update component parameters for each repeat
            # setup some python lists for storing info about the fix_mouse
            gotValidClick = False  # until a click is received
            # keep track of which components have finished
            fixationComponents = [fix_text, fix_circle, fix_mouse]
            for thisComponent in fixationComponents:
                thisComponent.tStart = None
                thisComponent.tStop = None
                thisComponent.tStartRefresh = None
                thisComponent.tStopRefresh = None
                if hasattr(thisComponent, 'status'):
                    thisComponent.status = NOT_STARTED
            # reset timers
            t = 0
            _timeToFirstFrame = win.getFutureFlipTime(clock="now")
            frameN = -1
            
            # --- Run Routine "fixation" ---
            routineForceEnded = not continueRoutine
            while continueRoutine:
                # get current time
                t = routineTimer.getTime()
                tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                # Run 'Each Frame' code from fix_end_code
                if fix_circle.contains(fix_mouse):
                    continueRoutine = False
                
                # *fix_text* updates
                
                # if fix_text is starting this frame...
                if fix_text.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    fix_text.frameNStart = frameN  # exact frame index
                    fix_text.tStart = t  # local t and not account for scr refresh
                    fix_text.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(fix_text, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    fix_text.status = STARTED
                    fix_text.setAutoDraw(True)
                
                # if fix_text is active this frame...
                if fix_text.status == STARTED:
                    # update params
                    pass
                
                # *fix_circle* updates
                
                # if fix_circle is starting this frame...
                if fix_circle.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    fix_circle.frameNStart = frameN  # exact frame index
                    fix_circle.tStart = t  # local t and not account for scr refresh
                    fix_circle.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(fix_circle, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    fix_circle.status = STARTED
                    fix_circle.setAutoDraw(True)
                
                # if fix_circle is active this frame...
                if fix_circle.status == STARTED:
                    # update params
                    pass
                # *fix_mouse* updates
                
                # if fix_mouse is starting this frame...
                if fix_mouse.status == NOT_STARTED and t >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    fix_mouse.frameNStart = frameN  # exact frame index
                    fix_mouse.tStart = t  # local t and not account for scr refresh
                    fix_mouse.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(fix_mouse, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    fix_mouse.status = STARTED
                    fix_mouse.mouseClock.reset()
                    prevButtonState = [0, 0, 0]  # if now button is down we will treat as 'new' click
                
                # check for quit (typically the Esc key)
                if defaultKeyboard.getKeys(keyList=["escape"]):
                    thisExp.status = FINISHED
                if thisExp.status == FINISHED or endExpNow:
                    endExperiment(thisExp, inputs=inputs, win=win)
                    return
                
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    routineForceEnded = True
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in fixationComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
                
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            # --- Ending Routine "fixation" ---
            for thisComponent in fixationComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            # store data for train_trials (TrialHandler)
            # the Routine "fixation" was not non-slip safe, so reset the non-slip timer
            routineTimer.reset()
            
            # --- Prepare to start Routine "fixation_cross" ---
            continueRoutine = True
            # update component parameters for each repeat
            # skip this Routine if its 'Skip if' condition is True
            continueRoutine = continueRoutine and not (train_trials.thisN != 0)
            # keep track of which components have finished
            fixation_crossComponents = [fix_wait]
            for thisComponent in fixation_crossComponents:
                thisComponent.tStart = None
                thisComponent.tStop = None
                thisComponent.tStartRefresh = None
                thisComponent.tStopRefresh = None
                if hasattr(thisComponent, 'status'):
                    thisComponent.status = NOT_STARTED
            # reset timers
            t = 0
            _timeToFirstFrame = win.getFutureFlipTime(clock="now")
            frameN = -1
            
            # --- Run Routine "fixation_cross" ---
            routineForceEnded = not continueRoutine
            while continueRoutine and routineTimer.getTime() < 0.3:
                # get current time
                t = routineTimer.getTime()
                tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                
                # *fix_wait* updates
                
                # if fix_wait is starting this frame...
                if fix_wait.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    fix_wait.frameNStart = frameN  # exact frame index
                    fix_wait.tStart = t  # local t and not account for scr refresh
                    fix_wait.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(fix_wait, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    fix_wait.status = STARTED
                    fix_wait.setAutoDraw(True)
                
                # if fix_wait is active this frame...
                if fix_wait.status == STARTED:
                    # update params
                    pass
                
                # if fix_wait is stopping this frame...
                if fix_wait.status == STARTED:
                    # is it time to stop? (based on global clock, using actual start)
                    if tThisFlipGlobal > fix_wait.tStartRefresh + 0.3-frameTolerance:
                        # keep track of stop time/frame for later
                        fix_wait.tStop = t  # not accounting for scr refresh
                        fix_wait.frameNStop = frameN  # exact frame index
                        # update status
                        fix_wait.status = FINISHED
                        fix_wait.setAutoDraw(False)
                
                # check for quit (typically the Esc key)
                if defaultKeyboard.getKeys(keyList=["escape"]):
                    thisExp.status = FINISHED
                if thisExp.status == FINISHED or endExpNow:
                    endExperiment(thisExp, inputs=inputs, win=win)
                    return
                
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    routineForceEnded = True
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in fixation_crossComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
                
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            # --- Ending Routine "fixation_cross" ---
            for thisComponent in fixation_crossComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
            if routineForceEnded:
                routineTimer.reset()
            else:
                routineTimer.addTime(-0.300000)
            
            # --- Prepare to start Routine "condition_switch" ---
            continueRoutine = True
            # update component parameters for each repeat
            # Run 'Begin Routine' code from select_cond
            if expInfo['condition'] in ['TCN','TCR']:
                nrep_sampling = 1
                nrep_selection = 0
            elif expInfo['condition'] in ['SCN','SCR']:
                nrep_sampling = 0
                nrep_selection = 1
            # keep track of which components have finished
            condition_switchComponents = []
            for thisComponent in condition_switchComponents:
                thisComponent.tStart = None
                thisComponent.tStop = None
                thisComponent.tStartRefresh = None
                thisComponent.tStopRefresh = None
                if hasattr(thisComponent, 'status'):
                    thisComponent.status = NOT_STARTED
            # reset timers
            t = 0
            _timeToFirstFrame = win.getFutureFlipTime(clock="now")
            frameN = -1
            
            # --- Run Routine "condition_switch" ---
            routineForceEnded = not continueRoutine
            while continueRoutine:
                # get current time
                t = routineTimer.getTime()
                tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                
                # check for quit (typically the Esc key)
                if defaultKeyboard.getKeys(keyList=["escape"]):
                    thisExp.status = FINISHED
                if thisExp.status == FINISHED or endExpNow:
                    endExperiment(thisExp, inputs=inputs, win=win)
                    return
                
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    routineForceEnded = True
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in condition_switchComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
                
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            # --- Ending Routine "condition_switch" ---
            for thisComponent in condition_switchComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            # the Routine "condition_switch" was not non-slip safe, so reset the non-slip timer
            routineTimer.reset()
            
            # set up handler to look after randomisation of conditions etc
            SC_cond_filter = data.TrialHandler(nReps=nrep_selection, method='random', 
                extraInfo=expInfo, originPath=-1,
                trialList=[None],
                seed=None, name='SC_cond_filter')
            thisExp.addLoop(SC_cond_filter)  # add the loop to the experiment
            thisSC_cond_filter = SC_cond_filter.trialList[0]  # so we can initialise stimuli with some values
            # abbreviate parameter names if possible (e.g. rgb = thisSC_cond_filter.rgb)
            if thisSC_cond_filter != None:
                for paramName in thisSC_cond_filter:
                    globals()[paramName] = thisSC_cond_filter[paramName]
            
            for thisSC_cond_filter in SC_cond_filter:
                currentLoop = SC_cond_filter
                thisExp.timestampOnFlip(win, 'thisRow.t')
                # pause experiment here if requested
                if thisExp.status == PAUSED:
                    pauseExperiment(
                        thisExp=thisExp, 
                        inputs=inputs, 
                        win=win, 
                        timers=[routineTimer], 
                        playbackComponents=[]
                )
                # abbreviate parameter names if possible (e.g. rgb = thisSC_cond_filter.rgb)
                if thisSC_cond_filter != None:
                    for paramName in thisSC_cond_filter:
                        globals()[paramName] = thisSC_cond_filter[paramName]
                
                # --- Prepare to start Routine "Selection_train" ---
                continueRoutine = True
                # update component parameters for each repeat
                # Run 'Begin Routine' code from draw_rock_grid
                for i_rock in range(num_rows * num_cols):
                    rock_rect = rock_rect_grid[i_rock]
                    rock_image = rock_grid[i_rock]
                    rock_image.setAutoDraw(True)
                    if expInfo['condition'] == 'SCR':
                        trial_image = train_block_images[train_trials.thisN]
                        if trial_image.name in rock_image.image:
                            rock_rect.setAutoDraw(True)
                
                
                # setup some python lists for storing info about the learn_mouse
                learn_mouse.x = []
                learn_mouse.y = []
                learn_mouse.leftButton = []
                learn_mouse.midButton = []
                learn_mouse.rightButton = []
                learn_mouse.time = []
                learn_mouse.clicked_name = []
                gotValidClick = False  # until a click is received
                # Run 'Begin Routine' code from store_trial_vars_train
                thisExp.addData('block', blocks.thisN + 1)
                thisExp.addData('phase', 1)
                thisExp.addData('trial', train_trials.thisN + 1)
                # keep track of which components have finished
                Selection_trainComponents = [rock_grid_text, learn_mouse]
                for thisComponent in Selection_trainComponents:
                    thisComponent.tStart = None
                    thisComponent.tStop = None
                    thisComponent.tStartRefresh = None
                    thisComponent.tStopRefresh = None
                    if hasattr(thisComponent, 'status'):
                        thisComponent.status = NOT_STARTED
                # reset timers
                t = 0
                _timeToFirstFrame = win.getFutureFlipTime(clock="now")
                frameN = -1
                
                # --- Run Routine "Selection_train" ---
                routineForceEnded = not continueRoutine
                while continueRoutine:
                    # get current time
                    t = routineTimer.getTime()
                    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                    # update/draw components on each frame
                    # Run 'Each Frame' code from rock_selection
                    for i_rock in range(num_rows*num_cols):
                        MousePos = learn_mouse.getPos()
                        rock = rock_grid[i_rock]
                        rect = rock_rect_grid[i_rock]
                        rockPos = rock.pos
                        if eventfun.xydist(MousePos,rockPos) < max(rockSize)*.5:
                            rock.size = [.15,.15]
                            rect.lineColor = "red"
                        else:
                            rock.size = gridSize
                            rect.lineColor = "black"
                    
                    # *rock_grid_text* updates
                    
                    # if rock_grid_text is starting this frame...
                    if rock_grid_text.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                        # keep track of start time/frame for later
                        rock_grid_text.frameNStart = frameN  # exact frame index
                        rock_grid_text.tStart = t  # local t and not account for scr refresh
                        rock_grid_text.tStartRefresh = tThisFlipGlobal  # on global time
                        win.timeOnFlip(rock_grid_text, 'tStartRefresh')  # time at next scr refresh
                        # add timestamp to datafile
                        thisExp.timestampOnFlip(win, 'rock_grid_text.started')
                        # update status
                        rock_grid_text.status = STARTED
                        rock_grid_text.setAutoDraw(True)
                    
                    # if rock_grid_text is active this frame...
                    if rock_grid_text.status == STARTED:
                        # update params
                        pass
                    # *learn_mouse* updates
                    
                    # if learn_mouse is starting this frame...
                    if learn_mouse.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                        # keep track of start time/frame for later
                        learn_mouse.frameNStart = frameN  # exact frame index
                        learn_mouse.tStart = t  # local t and not account for scr refresh
                        learn_mouse.tStartRefresh = tThisFlipGlobal  # on global time
                        win.timeOnFlip(learn_mouse, 'tStartRefresh')  # time at next scr refresh
                        # update status
                        learn_mouse.status = STARTED
                        learn_mouse.mouseClock.reset()
                        prevButtonState = learn_mouse.getPressed()  # if button is down already this ISN'T a new click
                    if learn_mouse.status == STARTED:  # only update if started and not finished!
                        buttons = learn_mouse.getPressed()
                        if buttons != prevButtonState:  # button state changed?
                            prevButtonState = buttons
                            if sum(buttons) > 0:  # state changed to a new click
                                # check if the mouse was inside our 'clickable' objects
                                gotValidClick = False
                                clickableList = environmenttools.getFromNames([...rock_grid], namespace=locals())
                                for obj in clickableList:
                                    # is this object clicked on?
                                    if obj.contains(learn_mouse):
                                        gotValidClick = True
                                        learn_mouse.clicked_name.append(obj.name)
                                if gotValidClick:
                                    x, y = learn_mouse.getPos()
                                    learn_mouse.x.append(x)
                                    learn_mouse.y.append(y)
                                    buttons = learn_mouse.getPressed()
                                    learn_mouse.leftButton.append(buttons[0])
                                    learn_mouse.midButton.append(buttons[1])
                                    learn_mouse.rightButton.append(buttons[2])
                                    learn_mouse.time.append(learn_mouse.mouseClock.getTime())
                                if gotValidClick:
                                    continueRoutine = False  # end routine on response
                    
                    # check for quit (typically the Esc key)
                    if defaultKeyboard.getKeys(keyList=["escape"]):
                        thisExp.status = FINISHED
                    if thisExp.status == FINISHED or endExpNow:
                        endExperiment(thisExp, inputs=inputs, win=win)
                        return
                    
                    # check if all components have finished
                    if not continueRoutine:  # a component has requested a forced-end of Routine
                        routineForceEnded = True
                        break
                    continueRoutine = False  # will revert to True if at least one component still running
                    for thisComponent in Selection_trainComponents:
                        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                            continueRoutine = True
                            break  # at least one component has not yet finished
                    
                    # refresh the screen
                    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                        win.flip()
                
                # --- Ending Routine "Selection_train" ---
                for thisComponent in Selection_trainComponents:
                    if hasattr(thisComponent, "setAutoDraw"):
                        thisComponent.setAutoDraw(False)
                # Run 'End Routine' code from rock_selection
                irow = []
                icol = []
                rock_aspect_ratio = []
                rock_filename = []
                cat = []
                token = []
                aspectRatio_clicked = []
                rock_clicked = []
                filename_clicked = []
                cat_clicked = []
                token_clicked = []
                row_clicked = []
                col_clicked = []
                for i_rock in range(num_rows*num_cols):
                    rock = rock_grid[i_rock]
                    irow = rock_rows[i_rock]
                    icol = rock_cols[i_rock]
                    rock_aspect_ratio = rocks_orig_size[i_rock]
                    rock_filename = grid_image_files[irow][icol]
                    cat = extract_rock_info(rock_filename)["type"]
                    token = extract_rock_info(rock_filename)["token"]
                    if learn_mouse.isPressedIn(rock):
                        aspectRatio_clicked = rock_aspect_ratio
                        rock_clicked = rock
                        filename_clicked = rock_filename
                        cat_clicked = cat
                        token_clicked = token
                        row_clicked = irow
                        col_clicked = icol
                            
                
                # Run 'End Routine' code from draw_rock_grid
                for i_rock in range(num_rows * num_cols):
                    rock_rect = rock_rect_grid[i_rock]
                    rock_image = rock_grid[i_rock]
                    rock_image.setAutoDraw(False)
                    if expInfo['condition'] == 'SCR':
                        trial_image = train_block_images[train_trials.thisN]
                        if trial_image.name in rock_image.image:
                            rock_rect.setAutoDraw(False)
                # store data for SC_cond_filter (TrialHandler)
                SC_cond_filter.addData('learn_mouse.x', learn_mouse.x)
                SC_cond_filter.addData('learn_mouse.y', learn_mouse.y)
                SC_cond_filter.addData('learn_mouse.leftButton', learn_mouse.leftButton)
                SC_cond_filter.addData('learn_mouse.midButton', learn_mouse.midButton)
                SC_cond_filter.addData('learn_mouse.rightButton', learn_mouse.rightButton)
                SC_cond_filter.addData('learn_mouse.time', learn_mouse.time)
                SC_cond_filter.addData('learn_mouse.clicked_name', learn_mouse.clicked_name)
                # Run 'End Routine' code from store_trial_vars_train
                thisExp.addData('cat', cat_clicked)
                thisExp.addData('token', token_clicked)
                thisExp.addData('row', row_clicked)
                thisExp.addData('col', col_clicked)
                thisExp.addData('t_select', round(learn_mouse.time[0],3))
                # the Routine "Selection_train" was not non-slip safe, so reset the non-slip timer
                routineTimer.reset()
            # completed nrep_selection repeats of 'SC_cond_filter'
            
            
            # set up handler to look after randomisation of conditions etc
            R_cond_filter = data.TrialHandler(nReps=nrep_sampling, method='random', 
                extraInfo=expInfo, originPath=-1,
                trialList=[None],
                seed=None, name='R_cond_filter')
            thisExp.addLoop(R_cond_filter)  # add the loop to the experiment
            thisR_cond_filter = R_cond_filter.trialList[0]  # so we can initialise stimuli with some values
            # abbreviate parameter names if possible (e.g. rgb = thisR_cond_filter.rgb)
            if thisR_cond_filter != None:
                for paramName in thisR_cond_filter:
                    globals()[paramName] = thisR_cond_filter[paramName]
            
            for thisR_cond_filter in R_cond_filter:
                currentLoop = R_cond_filter
                thisExp.timestampOnFlip(win, 'thisRow.t')
                # pause experiment here if requested
                if thisExp.status == PAUSED:
                    pauseExperiment(
                        thisExp=thisExp, 
                        inputs=inputs, 
                        win=win, 
                        timers=[routineTimer], 
                        playbackComponents=[]
                )
                # abbreviate parameter names if possible (e.g. rgb = thisR_cond_filter.rgb)
                if thisR_cond_filter != None:
                    for paramName in thisR_cond_filter:
                        globals()[paramName] = thisR_cond_filter[paramName]
                
                # --- Prepare to start Routine "Sampling_train" ---
                continueRoutine = True
                # update component parameters for each repeat
                # Run 'Begin Routine' code from draw_rock_grid_2
                for rock_image in rock_grid:
                    rock_image.setAutoDraw(True)
                # setup some python lists for storing info about the learn_mouse_2
                gotValidClick = False  # until a click is received
                # Run 'Begin Routine' code from store_trial_vars_train_2
                thisExp.addData('block', blocks.thisN + 1)
                thisExp.addData('phase', 1)
                thisExp.addData('trial', train_trials.thisN + 1)
                thisExp.addData('t_select', -1)
                # keep track of which components have finished
                Sampling_trainComponents = [rock_grid_text_2, learn_mouse_2]
                for thisComponent in Sampling_trainComponents:
                    thisComponent.tStart = None
                    thisComponent.tStop = None
                    thisComponent.tStartRefresh = None
                    thisComponent.tStopRefresh = None
                    if hasattr(thisComponent, 'status'):
                        thisComponent.status = NOT_STARTED
                # reset timers
                t = 0
                _timeToFirstFrame = win.getFutureFlipTime(clock="now")
                frameN = -1
                
                # --- Run Routine "Sampling_train" ---
                routineForceEnded = not continueRoutine
                while continueRoutine:
                    # get current time
                    t = routineTimer.getTime()
                    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                    # update/draw components on each frame
                    
                    # *rock_grid_text_2* updates
                    
                    # if rock_grid_text_2 is starting this frame...
                    if rock_grid_text_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                        # keep track of start time/frame for later
                        rock_grid_text_2.frameNStart = frameN  # exact frame index
                        rock_grid_text_2.tStart = t  # local t and not account for scr refresh
                        rock_grid_text_2.tStartRefresh = tThisFlipGlobal  # on global time
                        win.timeOnFlip(rock_grid_text_2, 'tStartRefresh')  # time at next scr refresh
                        # add timestamp to datafile
                        thisExp.timestampOnFlip(win, 'rock_grid_text_2.started')
                        # update status
                        rock_grid_text_2.status = STARTED
                        rock_grid_text_2.setAutoDraw(True)
                    
                    # if rock_grid_text_2 is active this frame...
                    if rock_grid_text_2.status == STARTED:
                        # update params
                        pass
                    # *learn_mouse_2* updates
                    
                    # if learn_mouse_2 is starting this frame...
                    if learn_mouse_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                        # keep track of start time/frame for later
                        learn_mouse_2.frameNStart = frameN  # exact frame index
                        learn_mouse_2.tStart = t  # local t and not account for scr refresh
                        learn_mouse_2.tStartRefresh = tThisFlipGlobal  # on global time
                        win.timeOnFlip(learn_mouse_2, 'tStartRefresh')  # time at next scr refresh
                        # update status
                        learn_mouse_2.status = STARTED
                        learn_mouse_2.mouseClock.reset()
                        prevButtonState = learn_mouse_2.getPressed()  # if button is down already this ISN'T a new click
                    if learn_mouse_2.status == STARTED:  # only update if started and not finished!
                        buttons = learn_mouse_2.getPressed()
                        if buttons != prevButtonState:  # button state changed?
                            prevButtonState = buttons
                            if sum(buttons) > 0:  # state changed to a new click
                                continueRoutine = False  # end routine on response                    
                    # check for quit (typically the Esc key)
                    if defaultKeyboard.getKeys(keyList=["escape"]):
                        thisExp.status = FINISHED
                    if thisExp.status == FINISHED or endExpNow:
                        endExperiment(thisExp, inputs=inputs, win=win)
                        return
                    
                    # check if all components have finished
                    if not continueRoutine:  # a component has requested a forced-end of Routine
                        routineForceEnded = True
                        break
                    continueRoutine = False  # will revert to True if at least one component still running
                    for thisComponent in Sampling_trainComponents:
                        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                            continueRoutine = True
                            break  # at least one component has not yet finished
                    
                    # refresh the screen
                    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                        win.flip()
                
                # --- Ending Routine "Sampling_train" ---
                for thisComponent in Sampling_trainComponents:
                    if hasattr(thisComponent, "setAutoDraw"):
                        thisComponent.setAutoDraw(False)
                # Run 'End Routine' code from draw_rock_grid_2
                for rock_image in rock_grid:
                    rock_image.setAutoDraw(False)
                # Run 'End Routine' code from extract_trial_rock_info
                trial_image = train_block_images[train_trials.thisN]
                trial_cat = extract_rock_info(trial_image)["type"]
                trial_token = extract_rock_info(trial_image)["token"]
                rock_width,rock_height = trial_rock_train.aspectRatio
                
                trial_rock_file = trial_image
                trial_rock_cat = trial_cat
                rock_width,rock_height = trial_rock_test.aspectRatio
                # store data for R_cond_filter (TrialHandler)
                # Run 'End Routine' code from store_trial_vars_train_2
                thisExp.addData('cat', trial_cat)
                thisExp.addData('token', trial_token)
                thisExp.addData('row', -1)
                thisExp.addData('col', -1)
                thisExp.addData('t_select', -1)
                # the Routine "Sampling_train" was not non-slip safe, so reset the non-slip timer
                routineTimer.reset()
            # completed nrep_sampling repeats of 'R_cond_filter'
            
            
            # --- Prepare to start Routine "Classification_train" ---
            continueRoutine = True
            # update component parameters for each repeat
            # Run 'Begin Routine' code from trial_rock_config
            if expInfo['condition'] in ['SCN','SCR']:
                trial_rock_file = filename_clicked
                rock_width,rock_height = aspectRatio_clicked
                aspect_ratio = rock_width/rock_height
            
            trial_rock_height = 0.55
            trial_rock_width = trial_rock_height * aspect_ratio
            trial_rock_size = [trial_rock_width,trial_rock_height]
            
            
            
              
                
            # Run 'Begin Routine' code from prog_bar_train
            prog_total = blocks.nTotal * n_trials_total
            prog_cur = blocks.thisN * n_trials_total + train_trials.thisN + 2
            prog_var = prog_cur/prog_total
            trial_counter_txt = "Trial # " + str(train_trials.thisN + 1) + "/" + str(train_trials.nTotal)
            trial_rock_image = directory_path + '/' + trial_rock_file
            
            
            # Run 'Begin Routine' code from draw_button_panel
            rect = []
            txt = []
            for i_button in range(buttons_ntotal):
                rect = cat_button_clickable[i_button]
                txt = cat_button_text[i_button]
                rect.setAutoDraw(True)
                txt.setAutoDraw(True)
            trial_rock_train.setSize(trial_rock_size)
            trial_rock_train.setImage(trial_rock_image)
            # setup some python lists for storing info about the cat_mouse_l
            cat_mouse_l.x = []
            cat_mouse_l.y = []
            cat_mouse_l.leftButton = []
            cat_mouse_l.midButton = []
            cat_mouse_l.rightButton = []
            cat_mouse_l.time = []
            cat_mouse_l.clicked_name = []
            gotValidClick = False  # until a click is received
            train_trial_counter.setText(trial_counter_txt)
            prog_bar_rect.setSize((prog_var * 0.8, 0.03))
            # keep track of which components have finished
            Classification_trainComponents = [trial_rock_train, cat_mouse_l, progress_bar_text, train_trial_counter, prog_bar_border, prog_bar_rect]
            for thisComponent in Classification_trainComponents:
                thisComponent.tStart = None
                thisComponent.tStop = None
                thisComponent.tStartRefresh = None
                thisComponent.tStopRefresh = None
                if hasattr(thisComponent, 'status'):
                    thisComponent.status = NOT_STARTED
            # reset timers
            t = 0
            _timeToFirstFrame = win.getFutureFlipTime(clock="now")
            frameN = -1
            
            # --- Run Routine "Classification_train" ---
            routineForceEnded = not continueRoutine
            while continueRoutine:
                # get current time
                t = routineTimer.getTime()
                tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                # Run 'Each Frame' code from rock_classification
                button = []
                button_text = []
                for i_button in range(buttons_ntotal):
                    button = cat_button_clickable[i_button]
                    button_text = cat_button_text[i_button]
                    if button.contains(cat_mouse_l):
                        button.borderColor = 'red'
                        button_text.color = 'red'
                    else:
                        button.borderColor = 'black'
                        button_text.color = 'black'
                
                # *trial_rock_train* updates
                
                # if trial_rock_train is starting this frame...
                if trial_rock_train.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    trial_rock_train.frameNStart = frameN  # exact frame index
                    trial_rock_train.tStart = t  # local t and not account for scr refresh
                    trial_rock_train.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(trial_rock_train, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    trial_rock_train.status = STARTED
                    trial_rock_train.setAutoDraw(True)
                
                # if trial_rock_train is active this frame...
                if trial_rock_train.status == STARTED:
                    # update params
                    pass
                # *cat_mouse_l* updates
                
                # if cat_mouse_l is starting this frame...
                if cat_mouse_l.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    cat_mouse_l.frameNStart = frameN  # exact frame index
                    cat_mouse_l.tStart = t  # local t and not account for scr refresh
                    cat_mouse_l.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(cat_mouse_l, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    cat_mouse_l.status = STARTED
                    cat_mouse_l.mouseClock.reset()
                    prevButtonState = cat_mouse_l.getPressed()  # if button is down already this ISN'T a new click
                if cat_mouse_l.status == STARTED:  # only update if started and not finished!
                    buttons = cat_mouse_l.getPressed()
                    if buttons != prevButtonState:  # button state changed?
                        prevButtonState = buttons
                        if sum(buttons) > 0:  # state changed to a new click
                            # check if the mouse was inside our 'clickable' objects
                            gotValidClick = False
                            clickableList = environmenttools.getFromNames([...cat_button_clickable], namespace=locals())
                            for obj in clickableList:
                                # is this object clicked on?
                                if obj.contains(cat_mouse_l):
                                    gotValidClick = True
                                    cat_mouse_l.clicked_name.append(obj.name)
                            if gotValidClick:
                                x, y = cat_mouse_l.getPos()
                                cat_mouse_l.x.append(x)
                                cat_mouse_l.y.append(y)
                                buttons = cat_mouse_l.getPressed()
                                cat_mouse_l.leftButton.append(buttons[0])
                                cat_mouse_l.midButton.append(buttons[1])
                                cat_mouse_l.rightButton.append(buttons[2])
                                cat_mouse_l.time.append(cat_mouse_l.mouseClock.getTime())
                            if gotValidClick:
                                continueRoutine = False  # end routine on response
                
                # *progress_bar_text* updates
                
                # if progress_bar_text is starting this frame...
                if progress_bar_text.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    progress_bar_text.frameNStart = frameN  # exact frame index
                    progress_bar_text.tStart = t  # local t and not account for scr refresh
                    progress_bar_text.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(progress_bar_text, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'progress_bar_text.started')
                    # update status
                    progress_bar_text.status = STARTED
                    progress_bar_text.setAutoDraw(True)
                
                # if progress_bar_text is active this frame...
                if progress_bar_text.status == STARTED:
                    # update params
                    pass
                
                # *train_trial_counter* updates
                
                # if train_trial_counter is starting this frame...
                if train_trial_counter.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    train_trial_counter.frameNStart = frameN  # exact frame index
                    train_trial_counter.tStart = t  # local t and not account for scr refresh
                    train_trial_counter.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(train_trial_counter, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    train_trial_counter.status = STARTED
                    train_trial_counter.setAutoDraw(True)
                
                # if train_trial_counter is active this frame...
                if train_trial_counter.status == STARTED:
                    # update params
                    pass
                
                # *prog_bar_border* updates
                
                # if prog_bar_border is starting this frame...
                if prog_bar_border.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    prog_bar_border.frameNStart = frameN  # exact frame index
                    prog_bar_border.tStart = t  # local t and not account for scr refresh
                    prog_bar_border.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(prog_bar_border, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'prog_bar_border.started')
                    # update status
                    prog_bar_border.status = STARTED
                    prog_bar_border.setAutoDraw(True)
                
                # if prog_bar_border is active this frame...
                if prog_bar_border.status == STARTED:
                    # update params
                    pass
                
                # *prog_bar_rect* updates
                
                # if prog_bar_rect is starting this frame...
                if prog_bar_rect.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    prog_bar_rect.frameNStart = frameN  # exact frame index
                    prog_bar_rect.tStart = t  # local t and not account for scr refresh
                    prog_bar_rect.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(prog_bar_rect, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'prog_bar_rect.started')
                    # update status
                    prog_bar_rect.status = STARTED
                    prog_bar_rect.setAutoDraw(True)
                
                # if prog_bar_rect is active this frame...
                if prog_bar_rect.status == STARTED:
                    # update params
                    pass
                
                # check for quit (typically the Esc key)
                if defaultKeyboard.getKeys(keyList=["escape"]):
                    thisExp.status = FINISHED
                if thisExp.status == FINISHED or endExpNow:
                    endExperiment(thisExp, inputs=inputs, win=win)
                    return
                
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    routineForceEnded = True
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in Classification_trainComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
                
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            # --- Ending Routine "Classification_train" ---
            for thisComponent in Classification_trainComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            # Run 'End Routine' code from draw_button_panel
            for i_button in range(buttons_ntotal):
                rect = cat_button_clickable[i_button]
                txt = cat_button_text[i_button]
                rect.setAutoDraw(False)
                txt.setAutoDraw(False)
            # store data for train_trials (TrialHandler)
            train_trials.addData('cat_mouse_l.x', cat_mouse_l.x)
            train_trials.addData('cat_mouse_l.y', cat_mouse_l.y)
            train_trials.addData('cat_mouse_l.leftButton', cat_mouse_l.leftButton)
            train_trials.addData('cat_mouse_l.midButton', cat_mouse_l.midButton)
            train_trials.addData('cat_mouse_l.rightButton', cat_mouse_l.rightButton)
            train_trials.addData('cat_mouse_l.time', cat_mouse_l.time)
            train_trials.addData('cat_mouse_l.clicked_name', cat_mouse_l.clicked_name)
            # Run 'End Routine' code from store_trial_vars_train_3
            cat_resp = cat_mouse_l.clicked_name[0].split("_")[0]
            thisExp.addData('resp', cat_resp)
            thisExp.addData('t_resp', round(cat_mouse_l.time[0],3))
            
            # the Routine "Classification_train" was not non-slip safe, so reset the non-slip timer
            routineTimer.reset()
            
            # --- Prepare to start Routine "feedback_corrective" ---
            continueRoutine = True
            # update component parameters for each repeat
            # Run 'Begin Routine' code from fb_selection
            corr_flag = cat_mouse_l.clicked_name[-1] == trial_rock_cat + '_rect'
            if corr_flag:
                fb_text = 'Correct!'
                fb_col = 'green'
            else:
                fb_text = 'Incorrect!'
                fb_col = 'red'
            trial_rock_train_2.setSize(trial_rock_size)
            trial_rock_train_2.setImage(directory_path + '/' + trial_rock_file)
            fb_text_l.setColor(fb_col, colorSpace='rgb')
            fb_text_l.setText(fb_text)
            fb_text_l_2.setText('This rock is ' + trial_rock_cat)
            # setup some python lists for storing info about the fb_mouse
            fb_mouse.clicked_name = []
            gotValidClick = False  # until a click is received
            # keep track of which components have finished
            feedback_correctiveComponents = [trial_rock_train_2, fb_text_l, fb_text_l_2, next, fb_mouse]
            for thisComponent in feedback_correctiveComponents:
                thisComponent.tStart = None
                thisComponent.tStop = None
                thisComponent.tStartRefresh = None
                thisComponent.tStopRefresh = None
                if hasattr(thisComponent, 'status'):
                    thisComponent.status = NOT_STARTED
            # reset timers
            t = 0
            _timeToFirstFrame = win.getFutureFlipTime(clock="now")
            frameN = -1
            
            # --- Run Routine "feedback_corrective" ---
            routineForceEnded = not continueRoutine
            while continueRoutine:
                # get current time
                t = routineTimer.getTime()
                tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                
                # *trial_rock_train_2* updates
                
                # if trial_rock_train_2 is starting this frame...
                if trial_rock_train_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    trial_rock_train_2.frameNStart = frameN  # exact frame index
                    trial_rock_train_2.tStart = t  # local t and not account for scr refresh
                    trial_rock_train_2.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(trial_rock_train_2, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    trial_rock_train_2.status = STARTED
                    trial_rock_train_2.setAutoDraw(True)
                
                # if trial_rock_train_2 is active this frame...
                if trial_rock_train_2.status == STARTED:
                    # update params
                    pass
                
                # *fb_text_l* updates
                
                # if fb_text_l is starting this frame...
                if fb_text_l.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    fb_text_l.frameNStart = frameN  # exact frame index
                    fb_text_l.tStart = t  # local t and not account for scr refresh
                    fb_text_l.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(fb_text_l, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    fb_text_l.status = STARTED
                    fb_text_l.setAutoDraw(True)
                
                # if fb_text_l is active this frame...
                if fb_text_l.status == STARTED:
                    # update params
                    pass
                
                # *fb_text_l_2* updates
                
                # if fb_text_l_2 is starting this frame...
                if fb_text_l_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    fb_text_l_2.frameNStart = frameN  # exact frame index
                    fb_text_l_2.tStart = t  # local t and not account for scr refresh
                    fb_text_l_2.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(fb_text_l_2, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    fb_text_l_2.status = STARTED
                    fb_text_l_2.setAutoDraw(True)
                
                # if fb_text_l_2 is active this frame...
                if fb_text_l_2.status == STARTED:
                    # update params
                    pass
                
                # *next* updates
                
                # if next is starting this frame...
                if next.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    next.frameNStart = frameN  # exact frame index
                    next.tStart = t  # local t and not account for scr refresh
                    next.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(next, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    next.status = STARTED
                    next.setAutoDraw(True)
                
                # if next is active this frame...
                if next.status == STARTED:
                    # update params
                    pass
                # *fb_mouse* updates
                
                # if fb_mouse is starting this frame...
                if fb_mouse.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    fb_mouse.frameNStart = frameN  # exact frame index
                    fb_mouse.tStart = t  # local t and not account for scr refresh
                    fb_mouse.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(fb_mouse, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    fb_mouse.status = STARTED
                    fb_mouse.mouseClock.reset()
                    prevButtonState = fb_mouse.getPressed()  # if button is down already this ISN'T a new click
                if fb_mouse.status == STARTED:  # only update if started and not finished!
                    buttons = fb_mouse.getPressed()
                    if buttons != prevButtonState:  # button state changed?
                        prevButtonState = buttons
                        if sum(buttons) > 0:  # state changed to a new click
                            # check if the mouse was inside our 'clickable' objects
                            gotValidClick = False
                            clickableList = environmenttools.getFromNames(next, namespace=locals())
                            for obj in clickableList:
                                # is this object clicked on?
                                if obj.contains(fb_mouse):
                                    gotValidClick = True
                                    fb_mouse.clicked_name.append(obj.name)
                            if gotValidClick:  
                                continueRoutine = False  # end routine on response
                
                # check for quit (typically the Esc key)
                if defaultKeyboard.getKeys(keyList=["escape"]):
                    thisExp.status = FINISHED
                if thisExp.status == FINISHED or endExpNow:
                    endExperiment(thisExp, inputs=inputs, win=win)
                    return
                
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    routineForceEnded = True
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in feedback_correctiveComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
                
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            # --- Ending Routine "feedback_corrective" ---
            for thisComponent in feedback_correctiveComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            # store data for train_trials (TrialHandler)
            # Run 'End Routine' code from store_trial_vars_train_4
            thisExp.addData('corr', int(corr_flag))
            
            # the Routine "feedback_corrective" was not non-slip safe, so reset the non-slip timer
            routineTimer.reset()
            thisExp.nextEntry()
            
            if thisSession is not None:
                # if running in a Session with a Liaison client, send data up to now
                thisSession.sendExperimentData()
        # completed 2*num_cats repeats of 'train_trials'
        
        # get names of stimulus parameters
        if train_trials.trialList in ([], [None], None):
            params = []
        else:
            params = train_trials.trialList[0].keys()
        # save data for this loop
        train_trials.saveAsExcel(filename + '.xlsx', sheetName='train_trials',
            stimOut=params,
            dataOut=['n','all_mean','all_std', 'all_raw'])
        
        # --- Prepare to start Routine "end_of_trainingProcess" ---
        continueRoutine = True
        # update component parameters for each repeat
        # Run 'Begin Routine' code from testInstr_skip
        if blocks.thisN == 0:
            testInstr_nrep = 9999
        else:
            testInstr_nrep = 0
        # keep track of which components have finished
        end_of_trainingProcessComponents = []
        for thisComponent in end_of_trainingProcessComponents:
            thisComponent.tStart = None
            thisComponent.tStop = None
            thisComponent.tStartRefresh = None
            thisComponent.tStopRefresh = None
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        # reset timers
        t = 0
        _timeToFirstFrame = win.getFutureFlipTime(clock="now")
        frameN = -1
        
        # --- Run Routine "end_of_trainingProcess" ---
        routineForceEnded = not continueRoutine
        while continueRoutine:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # check for quit (typically the Esc key)
            if defaultKeyboard.getKeys(keyList=["escape"]):
                thisExp.status = FINISHED
            if thisExp.status == FINISHED or endExpNow:
                endExperiment(thisExp, inputs=inputs, win=win)
                return
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineForceEnded = True
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in end_of_trainingProcessComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        # --- Ending Routine "end_of_trainingProcess" ---
        for thisComponent in end_of_trainingProcessComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        # the Routine "end_of_trainingProcess" was not non-slip safe, so reset the non-slip timer
        routineTimer.reset()
        
        # set up handler to look after randomisation of conditions etc
        testInstructions_controller = data.TrialHandler(nReps=testInstr_nrep, method='random', 
            extraInfo=expInfo, originPath=-1,
            trialList=[None],
            seed=None, name='testInstructions_controller')
        thisExp.addLoop(testInstructions_controller)  # add the loop to the experiment
        thisTestInstructions_controller = testInstructions_controller.trialList[0]  # so we can initialise stimuli with some values
        # abbreviate parameter names if possible (e.g. rgb = thisTestInstructions_controller.rgb)
        if thisTestInstructions_controller != None:
            for paramName in thisTestInstructions_controller:
                globals()[paramName] = thisTestInstructions_controller[paramName]
        
        for thisTestInstructions_controller in testInstructions_controller:
            currentLoop = testInstructions_controller
            thisExp.timestampOnFlip(win, 'thisRow.t')
            # pause experiment here if requested
            if thisExp.status == PAUSED:
                pauseExperiment(
                    thisExp=thisExp, 
                    inputs=inputs, 
                    win=win, 
                    timers=[routineTimer], 
                    playbackComponents=[]
            )
            # abbreviate parameter names if possible (e.g. rgb = thisTestInstructions_controller.rgb)
            if thisTestInstructions_controller != None:
                for paramName in thisTestInstructions_controller:
                    globals()[paramName] = thisTestInstructions_controller[paramName]
            
            # --- Prepare to start Routine "test_instrPrep" ---
            continueRoutine = True
            # update component parameters for each repeat
            # Run 'Begin Routine' code from instrPrecode_test
            if(instruct_mouse_test.isPressedIn(rightArrow_2)):
                cur_row_test += 1
            elif(instruct_mouse_test.isPressedIn(leftArrow_2)):
                cur_row_test -= 1
              
            if(cur_row_test < 0):
                cur_row_test = 0
                
            if(cur_row_test > max_slides_test):
                testInstructions_controller.finished = 1
                show_instructions_test = 0
                
                cur_row_test = max_slides_test - 1
            
            cur_row_test_string = str(cur_row_test)
            
            # keep track of which components have finished
            test_instrPrepComponents = []
            for thisComponent in test_instrPrepComponents:
                thisComponent.tStart = None
                thisComponent.tStop = None
                thisComponent.tStartRefresh = None
                thisComponent.tStopRefresh = None
                if hasattr(thisComponent, 'status'):
                    thisComponent.status = NOT_STARTED
            # reset timers
            t = 0
            _timeToFirstFrame = win.getFutureFlipTime(clock="now")
            frameN = -1
            
            # --- Run Routine "test_instrPrep" ---
            routineForceEnded = not continueRoutine
            while continueRoutine:
                # get current time
                t = routineTimer.getTime()
                tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                
                # check for quit (typically the Esc key)
                if defaultKeyboard.getKeys(keyList=["escape"]):
                    thisExp.status = FINISHED
                if thisExp.status == FINISHED or endExpNow:
                    endExperiment(thisExp, inputs=inputs, win=win)
                    return
                
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    routineForceEnded = True
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in test_instrPrepComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
                
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            # --- Ending Routine "test_instrPrep" ---
            for thisComponent in test_instrPrepComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            # the Routine "test_instrPrep" was not non-slip safe, so reset the non-slip timer
            routineTimer.reset()
            
            # set up handler to look after randomisation of conditions etc
            testInstruction_trials = data.TrialHandler(nReps=show_instructions_test, method='sequential', 
                extraInfo=expInfo, originPath=-1,
                trialList=data.importConditions('stimuli/test_instructions.xlsx', selection=cur_row_test_string),
                seed=None, name='testInstruction_trials')
            thisExp.addLoop(testInstruction_trials)  # add the loop to the experiment
            thisTestInstruction_trial = testInstruction_trials.trialList[0]  # so we can initialise stimuli with some values
            # abbreviate parameter names if possible (e.g. rgb = thisTestInstruction_trial.rgb)
            if thisTestInstruction_trial != None:
                for paramName in thisTestInstruction_trial:
                    globals()[paramName] = thisTestInstruction_trial[paramName]
            
            for thisTestInstruction_trial in testInstruction_trials:
                currentLoop = testInstruction_trials
                thisExp.timestampOnFlip(win, 'thisRow.t')
                # pause experiment here if requested
                if thisExp.status == PAUSED:
                    pauseExperiment(
                        thisExp=thisExp, 
                        inputs=inputs, 
                        win=win, 
                        timers=[routineTimer], 
                        playbackComponents=[]
                )
                # abbreviate parameter names if possible (e.g. rgb = thisTestInstruction_trial.rgb)
                if thisTestInstruction_trial != None:
                    for paramName in thisTestInstruction_trial:
                        globals()[paramName] = thisTestInstruction_trial[paramName]
                
                # --- Prepare to start Routine "test_instructions" ---
                continueRoutine = True
                # update component parameters for each repeat
                instruction_image_test.setImage(test_slide)
                # setup some python lists for storing info about the instruct_mouse_test
                instruct_mouse_test.clicked_name = []
                gotValidClick = False  # until a click is received
                instruct_counter_test.setText(str(cur_row_test + 1) + '/' + str(max_slides_test + 1))
                # keep track of which components have finished
                test_instructionsComponents = [instruction_image_test, leftArrow_2, rightArrow_2, instruct_mouse_test, instruct_counter_test]
                for thisComponent in test_instructionsComponents:
                    thisComponent.tStart = None
                    thisComponent.tStop = None
                    thisComponent.tStartRefresh = None
                    thisComponent.tStopRefresh = None
                    if hasattr(thisComponent, 'status'):
                        thisComponent.status = NOT_STARTED
                # reset timers
                t = 0
                _timeToFirstFrame = win.getFutureFlipTime(clock="now")
                frameN = -1
                
                # --- Run Routine "test_instructions" ---
                routineForceEnded = not continueRoutine
                while continueRoutine:
                    # get current time
                    t = routineTimer.getTime()
                    tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                    # update/draw components on each frame
                    
                    # *instruction_image_test* updates
                    
                    # if instruction_image_test is starting this frame...
                    if instruction_image_test.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                        # keep track of start time/frame for later
                        instruction_image_test.frameNStart = frameN  # exact frame index
                        instruction_image_test.tStart = t  # local t and not account for scr refresh
                        instruction_image_test.tStartRefresh = tThisFlipGlobal  # on global time
                        win.timeOnFlip(instruction_image_test, 'tStartRefresh')  # time at next scr refresh
                        # update status
                        instruction_image_test.status = STARTED
                        instruction_image_test.setAutoDraw(True)
                    
                    # if instruction_image_test is active this frame...
                    if instruction_image_test.status == STARTED:
                        # update params
                        pass
                    
                    # *leftArrow_2* updates
                    
                    # if leftArrow_2 is starting this frame...
                    if leftArrow_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                        # keep track of start time/frame for later
                        leftArrow_2.frameNStart = frameN  # exact frame index
                        leftArrow_2.tStart = t  # local t and not account for scr refresh
                        leftArrow_2.tStartRefresh = tThisFlipGlobal  # on global time
                        win.timeOnFlip(leftArrow_2, 'tStartRefresh')  # time at next scr refresh
                        # update status
                        leftArrow_2.status = STARTED
                        leftArrow_2.setAutoDraw(True)
                    
                    # if leftArrow_2 is active this frame...
                    if leftArrow_2.status == STARTED:
                        # update params
                        pass
                    
                    # *rightArrow_2* updates
                    
                    # if rightArrow_2 is starting this frame...
                    if rightArrow_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                        # keep track of start time/frame for later
                        rightArrow_2.frameNStart = frameN  # exact frame index
                        rightArrow_2.tStart = t  # local t and not account for scr refresh
                        rightArrow_2.tStartRefresh = tThisFlipGlobal  # on global time
                        win.timeOnFlip(rightArrow_2, 'tStartRefresh')  # time at next scr refresh
                        # update status
                        rightArrow_2.status = STARTED
                        rightArrow_2.setAutoDraw(True)
                    
                    # if rightArrow_2 is active this frame...
                    if rightArrow_2.status == STARTED:
                        # update params
                        pass
                    # *instruct_mouse_test* updates
                    
                    # if instruct_mouse_test is starting this frame...
                    if instruct_mouse_test.status == NOT_STARTED and t >= 0.0-frameTolerance:
                        # keep track of start time/frame for later
                        instruct_mouse_test.frameNStart = frameN  # exact frame index
                        instruct_mouse_test.tStart = t  # local t and not account for scr refresh
                        instruct_mouse_test.tStartRefresh = tThisFlipGlobal  # on global time
                        win.timeOnFlip(instruct_mouse_test, 'tStartRefresh')  # time at next scr refresh
                        # update status
                        instruct_mouse_test.status = STARTED
                        instruct_mouse_test.mouseClock.reset()
                        prevButtonState = instruct_mouse_test.getPressed()  # if button is down already this ISN'T a new click
                    if instruct_mouse_test.status == STARTED:  # only update if started and not finished!
                        buttons = instruct_mouse_test.getPressed()
                        if buttons != prevButtonState:  # button state changed?
                            prevButtonState = buttons
                            if sum(buttons) > 0:  # state changed to a new click
                                # check if the mouse was inside our 'clickable' objects
                                gotValidClick = False
                                clickableList = environmenttools.getFromNames([leftArrow_2,rightArrow_2], namespace=locals())
                                for obj in clickableList:
                                    # is this object clicked on?
                                    if obj.contains(instruct_mouse_test):
                                        gotValidClick = True
                                        instruct_mouse_test.clicked_name.append(obj.name)
                                if gotValidClick:  
                                    continueRoutine = False  # end routine on response
                    
                    # *instruct_counter_test* updates
                    
                    # if instruct_counter_test is starting this frame...
                    if instruct_counter_test.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                        # keep track of start time/frame for later
                        instruct_counter_test.frameNStart = frameN  # exact frame index
                        instruct_counter_test.tStart = t  # local t and not account for scr refresh
                        instruct_counter_test.tStartRefresh = tThisFlipGlobal  # on global time
                        win.timeOnFlip(instruct_counter_test, 'tStartRefresh')  # time at next scr refresh
                        # update status
                        instruct_counter_test.status = STARTED
                        instruct_counter_test.setAutoDraw(True)
                    
                    # if instruct_counter_test is active this frame...
                    if instruct_counter_test.status == STARTED:
                        # update params
                        pass
                    
                    # check for quit (typically the Esc key)
                    if defaultKeyboard.getKeys(keyList=["escape"]):
                        thisExp.status = FINISHED
                    if thisExp.status == FINISHED or endExpNow:
                        endExperiment(thisExp, inputs=inputs, win=win)
                        return
                    
                    # check if all components have finished
                    if not continueRoutine:  # a component has requested a forced-end of Routine
                        routineForceEnded = True
                        break
                    continueRoutine = False  # will revert to True if at least one component still running
                    for thisComponent in test_instructionsComponents:
                        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                            continueRoutine = True
                            break  # at least one component has not yet finished
                    
                    # refresh the screen
                    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                        win.flip()
                
                # --- Ending Routine "test_instructions" ---
                for thisComponent in test_instructionsComponents:
                    if hasattr(thisComponent, "setAutoDraw"):
                        thisComponent.setAutoDraw(False)
                # store data for testInstruction_trials (TrialHandler)
                # the Routine "test_instructions" was not non-slip safe, so reset the non-slip timer
                routineTimer.reset()
            # completed show_instructions_test repeats of 'testInstruction_trials'
            
        # completed testInstr_nrep repeats of 'testInstructions_controller'
        
        
        # --- Prepare to start Routine "start_of_testProcess" ---
        continueRoutine = True
        # update component parameters for each repeat
        block_prompt_test.setText('Starting Test Block ' + str(blocks.thisN + 1) +  ' of ' + str(blocks.nTotal))
        # Run 'Begin Routine' code from initialize_accuracy_list
        accuracy_dict = {}
        for cat_name in category_names:
            accuracy_dict[cat_name] = []
        # Run 'Begin Routine' code from initialize_response_tracker
        resp_list = []
        cat_list = []
        # keep track of which components have finished
        start_of_testProcessComponents = [block_prompt_test]
        for thisComponent in start_of_testProcessComponents:
            thisComponent.tStart = None
            thisComponent.tStop = None
            thisComponent.tStartRefresh = None
            thisComponent.tStopRefresh = None
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        # reset timers
        t = 0
        _timeToFirstFrame = win.getFutureFlipTime(clock="now")
        frameN = -1
        
        # --- Run Routine "start_of_testProcess" ---
        routineForceEnded = not continueRoutine
        while continueRoutine and routineTimer.getTime() < 1.0:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *block_prompt_test* updates
            
            # if block_prompt_test is starting this frame...
            if block_prompt_test.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                block_prompt_test.frameNStart = frameN  # exact frame index
                block_prompt_test.tStart = t  # local t and not account for scr refresh
                block_prompt_test.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(block_prompt_test, 'tStartRefresh')  # time at next scr refresh
                # update status
                block_prompt_test.status = STARTED
                block_prompt_test.setAutoDraw(True)
            
            # if block_prompt_test is active this frame...
            if block_prompt_test.status == STARTED:
                # update params
                pass
            
            # if block_prompt_test is stopping this frame...
            if block_prompt_test.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > block_prompt_test.tStartRefresh + 1.0-frameTolerance:
                    # keep track of stop time/frame for later
                    block_prompt_test.tStop = t  # not accounting for scr refresh
                    block_prompt_test.frameNStop = frameN  # exact frame index
                    # update status
                    block_prompt_test.status = FINISHED
                    block_prompt_test.setAutoDraw(False)
            
            # check for quit (typically the Esc key)
            if defaultKeyboard.getKeys(keyList=["escape"]):
                thisExp.status = FINISHED
            if thisExp.status == FINISHED or endExpNow:
                endExperiment(thisExp, inputs=inputs, win=win)
                return
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineForceEnded = True
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in start_of_testProcessComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        # --- Ending Routine "start_of_testProcess" ---
        for thisComponent in start_of_testProcessComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
        if routineForceEnded:
            routineTimer.reset()
        else:
            routineTimer.addTime(-1.000000)
        
        # set up handler to look after randomisation of conditions etc
        test_trials = data.TrialHandler(nReps=2*num_cats, method='random', 
            extraInfo=expInfo, originPath=-1,
            trialList=[None],
            seed=None, name='test_trials')
        thisExp.addLoop(test_trials)  # add the loop to the experiment
        thisTest_trial = test_trials.trialList[0]  # so we can initialise stimuli with some values
        # abbreviate parameter names if possible (e.g. rgb = thisTest_trial.rgb)
        if thisTest_trial != None:
            for paramName in thisTest_trial:
                globals()[paramName] = thisTest_trial[paramName]
        
        for thisTest_trial in test_trials:
            currentLoop = test_trials
            thisExp.timestampOnFlip(win, 'thisRow.t')
            # pause experiment here if requested
            if thisExp.status == PAUSED:
                pauseExperiment(
                    thisExp=thisExp, 
                    inputs=inputs, 
                    win=win, 
                    timers=[routineTimer], 
                    playbackComponents=[]
            )
            # abbreviate parameter names if possible (e.g. rgb = thisTest_trial.rgb)
            if thisTest_trial != None:
                for paramName in thisTest_trial:
                    globals()[paramName] = thisTest_trial[paramName]
            
            # --- Prepare to start Routine "Classification_test" ---
            continueRoutine = True
            # update component parameters for each repeat
            # Run 'Begin Routine' code from draw_button_panel_2
            rect = []
            txt = []
            for i_cat in range(buttons_ntotal):
                rect = cat_button_clickable[i_cat]
                txt = cat_button_text[i_cat]
                rect.setAutoDraw(True)
                txt.setAutoDraw(True)
            # Run 'Begin Routine' code from extract_trial_rock_info_2
            trial_image = test_images[blocks.thisN][test_trials.thisN]
            trial_cat = extract_rock_info(trial_image)["type"]
            trial_token = extract_rock_info(trial_image)["token"]
            rock_width,rock_height = trial_rock_test.aspectRatio
            aspect_ratio = rock_width/rock_height
            
            trial_rock_height = 0.6
            trial_rock_width = trial_rock_height * aspect_ratio
            trial_rock_size = [trial_rock_width,trial_rock_height]
            
            
            
            
              
                
            # Run 'Begin Routine' code from prog_bar_test
            prog_total = blocks.nTotal * n_trials_total
            prog_cur = blocks.thisN * n_trials_total + train_trials.nTotal + test_trials.thisN + 2
            prog_var = prog_cur/prog_total
            
              
                
            trial_rock_test.setSize(trial_rock_size)
            trial_rock_test.setImage(directory_path + '/' + trial_image.name)
            test_trial_counter.setText("Trial # " + str(test_trials.thisN + 1) + "/" + str(test_trials.nTotal))
            prog_bar_rect_2.setSize((prog_var * 0.8, 0.03))
            # setup some python lists for storing info about the cat_mouse_t
            cat_mouse_t.x = []
            cat_mouse_t.y = []
            cat_mouse_t.leftButton = []
            cat_mouse_t.midButton = []
            cat_mouse_t.rightButton = []
            cat_mouse_t.time = []
            cat_mouse_t.clicked_name = []
            gotValidClick = False  # until a click is received
            # Run 'Begin Routine' code from store_trial_vars_test
            thisExp.addData('block', blocks.thisN + 1)
            thisExp.addData('phase', 2)
            thisExp.addData('trial', test_trials.thisN + 1)
            
            
            # keep track of which components have finished
            Classification_testComponents = [trial_rock_test, progress_bar_text_3, test_trial_counter, prog_bar_border_2, prog_bar_rect_2, cat_mouse_t]
            for thisComponent in Classification_testComponents:
                thisComponent.tStart = None
                thisComponent.tStop = None
                thisComponent.tStartRefresh = None
                thisComponent.tStopRefresh = None
                if hasattr(thisComponent, 'status'):
                    thisComponent.status = NOT_STARTED
            # reset timers
            t = 0
            _timeToFirstFrame = win.getFutureFlipTime(clock="now")
            frameN = -1
            
            # --- Run Routine "Classification_test" ---
            routineForceEnded = not continueRoutine
            while continueRoutine:
                # get current time
                t = routineTimer.getTime()
                tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                # Run 'Each Frame' code from rock_classification_2
                button = []
                button_text = []
                for i_button in range(buttons_ntotal):
                    button = cat_button_clickable[i_button]
                    button_text = cat_button_text[i_button]
                    if button.contains(cat_mouse_l):
                        button.borderColor = 'red'
                        button_text.color = 'red'
                    else:
                        button.borderColor = 'black'
                        button_text.color = 'black'
                
                # *trial_rock_test* updates
                
                # if trial_rock_test is starting this frame...
                if trial_rock_test.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    trial_rock_test.frameNStart = frameN  # exact frame index
                    trial_rock_test.tStart = t  # local t and not account for scr refresh
                    trial_rock_test.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(trial_rock_test, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    trial_rock_test.status = STARTED
                    trial_rock_test.setAutoDraw(True)
                
                # if trial_rock_test is active this frame...
                if trial_rock_test.status == STARTED:
                    # update params
                    pass
                
                # *progress_bar_text_3* updates
                
                # if progress_bar_text_3 is starting this frame...
                if progress_bar_text_3.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    progress_bar_text_3.frameNStart = frameN  # exact frame index
                    progress_bar_text_3.tStart = t  # local t and not account for scr refresh
                    progress_bar_text_3.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(progress_bar_text_3, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'progress_bar_text_3.started')
                    # update status
                    progress_bar_text_3.status = STARTED
                    progress_bar_text_3.setAutoDraw(True)
                
                # if progress_bar_text_3 is active this frame...
                if progress_bar_text_3.status == STARTED:
                    # update params
                    pass
                
                # *test_trial_counter* updates
                
                # if test_trial_counter is starting this frame...
                if test_trial_counter.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    test_trial_counter.frameNStart = frameN  # exact frame index
                    test_trial_counter.tStart = t  # local t and not account for scr refresh
                    test_trial_counter.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(test_trial_counter, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    test_trial_counter.status = STARTED
                    test_trial_counter.setAutoDraw(True)
                
                # if test_trial_counter is active this frame...
                if test_trial_counter.status == STARTED:
                    # update params
                    pass
                
                # *prog_bar_border_2* updates
                
                # if prog_bar_border_2 is starting this frame...
                if prog_bar_border_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    prog_bar_border_2.frameNStart = frameN  # exact frame index
                    prog_bar_border_2.tStart = t  # local t and not account for scr refresh
                    prog_bar_border_2.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(prog_bar_border_2, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'prog_bar_border_2.started')
                    # update status
                    prog_bar_border_2.status = STARTED
                    prog_bar_border_2.setAutoDraw(True)
                
                # if prog_bar_border_2 is active this frame...
                if prog_bar_border_2.status == STARTED:
                    # update params
                    pass
                
                # *prog_bar_rect_2* updates
                
                # if prog_bar_rect_2 is starting this frame...
                if prog_bar_rect_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    prog_bar_rect_2.frameNStart = frameN  # exact frame index
                    prog_bar_rect_2.tStart = t  # local t and not account for scr refresh
                    prog_bar_rect_2.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(prog_bar_rect_2, 'tStartRefresh')  # time at next scr refresh
                    # add timestamp to datafile
                    thisExp.timestampOnFlip(win, 'prog_bar_rect_2.started')
                    # update status
                    prog_bar_rect_2.status = STARTED
                    prog_bar_rect_2.setAutoDraw(True)
                
                # if prog_bar_rect_2 is active this frame...
                if prog_bar_rect_2.status == STARTED:
                    # update params
                    pass
                # *cat_mouse_t* updates
                
                # if cat_mouse_t is starting this frame...
                if cat_mouse_t.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    cat_mouse_t.frameNStart = frameN  # exact frame index
                    cat_mouse_t.tStart = t  # local t and not account for scr refresh
                    cat_mouse_t.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(cat_mouse_t, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    cat_mouse_t.status = STARTED
                    cat_mouse_t.mouseClock.reset()
                    prevButtonState = cat_mouse_t.getPressed()  # if button is down already this ISN'T a new click
                if cat_mouse_t.status == STARTED:  # only update if started and not finished!
                    buttons = cat_mouse_t.getPressed()
                    if buttons != prevButtonState:  # button state changed?
                        prevButtonState = buttons
                        if sum(buttons) > 0:  # state changed to a new click
                            # check if the mouse was inside our 'clickable' objects
                            gotValidClick = False
                            clickableList = environmenttools.getFromNames([...cat_button_clickable], namespace=locals())
                            for obj in clickableList:
                                # is this object clicked on?
                                if obj.contains(cat_mouse_t):
                                    gotValidClick = True
                                    cat_mouse_t.clicked_name.append(obj.name)
                            if gotValidClick:
                                x, y = cat_mouse_t.getPos()
                                cat_mouse_t.x.append(x)
                                cat_mouse_t.y.append(y)
                                buttons = cat_mouse_t.getPressed()
                                cat_mouse_t.leftButton.append(buttons[0])
                                cat_mouse_t.midButton.append(buttons[1])
                                cat_mouse_t.rightButton.append(buttons[2])
                                cat_mouse_t.time.append(cat_mouse_t.mouseClock.getTime())
                            if gotValidClick:
                                continueRoutine = False  # end routine on response
                
                # check for quit (typically the Esc key)
                if defaultKeyboard.getKeys(keyList=["escape"]):
                    thisExp.status = FINISHED
                if thisExp.status == FINISHED or endExpNow:
                    endExperiment(thisExp, inputs=inputs, win=win)
                    return
                
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    routineForceEnded = True
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in Classification_testComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
                
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            # --- Ending Routine "Classification_test" ---
            for thisComponent in Classification_testComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            # Run 'End Routine' code from draw_button_panel_2
            for i_cat in range(buttons_ntotal):
                rect = cat_button_clickable[i_cat]
                txt = cat_button_text[i_cat]
                rect.setAutoDraw(False)
                txt.setAutoDraw(False)
            # store data for test_trials (TrialHandler)
            test_trials.addData('cat_mouse_t.x', cat_mouse_t.x)
            test_trials.addData('cat_mouse_t.y', cat_mouse_t.y)
            test_trials.addData('cat_mouse_t.leftButton', cat_mouse_t.leftButton)
            test_trials.addData('cat_mouse_t.midButton', cat_mouse_t.midButton)
            test_trials.addData('cat_mouse_t.rightButton', cat_mouse_t.rightButton)
            test_trials.addData('cat_mouse_t.time', cat_mouse_t.time)
            test_trials.addData('cat_mouse_t.clicked_name', cat_mouse_t.clicked_name)
            # Run 'End Routine' code from store_trial_vars_test
            thisExp.addData('cat', trial_cat)
            thisExp.addData('token', trial_token)
            cat_resp = cat_mouse_t.clicked_name[-1].split("_")[0]
            thisExp.addData('resp', cat_resp)
            thisExp.addData('corr', int(cat_resp === trial_cat))
            thisExp.addData('t_resp', round(cat_mouse_t.time[0],3))
            
            cat_list.append(trial_cat)
            resp_list.append(cat_resp)
            accuracy_dict[trial_cat].append(cat_resp == trial_cat)
            # the Routine "Classification_test" was not non-slip safe, so reset the non-slip timer
            routineTimer.reset()
            
            # --- Prepare to start Routine "feedback_neutral" ---
            continueRoutine = True
            # update component parameters for each repeat
            # keep track of which components have finished
            feedback_neutralComponents = [fb_text_t]
            for thisComponent in feedback_neutralComponents:
                thisComponent.tStart = None
                thisComponent.tStop = None
                thisComponent.tStartRefresh = None
                thisComponent.tStopRefresh = None
                if hasattr(thisComponent, 'status'):
                    thisComponent.status = NOT_STARTED
            # reset timers
            t = 0
            _timeToFirstFrame = win.getFutureFlipTime(clock="now")
            frameN = -1
            
            # --- Run Routine "feedback_neutral" ---
            routineForceEnded = not continueRoutine
            while continueRoutine and routineTimer.getTime() < 0.5:
                # get current time
                t = routineTimer.getTime()
                tThisFlip = win.getFutureFlipTime(clock=routineTimer)
                tThisFlipGlobal = win.getFutureFlipTime(clock=None)
                frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
                # update/draw components on each frame
                
                # *fb_text_t* updates
                
                # if fb_text_t is starting this frame...
                if fb_text_t.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                    # keep track of start time/frame for later
                    fb_text_t.frameNStart = frameN  # exact frame index
                    fb_text_t.tStart = t  # local t and not account for scr refresh
                    fb_text_t.tStartRefresh = tThisFlipGlobal  # on global time
                    win.timeOnFlip(fb_text_t, 'tStartRefresh')  # time at next scr refresh
                    # update status
                    fb_text_t.status = STARTED
                    fb_text_t.setAutoDraw(True)
                
                # if fb_text_t is active this frame...
                if fb_text_t.status == STARTED:
                    # update params
                    pass
                
                # if fb_text_t is stopping this frame...
                if fb_text_t.status == STARTED:
                    # is it time to stop? (based on global clock, using actual start)
                    if tThisFlipGlobal > fb_text_t.tStartRefresh + 0.5-frameTolerance:
                        # keep track of stop time/frame for later
                        fb_text_t.tStop = t  # not accounting for scr refresh
                        fb_text_t.frameNStop = frameN  # exact frame index
                        # update status
                        fb_text_t.status = FINISHED
                        fb_text_t.setAutoDraw(False)
                
                # check for quit (typically the Esc key)
                if defaultKeyboard.getKeys(keyList=["escape"]):
                    thisExp.status = FINISHED
                if thisExp.status == FINISHED or endExpNow:
                    endExperiment(thisExp, inputs=inputs, win=win)
                    return
                
                # check if all components have finished
                if not continueRoutine:  # a component has requested a forced-end of Routine
                    routineForceEnded = True
                    break
                continueRoutine = False  # will revert to True if at least one component still running
                for thisComponent in feedback_neutralComponents:
                    if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                        continueRoutine = True
                        break  # at least one component has not yet finished
                
                # refresh the screen
                if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                    win.flip()
            
            # --- Ending Routine "feedback_neutral" ---
            for thisComponent in feedback_neutralComponents:
                if hasattr(thisComponent, "setAutoDraw"):
                    thisComponent.setAutoDraw(False)
            # using non-slip timing so subtract the expected duration of this Routine (unless ended on request)
            if routineForceEnded:
                routineTimer.reset()
            else:
                routineTimer.addTime(-0.500000)
            thisExp.nextEntry()
            
            if thisSession is not None:
                # if running in a Session with a Liaison client, send data up to now
                thisSession.sendExperimentData()
        # completed 2*num_cats repeats of 'test_trials'
        
        # get names of stimulus parameters
        if test_trials.trialList in ([], [None], None):
            params = []
        else:
            params = test_trials.trialList[0].keys()
        # save data for this loop
        test_trials.saveAsExcel(filename + '.xlsx', sheetName='test_trials',
            stimOut=params,
            dataOut=['n','all_mean','all_std', 'all_raw'])
        
        # --- Prepare to start Routine "end_of_testProcess" ---
        continueRoutine = True
        # update component parameters for each repeat
        # Run 'Begin Routine' code from format_accuracy_summary
        prc_corr = [];
        corr_table = "";
        for cat_name in category_names:
            prc_corr = round(average(accuracy_dict[cat_name])*100)
            corr_table = corr_table + cat_name + ': ' + str(prc_corr) + '%\n\n'
        prc_corr_list = list(accuracy_dict.values())
        prc_corr_block = round(average(prc_corr_list)*100)
        corr_overall = 'you got ' + str(prc_corr_block) + '% of trials correct.'
        
        if blocks.thisN >= blocks.nTotal - 3:
            prc_corr_block_last3.append(prc_corr_block)  
        if blocks.thisN == blocks.nTotal - 1:
            prc_corr_total_last3 = sum(prc_corr_block_last3) / len(prc_corr_block_last3)
            hasBonus = 1 if prc_corr_total_last3 >= 0.65 else 0
        end_block_msg_2.setText('End Block ' + str(blocks.thisN + 1))
        feedbackSC2.setText(corr_table
        )
        feedbackTC1.setText(corr_overall
        )
        # setup some python lists for storing info about the next_mouse_block_fb
        next_mouse_block_fb.clicked_name = []
        gotValidClick = False  # until a click is received
        # Run 'Begin Routine' code from compute_diff_indices
        if expInfo['condition'] in ['SCR', 'TCR']:
            RC_thisblock = [];
            prc_dict_thisblock = {};
            for icat in range(num_cats):
                cat_name = category_names[icat]
                num_item_cat = sum(x == cat_name for x in cat_list)
                num_item_resp = sum(y == cat_name for y in resp_list)
                num_item_total = len(cat_list)
                num_item_cat_resp = sum((x == cat_name) and (y == cat_name) for x, y in zip(cat_list, resp_list))
                H_rate = num_item_cat_resp/num_item_cat
                FA_rate = (num_item_resp - num_item_cat_resp)/(num_item_total - num_item_cat)
                # the exact formula can be changed
                PS = H_rate - FA_rate
                PS_dict_blocks[cat_name].append(PS)
                PS_sum = 0
                weight_sum = 0
                for iblock in range(blocks.thisN + 1):
                    block_weight = math.exp(iblock - blocks.thisN)
                    weight_sum += block_weight
                    PS_sum += block_weight * PS_dict_blocks[cat_name][iblock]
                RC_thisblock.append(1 - PS_sum/weight_sum + 0.125)
        
            for icat in range(num_cats):
                cat_name = category_names[icat]
                prc_dict_thisblock[cat_name] = RC_thisblock[icat] / sum(RC_thisblock)
            
        
            
        
        # keep track of which components have finished
        end_of_testProcessComponents = [end_block_msg_2, feedbackSC1, feedbackSC2, feedbackTC1, next_block_fb, next_mouse_block_fb]
        for thisComponent in end_of_testProcessComponents:
            thisComponent.tStart = None
            thisComponent.tStop = None
            thisComponent.tStartRefresh = None
            thisComponent.tStopRefresh = None
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        # reset timers
        t = 0
        _timeToFirstFrame = win.getFutureFlipTime(clock="now")
        frameN = -1
        
        # --- Run Routine "end_of_testProcess" ---
        routineForceEnded = not continueRoutine
        while continueRoutine:
            # get current time
            t = routineTimer.getTime()
            tThisFlip = win.getFutureFlipTime(clock=routineTimer)
            tThisFlipGlobal = win.getFutureFlipTime(clock=None)
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            # *end_block_msg_2* updates
            
            # if end_block_msg_2 is starting this frame...
            if end_block_msg_2.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
                # keep track of start time/frame for later
                end_block_msg_2.frameNStart = frameN  # exact frame index
                end_block_msg_2.tStart = t  # local t and not account for scr refresh
                end_block_msg_2.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(end_block_msg_2, 'tStartRefresh')  # time at next scr refresh
                # update status
                end_block_msg_2.status = STARTED
                end_block_msg_2.setAutoDraw(True)
            
            # if end_block_msg_2 is active this frame...
            if end_block_msg_2.status == STARTED:
                # update params
                pass
            
            # if end_block_msg_2 is stopping this frame...
            if end_block_msg_2.status == STARTED:
                # is it time to stop? (based on global clock, using actual start)
                if tThisFlipGlobal > end_block_msg_2.tStartRefresh + .5-frameTolerance:
                    # keep track of stop time/frame for later
                    end_block_msg_2.tStop = t  # not accounting for scr refresh
                    end_block_msg_2.frameNStop = frameN  # exact frame index
                    # update status
                    end_block_msg_2.status = FINISHED
                    end_block_msg_2.setAutoDraw(False)
            
            # *feedbackSC1* updates
            
            # if feedbackSC1 is starting this frame...
            if feedbackSC1.status == NOT_STARTED and ['SCN' ,'SCR'].includes(expInfo['condition'])  &&  t >= 0.5:
                # keep track of start time/frame for later
                feedbackSC1.frameNStart = frameN  # exact frame index
                feedbackSC1.tStart = t  # local t and not account for scr refresh
                feedbackSC1.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(feedbackSC1, 'tStartRefresh')  # time at next scr refresh
                # update status
                feedbackSC1.status = STARTED
                feedbackSC1.setAutoDraw(True)
            
            # if feedbackSC1 is active this frame...
            if feedbackSC1.status == STARTED:
                # update params
                pass
            
            # *feedbackSC2* updates
            
            # if feedbackSC2 is starting this frame...
            if feedbackSC2.status == NOT_STARTED and ['SCN','SCR'].includes(expInfo['condition'])  &&  t >= 0.5:
                # keep track of start time/frame for later
                feedbackSC2.frameNStart = frameN  # exact frame index
                feedbackSC2.tStart = t  # local t and not account for scr refresh
                feedbackSC2.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(feedbackSC2, 'tStartRefresh')  # time at next scr refresh
                # update status
                feedbackSC2.status = STARTED
                feedbackSC2.setAutoDraw(True)
            
            # if feedbackSC2 is active this frame...
            if feedbackSC2.status == STARTED:
                # update params
                pass
            
            # *feedbackTC1* updates
            
            # if feedbackTC1 is starting this frame...
            if feedbackTC1.status == NOT_STARTED and ['TCN','TCR'].includes(expInfo['condition'])  &&  t >= 0.5:
                # keep track of start time/frame for later
                feedbackTC1.frameNStart = frameN  # exact frame index
                feedbackTC1.tStart = t  # local t and not account for scr refresh
                feedbackTC1.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(feedbackTC1, 'tStartRefresh')  # time at next scr refresh
                # update status
                feedbackTC1.status = STARTED
                feedbackTC1.setAutoDraw(True)
            
            # if feedbackTC1 is active this frame...
            if feedbackTC1.status == STARTED:
                # update params
                pass
            
            # *next_block_fb* updates
            
            # if next_block_fb is starting this frame...
            if next_block_fb.status == NOT_STARTED and tThisFlip >= 0.5-frameTolerance:
                # keep track of start time/frame for later
                next_block_fb.frameNStart = frameN  # exact frame index
                next_block_fb.tStart = t  # local t and not account for scr refresh
                next_block_fb.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(next_block_fb, 'tStartRefresh')  # time at next scr refresh
                # update status
                next_block_fb.status = STARTED
                next_block_fb.setAutoDraw(True)
            
            # if next_block_fb is active this frame...
            if next_block_fb.status == STARTED:
                # update params
                pass
            # *next_mouse_block_fb* updates
            
            # if next_mouse_block_fb is starting this frame...
            if next_mouse_block_fb.status == NOT_STARTED and t >= 0.5-frameTolerance:
                # keep track of start time/frame for later
                next_mouse_block_fb.frameNStart = frameN  # exact frame index
                next_mouse_block_fb.tStart = t  # local t and not account for scr refresh
                next_mouse_block_fb.tStartRefresh = tThisFlipGlobal  # on global time
                win.timeOnFlip(next_mouse_block_fb, 'tStartRefresh')  # time at next scr refresh
                # update status
                next_mouse_block_fb.status = STARTED
                next_mouse_block_fb.mouseClock.reset()
                prevButtonState = next_mouse_block_fb.getPressed()  # if button is down already this ISN'T a new click
            if next_mouse_block_fb.status == STARTED:  # only update if started and not finished!
                buttons = next_mouse_block_fb.getPressed()
                if buttons != prevButtonState:  # button state changed?
                    prevButtonState = buttons
                    if sum(buttons) > 0:  # state changed to a new click
                        # check if the mouse was inside our 'clickable' objects
                        gotValidClick = False
                        clickableList = environmenttools.getFromNames(next_block_fb, namespace=locals())
                        for obj in clickableList:
                            # is this object clicked on?
                            if obj.contains(next_mouse_block_fb):
                                gotValidClick = True
                                next_mouse_block_fb.clicked_name.append(obj.name)
                        if gotValidClick:  
                            continueRoutine = False  # end routine on response
            
            # check for quit (typically the Esc key)
            if defaultKeyboard.getKeys(keyList=["escape"]):
                thisExp.status = FINISHED
            if thisExp.status == FINISHED or endExpNow:
                endExperiment(thisExp, inputs=inputs, win=win)
                return
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                routineForceEnded = True
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in end_of_testProcessComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        # --- Ending Routine "end_of_testProcess" ---
        for thisComponent in end_of_testProcessComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        # store data for blocks (TrialHandler)
        # the Routine "end_of_testProcess" was not non-slip safe, so reset the non-slip timer
        routineTimer.reset()
    # completed 3.0 repeats of 'blocks'
    
    
    # --- Prepare to start Routine "debrief" ---
    continueRoutine = True
    # update component parameters for each repeat
    # setup some python lists for storing info about the next_mouse_end_expt
    next_mouse_end_expt.clicked_name = []
    gotValidClick = False  # until a click is received
    # keep track of which components have finished
    debriefComponents = [debrief_report, next_end_expt, next_mouse_end_expt]
    for thisComponent in debriefComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    frameN = -1
    
    # --- Run Routine "debrief" ---
    routineForceEnded = not continueRoutine
    while continueRoutine:
        # get current time
        t = routineTimer.getTime()
        tThisFlip = win.getFutureFlipTime(clock=routineTimer)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *debrief_report* updates
        
        # if debrief_report is starting this frame...
        if debrief_report.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            debrief_report.frameNStart = frameN  # exact frame index
            debrief_report.tStart = t  # local t and not account for scr refresh
            debrief_report.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(debrief_report, 'tStartRefresh')  # time at next scr refresh
            # add timestamp to datafile
            thisExp.timestampOnFlip(win, 'debrief_report.started')
            # update status
            debrief_report.status = STARTED
            debrief_report.setAutoDraw(True)
        
        # if debrief_report is active this frame...
        if debrief_report.status == STARTED:
            # update params
            pass
        
        # *next_end_expt* updates
        
        # if next_end_expt is starting this frame...
        if next_end_expt.status == NOT_STARTED and tThisFlip >= 0-frameTolerance:
            # keep track of start time/frame for later
            next_end_expt.frameNStart = frameN  # exact frame index
            next_end_expt.tStart = t  # local t and not account for scr refresh
            next_end_expt.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(next_end_expt, 'tStartRefresh')  # time at next scr refresh
            # update status
            next_end_expt.status = STARTED
            next_end_expt.setAutoDraw(True)
        
        # if next_end_expt is active this frame...
        if next_end_expt.status == STARTED:
            # update params
            pass
        # *next_mouse_end_expt* updates
        
        # if next_mouse_end_expt is starting this frame...
        if next_mouse_end_expt.status == NOT_STARTED and tThisFlip >= 0-frameTolerance:
            # keep track of start time/frame for later
            next_mouse_end_expt.frameNStart = frameN  # exact frame index
            next_mouse_end_expt.tStart = t  # local t and not account for scr refresh
            next_mouse_end_expt.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(next_mouse_end_expt, 'tStartRefresh')  # time at next scr refresh
            # update status
            next_mouse_end_expt.status = STARTED
            next_mouse_end_expt.mouseClock.reset()
            prevButtonState = next_mouse_end_expt.getPressed()  # if button is down already this ISN'T a new click
        if next_mouse_end_expt.status == STARTED:  # only update if started and not finished!
            buttons = next_mouse_end_expt.getPressed()
            if buttons != prevButtonState:  # button state changed?
                prevButtonState = buttons
                if sum(buttons) > 0:  # state changed to a new click
                    # check if the mouse was inside our 'clickable' objects
                    gotValidClick = False
                    clickableList = environmenttools.getFromNames(next_end_expt, namespace=locals())
                    for obj in clickableList:
                        # is this object clicked on?
                        if obj.contains(next_mouse_end_expt):
                            gotValidClick = True
                            next_mouse_end_expt.clicked_name.append(obj.name)
                    if gotValidClick:  
                        continueRoutine = False  # end routine on response
        
        # check for quit (typically the Esc key)
        if defaultKeyboard.getKeys(keyList=["escape"]):
            thisExp.status = FINISHED
        if thisExp.status == FINISHED or endExpNow:
            endExperiment(thisExp, inputs=inputs, win=win)
            return
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            routineForceEnded = True
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in debriefComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # --- Ending Routine "debrief" ---
    for thisComponent in debriefComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    # store data for thisExp (ExperimentHandler)
    thisExp.nextEntry()
    # the Routine "debrief" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    
    # mark experiment as finished
    endExperiment(thisExp, win=win, inputs=inputs)


def saveData(thisExp):
    """
    Save data from this experiment
    
    Parameters
    ==========
    thisExp : psychopy.data.ExperimentHandler
        Handler object for this experiment, contains the data to save and information about 
        where to save it to.
    """
    filename = thisExp.dataFileName
    # these shouldn't be strictly necessary (should auto-save)
    thisExp.saveAsWideText(filename + '.csv', delim='auto')
    thisExp.saveAsPickle(filename)


def endExperiment(thisExp, inputs=None, win=None):
    """
    End this experiment, performing final shut down operations.
    
    This function does NOT close the window or end the Python process - use `quit` for this.
    
    Parameters
    ==========
    thisExp : psychopy.data.ExperimentHandler
        Handler object for this experiment, contains the data to save and information about 
        where to save it to.
    inputs : dict
        Dictionary of input devices by name.
    win : psychopy.visual.Window
        Window for this experiment.
    """
    if win is not None:
        # remove autodraw from all current components
        win.clearAutoDraw()
        # Flip one final time so any remaining win.callOnFlip() 
        # and win.timeOnFlip() tasks get executed
        win.flip()
    # mark experiment handler as finished
    thisExp.status = FINISHED
    # shut down eyetracker, if there is one
    if inputs is not None:
        if 'eyetracker' in inputs and inputs['eyetracker'] is not None:
            inputs['eyetracker'].setConnectionState(False)


def quit(thisExp, win=None, inputs=None, thisSession=None):
    """
    Fully quit, closing the window and ending the Python process.
    
    Parameters
    ==========
    win : psychopy.visual.Window
        Window to close.
    inputs : dict
        Dictionary of input devices by name.
    thisSession : psychopy.session.Session or None
        Handle of the Session object this experiment is being run from, if any.
    """
    thisExp.abort()  # or data files will save again on exit
    # make sure everything is closed down
    if win is not None:
        # Flip one final time so any remaining win.callOnFlip() 
        # and win.timeOnFlip() tasks get executed before quitting
        win.flip()
        win.close()
    if inputs is not None:
        if 'eyetracker' in inputs and inputs['eyetracker'] is not None:
            inputs['eyetracker'].setConnectionState(False)
    if thisSession is not None:
        thisSession.stop()
    # terminate Python process
    core.quit()


# if running this experiment as a script...
if __name__ == '__main__':
    # call all functions in order
    expInfo = showExpInfoDlg(expInfo=expInfo)
    thisExp = setupData(expInfo=expInfo)
    logFile = setupLogging(filename=thisExp.dataFileName)
    win = setupWindow(expInfo=expInfo)
    inputs = setupInputs(expInfo=expInfo, thisExp=thisExp, win=win)
    run(
        expInfo=expInfo, 
        thisExp=thisExp, 
        win=win, 
        inputs=inputs
    )
    saveData(thisExp=thisExp)
    quit(thisExp=thisExp, win=win, inputs=inputs)
