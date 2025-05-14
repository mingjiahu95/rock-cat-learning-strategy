W_start1 = '<p>Welcome!</p>';
W_start2 = '<p>Thank you for participating in our experiment!</p>';
W_start3 = '<p style="color:red; font-weight:bold;">IMPORTANT: YOU MUST STAY IN FULL SCREEN MODE FOR THE ENTIRE EXPERIMENT OR YOU WILL NOT BE PAID</p>';
W_start4 = '<p>Your browser will enter full screen mode from here until the end of the experiment. If you leave full screen mode for any reason, you will exit the experiment, and you will return to Prolific without payment. Please remain in full screen mode for the whole experiment, which will take approximately 40-50 minutes.</p>';
sent1 = '<p>In this experiment, you will learn to identify 8 different kinds of rocks such as obsidian, pumice, etc.</p>';
sent2 = '<p>If you do a good job learning to identify the rocks, you will earn an additional <span style="color:green; font-weight:bold;">$4 bonus payment</span>.</p>';
sent3 = '<p>To get started, you will first be tested on your prior knowledge about the rocks you are about to learn.</p>';
sent4 = '<p>On each trial, you will see a picture of an example rock with buttons on the screen with the different types like below:</p>';
img1 = '<img src="Instructions/demo_class_response.png" style="max-height:300px; width:auto;"></img>';
sent5 = '<p>If you know what type of rock it is, make your selection by clicking the correct button.  If not, just make a guess on the rock type and proceed to the next rock.</p>';
sent6 = '<p>After you make your selection, the computer will say <q>Okay</q> to let you know it recorded your response.</p>';
sent7 = '<p>For most people, it will be the first time they’ve heard of these rocks, so during this first block, you should not feel bad about guessing.<span style="color:red; font-weight:bold;"> Your performance during this first round won’t affect the bonus payment.</span></p>';
sent8 = '<p>Click the right arrow to start the pre-test block.</p>';
sent9 = '<p>Now you’ve completed the pre-test block and will go through 4 cycles of training and testing phases.</p>'
sent10 = '<p>Now you’ve completed the pre-test block and will go through 4 cycles of training and testing phases. The training phase consists of two parts.</p>';
sent11 = '<p>In the training phase, you’ll be asked to classify individual rocks into the 8 geological types as in the pre-test. After you make your selection, the computer will tell you the correct answer.</p>';
sent12 = '<p>For the first part, you’ll be asked to classify individual rocks into the 8 geological types as in the pre-test. After you make your selection, the computer will tell you the correct answer.</p>';
sent13 = '<p>At first, you will be guessing, but by paying attention to the rocks and the correct answers provided by the computer, you should gradually learn to identify the rocks.</p>';
sent14 = '<p>The second part of the training block will ask you to choose one of the rocks that you find most difficult to identify.</p>';
img2 = '<img src="Instructions/demo_cat_selection_CCP1.png" style="max-height:150px; width:auto;"></img>';
sent15 = '<p>After selecting the first rock type, you will be prompted to choose a second type that is most easily confused with the first one you chose.</p>';
img3 = '<img src="Instructions/demo_cat_selection_CCP2.png" style="max-height:150px; width:auto;"></img>';
sent16 = '<p>The second part of the training block will select two rock types that may be difficult for you. You may click the <q>next</q> button to proceed to the next page</p>'
sent17 = '<p>After you make your selections, the computer will show you all the examples from the two rock categories you selected, side by side.</p>';
img4 = '<img src="Instructions/demo_cat_selection_GCP.png" style="max-height:150px; width:auto;"></img>';
sent18 = '<p>Please take your time to observe all the examples and think about how you can tell the two rock types apart.</p>';
sent19 = '<p>After a few seconds, a <q>next</q> button will appear at the bottom of the screen. You may click on it to enter the page where you can type in your descriptions for each rock type, as below.</p>';
img5 = '<img src="Instructions/demo_paired_cat_display1.png" style="max-height:300px; width:auto;"></img>';
img6 = '<img src="Instructions/demo_paired_cat_display2.png" style="max-height:450px; width:auto;"></img>';
sent20 = '<p>After seeing 12 such rock examples, you will be tested on what you have learned in a test phase. We will explain the rules for testing after you complete your first training phase.</p>';
sent21 = '<p>After learning 3 pairs of rock categories in this way, you will be tested on what you have learned in a test phase. We will explain the rules for testing after you complete your first training phase.</p>';
sent22 = '<p>Your goal is to learn to correctly classify the rocks into as many of the 8 geological types as you can during the TEST phase.</p>';
sent23 = '<p>The TRAINING trials will help you test your knowledge and learn the rock categories; <span style="color: red; font-weight: bold;">your performance during these TRAINING trials won’t affect the bonus payment.</span></p>';
sent24 = '<p>You will now start the first test phase of the experiment.</p>';
sent25 = '<p>During the test, you will be classifying rocks into the same 8 geological types as before. However, you will be seeing new rocks from each of the 8 geological types.</p>';
sent26 = '<p>As in the training, your task is to make your best guess of which type the rock belongs to by clicking one of the buttons.</p>';
sent27 = '<p>After you made the guess, the computer <span style="color:red;">WILL NOT</span> tell you whether your answer was correct. Like in the pre-test, the computer will just say <q>Okay</q> to let you know it recorded your response.</p>';
sent28 = '<p>At the end of each test period, the computer will let you know your overall percent correct for each rock type, as well as how often you have confused certain pairs of rock types.</p>';
sent29 = '<p>Remember, your goal is to learn to correctly classify the rocks into as many of the 8 geological types as you can during the TEST blocks.</p>';
W_end1 = '<p style="color:red; font-weight:bold;">Important!</p>';
W_end2 = '<p><span style="font-weight:bold;">Reminder: Stay in full screen mode throughout the full study.</span> If you exit full screen mode you will return to Prolific, and no compensation will be provided.</p>';



//construct pages and blocks
full_scr_instruction = W_start1 + W_start2 + W_start3 + W_start4;

pre_test_instruction = [sent1 + sent2,
                        sent3 + sent4 + img1 + sent5,
                        sent6 + sent7 + sent8];
        
train_seq_instruction_cond12 = [sent9 + sent11 + sent13,
                                sent20 + sent22 + sent23,
                                W_end1 + W_end2];

train_seq_instruction_cond34 = [sent10 + sent12 + sent13,
                                W_end1 + W_end2];

train_sim_instruction_cond3 = [sent16 + img4,
                               sent17 + img5 + sent18,
                               sent19 + img6,
                               sent21 + sent22 + sent23];

train_sim_instruction_cond4 = [sent14 + img2 + sent15 + img3,
                               sent17 + img5 + sent18,
                               sent19 + img6,
                               sent21 + sent22 + sent23];
test_instruction = [sent24 + sent25,
                    sent26 + sent27 + sent28,
                    sent29];


