/********************** 
 * Learnstrategy *
 **********************/

import { core, data, sound, util, visual, hardware } from './lib/psychojs-2023.2.3.js';
const { PsychoJS } = core;
const { TrialHandler, MultiStairHandler } = data;
const { Scheduler } = util;
//some handy aliases as in the psychopy scripts;
const { abs, sin, cos, PI: pi, sqrt } = Math;
const { round } = util;


// store info about the experiment session:
let expName = 'LearnStrategy';  // from the Builder filename that created this script
let expInfo = {
    'participant': '',
    'condition': ["SCN", "SCR", "TCN", "TCR"],
};

// Start code blocks for 'Before Experiment'
// Run 'Before Experiment' code from function_def

function isUpper(str) {return /^[A-Z]+$/.test(str); }

function isLower(str) {return /^[a-z]+$/.test(str); }

function reshapeArray(flatArray, dimensions) {
    function reshape(currentArray, dims) {
        if (dims.length === 1) {
            return currentArray.splice(0, dims[0]);
        }

        let result = [];
        for (let i = 0; i < dims[0]; i++) {
            result.push(reshape([...currentArray], dims.slice(1)));
            currentArray.splice(0, dims[1]);
        }
        return result;
    }

    return reshape([...flatArray], dimensions);
}

function ArraySize(arr) {
    let dimensions = [];

    while(Array.isArray(arr)) {
        dimensions.push(arr.length);
        arr = arr[0];
    }

    return dimensions;
}

function shuffleListElement(nestedList) {
    const flatList = nestedList.flat(Infinity);
    for (let i = flatList.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [flatList[i], flatList[j]] = [flatList[j], flatList[i]];
    }
    return reshapeArray(flatList, ArraySize(nestedList));
}

function getRandomSample(list, numSamples) {
  let sample_list = [];
  let tempList = [...list]; 
  for (let i = 0; i < numSamples; i++) {
    // If the temporary list is exhausted, refill and shuffle it
    if (tempList.length === 0) {
      tempList = [...list];
      shuffleListElement(tempList);
    }
    // Pick an element and remove it from the temporary array
    const randomIndex = Math.floor(Math.random() * tempList.length);
    sample_list.push(tempList.splice(randomIndex, 1)[0]);
  }
  return sample_list;
}


var rock_type;
var token;
var rock_info;
function extract_rock_info(fileName) {
    var rock_type,token,rock_info;
    rock_type = fileName.split("_")[1];
    token = fileName.split(".")[0].split("_").slice((- 1))[0];
    if (isUpper(rock_type[0]) && isLower(rock_type.slice(1)) && !isNaN(token)) {
        rock_info = {"type": rock_type, "token": token};
        return rock_info;
    }
    return null;
}


function EuclidDist(p1, p2) {
  let sum = 0;
  for (let i = 0; i < p1.length; i++) {
    sum += Math.pow((p2[i] - p1[i]), 2);
  }
  return Math.sqrt(sum);
}
//function standardize(xlist) {
//    var n_elem, ylist;
//    n_elem = xlist.length;
//    for (var i, _pj_c = 0, _pj_a = util.range(n_elem), _pj_b = _pj_a.length; (_pj_c < _pj_b); _pj_c += 1) {
//        i = _pj_a[_pj_c];
//        ylist.push(((xlist[i] - Math.min(...xlist)) / (Math.max(...xlist) - Math.min(...xlist))));
//    }
//    return ylist;
//}

var target_values;
var current_values;
var current_sum;
var current_diff;
var maxIterations;
var iteration;
function prop_to_count(proportions, target_sum) {
    var current_sum, current_diff, target_values, current_values, maxIterations, iteration;
    target_values = proportions.map(prop => prop * target_sum);
    current_values = target_values.map(value => util.round(value));
    current_sum = util.sum(current_values);
    current_diff = target_values.map((num, index) => num - current_values[index]);
    maxIterations = 1000; // Set a maximum number of iterations to prevent infinite loop
    iteration = 0;
    function findRandomIndexOfExtreme(list, extremeFunc) {
      const extremeVal = extremeFunc(...list);
      const extremeIndices = list
          .map((value, index) => value === extremeVal ? index : -1)
          .filter(index => index !== -1);
      return extremeIndices[Math.floor(Math.random() * extremeIndices.length)];
    };

    while (current_sum !== target_sum && iteration < maxIterations) {
            while (current_sum > target_sum){
                let i = findRandomIndexOfExtreme(current_diff, Math.min);
                current_values[i] -= 1;
                current_diff[i] += 1;
                current_sum -= 1;
            }
            while (current_sum < target_sum){
                let i = findRandomIndexOfExtreme(current_diff, Math.max);
                current_values[i] += 1;
                current_diff[i] -= 1;
                current_sum += 1;
            }
        }
        iteration++;
    return current_values;
};
//function ComputePredictAccuracy(train_dict, probe_dict, stim_dict) {
//    var corr_cat, probe_coord, probes_pred_corr, train_plus_stim_dict, sum_sim_corr, sum_sim_total, train_cat, train_coord, train_dist;
//    probes_pred_corr = [];
//    for (var j = 0; j < probe_dict.length; j++) {
//        j = _pj_a[_pj_c];
//        probe_coord = probe_dict[j].coord;
//        corr_cat = probe_dict[j].cat;
//        sum_sim_corr = 0;
//        sum_sim_total = 0;
//        train_plus_stim_dict = train_dict.concat(stim_dict);//assumes the length of stim_dict to be 1
//        for (var i = 0; i < train_plus_stim_dict.length; i++) {
//            train_coord = train_plus_stim_dict[i].coord;
//            train_dist = EuclidDist(train_coord, probe_coord);
//            train_cat = train_plus_stim_dict[i].cat;
//            sum_sim_total += Math.exp((- train_dist));
//            if ((train_cat === corr_cat)) {
//                sum_sim_corr += Math.exp((- train_dist));
//            }
//        }
//        probes_pred_corr.push((sum_sim_corr / sum_sim_total));
//    }
//    return util.average(probes_pred_corr);
//}


var filteredList;
var partitions;
function partitionList(originalList, separatePairs) {
    const separateNumbers = [...new Set(separatePairs.flat())];
    var filteredList, partition;
    filteredList = originalList.filter(n => !separateNumbers.includes(n));
    partitions = [[], []];
    separatePairs.forEach(pair => {
        if (Math.random() < 0.5) {
            partitions[0].push(pair[0]);
            partitions[1].push(pair[1]);
        } else {
            partitions[0].push(pair[1]);
            partitions[1].push(pair[0]);
        }
    });
    filteredList = shuffleListElement(filteredList);
    filteredList.forEach((num, i) => {
        partitions[i % 2].push(num);
    });

    return partitions;
}


// Run 'Before Experiment' code from end_expt_var
let end_message = " After you click \"ok\", you will be redirected to a short survey.";
let incomplete_url = "https://app.prolific.com/submissions/complete?cc=C15JKIPY";
// init psychoJS:
const psychoJS = new PsychoJS({
  debug: true
});

// open window:
psychoJS.openWindow({
  fullscr: true,
  color: new util.Color('white'),
  units: 'height',
  waitBlanking: true,
  backgroundImage: '',
  backgroundFit: 'none',
});
// schedule the experiment:
psychoJS.schedule(psychoJS.gui.DlgFromDict({
  dictionary: expInfo,
  title: expName
}));

const flowScheduler = new Scheduler(psychoJS);
const dialogCancelScheduler = new Scheduler(psychoJS);
psychoJS.scheduleCondition(function() { return (psychoJS.gui.dialogComponent.button === 'OK'); }, flowScheduler, dialogCancelScheduler);

// flowScheduler gets run if the participants presses OK
flowScheduler.add(updateInfo); // add timeStamp
flowScheduler.add(experimentInit);
const preload_trialsLoopScheduler = new Scheduler(psychoJS);
flowScheduler.add(preload_trialsLoopBegin(preload_trialsLoopScheduler));
flowScheduler.add(preload_trialsLoopScheduler);
flowScheduler.add(preload_trialsLoopEnd);


const TrainInstructions_controllerLoopScheduler = new Scheduler(psychoJS);
flowScheduler.add(TrainInstructions_controllerLoopBegin(TrainInstructions_controllerLoopScheduler));
flowScheduler.add(TrainInstructions_controllerLoopScheduler);
flowScheduler.add(TrainInstructions_controllerLoopEnd);





flowScheduler.add(expt_setupRoutineBegin());
flowScheduler.add(expt_setupRoutineEachFrame());
flowScheduler.add(expt_setupRoutineEnd());
const blocksLoopScheduler = new Scheduler(psychoJS);
flowScheduler.add(blocksLoopBegin(blocksLoopScheduler));
flowScheduler.add(blocksLoopScheduler);
flowScheduler.add(blocksLoopEnd);




























flowScheduler.add(debriefRoutineBegin());
flowScheduler.add(debriefRoutineEachFrame());
flowScheduler.add(debriefRoutineEnd());
flowScheduler.add(quitPsychoJS, end_message, true);

// quit if user presses Cancel in dialog box:
dialogCancelScheduler.add(quitPsychoJS, '', false);

psychoJS.start({
  expName: expName,
  expInfo: expInfo,
  resources: [
    // resources:
    {'name': 'stimuli/rock_image_info.xlsx', 'path': 'stimuli/rock_image_info.xlsx'},
    {'name': 'stimuli/test_instructions.xlsx', 'path': 'stimuli/test_instructions.xlsx'},
    {'name': 'Instructions/test1.png', 'path': 'Instructions/test1.png'},
    {'name': 'Instructions/test2.png', 'path': 'Instructions/test2.png'},
    {'name': 'Instructions/test3.png', 'path': 'Instructions/test3.png'},
    {'name': 'default.png', 'path': 'https://pavlovia.org/assets/default/default.png'},
    {'name': 'img/leftarrow.png', 'path': 'img/leftarrow.png'},
    {'name': 'img/rightarrow.png', 'path': 'img/rightarrow.png'},
    {'name': 'img/next.png', 'path': 'img/next.png'},
    {'name': 'Instructions/debrief.png', 'path': 'Instructions/debrief.png'},
    {'name': 'Instructions/train4.png', 'path': 'Instructions/train4.png'},
    {'name': 'Instructions/train8SCN.png', 'path': 'Instructions/train8SCN.png'},
    {'name': 'Instructions/train8SCR.png', 'path': 'Instructions/train8SCR.png'},
    {'name': 'Instructions/W.png', 'path': 'Instructions/W.png'},
    {'name': 'stimuli/rock_image_info.xlsx', 'path': 'stimuli/rock_image_info.xlsx'},
    {'name': 'rock_images/I_Andesite_01.jpg', 'path': 'rock_images/I_Andesite_01.jpg'},
    {'name': 'rock_images/I_Andesite_02.jpg', 'path': 'rock_images/I_Andesite_02.jpg'},
    {'name': 'rock_images/I_Andesite_03.jpg', 'path': 'rock_images/I_Andesite_03.jpg'},
    {'name': 'rock_images/I_Andesite_04.jpg', 'path': 'rock_images/I_Andesite_04.jpg'},
    {'name': 'rock_images/I_Andesite_05.jpg', 'path': 'rock_images/I_Andesite_05.jpg'},
    {'name': 'rock_images/I_Andesite_06.jpg', 'path': 'rock_images/I_Andesite_06.jpg'},
    {'name': 'rock_images/I_Andesite_07.jpg', 'path': 'rock_images/I_Andesite_07.jpg'},
    {'name': 'rock_images/I_Andesite_09.jpg', 'path': 'rock_images/I_Andesite_09.jpg'},
    {'name': 'rock_images/I_Andesite_10.jpg', 'path': 'rock_images/I_Andesite_10.jpg'},
    {'name': 'rock_images/I_Andesite_11.jpg', 'path': 'rock_images/I_Andesite_11.jpg'},
    {'name': 'rock_images/I_Andesite_14.jpg', 'path': 'rock_images/I_Andesite_14.jpg'},
    {'name': 'rock_images/I_Andesite_16.jpg', 'path': 'rock_images/I_Andesite_16.jpg'},
    {'name': 'rock_images/I_Basalt_01.jpg', 'path': 'rock_images/I_Basalt_01.jpg'},
    {'name': 'rock_images/I_Basalt_02.jpg', 'path': 'rock_images/I_Basalt_02.jpg'},
    {'name': 'rock_images/I_Basalt_04.jpg', 'path': 'rock_images/I_Basalt_04.jpg'},
    {'name': 'rock_images/I_Basalt_05.jpg', 'path': 'rock_images/I_Basalt_05.jpg'},
    {'name': 'rock_images/I_Basalt_06.jpg', 'path': 'rock_images/I_Basalt_06.jpg'},
    {'name': 'rock_images/I_Basalt_08.jpg', 'path': 'rock_images/I_Basalt_08.jpg'},
    {'name': 'rock_images/I_Basalt_09.jpg', 'path': 'rock_images/I_Basalt_09.jpg'},
    {'name': 'rock_images/I_Basalt_10.jpg', 'path': 'rock_images/I_Basalt_10.jpg'},
    {'name': 'rock_images/I_Basalt_11.jpg', 'path': 'rock_images/I_Basalt_11.jpg'},
    {'name': 'rock_images/I_Basalt_12.jpg', 'path': 'rock_images/I_Basalt_12.jpg'},
    {'name': 'rock_images/I_Basalt_14.jpg', 'path': 'rock_images/I_Basalt_14.jpg'},
    {'name': 'rock_images/I_Basalt_16.jpg', 'path': 'rock_images/I_Basalt_16.jpg'},
    {'name': 'rock_images/I_Diorite_02.jpg', 'path': 'rock_images/I_Diorite_02.jpg'},
    {'name': 'rock_images/I_Diorite_06.jpg', 'path': 'rock_images/I_Diorite_06.jpg'},
    {'name': 'rock_images/I_Diorite_07.jpg', 'path': 'rock_images/I_Diorite_07.jpg'},
    {'name': 'rock_images/I_Diorite_08.jpg', 'path': 'rock_images/I_Diorite_08.jpg'},
    {'name': 'rock_images/I_Diorite_09.jpg', 'path': 'rock_images/I_Diorite_09.jpg'},
    {'name': 'rock_images/I_Diorite_10.jpg', 'path': 'rock_images/I_Diorite_10.jpg'},
    {'name': 'rock_images/I_Diorite_11.jpg', 'path': 'rock_images/I_Diorite_11.jpg'},
    {'name': 'rock_images/I_Diorite_12.jpg', 'path': 'rock_images/I_Diorite_12.jpg'},
    {'name': 'rock_images/I_Diorite_13.jpg', 'path': 'rock_images/I_Diorite_13.jpg'},
    {'name': 'rock_images/I_Diorite_14.jpg', 'path': 'rock_images/I_Diorite_14.jpg'},
    {'name': 'rock_images/I_Diorite_15.jpg', 'path': 'rock_images/I_Diorite_15.jpg'},
    {'name': 'rock_images/I_Diorite_16.jpg', 'path': 'rock_images/I_Diorite_16.jpg'},
    {'name': 'rock_images/I_Gabbro_01.jpg', 'path': 'rock_images/I_Gabbro_01.jpg'},
    {'name': 'rock_images/I_Gabbro_03.jpg', 'path': 'rock_images/I_Gabbro_03.jpg'},
    {'name': 'rock_images/I_Gabbro_05.jpg', 'path': 'rock_images/I_Gabbro_05.jpg'},
    {'name': 'rock_images/I_Gabbro_08.jpg', 'path': 'rock_images/I_Gabbro_08.jpg'},
    {'name': 'rock_images/I_Gabbro_09.jpg', 'path': 'rock_images/I_Gabbro_09.jpg'},
    {'name': 'rock_images/I_Gabbro_10.jpg', 'path': 'rock_images/I_Gabbro_10.jpg'},
    {'name': 'rock_images/I_Gabbro_11.jpg', 'path': 'rock_images/I_Gabbro_11.jpg'},
    {'name': 'rock_images/I_Gabbro_12.jpg', 'path': 'rock_images/I_Gabbro_12.jpg'},
    {'name': 'rock_images/I_Gabbro_13.jpg', 'path': 'rock_images/I_Gabbro_13.jpg'},
    {'name': 'rock_images/I_Gabbro_14.jpg', 'path': 'rock_images/I_Gabbro_14.jpg'},
    {'name': 'rock_images/I_Gabbro_15.jpg', 'path': 'rock_images/I_Gabbro_15.jpg'},
    {'name': 'rock_images/I_Gabbro_16.jpg', 'path': 'rock_images/I_Gabbro_16.jpg'},
    {'name': 'rock_images/I_Obsidian_02.jpg', 'path': 'rock_images/I_Obsidian_02.jpg'},
    {'name': 'rock_images/I_Obsidian_04.jpg', 'path': 'rock_images/I_Obsidian_04.jpg'},
    {'name': 'rock_images/I_Obsidian_05.jpg', 'path': 'rock_images/I_Obsidian_05.jpg'},
    {'name': 'rock_images/I_Obsidian_06.jpg', 'path': 'rock_images/I_Obsidian_06.jpg'},
    {'name': 'rock_images/I_Obsidian_07.jpg', 'path': 'rock_images/I_Obsidian_07.jpg'},
    {'name': 'rock_images/I_Obsidian_08.jpg', 'path': 'rock_images/I_Obsidian_08.jpg'},
    {'name': 'rock_images/I_Obsidian_09.jpg', 'path': 'rock_images/I_Obsidian_09.jpg'},
    {'name': 'rock_images/I_Obsidian_10.jpg', 'path': 'rock_images/I_Obsidian_10.jpg'},
    {'name': 'rock_images/I_Obsidian_11.jpg', 'path': 'rock_images/I_Obsidian_11.jpg'},
    {'name': 'rock_images/I_Obsidian_12.jpg', 'path': 'rock_images/I_Obsidian_12.jpg'},
    {'name': 'rock_images/I_Obsidian_14.jpg', 'path': 'rock_images/I_Obsidian_14.jpg'},
    {'name': 'rock_images/I_Obsidian_16.jpg', 'path': 'rock_images/I_Obsidian_16.jpg'},
    {'name': 'rock_images/I_Pegmatite_03.jpg', 'path': 'rock_images/I_Pegmatite_03.jpg'},
    {'name': 'rock_images/I_Pegmatite_05.jpg', 'path': 'rock_images/I_Pegmatite_05.jpg'},
    {'name': 'rock_images/I_Pegmatite_06.jpg', 'path': 'rock_images/I_Pegmatite_06.jpg'},
    {'name': 'rock_images/I_Pegmatite_07.jpg', 'path': 'rock_images/I_Pegmatite_07.jpg'},
    {'name': 'rock_images/I_Pegmatite_08.jpg', 'path': 'rock_images/I_Pegmatite_08.jpg'},
    {'name': 'rock_images/I_Pegmatite_09.jpg', 'path': 'rock_images/I_Pegmatite_09.jpg'},
    {'name': 'rock_images/I_Pegmatite_10.jpg', 'path': 'rock_images/I_Pegmatite_10.jpg'},
    {'name': 'rock_images/I_Pegmatite_11.jpg', 'path': 'rock_images/I_Pegmatite_11.jpg'},
    {'name': 'rock_images/I_Pegmatite_12.jpg', 'path': 'rock_images/I_Pegmatite_12.jpg'},
    {'name': 'rock_images/I_Pegmatite_13.jpg', 'path': 'rock_images/I_Pegmatite_13.jpg'},
    {'name': 'rock_images/I_Pegmatite_15.jpg', 'path': 'rock_images/I_Pegmatite_15.jpg'},
    {'name': 'rock_images/I_Pegmatite_16.jpg', 'path': 'rock_images/I_Pegmatite_16.jpg'},
    {'name': 'rock_images/I_Peridotite_02.jpg', 'path': 'rock_images/I_Peridotite_02.jpg'},
    {'name': 'rock_images/I_Peridotite_04.jpg', 'path': 'rock_images/I_Peridotite_04.jpg'},
    {'name': 'rock_images/I_Peridotite_05.jpg', 'path': 'rock_images/I_Peridotite_05.jpg'},
    {'name': 'rock_images/I_Peridotite_06.jpg', 'path': 'rock_images/I_Peridotite_06.jpg'},
    {'name': 'rock_images/I_Peridotite_07.jpg', 'path': 'rock_images/I_Peridotite_07.jpg'},
    {'name': 'rock_images/I_Peridotite_08.jpg', 'path': 'rock_images/I_Peridotite_08.jpg'},
    {'name': 'rock_images/I_Peridotite_10.jpg', 'path': 'rock_images/I_Peridotite_10.jpg'},
    {'name': 'rock_images/I_Peridotite_12.jpg', 'path': 'rock_images/I_Peridotite_12.jpg'},
    {'name': 'rock_images/I_Peridotite_13.jpg', 'path': 'rock_images/I_Peridotite_13.jpg'},
    {'name': 'rock_images/I_Peridotite_14.jpg', 'path': 'rock_images/I_Peridotite_14.jpg'},
    {'name': 'rock_images/I_Peridotite_15.jpg', 'path': 'rock_images/I_Peridotite_15.jpg'},
    {'name': 'rock_images/I_Peridotite_16.jpg', 'path': 'rock_images/I_Peridotite_16.jpg'},
    {'name': 'rock_images/I_Pumice_02.jpg', 'path': 'rock_images/I_Pumice_02.jpg'},
    {'name': 'rock_images/I_Pumice_03.jpg', 'path': 'rock_images/I_Pumice_03.jpg'},
    {'name': 'rock_images/I_Pumice_04.jpg', 'path': 'rock_images/I_Pumice_04.jpg'},
    {'name': 'rock_images/I_Pumice_05.jpg', 'path': 'rock_images/I_Pumice_05.jpg'},
    {'name': 'rock_images/I_Pumice_06.jpg', 'path': 'rock_images/I_Pumice_06.jpg'},
    {'name': 'rock_images/I_Pumice_08.jpg', 'path': 'rock_images/I_Pumice_08.jpg'},
    {'name': 'rock_images/I_Pumice_09.jpg', 'path': 'rock_images/I_Pumice_09.jpg'},
    {'name': 'rock_images/I_Pumice_10.jpg', 'path': 'rock_images/I_Pumice_10.jpg'},
    {'name': 'rock_images/I_Pumice_13.jpg', 'path': 'rock_images/I_Pumice_13.jpg'},
    {'name': 'rock_images/I_Pumice_14.jpg', 'path': 'rock_images/I_Pumice_14.jpg'},
    {'name': 'rock_images/I_Pumice_15.jpg', 'path': 'rock_images/I_Pumice_15.jpg'},
    {'name': 'rock_images/I_Pumice_16.jpg', 'path': 'rock_images/I_Pumice_16.jpg'},
    {'name': 'stimuli/train_instructionsSCN.xlsx', 'path': 'stimuli/train_instructionsSCN.xlsx'},
    {'name': 'stimuli/train_instructionsSCR.xlsx', 'path': 'stimuli/train_instructionsSCR.xlsx'},
    {'name': 'stimuli/train_instructionsTCN.xlsx', 'path': 'stimuli/train_instructionsTCN.xlsx'},
    {'name': 'stimuli/train_instructionsTCR.xlsx', 'path': 'stimuli/train_instructionsTCR.xlsx'},
    {'name': 'Instructions/train3TC.png', 'path': 'Instructions/train3TC.png'},
    {'name': 'Instructions/train6TC.png', 'path': 'Instructions/train6TC.png'},
    {'name': 'Instructions/train7TC.png', 'path': 'Instructions/train7TC.png'},
    {'name': 'Instructions/train6SC.png', 'path': 'Instructions/train6SC.png'},
    {'name': 'Instructions/train7SC.png', 'path': 'Instructions/train7SC.png'},
    {'name': 'Instructions/test1.png', 'path': 'Instructions/test1.png'},
    {'name': 'Instructions/test2.png', 'path': 'Instructions/test2.png'},
    {'name': 'Instructions/test3.png', 'path': 'Instructions/test3.png'},
    {'name': 'Instructions/train1.png', 'path': 'Instructions/train1.png'},
    {'name': 'Instructions/train2.png', 'path': 'Instructions/train2.png'},
    {'name': 'Instructions/train3SC.png', 'path': 'Instructions/train3SC.png'},
    {'name': 'Instructions/train5.png', 'path': 'Instructions/train5.png'},
    {'name': 'stimuli/test_instructions.xlsx', 'path': 'stimuli/test_instructions.xlsx'},
    {'name': 'img/leftarrow.png', 'path': 'img/leftarrow.png'},
    {'name': 'img/next.png', 'path': 'img/next.png'},
    {'name': 'img/rightarrow.png', 'path': 'img/rightarrow.png'},
  ]
});

psychoJS.experimentLogger.setLevel(core.Logger.ServerLevel.DATA);


var currentLoop;
var frameDur;
async function updateInfo() {
  currentLoop = psychoJS.experiment;  // right now there are no loops
  expInfo['date'] = util.MonotonicClock.getDateStr();  // add a simple timestamp
  expInfo['expName'] = expName;
  expInfo['psychopyVersion'] = '2023.2.3';
  expInfo['OS'] = window.navigator.platform;


  // store frame rate of monitor if we can measure it successfully
  expInfo['frameRate'] = psychoJS.window.getActualFrameRate();
  if (typeof expInfo['frameRate'] !== 'undefined')
    frameDur = 1.0 / Math.round(expInfo['frameRate']);
  else
    frameDur = 1.0 / 60.0; // couldn't get a reliable measure so guess

  // add info from the URL:
  util.addInfoFromUrl(expInfo);
  psychoJS.setRedirectUrls('', incomplete_url);


  
  psychoJS.experiment.dataFileName = (("." + "/") + `data/${expInfo["participant"]}_${expName}_${expInfo["date"]}`);
  psychoJS.experiment.field_separator = '\t';


  return Scheduler.Event.NEXT;
}


var load_image_infoClock;
var directory_path;
var rockInfo_dict;
var instPrepClock;
var cur_row_train;
var show_instructions_train;
var max_slides_train;
var instruct_filename;
var arrowSize;
var arrowPos_back;
var arrowPos_next;
var train_instructionsClock;
var instruction_image_train;
var leftArrow;
var rightArrow;
var instruct_mouse_train;
var instruct_counter_train;
var expt_setupClock;
var next_buttonSize;
var gridSize;
var gridSize_large;
var rockSize_large;
var category_names;
var substring_map;
var num_cats;
var nblock;
var num_rows;
var num_cols;
var x_bound;
var y_bound;
var y_padding;
var grid_image_pos;
var grid_image_row;
var x_pos;
var y_pos;
var start_of_trainingProcessClock;
var block_prompt_train;
var fixationClock;
var fix_text;
var fix_circle;
var fix_mouse;
var fixation_bufferClock;
var fix_wait;
var condition_switchClock;
var Selection_trainClock;
var rock_grid_text;
var learn_mouse;
var Sampling_trainClock;
var rock_grid_rect_2;
var rock_grid_text_2;
var learn_mouse_2;
var Classification_trainClock;
var n_trials_total;
var buttons_nrow;
var buttons_ncol;
var buttons_ntotal;
var xbound;
var ybound;
var buttonSize;
var xPos;
var yPos;
var buttonPos;
var cat_button_clickable;
var cat_button_text;
var Button_rect;
var Button_txt;
var trial_rock_train;
var cat_mouse_l;
var progress_bar_text;
var train_trial_counter;
var prog_bar_border;
var prog_bar_rect;
var feedback_correctiveClock;
var trial_rock_train_2;
var fb_text_l;
var fb_text_l_2;
var next;
var fb_mouse;
var end_of_trainingProcessClock;
var test_instrPrepClock;
var cur_row_test;
var show_instructions_test;
var max_slides_test;
var test_instructionsClock;
var instruction_image_test;
var leftArrow_2;
var rightArrow_2;
var instruct_mouse_test;
var instruct_counter_test;
var start_of_testProcessClock;
var block_prompt_test;
var Classification_testClock;
var trial_rock_test;
var progress_bar_text_3;
var test_trial_counter;
var prog_bar_border_2;
var prog_bar_rect_2;
var cat_mouse_t;
var feedback_neutralClock;
var fb_text_t;
var end_of_testProcessClock;
var prc_corr_block_last3;
var end_block_msg_2;
var feedbackSC1;
var feedbackSC2;
var next_block_fb;
var next_mouse_block_fb;
var PS_dict_blocks;
var debriefClock;
var debrief_report;
var next_end_expt;
var next_mouse_end_expt;
var globalClock;
var routineTimer;
async function experimentInit() {
  // Initialize components for Routine "load_image_info"
  load_image_infoClock = new util.Clock();
  directory_path = "rock_images";
  rockInfo_dict = [];
  
  // Initialize components for Routine "instPrep"
  instPrepClock = new util.Clock();
  // Run 'Begin Experiment' code from instrPrecode
  cur_row_train = 0;
  show_instructions_train = 1;
  if (['TCN', 'TCR'].includes(expInfo['condition'])) {
      max_slides_train = 8 - 1;
  } else if (expInfo['condition'] === 'SCN') {
      max_slides_train = 9 - 1;
  } else if (expInfo['condition'] === 'SCR') {
      max_slides_train = 9 - 1;
  }
  instruct_filename = (("stimuli/train_instructions" + expInfo["condition"]) + ".xlsx");
  arrowSize = [0.15, 0.15];
  arrowPos_back = [(- 0.5), (- 0.38)];
  arrowPos_next = [0.5, (- 0.38)];
  
  // Initialize components for Routine "train_instructions"
  train_instructionsClock = new util.Clock();
  instruction_image_train = new visual.ImageStim({
    win : psychoJS.window,
    name : 'instruction_image_train', units : undefined, 
    image : 'default.png', mask : undefined,
    anchor : 'center',
    ori : 0.0, pos : [0, 0], size : [1.1, 0.62],
    color : new util.Color('white'), opacity : undefined,
    flipHoriz : false, flipVert : false,
    texRes : 128.0, interpolate : true, depth : -1.0 
  });
  leftArrow = new visual.ImageStim({
    win : psychoJS.window,
    name : 'leftArrow', units : undefined, 
    image : 'img/leftarrow.png', mask : undefined,
    anchor : 'center',
    ori : 0.0, pos : arrowPos_back, size : arrowSize,
    color : new util.Color('white'), opacity : undefined,
    flipHoriz : false, flipVert : false,
    texRes : 128.0, interpolate : true, depth : -2.0 
  });
  rightArrow = new visual.ImageStim({
    win : psychoJS.window,
    name : 'rightArrow', units : undefined, 
    image : 'img/rightarrow.png', mask : undefined,
    anchor : 'center',
    ori : 0.0, pos : arrowPos_next, size : arrowSize,
    color : new util.Color('white'), opacity : undefined,
    flipHoriz : false, flipVert : false,
    texRes : 128.0, interpolate : true, depth : -3.0 
  });
  instruct_mouse_train = new core.Mouse({
    win: psychoJS.window,
  });
  instruct_mouse_train.mouseClock = new util.Clock();
  instruct_counter_train = new visual.TextStim({
    win: psychoJS.window,
    name: 'instruct_counter_train',
    text: '',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, (- 0.45)], height: 0.05,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -5.0 
  });
  
  // Initialize components for Routine "expt_setup"
  expt_setupClock = new util.Clock();
  // Run 'Begin Experiment' code from function_def
  next_buttonSize = [0.24, 0.08];
  // Run 'Begin Experiment' code from def_rock_params
  // define experiment parameters
  gridSize = [0.11,0.11];
  gridSize_large = gridSize.map(element => element * 1.3);
  rockSize_large = gridSize.map(element => element * 1.2);
  category_names = ["Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice"];
  substring_map = {
      'Basalt': [['14', '16']],
      'Gabbro': [['03', '12'], ['14', '15']],
      'Pegmatite': [['09', '10']]
  };
  num_cats = category_names.length;
  nblock = 9;
  num_rows = 6;
  num_cols = num_cats;
  
  // define grid display parameters
  x_bound = [(- 0.55), 0.55];
  y_bound = [(- 0.39), 0.39];
  y_padding = 0.02;
  grid_image_pos = [];
  grid_image_row = [];
  x_pos = [];
  y_pos = [];
  for (var irow = 0; irow< num_rows; irow++) {
      grid_image_row = [];
      for (var icol = 0; icol< num_cols; icol++) {
          x_pos = (x_bound[0] + ((icol * (x_bound[1] - x_bound[0])) / (num_cols - 1)));
          y_pos = (y_bound[0] + ((irow * (y_bound[1] - y_bound[0])) / (num_rows - 1)));
          if (y_pos > 0){
              y_pos = y_pos + y_padding}
          else{
              y_pos = y_pos - y_padding};
          grid_image_row.push([x_pos, y_pos]);
      }
      grid_image_pos.push(grid_image_row);
  }
  
  // Initialize components for Routine "start_of_trainingProcess"
  start_of_trainingProcessClock = new util.Clock();
  block_prompt_train = new visual.TextStim({
    win: psychoJS.window,
    name: 'block_prompt_train',
    text: '',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, 0], height: 0.05,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -1.0 
  });
  
  // Initialize components for Routine "fixation"
  fixationClock = new util.Clock();
  fix_text = new visual.TextStim({
    win: psychoJS.window,
    name: 'fix_text',
    text: 'move your mouse to the dot at the center to continue',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, 0.1], height: 0.05,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -2.0 
  });
  
  fix_circle = new visual.Polygon({
    win: psychoJS.window, name: 'fix_circle', 
    edges: 100, size:[0.03, 0.03],
    ori: 0.0, pos: [0, 0],
    anchor: 'center',
    lineWidth: 1.0, 
    colorSpace: 'rgb',
    lineColor: new util.Color('black'),
    fillColor: new util.Color('black'),
    opacity: undefined, depth: -3, interpolate: true,
  });
  
  fix_mouse = new core.Mouse({
    win: psychoJS.window,
  });
  fix_mouse.mouseClock = new util.Clock();
  // Initialize components for Routine "fixation_buffer"
  fixation_bufferClock = new util.Clock();
  fix_wait = new visual.TextStim({
    win: psychoJS.window,
    name: 'fix_wait',
    text: 'loading...',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, 0], height: 0.1,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -1.0 
  });
  
  // Initialize components for Routine "condition_switch"
  condition_switchClock = new util.Clock();
  // Initialize components for Routine "Selection_train"
  Selection_trainClock = new util.Clock();
  rock_grid_text = new visual.TextStim({
    win: psychoJS.window,
    name: 'rock_grid_text',
    text: 'Click on the rock you want to study next',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, 0], height: 0.04,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -3.0 
  });
  
  learn_mouse = new core.Mouse({
    win: psychoJS.window,
  });
  learn_mouse.mouseClock = new util.Clock();
  // Initialize components for Routine "Sampling_train"
  Sampling_trainClock = new util.Clock();
  rock_grid_rect_2 = new visual.Rect ({
    win: psychoJS.window, name: 'rock_grid_rect_2', 
    width: [0.42, 0.05][0], height: [0.42, 0.05][1],
    ori: 0.0, pos: [0, 0],
    anchor: 'center',
    lineWidth: 2.0, 
    colorSpace: 'rgb',
    lineColor: new util.Color('white'),
    fillColor: new util.Color('white'),
    opacity: undefined, depth: -3, interpolate: true,
  });
  
  rock_grid_text_2 = new visual.TextStim({
    win: psychoJS.window,
    name: 'rock_grid_text_2',
    text: 'Click here to continue',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, 0], height: 0.04,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('white'),  opacity: undefined,
    depth: -4.0 
  });
  
  learn_mouse_2 = new core.Mouse({
    win: psychoJS.window,
  });
  learn_mouse_2.mouseClock = new util.Clock();
  // Initialize components for Routine "Classification_train"
  Classification_trainClock = new util.Clock();
  // Run 'Begin Experiment' code from prog_bar_train
  n_trials_total = (16 * 2);
  
  // Run 'Begin Experiment' code from buttons_config
  buttons_nrow = 2;
  buttons_ncol = 4;
  buttons_ntotal = (buttons_nrow * buttons_ncol);
  xbound = [(- 0.4), 0.4];
  ybound = [(- 0.25), (- 0.4)];
  buttonSize = [0.22, 0.08];
  xPos = [];
  yPos = [];
  buttonPos = [];
  for (var i_button = 0; i_button < buttons_ntotal; i_button++) {
      let i_button_x = i_button % buttons_ncol;
      let i_button_y = Math.floor(i_button / buttons_ncol);
      xPos = (xbound[0] + ((Math.abs((xbound[0] - xbound[1])) / (buttons_ncol - 1)) * i_button_x));
      yPos = (ybound[0] - ((Math.abs((ybound[0] - ybound[1])) / (buttons_nrow - 1)) * i_button_y));
      buttonPos.push([xPos, yPos]);
  }
  
  // Run 'Begin Experiment' code from draw_button_panel
  cat_button_clickable = [];
  cat_button_text = [];
  Button_rect = [];
  Button_txt = [];
  for (var i_button = 0; i_button < buttons_ntotal; i_button++) {
      cat_name = category_names[i_button];
      Button_rect = new visual.TextBox({"win": psychoJS.window, "name": (cat_name + "_rect"), "text": '', "placeholder": 'Type here...', "font": 'Arial', "pos": buttonPos[i_button], "letterHeight": 0.03, "lineSpacing": 1.0, "size": buttonSize, "units": undefined, "color": null, "colorSpace": 'rgb', "fillColor": undefined, "borderColor": 'black', "borderWidth": 0.007, "languageStyle": 'LTR', "bold": false, "italic": false, "opacity": undefined, "padding": 0.0, "alignment": 'center', "overflow": 'visible', "editable": false, "multiline": true, "anchor": 'center', "depth": (-6.0)});
      Button_txt = new visual.TextStim({"win": psychoJS.window, "name": (cat_name + "_txt"), "text": cat_name, "font": "Open Sans", "pos": buttonPos[i_button], "height": 0.04, "wrapWidth": null, "ori": 0.0, "color": "black", "colorSpace": "rgb", "opacity": null, "languageStyle": "LTR", "depth": (- 7.0)});
      cat_button_clickable.push(Button_rect);
      cat_button_text.push(Button_txt);
  }
  
  trial_rock_train = new visual.ImageStim({
    win : psychoJS.window,
    name : 'trial_rock_train', units : undefined, 
    image : 'default.png', mask : undefined,
    anchor : 'center',
    ori : 0.0, pos : [0, 0.1], size : 1.0,
    color : new util.Color([1,1,1]), opacity : undefined,
    flipHoriz : false, flipVert : false,
    texRes : 128.0, interpolate : true, depth : -6.0 
  });
  cat_mouse_l = new core.Mouse({
    win: psychoJS.window,
  });
  cat_mouse_l.mouseClock = new util.Clock();
  progress_bar_text = new visual.TextStim({
    win: psychoJS.window,
    name: 'progress_bar_text',
    text: 'Progress',
    font: 'Open Sans',
    units: undefined, 
    pos: [(- 0.55), 0.42], height: 0.05,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -8.0 
  });
  
  train_trial_counter = new visual.TextStim({
    win: psychoJS.window,
    name: 'train_trial_counter',
    text: '',
    font: 'Open Sans',
    units: undefined, 
    pos: [0.55, 0.42], height: 0.05,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -9.0 
  });
  
  prog_bar_border = new visual.Rect ({
    win: psychoJS.window, name: 'prog_bar_border', 
    width: [0.8, 0.03][0], height: [0.8, 0.03][1],
    ori: 0.0, pos: [(- 0.4), 0.42],
    anchor: 'center-left',
    lineWidth: 4.0, 
    colorSpace: 'rgb',
    lineColor: new util.Color('black'),
    fillColor: new util.Color('white'),
    opacity: undefined, depth: -10, interpolate: true,
  });
  
  prog_bar_rect = new visual.Rect ({
    win: psychoJS.window, name: 'prog_bar_rect', 
    width: [1.0, 1.0][0], height: [1.0, 1.0][1],
    ori: 0.0, pos: [(- 0.4), 0.42],
    anchor: 'center-left',
    lineWidth: 4.0, 
    colorSpace: 'rgb',
    lineColor: new util.Color('black'),
    fillColor: new util.Color('black'),
    opacity: undefined, depth: -11, interpolate: true,
  });
  
  // Initialize components for Routine "feedback_corrective"
  feedback_correctiveClock = new util.Clock();
  trial_rock_train_2 = new visual.ImageStim({
    win : psychoJS.window,
    name : 'trial_rock_train_2', units : undefined, 
    image : 'default.png', mask : undefined,
    anchor : 'center',
    ori : 0.0, pos : [0, 0.1], size : 1.0,
    color : new util.Color([1,1,1]), opacity : undefined,
    flipHoriz : false, flipVert : false,
    texRes : 128.0, interpolate : true, depth : -2.0 
  });
  fb_text_l = new visual.TextStim({
    win: psychoJS.window,
    name: 'fb_text_l',
    text: '',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, (- 0.22)], height: 0.05,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('white'),  opacity: undefined,
    depth: -3.0 
  });
  
  fb_text_l_2 = new visual.TextStim({
    win: psychoJS.window,
    name: 'fb_text_l_2',
    text: '',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, (- 0.28)], height: 0.05,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -4.0 
  });
  
  next = new visual.ImageStim({
    win : psychoJS.window,
    name : 'next', units : undefined, 
    image : 'img/next.png', mask : undefined,
    anchor : 'center',
    ori : 0.0, pos : [0, (- 0.4)], size : next_buttonSize,
    color : new util.Color('white'), opacity : undefined,
    flipHoriz : false, flipVert : false,
    texRes : 128.0, interpolate : true, depth : -5.0 
  });
  fb_mouse = new core.Mouse({
    win: psychoJS.window,
  });
  fb_mouse.mouseClock = new util.Clock();
  // Initialize components for Routine "end_of_trainingProcess"
  end_of_trainingProcessClock = new util.Clock();
  // Initialize components for Routine "test_instrPrep"
  test_instrPrepClock = new util.Clock();
  // Run 'Begin Experiment' code from instrPrecode_test
  cur_row_test = 0;
  show_instructions_test = 1;
  max_slides_test = (3 - 1);
  
  // Initialize components for Routine "test_instructions"
  test_instructionsClock = new util.Clock();
  instruction_image_test = new visual.ImageStim({
    win : psychoJS.window,
    name : 'instruction_image_test', units : undefined, 
    image : 'default.png', mask : undefined,
    anchor : 'center',
    ori : 0.0, pos : [0, 0], size : [1.1, 0.62],
    color : new util.Color('white'), opacity : undefined,
    flipHoriz : false, flipVert : false,
    texRes : 128.0, interpolate : true, depth : -1.0 
  });
  leftArrow_2 = new visual.ImageStim({
    win : psychoJS.window,
    name : 'leftArrow_2', units : undefined, 
    image : 'img/leftarrow.png', mask : undefined,
    anchor : 'center',
    ori : 0.0, pos : arrowPos_back, size : arrowSize,
    color : new util.Color('white'), opacity : undefined,
    flipHoriz : false, flipVert : false,
    texRes : 128.0, interpolate : true, depth : -2.0 
  });
  rightArrow_2 = new visual.ImageStim({
    win : psychoJS.window,
    name : 'rightArrow_2', units : undefined, 
    image : 'img/rightarrow.png', mask : undefined,
    anchor : 'center',
    ori : 0.0, pos : arrowPos_next, size : arrowSize,
    color : new util.Color('white'), opacity : undefined,
    flipHoriz : false, flipVert : false,
    texRes : 128.0, interpolate : true, depth : -3.0 
  });
  instruct_mouse_test = new core.Mouse({
    win: psychoJS.window,
  });
  instruct_mouse_test.mouseClock = new util.Clock();
  instruct_counter_test = new visual.TextStim({
    win: psychoJS.window,
    name: 'instruct_counter_test',
    text: '',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, (- 0.45)], height: 0.05,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -5.0 
  });
  
  // Initialize components for Routine "start_of_testProcess"
  start_of_testProcessClock = new util.Clock();
  block_prompt_test = new visual.TextStim({
    win: psychoJS.window,
    name: 'block_prompt_test',
    text: '',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, 0], height: 0.05,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -1.0 
  });
  
  // Initialize components for Routine "Classification_test"
  Classification_testClock = new util.Clock();
  trial_rock_test = new visual.ImageStim({
    win : psychoJS.window,
    name : 'trial_rock_test', units : undefined, 
    image : 'default.png', mask : undefined,
    anchor : 'center',
    ori : 0.0, pos : [0, 0.1], size : 1.0,
    color : new util.Color('white'), opacity : undefined,
    flipHoriz : false, flipVert : false,
    texRes : 128.0, interpolate : true, depth : -5.0 
  });
  progress_bar_text_3 = new visual.TextStim({
    win: psychoJS.window,
    name: 'progress_bar_text_3',
    text: 'Progress',
    font: 'Open Sans',
    units: undefined, 
    pos: [(- 0.55), 0.42], height: 0.05,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -6.0 
  });
  
  test_trial_counter = new visual.TextStim({
    win: psychoJS.window,
    name: 'test_trial_counter',
    text: '',
    font: 'Open Sans',
    units: undefined, 
    pos: [0.55, 0.42], height: 0.05,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -7.0 
  });
  
  prog_bar_border_2 = new visual.Rect ({
    win: psychoJS.window, name: 'prog_bar_border_2', 
    width: [0.8, 0.03][0], height: [0.8, 0.03][1],
    ori: 0.0, pos: [(- 0.4), 0.42],
    anchor: 'center-left',
    lineWidth: 4.0, 
    colorSpace: 'rgb',
    lineColor: new util.Color('black'),
    fillColor: new util.Color('white'),
    opacity: undefined, depth: -8, interpolate: true,
  });
  
  prog_bar_rect_2 = new visual.Rect ({
    win: psychoJS.window, name: 'prog_bar_rect_2', 
    width: [1.0, 1.0][0], height: [1.0, 1.0][1],
    ori: 0.0, pos: [(- 0.4), 0.42],
    anchor: 'center-left',
    lineWidth: 2.0, 
    colorSpace: 'rgb',
    lineColor: new util.Color('black'),
    fillColor: new util.Color('black'),
    opacity: undefined, depth: -9, interpolate: true,
  });
  
  cat_mouse_t = new core.Mouse({
    win: psychoJS.window,
  });
  cat_mouse_t.mouseClock = new util.Clock();
  // Initialize components for Routine "feedback_neutral"
  feedback_neutralClock = new util.Clock();
  fb_text_t = new visual.TextStim({
    win: psychoJS.window,
    name: 'fb_text_t',
    text: 'Okay',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, 0], height: 0.04,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -1.0 
  });
  
  // Initialize components for Routine "end_of_testProcess"
  end_of_testProcessClock = new util.Clock();
  // Run 'Begin Experiment' code from format_accuracy_summary
  prc_corr_block_last3 = [];
  
  end_block_msg_2 = new visual.TextStim({
    win: psychoJS.window,
    name: 'end_block_msg_2',
    text: '',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, 0], height: 0.05,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -2.0 
  });
  
  feedbackSC1 = new visual.TextStim({
    win: psychoJS.window,
    name: 'feedbackSC1',
    text: 'Summary of classification accuracy for each category:\n',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, 0.4], height: 0.05,  wrapWidth: 1.0, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('black'),  opacity: undefined,
    depth: -3.0 
  });
  
  feedbackSC2 = new visual.TextStim({
    win: psychoJS.window,
    name: 'feedbackSC2',
    text: '',
    font: 'Open Sans',
    units: undefined, 
    pos: [0, (- 0.05)], height: 0.04,  wrapWidth: undefined, ori: 0.0,
    languageStyle: 'LTR',
    color: new util.Color('red'),  opacity: undefined,
    depth: -4.0 
  });
  
  next_block_fb = new visual.ImageStim({
    win : psychoJS.window,
    name : 'next_block_fb', units : undefined, 
    image : 'img/next.png', mask : undefined,
    anchor : 'center',
    ori : 0.0, pos : [0, (- 0.4)], size : next_buttonSize,
    color : new util.Color('white'), opacity : undefined,
    flipHoriz : false, flipVert : false,
    texRes : 128.0, interpolate : true, depth : -5.0 
  });
  next_mouse_block_fb = new core.Mouse({
    win: psychoJS.window,
  });
  next_mouse_block_fb.mouseClock = new util.Clock();
  // Run 'Begin Experiment' code from compute_diff_indices
  PS_dict_blocks = {};
  category_names.forEach(cat_name => {
      PS_dict_blocks[cat_name] = [];
  });
  // Initialize components for Routine "debrief"
  debriefClock = new util.Clock();
  debrief_report = new visual.ImageStim({
    win : psychoJS.window,
    name : 'debrief_report', units : undefined, 
    image : 'Instructions/debrief.png', mask : undefined,
    anchor : 'center',
    ori : 0.0, pos : [0, 0], size : [1.4, 0.8],
    color : new util.Color('white'), opacity : undefined,
    flipHoriz : false, flipVert : false,
    texRes : 128.0, interpolate : true, depth : 0.0 
  });
  next_end_expt = new visual.ImageStim({
    win : psychoJS.window,
    name : 'next_end_expt', units : undefined, 
    image : 'img/next.png', mask : undefined,
    anchor : 'center',
    ori : 0.0, pos : [0, (- 0.4)], size : next_buttonSize,
    color : new util.Color('white'), opacity : undefined,
    flipHoriz : false, flipVert : false,
    texRes : 128.0, interpolate : true, depth : -1.0 
  });
  next_mouse_end_expt = new core.Mouse({
    win: psychoJS.window,
  });
  next_mouse_end_expt.mouseClock = new util.Clock();
  // Create some handy timers
  globalClock = new util.Clock();  // to track the time since experiment started
  routineTimer = new util.CountdownTimer();  // to track time remaining of each (non-slip) routine
  
  return Scheduler.Event.NEXT;
}


var preload_trials;
function preload_trialsLoopBegin(preload_trialsLoopScheduler, snapshot) {
  return async function() {
    TrialHandler.fromSnapshot(snapshot); // update internal variables (.thisN etc) of the loop
    
    // set up handler to look after randomisation of conditions etc
    preload_trials = new TrialHandler({
      psychoJS: psychoJS,
      nReps: 1, method: TrialHandler.Method.SEQUENTIAL,
      extraInfo: expInfo, originPath: undefined,
      trialList: 'stimuli/rock_image_info.xlsx',
      seed: undefined, name: 'preload_trials'
    });
    psychoJS.experiment.addLoop(preload_trials); // add the loop to the experiment
    currentLoop = preload_trials;  // we're now the current loop
    
    // Schedule all the trials in the trialList:
    for (const thisPreload_trial of preload_trials) {
      snapshot = preload_trials.getSnapshot();
      preload_trialsLoopScheduler.add(importConditions(snapshot));
      preload_trialsLoopScheduler.add(load_image_infoRoutineBegin(snapshot));
      preload_trialsLoopScheduler.add(load_image_infoRoutineEachFrame());
      preload_trialsLoopScheduler.add(load_image_infoRoutineEnd(snapshot));
      preload_trialsLoopScheduler.add(preload_trialsLoopEndIteration(preload_trialsLoopScheduler, snapshot));
    }
    
    return Scheduler.Event.NEXT;
  }
}


async function preload_trialsLoopEnd() {
  // terminate loop
  psychoJS.experiment.removeLoop(preload_trials);
  // update the current loop from the ExperimentHandler
  if (psychoJS.experiment._unfinishedLoops.length>0)
    currentLoop = psychoJS.experiment._unfinishedLoops.at(-1);
  else
    currentLoop = psychoJS.experiment;  // so we use addData from the experiment
  return Scheduler.Event.NEXT;
}


function preload_trialsLoopEndIteration(scheduler, snapshot) {
  // ------Prepare for next entry------
  return async function () {
    if (typeof snapshot !== 'undefined') {
      // ------Check if user ended loop early------
      if (snapshot.finished) {
        // Check for and save orphaned data
        if (psychoJS.experiment.isEntryEmpty()) {
          psychoJS.experiment.nextEntry(snapshot);
        }
        scheduler.stop();
      }
    return Scheduler.Event.NEXT;
    }
  };
}


var TrainInstructions_controller;
function TrainInstructions_controllerLoopBegin(TrainInstructions_controllerLoopScheduler, snapshot) {
  return async function() {
    TrialHandler.fromSnapshot(snapshot); // update internal variables (.thisN etc) of the loop
    
    // set up handler to look after randomisation of conditions etc
    TrainInstructions_controller = new TrialHandler({
      psychoJS: psychoJS,
      nReps: 9999, method: TrialHandler.Method.RANDOM,
      extraInfo: expInfo, originPath: undefined,
      trialList: undefined,
      seed: undefined, name: 'TrainInstructions_controller'
    });
    psychoJS.experiment.addLoop(TrainInstructions_controller); // add the loop to the experiment
    currentLoop = TrainInstructions_controller;  // we're now the current loop
    
    // Schedule all the trials in the trialList:
    for (const thisTrainInstructions_controller of TrainInstructions_controller) {
      snapshot = TrainInstructions_controller.getSnapshot();
      TrainInstructions_controllerLoopScheduler.add(importConditions(snapshot));
      TrainInstructions_controllerLoopScheduler.add(instPrepRoutineBegin(snapshot));
      TrainInstructions_controllerLoopScheduler.add(instPrepRoutineEachFrame());
      TrainInstructions_controllerLoopScheduler.add(instPrepRoutineEnd(snapshot));
      const TrainInstruction_trialsLoopScheduler = new Scheduler(psychoJS);
      TrainInstructions_controllerLoopScheduler.add(TrainInstruction_trialsLoopBegin(TrainInstruction_trialsLoopScheduler, snapshot));
      TrainInstructions_controllerLoopScheduler.add(TrainInstruction_trialsLoopScheduler);
      TrainInstructions_controllerLoopScheduler.add(TrainInstruction_trialsLoopEnd);
      TrainInstructions_controllerLoopScheduler.add(TrainInstructions_controllerLoopEndIteration(TrainInstructions_controllerLoopScheduler, snapshot));
    }
    
    return Scheduler.Event.NEXT;
  }
}


var TrainInstruction_trials;
function TrainInstruction_trialsLoopBegin(TrainInstruction_trialsLoopScheduler, snapshot) {
  return async function() {
    TrialHandler.fromSnapshot(snapshot); // update internal variables (.thisN etc) of the loop
    
    // set up handler to look after randomisation of conditions etc
    TrainInstruction_trials = new TrialHandler({
      psychoJS: psychoJS,
      nReps: show_instructions_train, method: TrialHandler.Method.SEQUENTIAL,
      extraInfo: expInfo, originPath: undefined,
      trialList: TrialHandler.importConditions(psychoJS.serverManager, instruct_filename, cur_row_train_string),
      seed: undefined, name: 'TrainInstruction_trials'
    });
    psychoJS.experiment.addLoop(TrainInstruction_trials); // add the loop to the experiment
    currentLoop = TrainInstruction_trials;  // we're now the current loop
    
    // Schedule all the trials in the trialList:
    for (const thisTrainInstruction_trial of TrainInstruction_trials) {
      snapshot = TrainInstruction_trials.getSnapshot();
      TrainInstruction_trialsLoopScheduler.add(importConditions(snapshot));
      TrainInstruction_trialsLoopScheduler.add(train_instructionsRoutineBegin(snapshot));
      TrainInstruction_trialsLoopScheduler.add(train_instructionsRoutineEachFrame());
      TrainInstruction_trialsLoopScheduler.add(train_instructionsRoutineEnd(snapshot));
      TrainInstruction_trialsLoopScheduler.add(TrainInstruction_trialsLoopEndIteration(TrainInstruction_trialsLoopScheduler, snapshot));
    }
    
    return Scheduler.Event.NEXT;
  }
}


async function TrainInstruction_trialsLoopEnd() {
  // terminate loop
  psychoJS.experiment.removeLoop(TrainInstruction_trials);
  // update the current loop from the ExperimentHandler
  if (psychoJS.experiment._unfinishedLoops.length>0)
    currentLoop = psychoJS.experiment._unfinishedLoops.at(-1);
  else
    currentLoop = psychoJS.experiment;  // so we use addData from the experiment
  return Scheduler.Event.NEXT;
}


function TrainInstruction_trialsLoopEndIteration(scheduler, snapshot) {
  // ------Prepare for next entry------
  return async function () {
    if (typeof snapshot !== 'undefined') {
      // ------Check if user ended loop early------
      if (snapshot.finished) {
        // Check for and save orphaned data
        if (psychoJS.experiment.isEntryEmpty()) {
          psychoJS.experiment.nextEntry(snapshot);
        }
        scheduler.stop();
      }
    return Scheduler.Event.NEXT;
    }
  };
}


async function TrainInstructions_controllerLoopEnd() {
  // terminate loop
  psychoJS.experiment.removeLoop(TrainInstructions_controller);
  // update the current loop from the ExperimentHandler
  if (psychoJS.experiment._unfinishedLoops.length>0)
    currentLoop = psychoJS.experiment._unfinishedLoops.at(-1);
  else
    currentLoop = psychoJS.experiment;  // so we use addData from the experiment
  return Scheduler.Event.NEXT;
}


function TrainInstructions_controllerLoopEndIteration(scheduler, snapshot) {
  // ------Prepare for next entry------
  return async function () {
    if (typeof snapshot !== 'undefined') {
      // ------Check if user ended loop early------
      if (snapshot.finished) {
        // Check for and save orphaned data
        if (psychoJS.experiment.isEntryEmpty()) {
          psychoJS.experiment.nextEntry(snapshot);
        }
        scheduler.stop();
      }
    return Scheduler.Event.NEXT;
    }
  };
}


var blocks;
function blocksLoopBegin(blocksLoopScheduler, snapshot) {
  return async function() {
    TrialHandler.fromSnapshot(snapshot); // update internal variables (.thisN etc) of the loop
    
    // set up handler to look after randomisation of conditions etc
    blocks = new TrialHandler({
      psychoJS: psychoJS,
      nReps: nblock, method: TrialHandler.Method.RANDOM,
      extraInfo: expInfo, originPath: undefined,
      trialList: undefined,
      seed: undefined, name: 'blocks'
    });
    psychoJS.experiment.addLoop(blocks); // add the loop to the experiment
    currentLoop = blocks;  // we're now the current loop
    
    // Schedule all the trials in the trialList:
    for (const thisBlock of blocks) {
      snapshot = blocks.getSnapshot();
      blocksLoopScheduler.add(importConditions(snapshot));
      blocksLoopScheduler.add(start_of_trainingProcessRoutineBegin(snapshot));
      blocksLoopScheduler.add(start_of_trainingProcessRoutineEachFrame());
      blocksLoopScheduler.add(start_of_trainingProcessRoutineEnd(snapshot));
      const train_trialsLoopScheduler = new Scheduler(psychoJS);
      blocksLoopScheduler.add(train_trialsLoopBegin(train_trialsLoopScheduler, snapshot));
      blocksLoopScheduler.add(train_trialsLoopScheduler);
      blocksLoopScheduler.add(train_trialsLoopEnd);
      blocksLoopScheduler.add(end_of_trainingProcessRoutineBegin(snapshot));
      blocksLoopScheduler.add(end_of_trainingProcessRoutineEachFrame());
      blocksLoopScheduler.add(end_of_trainingProcessRoutineEnd(snapshot));
      const testInstructions_controllerLoopScheduler = new Scheduler(psychoJS);
      blocksLoopScheduler.add(testInstructions_controllerLoopBegin(testInstructions_controllerLoopScheduler, snapshot));
      blocksLoopScheduler.add(testInstructions_controllerLoopScheduler);
      blocksLoopScheduler.add(testInstructions_controllerLoopEnd);
      blocksLoopScheduler.add(start_of_testProcessRoutineBegin(snapshot));
      blocksLoopScheduler.add(start_of_testProcessRoutineEachFrame());
      blocksLoopScheduler.add(start_of_testProcessRoutineEnd(snapshot));
      const test_trialsLoopScheduler = new Scheduler(psychoJS);
      blocksLoopScheduler.add(test_trialsLoopBegin(test_trialsLoopScheduler, snapshot));
      blocksLoopScheduler.add(test_trialsLoopScheduler);
      blocksLoopScheduler.add(test_trialsLoopEnd);
      blocksLoopScheduler.add(end_of_testProcessRoutineBegin(snapshot));
      blocksLoopScheduler.add(end_of_testProcessRoutineEachFrame());
      blocksLoopScheduler.add(end_of_testProcessRoutineEnd(snapshot));
      blocksLoopScheduler.add(blocksLoopEndIteration(blocksLoopScheduler, snapshot));
    }
    
    return Scheduler.Event.NEXT;
  }
}


var train_trials;
function train_trialsLoopBegin(train_trialsLoopScheduler, snapshot) {
  return async function() {
    TrialHandler.fromSnapshot(snapshot); // update internal variables (.thisN etc) of the loop
    
    // set up handler to look after randomisation of conditions etc
    train_trials = new TrialHandler({
      psychoJS: psychoJS,
      nReps: 2*num_cats, method: TrialHandler.Method.RANDOM,
      extraInfo: expInfo, originPath: undefined,
      trialList: undefined,
      seed: undefined, name: 'train_trials'
    });
    psychoJS.experiment.addLoop(train_trials); // add the loop to the experiment
    currentLoop = train_trials;  // we're now the current loop
    
    // Schedule all the trials in the trialList:
    for (const thisTrain_trial of train_trials) {
      snapshot = train_trials.getSnapshot();
      train_trialsLoopScheduler.add(importConditions(snapshot));
      train_trialsLoopScheduler.add(fixationRoutineBegin(snapshot));
      train_trialsLoopScheduler.add(fixationRoutineEachFrame());
      train_trialsLoopScheduler.add(fixationRoutineEnd(snapshot));
      train_trialsLoopScheduler.add(fixation_bufferRoutineBegin(snapshot));
      train_trialsLoopScheduler.add(fixation_bufferRoutineEachFrame());
      train_trialsLoopScheduler.add(fixation_bufferRoutineEnd(snapshot));
      train_trialsLoopScheduler.add(condition_switchRoutineBegin(snapshot));
      train_trialsLoopScheduler.add(condition_switchRoutineEachFrame());
      train_trialsLoopScheduler.add(condition_switchRoutineEnd(snapshot));
      const SC_cond_filterLoopScheduler = new Scheduler(psychoJS);
      train_trialsLoopScheduler.add(SC_cond_filterLoopBegin(SC_cond_filterLoopScheduler, snapshot));
      train_trialsLoopScheduler.add(SC_cond_filterLoopScheduler);
      train_trialsLoopScheduler.add(SC_cond_filterLoopEnd);
      const TC_cond_filterLoopScheduler = new Scheduler(psychoJS);
      train_trialsLoopScheduler.add(TC_cond_filterLoopBegin(TC_cond_filterLoopScheduler, snapshot));
      train_trialsLoopScheduler.add(TC_cond_filterLoopScheduler);
      train_trialsLoopScheduler.add(TC_cond_filterLoopEnd);
      train_trialsLoopScheduler.add(Classification_trainRoutineBegin(snapshot));
      train_trialsLoopScheduler.add(Classification_trainRoutineEachFrame());
      train_trialsLoopScheduler.add(Classification_trainRoutineEnd(snapshot));
      train_trialsLoopScheduler.add(feedback_correctiveRoutineBegin(snapshot));
      train_trialsLoopScheduler.add(feedback_correctiveRoutineEachFrame());
      train_trialsLoopScheduler.add(feedback_correctiveRoutineEnd(snapshot));
      train_trialsLoopScheduler.add(train_trialsLoopEndIteration(train_trialsLoopScheduler, snapshot));
    }
    
    return Scheduler.Event.NEXT;
  }
}


var SC_cond_filter;
function SC_cond_filterLoopBegin(SC_cond_filterLoopScheduler, snapshot) {
  return async function() {
    TrialHandler.fromSnapshot(snapshot); // update internal variables (.thisN etc) of the loop
    
    // set up handler to look after randomisation of conditions etc
    SC_cond_filter = new TrialHandler({
      psychoJS: psychoJS,
      nReps: nrep_selection, method: TrialHandler.Method.RANDOM,
      extraInfo: expInfo, originPath: undefined,
      trialList: undefined,
      seed: undefined, name: 'SC_cond_filter'
    });
    psychoJS.experiment.addLoop(SC_cond_filter); // add the loop to the experiment
    currentLoop = SC_cond_filter;  // we're now the current loop
    
    // Schedule all the trials in the trialList:
    for (const thisSC_cond_filter of SC_cond_filter) {
      snapshot = SC_cond_filter.getSnapshot();
      SC_cond_filterLoopScheduler.add(importConditions(snapshot));
      SC_cond_filterLoopScheduler.add(Selection_trainRoutineBegin(snapshot));
      SC_cond_filterLoopScheduler.add(Selection_trainRoutineEachFrame());
      SC_cond_filterLoopScheduler.add(Selection_trainRoutineEnd(snapshot));
      SC_cond_filterLoopScheduler.add(SC_cond_filterLoopEndIteration(SC_cond_filterLoopScheduler, snapshot));
    }
    
    return Scheduler.Event.NEXT;
  }
}


async function SC_cond_filterLoopEnd() {
  // terminate loop
  psychoJS.experiment.removeLoop(SC_cond_filter);
  // update the current loop from the ExperimentHandler
  if (psychoJS.experiment._unfinishedLoops.length>0)
    currentLoop = psychoJS.experiment._unfinishedLoops.at(-1);
  else
    currentLoop = psychoJS.experiment;  // so we use addData from the experiment
  return Scheduler.Event.NEXT;
}


function SC_cond_filterLoopEndIteration(scheduler, snapshot) {
  // ------Prepare for next entry------
  return async function () {
    if (typeof snapshot !== 'undefined') {
      // ------Check if user ended loop early------
      if (snapshot.finished) {
        // Check for and save orphaned data
        if (psychoJS.experiment.isEntryEmpty()) {
          psychoJS.experiment.nextEntry(snapshot);
        }
        scheduler.stop();
      }
    return Scheduler.Event.NEXT;
    }
  };
}


var TC_cond_filter;
function TC_cond_filterLoopBegin(TC_cond_filterLoopScheduler, snapshot) {
  return async function() {
    TrialHandler.fromSnapshot(snapshot); // update internal variables (.thisN etc) of the loop
    
    // set up handler to look after randomisation of conditions etc
    TC_cond_filter = new TrialHandler({
      psychoJS: psychoJS,
      nReps: nrep_sampling, method: TrialHandler.Method.RANDOM,
      extraInfo: expInfo, originPath: undefined,
      trialList: undefined,
      seed: undefined, name: 'TC_cond_filter'
    });
    psychoJS.experiment.addLoop(TC_cond_filter); // add the loop to the experiment
    currentLoop = TC_cond_filter;  // we're now the current loop
    
    // Schedule all the trials in the trialList:
    for (const thisTC_cond_filter of TC_cond_filter) {
      snapshot = TC_cond_filter.getSnapshot();
      TC_cond_filterLoopScheduler.add(importConditions(snapshot));
      TC_cond_filterLoopScheduler.add(Sampling_trainRoutineBegin(snapshot));
      TC_cond_filterLoopScheduler.add(Sampling_trainRoutineEachFrame());
      TC_cond_filterLoopScheduler.add(Sampling_trainRoutineEnd(snapshot));
      TC_cond_filterLoopScheduler.add(TC_cond_filterLoopEndIteration(TC_cond_filterLoopScheduler, snapshot));
    }
    
    return Scheduler.Event.NEXT;
  }
}


async function TC_cond_filterLoopEnd() {
  // terminate loop
  psychoJS.experiment.removeLoop(TC_cond_filter);
  // update the current loop from the ExperimentHandler
  if (psychoJS.experiment._unfinishedLoops.length>0)
    currentLoop = psychoJS.experiment._unfinishedLoops.at(-1);
  else
    currentLoop = psychoJS.experiment;  // so we use addData from the experiment
  return Scheduler.Event.NEXT;
}


function TC_cond_filterLoopEndIteration(scheduler, snapshot) {
  // ------Prepare for next entry------
  return async function () {
    if (typeof snapshot !== 'undefined') {
      // ------Check if user ended loop early------
      if (snapshot.finished) {
        // Check for and save orphaned data
        if (psychoJS.experiment.isEntryEmpty()) {
          psychoJS.experiment.nextEntry(snapshot);
        }
        scheduler.stop();
      }
    return Scheduler.Event.NEXT;
    }
  };
}


async function train_trialsLoopEnd() {
  // terminate loop
  psychoJS.experiment.removeLoop(train_trials);
  // update the current loop from the ExperimentHandler
  if (psychoJS.experiment._unfinishedLoops.length>0)
    currentLoop = psychoJS.experiment._unfinishedLoops.at(-1);
  else
    currentLoop = psychoJS.experiment;  // so we use addData from the experiment
  return Scheduler.Event.NEXT;
}


function train_trialsLoopEndIteration(scheduler, snapshot) {
  // ------Prepare for next entry------
  return async function () {
    if (typeof snapshot !== 'undefined') {
      // ------Check if user ended loop early------
      if (snapshot.finished) {
        // Check for and save orphaned data
        if (psychoJS.experiment.isEntryEmpty()) {
          psychoJS.experiment.nextEntry(snapshot);
        }
        scheduler.stop();
      } else {
        psychoJS.experiment.nextEntry(snapshot);
      }
    return Scheduler.Event.NEXT;
    }
  };
}


var testInstructions_controller;
function testInstructions_controllerLoopBegin(testInstructions_controllerLoopScheduler, snapshot) {
  return async function() {
    TrialHandler.fromSnapshot(snapshot); // update internal variables (.thisN etc) of the loop
    
    // set up handler to look after randomisation of conditions etc
    testInstructions_controller = new TrialHandler({
      psychoJS: psychoJS,
      nReps: testInstr_nrep, method: TrialHandler.Method.RANDOM,
      extraInfo: expInfo, originPath: undefined,
      trialList: undefined,
      seed: undefined, name: 'testInstructions_controller'
    });
    psychoJS.experiment.addLoop(testInstructions_controller); // add the loop to the experiment
    currentLoop = testInstructions_controller;  // we're now the current loop
    
    // Schedule all the trials in the trialList:
    for (const thisTestInstructions_controller of testInstructions_controller) {
      snapshot = testInstructions_controller.getSnapshot();
      testInstructions_controllerLoopScheduler.add(importConditions(snapshot));
      testInstructions_controllerLoopScheduler.add(test_instrPrepRoutineBegin(snapshot));
      testInstructions_controllerLoopScheduler.add(test_instrPrepRoutineEachFrame());
      testInstructions_controllerLoopScheduler.add(test_instrPrepRoutineEnd(snapshot));
      const testInstruction_trialsLoopScheduler = new Scheduler(psychoJS);
      testInstructions_controllerLoopScheduler.add(testInstruction_trialsLoopBegin(testInstruction_trialsLoopScheduler, snapshot));
      testInstructions_controllerLoopScheduler.add(testInstruction_trialsLoopScheduler);
      testInstructions_controllerLoopScheduler.add(testInstruction_trialsLoopEnd);
      testInstructions_controllerLoopScheduler.add(testInstructions_controllerLoopEndIteration(testInstructions_controllerLoopScheduler, snapshot));
    }
    
    return Scheduler.Event.NEXT;
  }
}


var testInstruction_trials;
function testInstruction_trialsLoopBegin(testInstruction_trialsLoopScheduler, snapshot) {
  return async function() {
    TrialHandler.fromSnapshot(snapshot); // update internal variables (.thisN etc) of the loop
    
    // set up handler to look after randomisation of conditions etc
    testInstruction_trials = new TrialHandler({
      psychoJS: psychoJS,
      nReps: show_instructions_test, method: TrialHandler.Method.SEQUENTIAL,
      extraInfo: expInfo, originPath: undefined,
      trialList: TrialHandler.importConditions(psychoJS.serverManager, 'stimuli/test_instructions.xlsx', cur_row_test_string),
      seed: undefined, name: 'testInstruction_trials'
    });
    psychoJS.experiment.addLoop(testInstruction_trials); // add the loop to the experiment
    currentLoop = testInstruction_trials;  // we're now the current loop
    
    // Schedule all the trials in the trialList:
    for (const thisTestInstruction_trial of testInstruction_trials) {
      snapshot = testInstruction_trials.getSnapshot();
      testInstruction_trialsLoopScheduler.add(importConditions(snapshot));
      testInstruction_trialsLoopScheduler.add(test_instructionsRoutineBegin(snapshot));
      testInstruction_trialsLoopScheduler.add(test_instructionsRoutineEachFrame());
      testInstruction_trialsLoopScheduler.add(test_instructionsRoutineEnd(snapshot));
      testInstruction_trialsLoopScheduler.add(testInstruction_trialsLoopEndIteration(testInstruction_trialsLoopScheduler, snapshot));
    }
    
    return Scheduler.Event.NEXT;
  }
}


async function testInstruction_trialsLoopEnd() {
  // terminate loop
  psychoJS.experiment.removeLoop(testInstruction_trials);
  // update the current loop from the ExperimentHandler
  if (psychoJS.experiment._unfinishedLoops.length>0)
    currentLoop = psychoJS.experiment._unfinishedLoops.at(-1);
  else
    currentLoop = psychoJS.experiment;  // so we use addData from the experiment
  return Scheduler.Event.NEXT;
}


function testInstruction_trialsLoopEndIteration(scheduler, snapshot) {
  // ------Prepare for next entry------
  return async function () {
    if (typeof snapshot !== 'undefined') {
      // ------Check if user ended loop early------
      if (snapshot.finished) {
        // Check for and save orphaned data
        if (psychoJS.experiment.isEntryEmpty()) {
          psychoJS.experiment.nextEntry(snapshot);
        }
        scheduler.stop();
      }
    return Scheduler.Event.NEXT;
    }
  };
}


async function testInstructions_controllerLoopEnd() {
  // terminate loop
  psychoJS.experiment.removeLoop(testInstructions_controller);
  // update the current loop from the ExperimentHandler
  if (psychoJS.experiment._unfinishedLoops.length>0)
    currentLoop = psychoJS.experiment._unfinishedLoops.at(-1);
  else
    currentLoop = psychoJS.experiment;  // so we use addData from the experiment
  return Scheduler.Event.NEXT;
}


function testInstructions_controllerLoopEndIteration(scheduler, snapshot) {
  // ------Prepare for next entry------
  return async function () {
    if (typeof snapshot !== 'undefined') {
      // ------Check if user ended loop early------
      if (snapshot.finished) {
        // Check for and save orphaned data
        if (psychoJS.experiment.isEntryEmpty()) {
          psychoJS.experiment.nextEntry(snapshot);
        }
        scheduler.stop();
      }
    return Scheduler.Event.NEXT;
    }
  };
}


var test_trials;
function test_trialsLoopBegin(test_trialsLoopScheduler, snapshot) {
  return async function() {
    TrialHandler.fromSnapshot(snapshot); // update internal variables (.thisN etc) of the loop
    
    // set up handler to look after randomisation of conditions etc
    test_trials = new TrialHandler({
      psychoJS: psychoJS,
      nReps: 2*num_cats, method: TrialHandler.Method.RANDOM,
      extraInfo: expInfo, originPath: undefined,
      trialList: undefined,
      seed: undefined, name: 'test_trials'
    });
    psychoJS.experiment.addLoop(test_trials); // add the loop to the experiment
    currentLoop = test_trials;  // we're now the current loop
    
    // Schedule all the trials in the trialList:
    for (const thisTest_trial of test_trials) {
      snapshot = test_trials.getSnapshot();
      test_trialsLoopScheduler.add(importConditions(snapshot));
      test_trialsLoopScheduler.add(Classification_testRoutineBegin(snapshot));
      test_trialsLoopScheduler.add(Classification_testRoutineEachFrame());
      test_trialsLoopScheduler.add(Classification_testRoutineEnd(snapshot));
      test_trialsLoopScheduler.add(feedback_neutralRoutineBegin(snapshot));
      test_trialsLoopScheduler.add(feedback_neutralRoutineEachFrame());
      test_trialsLoopScheduler.add(feedback_neutralRoutineEnd(snapshot));
      test_trialsLoopScheduler.add(test_trialsLoopEndIteration(test_trialsLoopScheduler, snapshot));
    }
    
    return Scheduler.Event.NEXT;
  }
}


async function test_trialsLoopEnd() {
  // terminate loop
  psychoJS.experiment.removeLoop(test_trials);
  // update the current loop from the ExperimentHandler
  if (psychoJS.experiment._unfinishedLoops.length>0)
    currentLoop = psychoJS.experiment._unfinishedLoops.at(-1);
  else
    currentLoop = psychoJS.experiment;  // so we use addData from the experiment
  return Scheduler.Event.NEXT;
}


function test_trialsLoopEndIteration(scheduler, snapshot) {
  // ------Prepare for next entry------
  return async function () {
    if (typeof snapshot !== 'undefined') {
      // ------Check if user ended loop early------
      if (snapshot.finished) {
        // Check for and save orphaned data
        if (psychoJS.experiment.isEntryEmpty()) {
          psychoJS.experiment.nextEntry(snapshot);
        }
        scheduler.stop();
      } else {
        psychoJS.experiment.nextEntry(snapshot);
      }
    return Scheduler.Event.NEXT;
    }
  };
}


async function blocksLoopEnd() {
  // terminate loop
  psychoJS.experiment.removeLoop(blocks);
  // update the current loop from the ExperimentHandler
  if (psychoJS.experiment._unfinishedLoops.length>0)
    currentLoop = psychoJS.experiment._unfinishedLoops.at(-1);
  else
    currentLoop = psychoJS.experiment;  // so we use addData from the experiment
  return Scheduler.Event.NEXT;
}


function blocksLoopEndIteration(scheduler, snapshot) {
  // ------Prepare for next entry------
  return async function () {
    if (typeof snapshot !== 'undefined') {
      // ------Check if user ended loop early------
      if (snapshot.finished) {
        // Check for and save orphaned data
        if (psychoJS.experiment.isEntryEmpty()) {
          psychoJS.experiment.nextEntry(snapshot);
        }
        scheduler.stop();
      }
    return Scheduler.Event.NEXT;
    }
  };
}


var t;
var frameN;
var continueRoutine;
var load_image_infoComponents;
function load_image_infoRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'load_image_info' ---
    t = 0;
    load_image_infoClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    rockInfo_dict.push({'name':file_name,'size':[width,height]});
    // keep track of which components have finished
    load_image_infoComponents = [];
    
    for (const thisComponent of load_image_infoComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function load_image_infoRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'load_image_info' ---
    // get current time
    t = load_image_infoClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of load_image_infoComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function load_image_infoRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'load_image_info' ---
    for (const thisComponent of load_image_infoComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // the Routine "load_image_info" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var cur_row_train_string;
var instPrepComponents;
function instPrepRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'instPrep' ---
    t = 0;
    instPrepClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    // Run 'Begin Routine' code from instrPrecode
    if (instruct_mouse_test.isPressedIn(rightArrow)) {
        cur_row_train += 1;
    } else {
        if (instruct_mouse_test.isPressedIn(leftArrow)) {
            cur_row_train -= 1;
        }
    }
    if ((cur_row_train < 0)) {
        cur_row_train = 0;
    }
    if ((cur_row_train > max_slides_train)) {
        TrainInstructions_controller.finished = 1;
        show_instructions_train = 0;
        cur_row_train = (max_slides_train - 1);
    }
    cur_row_train_string = cur_row_train.toString();
    
    // keep track of which components have finished
    instPrepComponents = [];
    
    for (const thisComponent of instPrepComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function instPrepRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'instPrep' ---
    // get current time
    t = instPrepClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of instPrepComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function instPrepRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'instPrep' ---
    for (const thisComponent of instPrepComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // the Routine "instPrep" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var gotValidClick;
var train_instructionsComponents;
function train_instructionsRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'train_instructions' ---
    t = 0;
    train_instructionsClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    instruction_image_train.setImage(train_slide);
    // setup some python lists for storing info about the instruct_mouse_train
    instruct_mouse_train.clicked_name = [];
    gotValidClick = false; // until a click is received
    instruct_counter_train.setText((((cur_row_train + 1).toString() + "/") + (max_slides_train + 1).toString()));
    // keep track of which components have finished
    train_instructionsComponents = [];
    train_instructionsComponents.push(instruction_image_train);
    train_instructionsComponents.push(leftArrow);
    train_instructionsComponents.push(rightArrow);
    train_instructionsComponents.push(instruct_mouse_train);
    train_instructionsComponents.push(instruct_counter_train);
    
    for (const thisComponent of train_instructionsComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


var prevButtonState;
var _mouseButtons;
function train_instructionsRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'train_instructions' ---
    // get current time
    t = train_instructionsClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // Run 'Each Frame' code from full_screen_5
    if (frameN > 10) {
        if (! psychoJS.window._windowAlreadyInFullScreen) {
        alert("looks like you exited full screen mode. You must stay in full screen mode to be eligible to participate");
        quitPsychoJS('',false);
        }
    }
    
    
    // *instruction_image_train* updates
    if (t >= 0.0 && instruction_image_train.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      instruction_image_train.tStart = t;  // (not accounting for frame time here)
      instruction_image_train.frameNStart = frameN;  // exact frame index
      
      instruction_image_train.setAutoDraw(true);
    }
    
    
    // *leftArrow* updates
    if (t >= 0.0 && leftArrow.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      leftArrow.tStart = t;  // (not accounting for frame time here)
      leftArrow.frameNStart = frameN;  // exact frame index
      
      leftArrow.setAutoDraw(true);
    }
    
    
    // *rightArrow* updates
    if (t >= 0.0 && rightArrow.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      rightArrow.tStart = t;  // (not accounting for frame time here)
      rightArrow.frameNStart = frameN;  // exact frame index
      
      rightArrow.setAutoDraw(true);
    }
    
    // *instruct_mouse_train* updates
    if (t >= 0.0 && instruct_mouse_train.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      instruct_mouse_train.tStart = t;  // (not accounting for frame time here)
      instruct_mouse_train.frameNStart = frameN;  // exact frame index
      
      instruct_mouse_train.status = PsychoJS.Status.STARTED;
      instruct_mouse_train.mouseClock.reset();
      prevButtonState = instruct_mouse_train.getPressed();  // if button is down already this ISN'T a new click
      }
    if (instruct_mouse_train.status === PsychoJS.Status.STARTED) {  // only update if started and not finished!
      _mouseButtons = instruct_mouse_train.getPressed();
      if (!_mouseButtons.every( (e,i,) => (e == prevButtonState[i]) )) { // button state changed?
        prevButtonState = _mouseButtons;
        if (_mouseButtons.reduce( (e, acc) => (e+acc) ) > 0) { // state changed to a new click
          // check if the mouse was inside our 'clickable' objects
          gotValidClick = false;
          for (const obj of [leftArrow,rightArrow]) {
            if (obj.contains(instruct_mouse_train)) {
              gotValidClick = true;
              instruct_mouse_train.clicked_name.push(obj.name)
            }
          }
          if (gotValidClick === true) { // end routine on response
            continueRoutine = false;
          }
        }
      }
    }
    
    // *instruct_counter_train* updates
    if (t >= 0.0 && instruct_counter_train.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      instruct_counter_train.tStart = t;  // (not accounting for frame time here)
      instruct_counter_train.frameNStart = frameN;  // exact frame index
      
      instruct_counter_train.setAutoDraw(true);
    }
    
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of train_instructionsComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function train_instructionsRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'train_instructions' ---
    for (const thisComponent of train_instructionsComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // store data for psychoJS.experiment (ExperimentHandler)
    // the Routine "train_instructions" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var cat_token_index_train;
var cat_token_index_test;
var file_names;
var image_fileInfo_dict_ordered;
var cat_name;
var token_idx;
var grid_image_fileInfo;
var rock_grid;
var rock_rect_grid;
var rock_fileName_grid;
var rock_info_grid;
var rock_cat_num;
var rock_token;
var rock_rows;
var rock_cols;
var rock_pos;
var image_fileInfo;
var image_fileName;
var rock_name;
var rock_rect_name;
var rock_image;
var rock_rect;
var logical_order;
var permutation;
var logical_cat;
var train_images;
var seq_idx;
var block_images;
var file_names_cat;
var logical_idx1;
var logical_idx2;
var tokens_idx1;
var tokens_idx2;
var test_images;
var expt_setupComponents;
function expt_setupRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'expt_setup' ---
    t = 0;
    expt_setupClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    // Run 'Begin Routine' code from def_rock_params
    // partition token indices into training and test sets 
    cat_token_index_train = [];
    cat_token_index_test = [];
    file_names = rockInfo_dict.map(file => file.name);
    
    
    for (let cat_name of category_names) {
        let file_names_cat = file_names.filter(file => file.includes(cat_name));
        let separatePairs = [];
        
        if (substring_map[cat_name]) {
            for (let substring of substring_map[cat_name]) {
                let rockIndex = [null, null];
                rockIndex[0] = file_names_cat.map((file, index) => file.includes(substring[0]) ? index : null).filter(index => index !== null)[0];
                rockIndex[1] = file_names_cat.map((file, index) => file.includes(substring[1]) ? index : null).filter(index => index !== null)[0];
                separatePairs.push(rockIndex);
            }
        }
        
        let indexList = Array.from({length: 12}, (_, index) => index);
        const [part1, part2] = partitionList(indexList, separatePairs); // Assuming partitionList function is defined
        
        cat_token_index_train.push(part1);
        cat_token_index_test.push(part2);
    }
    //console.log('cat_token_index_train:',cat_token_index_train);
    //console.log('cat_token_index_test:',cat_token_index_test);
    
    // define grid image files
    image_fileInfo_dict_ordered = [];
    cat_name =[];
    token_idx=[];
    for (var irow = 0; irow < num_rows; irow++) {
        let row_image_fileInfo = [];
        for (var icat = 0; icat < num_cats; icat++) {
            cat_name = category_names[icat];
            let rockInfo_dict_cat = rockInfo_dict.filter(file => file.name.includes(cat_name));
            token_idx = cat_token_index_train[icat][irow];
            row_image_fileInfo.push(rockInfo_dict_cat[token_idx]);
        }
        image_fileInfo_dict_ordered.push(row_image_fileInfo);
    }
    grid_image_fileInfo = shuffleListElement(image_fileInfo_dict_ordered);
    
    // Run 'Begin Routine' code from def_rock_grid
    rock_grid = [];
    rock_rect_grid = [];
    rock_fileName_grid = [];
    rock_info_grid = [];
    rock_cat_num = [];
    rock_token = [];
    rock_rows = [];
    rock_cols = [];
    rock_pos = [];
    image_fileInfo = [];
    image_fileName = [];
    rock_info = [];
    rock_name = [];
    rock_rect_name = [];
    rock_image = [];
    rock_rect = [];
    for (var irow = 0; irow < num_rows; irow++) {
        for (var icol = 0; icol < num_cols; icol++) {
            rock_pos = grid_image_pos[irow][icol];
            image_fileInfo = grid_image_fileInfo[irow][icol];
            image_fileName = image_fileInfo.name;
            rock_info = extract_rock_info(image_fileName);
            rock_name = ((rock_info.type + "_") + rock_info.token);
            rock_rect_name = ((rock_name + "_") + "rect");
            rock_image = new visual.ImageStim({"win": psychoJS.window, "name": rock_name, "image": ((directory_path + "/") + image_fileName), "mask": null, "anchor": "center", "ori": 0.0, "pos": rock_pos, "size": gridSize, "color": [1, 1, 1], "colorSpace": "rgb", "opacity": null, "flipHoriz": false, "flipVert": false, "texRes": 128.0, "interpolate": true, "depth": (- 1.0)});
            rock_rect = new visual.TextBox({"win": psychoJS.window, "name": rock_rect_name, "text": '', "placeholder": 'Type here...', "font": 'Arial', "pos": rock_pos, "letterHeight": 0, "lineSpacing": 1.0, "size": gridSize_large, "units": undefined, "color": null, "colorSpace": 'rgb', "fillColor": null, "borderColor": "black", "borderWidth": 0.008, "languageStyle": 'LTR', "bold": false, "italic": false, "opacity": 1, "padding": 0.0, "alignment": 'center', "overflow": 'visible', "editable": false, "multiline": true, "anchor": 'center', "depth": (-5.0)});        
            rock_grid.push(rock_image);
            rock_rect_grid.push(rock_rect);
            rock_fileName_grid.push(image_fileName);
            rock_rows.push(irow);
            rock_cols.push(icol);
            // save rock info for data export
            rock_cat_num = category_names.findIndex(cat => cat === rock_info.type) + 1;
            rock_token = rock_info.token;
            rock_info_grid.push({row:irow+1, col:icol+1, cat:rock_cat_num, token:rock_token});
        }
    }
    // Run 'Begin Routine' code from sample_rocks_train
    if (['TCR','TCN','SCR'].includes(expInfo["condition"])){
        logical_order = [];
        permutation = [];
        logical_cat=[];
        for (var icat = 0; icat < num_cats; icat++) {
            logical_cat = [];
            for (var irep = 0; irep < 3; irep++) {
                permutation = shuffleListElement(util.range(num_rows));
                logical_cat.push(...permutation);
            }
            logical_order.push(logical_cat);
        }
        train_images = [];
        seq_idx = [];
        block_images = [];
        file_names_cat = [];
        logical_idx1 = [];
        logical_idx2 = [];
        tokens_idx1 = [];
        tokens_idx2 = [];
        for (var iblock = 0; iblock < nblock; iblock++) {
            seq_idx = [];
            seq_idx.push((iblock * 2));
            seq_idx.push(((iblock * 2) + 1));
            block_images = [];
            for (var icat = 0; icat < num_cats; icat++) {
                logical_idx1 = logical_order[icat][seq_idx[0]];
                logical_idx2 = logical_order[icat][seq_idx[1]];
                cat_name = category_names[icat];
                let rockInfo_dict_cat = rockInfo_dict.filter(file => file.name.includes(cat_name));
                tokens_idx1 = cat_token_index_train[icat][logical_idx1];
                tokens_idx2 = cat_token_index_train[icat][logical_idx2];
                block_images.push(rockInfo_dict_cat[tokens_idx1]);
                block_images.push(rockInfo_dict_cat[tokens_idx2]);
            }
            block_images = shuffleListElement(block_images);
            train_images.push(block_images);
        }
    }
    // Run 'Begin Routine' code from sample_rocks_test
    logical_order = [];
    permutation = [];
    logical_cat=[];
    for (var icat = 0; icat < num_cats; icat++) {
        logical_cat = [];
        for (var irep = 0; irep < 3; irep++) {
            permutation = shuffleListElement(util.range(num_rows));
            logical_cat.push(...permutation);
        }
        logical_order.push(logical_cat);
    }
    test_images = [];
    seq_idx = [];
    block_images = [];
    logical_idx1 = [];
    logical_idx2 = [];
    tokens_idx1 = [];
    tokens_idx2 = [];
    for (var iblock = 0; iblock < nblock; iblock++) {
        seq_idx = [];
        seq_idx.push((iblock * 2));
        seq_idx.push(((iblock * 2) + 1));
        block_images = [];
        for (var icat = 0; icat < num_cats; icat++) {
            logical_idx1 = logical_order[icat][seq_idx[0]];
            logical_idx2 = logical_order[icat][seq_idx[1]];
            cat_name = category_names[icat];
            let rockInfo_dict_cat = rockInfo_dict.filter(file => file.name.includes(cat_name));
            tokens_idx1 = cat_token_index_test[icat][logical_idx1];
            tokens_idx2 = cat_token_index_test[icat][logical_idx2];
            block_images.push(rockInfo_dict_cat[tokens_idx1]);
            block_images.push(rockInfo_dict_cat[tokens_idx2]);
        }
        block_images = shuffleListElement(block_images);
        test_images.push(block_images);
    }
    
    // keep track of which components have finished
    expt_setupComponents = [];
    
    for (const thisComponent of expt_setupComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function expt_setupRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'expt_setup' ---
    // get current time
    t = expt_setupClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of expt_setupComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function expt_setupRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'expt_setup' ---
    for (const thisComponent of expt_setupComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // the Routine "expt_setup" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var train_block_images;
var start_of_trainingProcessComponents;
function start_of_trainingProcessRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'start_of_trainingProcess' ---
    t = 0;
    start_of_trainingProcessClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    routineTimer.add(1.000000);
    // update component parameters for each repeat
    block_prompt_train.setText(((("Starting Training Block " + (blocks.thisN + 1).toString()) + " of ") + blocks.nTotal.toString()));
    // Run 'Begin Routine' code from adjust_rocks_train_block
    train_block_images = [];
    if (['SCR','TCR'].includes(expInfo['condition'])) {
        if ((blocks.thisN === 0)) {
            train_block_images = train_images[blocks.thisN];
        } else {
            let train_images_flat = train_images.flat();
            let prc_list_thisblock = Object.values(prc_dict_thisblock);
            let num_items_cats = prop_to_count(prc_list_thisblock, (2 * num_cats));
            for (let icat = 0; icat < num_cats; icat++) {
                let cat_name = category_names[icat];
                let train_images_cat = train_images_flat.filter(file => file.name.includes(cat_name));
                let train_images_cat_sampled = getRandomSample(train_images_cat, num_items_cats[icat]);
                train_block_images.push(...train_images_cat_sampled);
            }
            train_block_images = shuffleListElement(train_block_images);
        }
    } else if (expInfo['condition'] === 'TCN'){
        train_block_images = train_images[blocks.thisN];
    }
    // keep track of which components have finished
    start_of_trainingProcessComponents = [];
    start_of_trainingProcessComponents.push(block_prompt_train);
    
    for (const thisComponent of start_of_trainingProcessComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


var frameRemains;
function start_of_trainingProcessRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'start_of_trainingProcess' ---
    // get current time
    t = start_of_trainingProcessClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // Run 'Each Frame' code from full_screen_10
    if (frameN > 10) {
        if (! psychoJS.window._windowAlreadyInFullScreen) {
        alert("looks like you exited full screen mode. You must stay in full screen mode to be eligible to participate");
        quitPsychoJS('',false);
        }
    }
    
    
    // *block_prompt_train* updates
    if (t >= 0.0 && block_prompt_train.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      block_prompt_train.tStart = t;  // (not accounting for frame time here)
      block_prompt_train.frameNStart = frameN;  // exact frame index
      
      block_prompt_train.setAutoDraw(true);
    }
    
    frameRemains = 0.0 + 1.0 - psychoJS.window.monitorFramePeriod * 0.75;  // most of one frame period left
    if (block_prompt_train.status === PsychoJS.Status.STARTED && t >= frameRemains) {
      block_prompt_train.setAutoDraw(false);
    }
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of start_of_trainingProcessComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine && routineTimer.getTime() > 0) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function start_of_trainingProcessRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'start_of_trainingProcess' ---
    for (const thisComponent of start_of_trainingProcessComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var fixationComponents;
function fixationRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'fixation' ---
    t = 0;
    fixationClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    // skip this Routine if its 'Skip if' condition is True
    continueRoutine = continueRoutine && !(["TCN", "TCR"].includes(expInfo["condition"]));
    // setup some python lists for storing info about the fix_mouse
    gotValidClick = false; // until a click is received
    // keep track of which components have finished
    fixationComponents = [];
    fixationComponents.push(fix_text);
    fixationComponents.push(fix_circle);
    fixationComponents.push(fix_mouse);
    
    for (const thisComponent of fixationComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function fixationRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'fixation' ---
    // get current time
    t = fixationClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // Run 'Each Frame' code from full_screen_7
    if (frameN > 10) {
        if (! psychoJS.window._windowAlreadyInFullScreen) {
        alert("looks like you exited full screen mode. You must stay in full screen mode to be eligible to participate.");
        quitPsychoJS('',false);
        }
    }
    
    // Run 'Each Frame' code from fix_end_code
    if (fix_circle.contains(fix_mouse)) {
        continueRoutine = false;
    }
    
    
    
    // *fix_text* updates
    if (t >= 0.0 && fix_text.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      fix_text.tStart = t;  // (not accounting for frame time here)
      fix_text.frameNStart = frameN;  // exact frame index
      
      fix_text.setAutoDraw(true);
    }
    
    
    // *fix_circle* updates
    if (t >= 0.0 && fix_circle.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      fix_circle.tStart = t;  // (not accounting for frame time here)
      fix_circle.frameNStart = frameN;  // exact frame index
      
      fix_circle.setAutoDraw(true);
    }
    
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of fixationComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function fixationRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'fixation' ---
    for (const thisComponent of fixationComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // store data for psychoJS.experiment (ExperimentHandler)
    // the Routine "fixation" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var fixation_bufferComponents;
function fixation_bufferRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'fixation_buffer' ---
    t = 0;
    fixation_bufferClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    routineTimer.add(0.500000);
    // update component parameters for each repeat
    // skip this Routine if its 'Skip if' condition is True
    continueRoutine = continueRoutine && !((train_trials.thisN != 0));
    // keep track of which components have finished
    fixation_bufferComponents = [];
    fixation_bufferComponents.push(fix_wait);
    
    for (const thisComponent of fixation_bufferComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function fixation_bufferRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'fixation_buffer' ---
    // get current time
    t = fixation_bufferClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // Run 'Each Frame' code from full_screen_13
    if (frameN > 10) {
        if (! psychoJS.window._windowAlreadyInFullScreen) {
        alert("looks like you exited full screen mode. You must stay in full screen mode to be eligible to participate");
        quitPsychoJS('',false);
        }
    }
    
    
    // *fix_wait* updates
    if (t >= 0.0 && fix_wait.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      fix_wait.tStart = t;  // (not accounting for frame time here)
      fix_wait.frameNStart = frameN;  // exact frame index
      
      fix_wait.setAutoDraw(true);
    }
    
    frameRemains = 0.0 + 0.5 - psychoJS.window.monitorFramePeriod * 0.75;  // most of one frame period left
    if (fix_wait.status === PsychoJS.Status.STARTED && t >= frameRemains) {
      fix_wait.setAutoDraw(false);
    }
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of fixation_bufferComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine && routineTimer.getTime() > 0) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function fixation_bufferRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'fixation_buffer' ---
    for (const thisComponent of fixation_bufferComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var nrep_sampling;
var nrep_selection;
var condition_switchComponents;
function condition_switchRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'condition_switch' ---
    t = 0;
    condition_switchClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    // Run 'Begin Routine' code from select_cond
    if (['TCN','TCR'].includes(expInfo['condition'])) {
        nrep_sampling = 1;
        nrep_selection = 0;
    } else if (['SCN','SCR'].includes(expInfo['condition'])) {
        nrep_sampling = 0;
        nrep_selection = 1;
    }
    
    // keep track of which components have finished
    condition_switchComponents = [];
    
    for (const thisComponent of condition_switchComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function condition_switchRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'condition_switch' ---
    // get current time
    t = condition_switchClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of condition_switchComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function condition_switchRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'condition_switch' ---
    for (const thisComponent of condition_switchComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // the Routine "condition_switch" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var trial_image_name;
var grid_image_fileName;
var Selection_trainComponents;
function Selection_trainRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'Selection_train' ---
    t = 0;
    Selection_trainClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    // Run 'Begin Routine' code from draw_rock_grid
    trial_image_name = [];
    grid_image_fileName = [];
    for (var i_rock = 0; i_rock < num_rows * num_cols; i_rock++) {
        rock_rect = rock_rect_grid[i_rock];
        rock_image = rock_grid[i_rock];
        rock_image.setAutoDraw(true);
        if (expInfo["condition"] === 'SCR') {
            trial_image_name = train_block_images[train_trials.thisN].name;
            grid_image_fileName = rock_fileName_grid[i_rock];
            if (grid_image_fileName === trial_image_name) {
                rock_rect.setAutoDraw(true);
            }
        }
    }
    
    // setup some python lists for storing info about the learn_mouse
    // current position of the mouse:
    learn_mouse.x = [];
    learn_mouse.y = [];
    learn_mouse.leftButton = [];
    learn_mouse.midButton = [];
    learn_mouse.rightButton = [];
    learn_mouse.time = [];
    learn_mouse.clicked_name = [];
    gotValidClick = false; // until a click is received
    // Run 'Begin Routine' code from store_trial_vars_train
    psychoJS.experiment.addData("block", (blocks.thisN + 1));
    psychoJS.experiment.addData("phase", 1);
    psychoJS.experiment.addData("trial", (train_trials.thisN + 1));
    
    // keep track of which components have finished
    Selection_trainComponents = [];
    Selection_trainComponents.push(rock_grid_text);
    Selection_trainComponents.push(learn_mouse);
    
    for (const thisComponent of Selection_trainComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


var MousePos;
var rock;
var rect;
var rockPos;
var _mouseXYs;
function Selection_trainRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'Selection_train' ---
    // get current time
    t = Selection_trainClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // Run 'Each Frame' code from full_screen_8
    if (frameN > 10) {
        if (! psychoJS.window._windowAlreadyInFullScreen) {
        alert("looks like you exited full screen mode. You must stay in full screen mode to be eligible to participate");
        quitPsychoJS('',false);
        }
    }
    
    // Run 'Each Frame' code from rock_selection
    MousePos = [];
    rock = [];
    rect = [];
    rockPos = [];
    for (var i_rock = 0; i_rock < num_rows * num_cols; i_rock++) {
        MousePos = learn_mouse.getPos();
        rock = rock_grid[i_rock];
        rockPos = rock.pos;
        if (EuclidDist(MousePos, rockPos) < Math.max(...gridSize) * 0.5) {
            rock.size = rockSize_large;
        } else {
            rock.size = gridSize;
        }
    }
    
    
    // *rock_grid_text* updates
    if (t >= 0.0 && rock_grid_text.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      rock_grid_text.tStart = t;  // (not accounting for frame time here)
      rock_grid_text.frameNStart = frameN;  // exact frame index
      
      rock_grid_text.setAutoDraw(true);
    }
    
    // *learn_mouse* updates
    if (t >= 0.0 && learn_mouse.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      learn_mouse.tStart = t;  // (not accounting for frame time here)
      learn_mouse.frameNStart = frameN;  // exact frame index
      
      learn_mouse.status = PsychoJS.Status.STARTED;
      learn_mouse.mouseClock.reset();
      prevButtonState = learn_mouse.getPressed();  // if button is down already this ISN'T a new click
      }
    if (learn_mouse.status === PsychoJS.Status.STARTED) {  // only update if started and not finished!
      _mouseButtons = learn_mouse.getPressed();
      if (!_mouseButtons.every( (e,i,) => (e == prevButtonState[i]) )) { // button state changed?
        prevButtonState = _mouseButtons;
        if (_mouseButtons.reduce( (e, acc) => (e+acc) ) > 0) { // state changed to a new click
          // check if the mouse was inside our 'clickable' objects
          gotValidClick = false;
          for (const obj of [...rock_grid]) {
            if (obj.contains(learn_mouse)) {
              gotValidClick = true;
              learn_mouse.clicked_name.push(obj.name)
            }
          }
          if (gotValidClick === true) { 
            _mouseXYs = learn_mouse.getPos();
            learn_mouse.x.push(_mouseXYs[0]);
            learn_mouse.y.push(_mouseXYs[1]);
            learn_mouse.leftButton.push(_mouseButtons[0]);
            learn_mouse.midButton.push(_mouseButtons[1]);
            learn_mouse.rightButton.push(_mouseButtons[2]);
            learn_mouse.time.push(learn_mouse.mouseClock.getTime());
          }
          if (gotValidClick === true) { // end routine on response
            continueRoutine = false;
          }
        }
      }
    }
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of Selection_trainComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


var aspectRatio_clicked;
var rock_clicked;
var filename_clicked;
var cat_clicked;
var token_clicked;
var row_clicked;
var col_clicked;
var cat_clicked_num;
var cat_rec;
var cat_rec_num;
var token_rec;
function Selection_trainRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'Selection_train' ---
    for (const thisComponent of Selection_trainComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // Run 'End Routine' code from rock_selection
    aspectRatio_clicked = [];
    rock_clicked = [];
    filename_clicked = [];
    cat_clicked = [];
    token_clicked = [];
    row_clicked = [];
    col_clicked = [];
    for (var i_rock = 0; i_rock < num_rows * num_cols; i_rock++) {
        let rock = rock_grid[i_rock];
        let irow = rock_rows[i_rock];
        let icol = rock_cols[i_rock];
        let rock_fileInfo = grid_image_fileInfo[irow][icol];
        let rock_aspect_ratio = rock_fileInfo.size;
        let rock_filename = rock_fileInfo.name;
        let cat = extract_rock_info(rock_filename)["type"];
        let token = extract_rock_info(rock_filename)["token"];
        if (learn_mouse.isPressedIn(rock)) {
            aspectRatio_clicked = rock_aspect_ratio;
            rock_clicked = rock;
            filename_clicked = rock_filename;
            cat_clicked = cat;
            token_clicked = token;
            row_clicked = irow + 1;
            col_clicked = icol + 1;
        }
    }
    // Run 'End Routine' code from draw_rock_grid
    for (var i_rock = 0; i_rock < num_rows * num_cols; i_rock++) {
        rock_rect = rock_rect_grid[i_rock];
        rock_image = rock_grid[i_rock];
        rock_image.setAutoDraw(false);
        if (expInfo["condition"] === 'SCR') {
            trial_image_name = train_block_images[train_trials.thisN].name;
            grid_image_fileName = rock_fileName_grid[i_rock];
            if (grid_image_fileName === trial_image_name) {
                rock_rect.setAutoDraw(false);
            }
        }
    }
    
    //cat = extract_rock_info(trial_image_name)["type"];
    //token = extract_rock_info(trial_image_name)["token"];
    //console.log(trial_image_name, cat, token);
    // store data for psychoJS.experiment (ExperimentHandler)
    if (learn_mouse.x) {  psychoJS.experiment.addData('learn_mouse.x', learn_mouse.x[0])};
    if (learn_mouse.y) {  psychoJS.experiment.addData('learn_mouse.y', learn_mouse.y[0])};
    if (learn_mouse.leftButton) {  psychoJS.experiment.addData('learn_mouse.leftButton', learn_mouse.leftButton[0])};
    if (learn_mouse.midButton) {  psychoJS.experiment.addData('learn_mouse.midButton', learn_mouse.midButton[0])};
    if (learn_mouse.rightButton) {  psychoJS.experiment.addData('learn_mouse.rightButton', learn_mouse.rightButton[0])};
    if (learn_mouse.time) {  psychoJS.experiment.addData('learn_mouse.time', learn_mouse.time[0])};
    if (learn_mouse.clicked_name) {  psychoJS.experiment.addData('learn_mouse.clicked_name', learn_mouse.clicked_name[0])};
    
    // Run 'End Routine' code from store_trial_vars_train
    cat_clicked_num = category_names.findIndex(cat => cat === cat_clicked) + 1;
    psychoJS.experiment.addData("cat", cat_clicked_num);
    psychoJS.experiment.addData("token", token_clicked);
    psychoJS.experiment.addData("row", row_clicked);
    psychoJS.experiment.addData("col", col_clicked);
    psychoJS.experiment.addData("t_select", util.round(learn_mouse.time[0], 3));
    if (expInfo["condition"] === 'SCR'){
        cat_rec = extract_rock_info(trial_image_name)["type"];
        cat_rec_num = category_names.findIndex(cat => cat === cat_rec) + 1;
        token_rec = extract_rock_info(trial_image_name)["token"];
        psychoJS.experiment.addData("cat_rec", cat_rec_num);
        psychoJS.experiment.addData("token_rec", token_rec);
    }
    
    // the Routine "Selection_train" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var Sampling_trainComponents;
function Sampling_trainRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'Sampling_train' ---
    t = 0;
    Sampling_trainClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    // Run 'Begin Routine' code from draw_rock_grid_2
    for (let rock_image of rock_grid) {
        rock_image.setAutoDraw(true);
    }
    
    // setup some python lists for storing info about the learn_mouse_2
    // current position of the mouse:
    learn_mouse_2.x = [];
    learn_mouse_2.y = [];
    learn_mouse_2.leftButton = [];
    learn_mouse_2.midButton = [];
    learn_mouse_2.rightButton = [];
    learn_mouse_2.time = [];
    learn_mouse_2.clicked_name = [];
    gotValidClick = false; // until a click is received
    // Run 'Begin Routine' code from store_trial_vars_train_2
    psychoJS.experiment.addData("block", (blocks.thisN + 1));
    psychoJS.experiment.addData("phase", 1);
    psychoJS.experiment.addData("trial", (train_trials.thisN + 1));
    
    // keep track of which components have finished
    Sampling_trainComponents = [];
    Sampling_trainComponents.push(rock_grid_rect_2);
    Sampling_trainComponents.push(rock_grid_text_2);
    Sampling_trainComponents.push(learn_mouse_2);
    
    for (const thisComponent of Sampling_trainComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


var rock_grid_text_color;
var rock_grid_rect_color;
function Sampling_trainRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'Sampling_train' ---
    // get current time
    t = Sampling_trainClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // Run 'Each Frame' code from full_screen_9
    if (frameN > 10) {
        if (! psychoJS.window._windowAlreadyInFullScreen) {
        alert("looks like you exited full screen mode. You must stay in full screen mode to be eligible to participate");
        quitPsychoJS('',false);
        }
    }
    
    // Run 'Each Frame' code from prompt_mouseover
    if (rock_grid_rect_2.contains(learn_mouse_2)) {
            rock_grid_text_color = 'red';
            rock_grid_rect_color = 'red';
        } else {
            rock_grid_text_color = 'black';
            rock_grid_rect_color = 'black';
        }
    
    if (rock_grid_rect_2.status === PsychoJS.Status.STARTED){ // only update if being drawn
      rock_grid_rect_2.setLineColor(new util.Color(rock_grid_rect_color), false);
    }
    
    // *rock_grid_rect_2* updates
    if (t >= 0.0 && rock_grid_rect_2.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      rock_grid_rect_2.tStart = t;  // (not accounting for frame time here)
      rock_grid_rect_2.frameNStart = frameN;  // exact frame index
      
      rock_grid_rect_2.setAutoDraw(true);
    }
    
    
    if (rock_grid_text_2.status === PsychoJS.Status.STARTED){ // only update if being drawn
      rock_grid_text_2.setColor(new util.Color(rock_grid_text_color), false);
    }
    
    // *rock_grid_text_2* updates
    if (t >= 0.0 && rock_grid_text_2.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      rock_grid_text_2.tStart = t;  // (not accounting for frame time here)
      rock_grid_text_2.frameNStart = frameN;  // exact frame index
      
      rock_grid_text_2.setAutoDraw(true);
    }
    
    // *learn_mouse_2* updates
    if (t >= 0.0 && learn_mouse_2.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      learn_mouse_2.tStart = t;  // (not accounting for frame time here)
      learn_mouse_2.frameNStart = frameN;  // exact frame index
      
      learn_mouse_2.status = PsychoJS.Status.STARTED;
      learn_mouse_2.mouseClock.reset();
      prevButtonState = learn_mouse_2.getPressed();  // if button is down already this ISN'T a new click
      }
    if (learn_mouse_2.status === PsychoJS.Status.STARTED) {  // only update if started and not finished!
      _mouseButtons = learn_mouse_2.getPressed();
      if (!_mouseButtons.every( (e,i,) => (e == prevButtonState[i]) )) { // button state changed?
        prevButtonState = _mouseButtons;
        if (_mouseButtons.reduce( (e, acc) => (e+acc) ) > 0) { // state changed to a new click
          // check if the mouse was inside our 'clickable' objects
          gotValidClick = false;
          for (const obj of [rock_grid_rect_2]) {
            if (obj.contains(learn_mouse_2)) {
              gotValidClick = true;
              learn_mouse_2.clicked_name.push(obj.name)
            }
          }
          _mouseXYs = learn_mouse_2.getPos();
          learn_mouse_2.x.push(_mouseXYs[0]);
          learn_mouse_2.y.push(_mouseXYs[1]);
          learn_mouse_2.leftButton.push(_mouseButtons[0]);
          learn_mouse_2.midButton.push(_mouseButtons[1]);
          learn_mouse_2.rightButton.push(_mouseButtons[2]);
          learn_mouse_2.time.push(learn_mouse_2.mouseClock.getTime());
          // end routine on response
          continueRoutine = false;
        }
      }
    }
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of Sampling_trainComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


var trial_image;
var trial_rock_info;
var trial_cat;
var trial_token;
var trial_rock_file;
var trial_rock_cat;
var trial_cat_num;
function Sampling_trainRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'Sampling_train' ---
    for (const thisComponent of Sampling_trainComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // Run 'End Routine' code from draw_rock_grid_2
    for (let rock_image of rock_grid) {
        rock_image.setAutoDraw(false);
    }
    
    // Run 'End Routine' code from extract_trial_rock_info
    trial_image = train_block_images[train_trials.thisN];
    trial_rock_info = extract_rock_info(trial_image.name);
    trial_cat = trial_rock_info["type"];
    trial_token = trial_rock_info["token"];
    [rock_width, rock_height] = trial_image.size;
    
    trial_rock_file = trial_image.name;
    trial_rock_cat = trial_cat;
    
    // store data for psychoJS.experiment (ExperimentHandler)
    if (learn_mouse_2.x) {  psychoJS.experiment.addData('learn_mouse_2.x', learn_mouse_2.x[0])};
    if (learn_mouse_2.y) {  psychoJS.experiment.addData('learn_mouse_2.y', learn_mouse_2.y[0])};
    if (learn_mouse_2.leftButton) {  psychoJS.experiment.addData('learn_mouse_2.leftButton', learn_mouse_2.leftButton[0])};
    if (learn_mouse_2.midButton) {  psychoJS.experiment.addData('learn_mouse_2.midButton', learn_mouse_2.midButton[0])};
    if (learn_mouse_2.rightButton) {  psychoJS.experiment.addData('learn_mouse_2.rightButton', learn_mouse_2.rightButton[0])};
    if (learn_mouse_2.time) {  psychoJS.experiment.addData('learn_mouse_2.time', learn_mouse_2.time[0])};
    if (learn_mouse_2.clicked_name) {  psychoJS.experiment.addData('learn_mouse_2.clicked_name', learn_mouse_2.clicked_name[0])};
    
    // Run 'End Routine' code from store_trial_vars_train_2
    trial_cat_num = category_names.findIndex(element => element === trial_cat) + 1;
    psychoJS.experiment.addData("cat", trial_cat_num);
    psychoJS.experiment.addData("token", trial_token);
    psychoJS.experiment.addData("row", (- 1));
    psychoJS.experiment.addData("col", (- 1));
    psychoJS.experiment.addData("t_select", util.round(learn_mouse_2.time[0], 3));
    
    // the Routine "Sampling_train" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var rock_width;
var rock_height;
var aspect_ratio;
var trial_rock_height;
var trial_rock_width;
var trial_rock_size;
var prog_total;
var prog_cur;
var prog_var;
var trial_counter_txt;
var trial_rock_image;
var txt;
var Classification_trainComponents;
function Classification_trainRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'Classification_train' ---
    t = 0;
    Classification_trainClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    // Run 'Begin Routine' code from trial_rock_config
    if (['SCN','SCR'].includes(expInfo['condition'])){
        rock_width = [];
        rock_height = [];
        aspect_ratio = [];
        trial_rock_file = filename_clicked;
        trial_rock_cat = cat_clicked;
        [rock_width, rock_height] = aspectRatio_clicked;
    }
    aspect_ratio = (rock_width / rock_height);
    trial_rock_height = 0.55;
    trial_rock_width = (trial_rock_height * aspect_ratio);
    trial_rock_size = [trial_rock_width, trial_rock_height];
    // Run 'Begin Routine' code from prog_bar_train
    prog_total = (blocks.nTotal * n_trials_total);
    prog_cur = (((blocks.thisN * n_trials_total) + train_trials.thisN) + 2);
    prog_var = (prog_cur / prog_total);
    trial_counter_txt = "Trial # " + (train_trials.thisN + 1).toString() + "/" + train_trials.nTotal.toString();
    trial_rock_image = directory_path + "/" + trial_rock_file;
    
    // Run 'Begin Routine' code from draw_button_panel
    rect = [];
    txt = [];
    for (var i_button = 0; i_button < buttons_ntotal; i_button++) {
        rect = cat_button_clickable[i_button];
        txt = cat_button_text[i_button];
        rect.setAutoDraw(true);
        txt.setAutoDraw(true);
    }
    
    trial_rock_train.setSize(trial_rock_size);
    trial_rock_train.setImage(trial_rock_image);
    // setup some python lists for storing info about the cat_mouse_l
    // current position of the mouse:
    cat_mouse_l.x = [];
    cat_mouse_l.y = [];
    cat_mouse_l.leftButton = [];
    cat_mouse_l.midButton = [];
    cat_mouse_l.rightButton = [];
    cat_mouse_l.time = [];
    cat_mouse_l.clicked_name = [];
    gotValidClick = false; // until a click is received
    train_trial_counter.setText(trial_counter_txt);
    prog_bar_rect.setSize([(prog_var * 0.8), 0.03]);
    // keep track of which components have finished
    Classification_trainComponents = [];
    Classification_trainComponents.push(trial_rock_train);
    Classification_trainComponents.push(cat_mouse_l);
    Classification_trainComponents.push(progress_bar_text);
    Classification_trainComponents.push(train_trial_counter);
    Classification_trainComponents.push(prog_bar_border);
    Classification_trainComponents.push(prog_bar_rect);
    
    for (const thisComponent of Classification_trainComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


var button;
var button_text;
function Classification_trainRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'Classification_train' ---
    // get current time
    t = Classification_trainClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // Run 'Each Frame' code from full_screen_3
    if (frameN > 10) {
        if (! psychoJS.window._windowAlreadyInFullScreen) {
        alert("looks like you exited full screen mode. You must stay in full screen mode to be eligible to participate");
        quitPsychoJS('',false);
        }
    }
    
    // Run 'Each Frame' code from rock_classification
    button = [];
    button_text = [];
    for (var i_button = 0; i_button < buttons_ntotal; i_button++) {
        button = cat_button_clickable[i_button];
        button_text = cat_button_text[i_button];
        if (button.contains(cat_mouse_l)) {
            button.borderColor = "red";
            button_text.color = "red";
        } else {
            button.borderColor = "black";
            button_text.color = "black";
        }
    }
    
    
    // *trial_rock_train* updates
    if (t >= 0.0 && trial_rock_train.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      trial_rock_train.tStart = t;  // (not accounting for frame time here)
      trial_rock_train.frameNStart = frameN;  // exact frame index
      
      trial_rock_train.setAutoDraw(true);
    }
    
    // *cat_mouse_l* updates
    if (t >= 0.0 && cat_mouse_l.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      cat_mouse_l.tStart = t;  // (not accounting for frame time here)
      cat_mouse_l.frameNStart = frameN;  // exact frame index
      
      cat_mouse_l.status = PsychoJS.Status.STARTED;
      cat_mouse_l.mouseClock.reset();
      prevButtonState = cat_mouse_l.getPressed();  // if button is down already this ISN'T a new click
      }
    if (cat_mouse_l.status === PsychoJS.Status.STARTED) {  // only update if started and not finished!
      _mouseButtons = cat_mouse_l.getPressed();
      if (!_mouseButtons.every( (e,i,) => (e == prevButtonState[i]) )) { // button state changed?
        prevButtonState = _mouseButtons;
        if (_mouseButtons.reduce( (e, acc) => (e+acc) ) > 0) { // state changed to a new click
          // check if the mouse was inside our 'clickable' objects
          gotValidClick = false;
          for (const obj of [...cat_button_clickable]) {
            if (obj.contains(cat_mouse_l)) {
              gotValidClick = true;
              cat_mouse_l.clicked_name.push(obj.name)
            }
          }
          if (gotValidClick === true) { 
            _mouseXYs = cat_mouse_l.getPos();
            cat_mouse_l.x.push(_mouseXYs[0]);
            cat_mouse_l.y.push(_mouseXYs[1]);
            cat_mouse_l.leftButton.push(_mouseButtons[0]);
            cat_mouse_l.midButton.push(_mouseButtons[1]);
            cat_mouse_l.rightButton.push(_mouseButtons[2]);
            cat_mouse_l.time.push(cat_mouse_l.mouseClock.getTime());
          }
          if (gotValidClick === true) { // end routine on response
            continueRoutine = false;
          }
        }
      }
    }
    
    // *progress_bar_text* updates
    if (t >= 0.0 && progress_bar_text.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      progress_bar_text.tStart = t;  // (not accounting for frame time here)
      progress_bar_text.frameNStart = frameN;  // exact frame index
      
      progress_bar_text.setAutoDraw(true);
    }
    
    
    // *train_trial_counter* updates
    if (t >= 0.0 && train_trial_counter.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      train_trial_counter.tStart = t;  // (not accounting for frame time here)
      train_trial_counter.frameNStart = frameN;  // exact frame index
      
      train_trial_counter.setAutoDraw(true);
    }
    
    
    // *prog_bar_border* updates
    if (t >= 0.0 && prog_bar_border.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      prog_bar_border.tStart = t;  // (not accounting for frame time here)
      prog_bar_border.frameNStart = frameN;  // exact frame index
      
      prog_bar_border.setAutoDraw(true);
    }
    
    
    // *prog_bar_rect* updates
    if (t >= 0.0 && prog_bar_rect.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      prog_bar_rect.tStart = t;  // (not accounting for frame time here)
      prog_bar_rect.frameNStart = frameN;  // exact frame index
      
      prog_bar_rect.setAutoDraw(true);
    }
    
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of Classification_trainComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


var cat_resp;
var cat_resp_num;
function Classification_trainRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'Classification_train' ---
    for (const thisComponent of Classification_trainComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // Run 'End Routine' code from draw_button_panel
    for (var i_button = 0; i_button < buttons_ntotal; i_button++) {
        rect = cat_button_clickable[i_button];
        txt = cat_button_text[i_button];
        rect.setAutoDraw(false);
        txt.setAutoDraw(false);
    }
    
    // store data for psychoJS.experiment (ExperimentHandler)
    if (cat_mouse_l.x) {  psychoJS.experiment.addData('cat_mouse_l.x', cat_mouse_l.x[0])};
    if (cat_mouse_l.y) {  psychoJS.experiment.addData('cat_mouse_l.y', cat_mouse_l.y[0])};
    if (cat_mouse_l.leftButton) {  psychoJS.experiment.addData('cat_mouse_l.leftButton', cat_mouse_l.leftButton[0])};
    if (cat_mouse_l.midButton) {  psychoJS.experiment.addData('cat_mouse_l.midButton', cat_mouse_l.midButton[0])};
    if (cat_mouse_l.rightButton) {  psychoJS.experiment.addData('cat_mouse_l.rightButton', cat_mouse_l.rightButton[0])};
    if (cat_mouse_l.time) {  psychoJS.experiment.addData('cat_mouse_l.time', cat_mouse_l.time[0])};
    if (cat_mouse_l.clicked_name) {  psychoJS.experiment.addData('cat_mouse_l.clicked_name', cat_mouse_l.clicked_name[0])};
    
    // Run 'End Routine' code from store_trial_vars_train_3
    cat_resp = cat_mouse_l.clicked_name[0].split("_")[0];
    cat_resp_num = category_names.findIndex(element => element === cat_resp) + 1;
    psychoJS.experiment.addData("resp", cat_resp_num);
    psychoJS.experiment.addData("t_resp", util.round(cat_mouse_l.time[0], 3));
    // the Routine "Classification_train" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var corr_flag;
var fb_text;
var fb_col;
var feedback_correctiveComponents;
function feedback_correctiveRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'feedback_corrective' ---
    t = 0;
    feedback_correctiveClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    // Run 'Begin Routine' code from fb_selection
    corr_flag = (cat_mouse_l.clicked_name.slice((- 1))[0] === (trial_rock_cat + "_rect"));
    if (corr_flag) {
        fb_text = "Correct!";
        fb_col = "green";
    } else {
        fb_text = "Incorrect!";
        fb_col = "red";
    }
    
    trial_rock_train_2.setSize(trial_rock_size);
    trial_rock_train_2.setImage(((directory_path + "/") + trial_rock_file));
    fb_text_l.setColor(new util.Color(fb_col));
    fb_text_l.setText(fb_text);
    fb_text_l_2.setText(("This rock is " + trial_rock_cat));
    // setup some python lists for storing info about the fb_mouse
    fb_mouse.clicked_name = [];
    gotValidClick = false; // until a click is received
    // keep track of which components have finished
    feedback_correctiveComponents = [];
    feedback_correctiveComponents.push(trial_rock_train_2);
    feedback_correctiveComponents.push(fb_text_l);
    feedback_correctiveComponents.push(fb_text_l_2);
    feedback_correctiveComponents.push(next);
    feedback_correctiveComponents.push(fb_mouse);
    
    for (const thisComponent of feedback_correctiveComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function feedback_correctiveRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'feedback_corrective' ---
    // get current time
    t = feedback_correctiveClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // Run 'Each Frame' code from full_screen_2
    if (frameN > 10) {
        if (! psychoJS.window._windowAlreadyInFullScreen) {
        alert("looks like you exited full screen mode. You must stay in full screen mode to be eligible to participate");
        quitPsychoJS('',false);
        }
    }
    
    
    // *trial_rock_train_2* updates
    if (t >= 0.0 && trial_rock_train_2.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      trial_rock_train_2.tStart = t;  // (not accounting for frame time here)
      trial_rock_train_2.frameNStart = frameN;  // exact frame index
      
      trial_rock_train_2.setAutoDraw(true);
    }
    
    
    // *fb_text_l* updates
    if (t >= 0.0 && fb_text_l.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      fb_text_l.tStart = t;  // (not accounting for frame time here)
      fb_text_l.frameNStart = frameN;  // exact frame index
      
      fb_text_l.setAutoDraw(true);
    }
    
    
    // *fb_text_l_2* updates
    if (t >= 0.0 && fb_text_l_2.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      fb_text_l_2.tStart = t;  // (not accounting for frame time here)
      fb_text_l_2.frameNStart = frameN;  // exact frame index
      
      fb_text_l_2.setAutoDraw(true);
    }
    
    
    // *next* updates
    if (t >= 0.0 && next.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      next.tStart = t;  // (not accounting for frame time here)
      next.frameNStart = frameN;  // exact frame index
      
      next.setAutoDraw(true);
    }
    
    // *fb_mouse* updates
    if (t >= 0.0 && fb_mouse.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      fb_mouse.tStart = t;  // (not accounting for frame time here)
      fb_mouse.frameNStart = frameN;  // exact frame index
      
      fb_mouse.status = PsychoJS.Status.STARTED;
      fb_mouse.mouseClock.reset();
      prevButtonState = fb_mouse.getPressed();  // if button is down already this ISN'T a new click
      }
    if (fb_mouse.status === PsychoJS.Status.STARTED) {  // only update if started and not finished!
      _mouseButtons = fb_mouse.getPressed();
      if (!_mouseButtons.every( (e,i,) => (e == prevButtonState[i]) )) { // button state changed?
        prevButtonState = _mouseButtons;
        if (_mouseButtons.reduce( (e, acc) => (e+acc) ) > 0) { // state changed to a new click
          // check if the mouse was inside our 'clickable' objects
          gotValidClick = false;
          for (const obj of [next]) {
            if (obj.contains(fb_mouse)) {
              gotValidClick = true;
              fb_mouse.clicked_name.push(obj.name)
            }
          }
          if (gotValidClick === true) { // end routine on response
            continueRoutine = false;
          }
        }
      }
    }
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of feedback_correctiveComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function feedback_correctiveRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'feedback_corrective' ---
    for (const thisComponent of feedback_correctiveComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // store data for psychoJS.experiment (ExperimentHandler)
    // Run 'End Routine' code from store_trial_vars_train_4
    psychoJS.experiment.addData("corr", +corr_flag);
    
    // the Routine "feedback_corrective" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var testInstr_nrep;
var end_of_trainingProcessComponents;
function end_of_trainingProcessRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'end_of_trainingProcess' ---
    t = 0;
    end_of_trainingProcessClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    // Run 'Begin Routine' code from testInstr_skip
    if ((blocks.thisN === 0)) {
        testInstr_nrep = 9999;
    } else {
        testInstr_nrep = 0;
    }
    
    // keep track of which components have finished
    end_of_trainingProcessComponents = [];
    
    for (const thisComponent of end_of_trainingProcessComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function end_of_trainingProcessRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'end_of_trainingProcess' ---
    // get current time
    t = end_of_trainingProcessClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of end_of_trainingProcessComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function end_of_trainingProcessRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'end_of_trainingProcess' ---
    for (const thisComponent of end_of_trainingProcessComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // the Routine "end_of_trainingProcess" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var cur_row_test_string;
var test_instrPrepComponents;
function test_instrPrepRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'test_instrPrep' ---
    t = 0;
    test_instrPrepClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    // Run 'Begin Routine' code from instrPrecode_test
    if (instruct_mouse_test.isPressedIn(rightArrow_2)) {
        cur_row_test += 1;
    } else {
        if (instruct_mouse_test.isPressedIn(leftArrow_2)) {
            cur_row_test -= 1;
        }
    }
    if ((cur_row_test < 0)) {
        cur_row_test = 0;
    }
    if ((cur_row_test > max_slides_test)) {
        testInstructions_controller.finished = 1;
        show_instructions_test = 0;
        cur_row_test = (max_slides_test - 1);
    }
    cur_row_test_string = cur_row_test.toString();
    
    // keep track of which components have finished
    test_instrPrepComponents = [];
    
    for (const thisComponent of test_instrPrepComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function test_instrPrepRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'test_instrPrep' ---
    // get current time
    t = test_instrPrepClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of test_instrPrepComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function test_instrPrepRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'test_instrPrep' ---
    for (const thisComponent of test_instrPrepComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // the Routine "test_instrPrep" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var test_instructionsComponents;
function test_instructionsRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'test_instructions' ---
    t = 0;
    test_instructionsClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    instruction_image_test.setImage(test_slide);
    // setup some python lists for storing info about the instruct_mouse_test
    instruct_mouse_test.clicked_name = [];
    gotValidClick = false; // until a click is received
    instruct_counter_test.setText((((cur_row_test + 1).toString() + "/") + (max_slides_test + 1).toString()));
    // keep track of which components have finished
    test_instructionsComponents = [];
    test_instructionsComponents.push(instruction_image_test);
    test_instructionsComponents.push(leftArrow_2);
    test_instructionsComponents.push(rightArrow_2);
    test_instructionsComponents.push(instruct_mouse_test);
    test_instructionsComponents.push(instruct_counter_test);
    
    for (const thisComponent of test_instructionsComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function test_instructionsRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'test_instructions' ---
    // get current time
    t = test_instructionsClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // Run 'Each Frame' code from full_screen_6
    if (frameN > 10) {
        if (! psychoJS.window._windowAlreadyInFullScreen) {
        alert("looks like you exited full screen mode. You must stay in full screen mode to be eligible to participate");
        quitPsychoJS('',false);
        }
    }
    
    
    // *instruction_image_test* updates
    if (t >= 0.0 && instruction_image_test.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      instruction_image_test.tStart = t;  // (not accounting for frame time here)
      instruction_image_test.frameNStart = frameN;  // exact frame index
      
      instruction_image_test.setAutoDraw(true);
    }
    
    
    // *leftArrow_2* updates
    if (t >= 0.0 && leftArrow_2.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      leftArrow_2.tStart = t;  // (not accounting for frame time here)
      leftArrow_2.frameNStart = frameN;  // exact frame index
      
      leftArrow_2.setAutoDraw(true);
    }
    
    
    // *rightArrow_2* updates
    if (t >= 0.0 && rightArrow_2.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      rightArrow_2.tStart = t;  // (not accounting for frame time here)
      rightArrow_2.frameNStart = frameN;  // exact frame index
      
      rightArrow_2.setAutoDraw(true);
    }
    
    // *instruct_mouse_test* updates
    if (t >= 0.0 && instruct_mouse_test.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      instruct_mouse_test.tStart = t;  // (not accounting for frame time here)
      instruct_mouse_test.frameNStart = frameN;  // exact frame index
      
      instruct_mouse_test.status = PsychoJS.Status.STARTED;
      instruct_mouse_test.mouseClock.reset();
      prevButtonState = instruct_mouse_test.getPressed();  // if button is down already this ISN'T a new click
      }
    if (instruct_mouse_test.status === PsychoJS.Status.STARTED) {  // only update if started and not finished!
      _mouseButtons = instruct_mouse_test.getPressed();
      if (!_mouseButtons.every( (e,i,) => (e == prevButtonState[i]) )) { // button state changed?
        prevButtonState = _mouseButtons;
        if (_mouseButtons.reduce( (e, acc) => (e+acc) ) > 0) { // state changed to a new click
          // check if the mouse was inside our 'clickable' objects
          gotValidClick = false;
          for (const obj of [leftArrow_2,rightArrow_2]) {
            if (obj.contains(instruct_mouse_test)) {
              gotValidClick = true;
              instruct_mouse_test.clicked_name.push(obj.name)
            }
          }
          if (gotValidClick === true) { // end routine on response
            continueRoutine = false;
          }
        }
      }
    }
    
    // *instruct_counter_test* updates
    if (t >= 0.0 && instruct_counter_test.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      instruct_counter_test.tStart = t;  // (not accounting for frame time here)
      instruct_counter_test.frameNStart = frameN;  // exact frame index
      
      instruct_counter_test.setAutoDraw(true);
    }
    
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of test_instructionsComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function test_instructionsRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'test_instructions' ---
    for (const thisComponent of test_instructionsComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // store data for psychoJS.experiment (ExperimentHandler)
    // the Routine "test_instructions" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var accuracy_dict;
var resp_list;
var cat_list;
var start_of_testProcessComponents;
function start_of_testProcessRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'start_of_testProcess' ---
    t = 0;
    start_of_testProcessClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    routineTimer.add(1.000000);
    // update component parameters for each repeat
    block_prompt_test.setText(((("Starting Test Block " + (blocks.thisN + 1).toString()) + " of ") + blocks.nTotal.toString()));
    // Run 'Begin Routine' code from initialize_accuracy_list
    accuracy_dict = {};
    category_names.forEach(cat_name => {
        accuracy_dict[cat_name] = [];
    });
    // Run 'Begin Routine' code from initialize_response_tracker
    resp_list = [];
    cat_list = [];
    
    // keep track of which components have finished
    start_of_testProcessComponents = [];
    start_of_testProcessComponents.push(block_prompt_test);
    
    for (const thisComponent of start_of_testProcessComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function start_of_testProcessRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'start_of_testProcess' ---
    // get current time
    t = start_of_testProcessClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // Run 'Each Frame' code from full_screen_12
    if (frameN > 10) {
        if (! psychoJS.window._windowAlreadyInFullScreen) {
        alert("looks like you exited full screen mode. You must stay in full screen mode to be eligible to participate");
        quitPsychoJS('',false);
        }
    }
    
    
    // *block_prompt_test* updates
    if (t >= 0.0 && block_prompt_test.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      block_prompt_test.tStart = t;  // (not accounting for frame time here)
      block_prompt_test.frameNStart = frameN;  // exact frame index
      
      block_prompt_test.setAutoDraw(true);
    }
    
    frameRemains = 0.0 + 1.0 - psychoJS.window.monitorFramePeriod * 0.75;  // most of one frame period left
    if (block_prompt_test.status === PsychoJS.Status.STARTED && t >= frameRemains) {
      block_prompt_test.setAutoDraw(false);
    }
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of start_of_testProcessComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine && routineTimer.getTime() > 0) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function start_of_testProcessRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'start_of_testProcess' ---
    for (const thisComponent of start_of_testProcessComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var Classification_testComponents;
function Classification_testRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'Classification_test' ---
    t = 0;
    Classification_testClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    // Run 'Begin Routine' code from draw_button_panel_2
    rect = [];
    txt = [];
    for (var i_cat = 0; i_cat < buttons_ntotal; i_cat++) {
        rect = cat_button_clickable[i_cat];
        txt = cat_button_text[i_cat];
        rect.setAutoDraw(true);
        txt.setAutoDraw(true);
    }
    
    // Run 'Begin Routine' code from extract_trial_rock_info_2
    trial_image = test_images[blocks.thisN][test_trials.thisN];
    trial_rock_info = extract_rock_info(trial_image.name);
    trial_cat = trial_rock_info["type"];
    trial_token =trial_rock_info["token"];
    [rock_width, rock_height] = trial_image.size;
    aspect_ratio = (rock_width / rock_height);
    trial_rock_height = 0.6;
    trial_rock_width = (trial_rock_height * aspect_ratio);
    trial_rock_size = [trial_rock_width, trial_rock_height];
    // Run 'Begin Routine' code from prog_bar_test
    prog_total = (blocks.nTotal * n_trials_total);
    prog_cur = ((((blocks.thisN * n_trials_total) + train_trials.nTotal) + test_trials.thisN) + 2);
    prog_var = (prog_cur / prog_total);
    
    trial_rock_test.setSize(trial_rock_size);
    trial_rock_test.setImage(((directory_path + "/") + trial_image.name));
    test_trial_counter.setText(((("Trial # " + (test_trials.thisN + 1).toString()) + "/") + test_trials.nTotal.toString()));
    prog_bar_rect_2.setSize([(prog_var * 0.8), 0.03]);
    // setup some python lists for storing info about the cat_mouse_t
    // current position of the mouse:
    cat_mouse_t.x = [];
    cat_mouse_t.y = [];
    cat_mouse_t.leftButton = [];
    cat_mouse_t.midButton = [];
    cat_mouse_t.rightButton = [];
    cat_mouse_t.time = [];
    cat_mouse_t.clicked_name = [];
    gotValidClick = false; // until a click is received
    // Run 'Begin Routine' code from store_trial_vars_test
    psychoJS.experiment.addData("block", (blocks.thisN + 1));
    psychoJS.experiment.addData("phase", 2);
    psychoJS.experiment.addData("trial", (test_trials.thisN + 1));
    
    
    // keep track of which components have finished
    Classification_testComponents = [];
    Classification_testComponents.push(trial_rock_test);
    Classification_testComponents.push(progress_bar_text_3);
    Classification_testComponents.push(test_trial_counter);
    Classification_testComponents.push(prog_bar_border_2);
    Classification_testComponents.push(prog_bar_rect_2);
    Classification_testComponents.push(cat_mouse_t);
    
    for (const thisComponent of Classification_testComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function Classification_testRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'Classification_test' ---
    // get current time
    t = Classification_testClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // Run 'Each Frame' code from full_screen_4
    if (frameN > 10) {
        if (! psychoJS.window._windowAlreadyInFullScreen) {
        alert("looks like you exited full screen mode. You must stay in full screen mode to be eligible to participate");
        quitPsychoJS('',false);
        }
    }
    
    // Run 'Each Frame' code from rock_classification_2
    button = [];
    button_text = [];
    for (var i_button = 0; i_button < buttons_ntotal; i_button++) {
        button = cat_button_clickable[i_button];
        button_text = cat_button_text[i_button];
        if (button.contains(cat_mouse_l)) {
            button.borderColor = "red";
            button_text.color = "red";
        } else {
            button.borderColor = "black";
            button_text.color = "black";
        }
    }
    
    
    // *trial_rock_test* updates
    if (t >= 0.0 && trial_rock_test.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      trial_rock_test.tStart = t;  // (not accounting for frame time here)
      trial_rock_test.frameNStart = frameN;  // exact frame index
      
      trial_rock_test.setAutoDraw(true);
    }
    
    
    // *progress_bar_text_3* updates
    if (t >= 0.0 && progress_bar_text_3.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      progress_bar_text_3.tStart = t;  // (not accounting for frame time here)
      progress_bar_text_3.frameNStart = frameN;  // exact frame index
      
      progress_bar_text_3.setAutoDraw(true);
    }
    
    
    // *test_trial_counter* updates
    if (t >= 0.0 && test_trial_counter.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      test_trial_counter.tStart = t;  // (not accounting for frame time here)
      test_trial_counter.frameNStart = frameN;  // exact frame index
      
      test_trial_counter.setAutoDraw(true);
    }
    
    
    // *prog_bar_border_2* updates
    if (t >= 0.0 && prog_bar_border_2.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      prog_bar_border_2.tStart = t;  // (not accounting for frame time here)
      prog_bar_border_2.frameNStart = frameN;  // exact frame index
      
      prog_bar_border_2.setAutoDraw(true);
    }
    
    
    // *prog_bar_rect_2* updates
    if (t >= 0.0 && prog_bar_rect_2.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      prog_bar_rect_2.tStart = t;  // (not accounting for frame time here)
      prog_bar_rect_2.frameNStart = frameN;  // exact frame index
      
      prog_bar_rect_2.setAutoDraw(true);
    }
    
    // *cat_mouse_t* updates
    if (t >= 0.0 && cat_mouse_t.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      cat_mouse_t.tStart = t;  // (not accounting for frame time here)
      cat_mouse_t.frameNStart = frameN;  // exact frame index
      
      cat_mouse_t.status = PsychoJS.Status.STARTED;
      cat_mouse_t.mouseClock.reset();
      prevButtonState = cat_mouse_t.getPressed();  // if button is down already this ISN'T a new click
      }
    if (cat_mouse_t.status === PsychoJS.Status.STARTED) {  // only update if started and not finished!
      _mouseButtons = cat_mouse_t.getPressed();
      if (!_mouseButtons.every( (e,i,) => (e == prevButtonState[i]) )) { // button state changed?
        prevButtonState = _mouseButtons;
        if (_mouseButtons.reduce( (e, acc) => (e+acc) ) > 0) { // state changed to a new click
          // check if the mouse was inside our 'clickable' objects
          gotValidClick = false;
          for (const obj of [...cat_button_clickable]) {
            if (obj.contains(cat_mouse_t)) {
              gotValidClick = true;
              cat_mouse_t.clicked_name.push(obj.name)
            }
          }
          if (gotValidClick === true) { 
            _mouseXYs = cat_mouse_t.getPos();
            cat_mouse_t.x.push(_mouseXYs[0]);
            cat_mouse_t.y.push(_mouseXYs[1]);
            cat_mouse_t.leftButton.push(_mouseButtons[0]);
            cat_mouse_t.midButton.push(_mouseButtons[1]);
            cat_mouse_t.rightButton.push(_mouseButtons[2]);
            cat_mouse_t.time.push(cat_mouse_t.mouseClock.getTime());
          }
          if (gotValidClick === true) { // end routine on response
            continueRoutine = false;
          }
        }
      }
    }
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of Classification_testComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function Classification_testRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'Classification_test' ---
    for (const thisComponent of Classification_testComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // Run 'End Routine' code from draw_button_panel_2
    for (var i_cat = 0; i_cat < buttons_ntotal; i_cat++) {
        rect = cat_button_clickable[i_cat];
        txt = cat_button_text[i_cat];
        rect.setAutoDraw(false);
        txt.setAutoDraw(false);
    }
    
    // store data for psychoJS.experiment (ExperimentHandler)
    if (cat_mouse_t.x) {  psychoJS.experiment.addData('cat_mouse_t.x', cat_mouse_t.x[0])};
    if (cat_mouse_t.y) {  psychoJS.experiment.addData('cat_mouse_t.y', cat_mouse_t.y[0])};
    if (cat_mouse_t.leftButton) {  psychoJS.experiment.addData('cat_mouse_t.leftButton', cat_mouse_t.leftButton[0])};
    if (cat_mouse_t.midButton) {  psychoJS.experiment.addData('cat_mouse_t.midButton', cat_mouse_t.midButton[0])};
    if (cat_mouse_t.rightButton) {  psychoJS.experiment.addData('cat_mouse_t.rightButton', cat_mouse_t.rightButton[0])};
    if (cat_mouse_t.time) {  psychoJS.experiment.addData('cat_mouse_t.time', cat_mouse_t.time[0])};
    if (cat_mouse_t.clicked_name) {  psychoJS.experiment.addData('cat_mouse_t.clicked_name', cat_mouse_t.clicked_name[0])};
    
    // Run 'End Routine' code from store_trial_vars_test
    trial_cat_num = category_names.findIndex(element => element === trial_cat) + 1;
    cat_resp = cat_mouse_t.clicked_name.slice((- 1))[0].split("_")[0];
    cat_resp_num = category_names.findIndex(element => element === cat_resp) + 1;
    
    psychoJS.experiment.addData("cat", trial_cat_num);
    psychoJS.experiment.addData("token", trial_token);
    psychoJS.experiment.addData("resp", cat_resp_num);
    psychoJS.experiment.addData("corr", +(cat_resp === trial_cat));
    psychoJS.experiment.addData("t_resp", util.round(cat_mouse_t.time[0], 3));
    
    cat_list.push(trial_cat);
    resp_list.push(cat_resp);
    accuracy_dict[trial_cat].push(cat_resp == trial_cat);
    // the Routine "Classification_test" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var feedback_neutralComponents;
function feedback_neutralRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'feedback_neutral' ---
    t = 0;
    feedback_neutralClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    routineTimer.add(0.500000);
    // update component parameters for each repeat
    // keep track of which components have finished
    feedback_neutralComponents = [];
    feedback_neutralComponents.push(fb_text_t);
    
    for (const thisComponent of feedback_neutralComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function feedback_neutralRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'feedback_neutral' ---
    // get current time
    t = feedback_neutralClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // Run 'Each Frame' code from full_screen
    if (frameN > 10) {
        if (! psychoJS.window._windowAlreadyInFullScreen) {
        alert("looks like you exited full screen mode. You must stay in full screen mode to be eligible to participate");
        quitPsychoJS('',false);
        }
    }
    
    
    // *fb_text_t* updates
    if (t >= 0.0 && fb_text_t.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      fb_text_t.tStart = t;  // (not accounting for frame time here)
      fb_text_t.frameNStart = frameN;  // exact frame index
      
      fb_text_t.setAutoDraw(true);
    }
    
    frameRemains = 0.0 + 0.5 - psychoJS.window.monitorFramePeriod * 0.75;  // most of one frame period left
    if (fb_text_t.status === PsychoJS.Status.STARTED && t >= frameRemains) {
      fb_text_t.setAutoDraw(false);
    }
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of feedback_neutralComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine && routineTimer.getTime() > 0) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function feedback_neutralRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'feedback_neutral' ---
    for (const thisComponent of feedback_neutralComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var prc_corr;
var corr_table;
var prc_corr_list;
var prc_corr_block;
var corr_overall;
var prc_corr_total_last3;
var hasBonus;
var RC_thisblock;
var prc_dict_thisblock;
var end_of_testProcessComponents;
function end_of_testProcessRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'end_of_testProcess' ---
    t = 0;
    end_of_testProcessClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    // Run 'Begin Routine' code from format_accuracy_summary
    prc_corr = [];
    corr_table = "";
    for (let cat_name of category_names) {
        prc_corr = util.round(util.average(accuracy_dict[cat_name]) * 100);
        corr_table = corr_table + cat_name + ": " + prc_corr.toString() + "%\n\n";
    };
    prc_corr_list = Object.values(accuracy_dict).flat();
    prc_corr_block = util.round(util.average(prc_corr_list) * 100);
    corr_overall = 'You got ' + prc_corr_block.toString() + '% of trials correct.';
    
    if (blocks.thisN >= blocks.nTotal - 3){
        prc_corr_block_last3.push(prc_corr_block);
    }
    if (blocks.thisN === blocks.nTotal - 1){
        prc_corr_total_last3 = util.average(prc_corr_block_last3);
        hasBonus = (prc_corr_total_last3/100 >= 0.65)? 1: 0;
    }
    
    psychoJS.experiment.addData("Bonus", hasBonus);
    end_block_msg_2.setText(("End Block " + (blocks.thisN + 1).toString()));
    feedbackSC2.setText(corr_table);
    // setup some python lists for storing info about the next_mouse_block_fb
    next_mouse_block_fb.clicked_name = [];
    gotValidClick = false; // until a click is received
    // Run 'Begin Routine' code from compute_diff_indices
    if (['SCR','TCR'].includes(expInfo['condition'])) {
        RC_thisblock = [];
        prc_dict_thisblock = {};
        for (let icat = 0; icat < num_cats; icat++) {
            cat_name = category_names[icat];
            let num_item_cat = cat_list.filter(x => x === cat_name).length;
            let num_item_resp = resp_list.filter(y => y === cat_name).length;
            let num_item_total = cat_list.length;
            let num_item_cat_resp = cat_list.filter((x, index) => x === cat_name && resp_list[index] === cat_name).length;
            let H_rate = (num_item_cat_resp / num_item_cat);
            let FA_rate = ((num_item_resp - num_item_cat_resp) / (num_item_total - num_item_cat));
            let PS = (H_rate - FA_rate);
            PS_dict_blocks[cat_name].push(PS);
            let PS_sum = 0;
            let weight_sum = 0;
            let lambda = 0.5;
            for (let iblock = 0; iblock <= blocks.thisN; iblock++) {
                let block_weight = Math.exp(lambda * (iblock - blocks.thisN));
                weight_sum += block_weight;
                PS_sum += (block_weight * PS_dict_blocks[cat_name][iblock]);
            }
            RC_thisblock.push((1 - PS_sum/weight_sum + 0.125));
        }
        let sumRC = RC_thisblock.reduce((a, b) => a + b, 0);
        for (let icat = 0; icat < num_cats; icat++) {
            cat_name = category_names[icat];
            prc_dict_thisblock[cat_name] = RC_thisblock[icat] / sumRC;
        }
    }
    
    // keep track of which components have finished
    end_of_testProcessComponents = [];
    end_of_testProcessComponents.push(end_block_msg_2);
    end_of_testProcessComponents.push(feedbackSC1);
    end_of_testProcessComponents.push(feedbackSC2);
    end_of_testProcessComponents.push(next_block_fb);
    end_of_testProcessComponents.push(next_mouse_block_fb);
    
    for (const thisComponent of end_of_testProcessComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function end_of_testProcessRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'end_of_testProcess' ---
    // get current time
    t = end_of_testProcessClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    // Run 'Each Frame' code from full_screen_11
    if (frameN > 10) {
        if (! psychoJS.window._windowAlreadyInFullScreen) {
        alert("looks like you exited full screen mode. You must stay in full screen mode to be eligible to participate");
        quitPsychoJS('',false);
        }
    }
    
    
    // *end_block_msg_2* updates
    if (t >= 0.0 && end_block_msg_2.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      end_block_msg_2.tStart = t;  // (not accounting for frame time here)
      end_block_msg_2.frameNStart = frameN;  // exact frame index
      
      end_block_msg_2.setAutoDraw(true);
    }
    
    frameRemains = 0.0 + 0.5 - psychoJS.window.monitorFramePeriod * 0.75;  // most of one frame period left
    if (end_block_msg_2.status === PsychoJS.Status.STARTED && t >= frameRemains) {
      end_block_msg_2.setAutoDraw(false);
    }
    
    // *feedbackSC1* updates
    if (t >= 0.5 && feedbackSC1.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      feedbackSC1.tStart = t;  // (not accounting for frame time here)
      feedbackSC1.frameNStart = frameN;  // exact frame index
      
      feedbackSC1.setAutoDraw(true);
    }
    
    
    // *feedbackSC2* updates
    if (t >= 0.5 && feedbackSC2.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      feedbackSC2.tStart = t;  // (not accounting for frame time here)
      feedbackSC2.frameNStart = frameN;  // exact frame index
      
      feedbackSC2.setAutoDraw(true);
    }
    
    
    // *next_block_fb* updates
    if (t >= 0.5 && next_block_fb.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      next_block_fb.tStart = t;  // (not accounting for frame time here)
      next_block_fb.frameNStart = frameN;  // exact frame index
      
      next_block_fb.setAutoDraw(true);
    }
    
    // *next_mouse_block_fb* updates
    if (t >= 0.5 && next_mouse_block_fb.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      next_mouse_block_fb.tStart = t;  // (not accounting for frame time here)
      next_mouse_block_fb.frameNStart = frameN;  // exact frame index
      
      next_mouse_block_fb.status = PsychoJS.Status.STARTED;
      next_mouse_block_fb.mouseClock.reset();
      prevButtonState = next_mouse_block_fb.getPressed();  // if button is down already this ISN'T a new click
      }
    if (next_mouse_block_fb.status === PsychoJS.Status.STARTED) {  // only update if started and not finished!
      _mouseButtons = next_mouse_block_fb.getPressed();
      if (!_mouseButtons.every( (e,i,) => (e == prevButtonState[i]) )) { // button state changed?
        prevButtonState = _mouseButtons;
        if (_mouseButtons.reduce( (e, acc) => (e+acc) ) > 0) { // state changed to a new click
          // check if the mouse was inside our 'clickable' objects
          gotValidClick = false;
          for (const obj of [next_block_fb]) {
            if (obj.contains(next_mouse_block_fb)) {
              gotValidClick = true;
              next_mouse_block_fb.clicked_name.push(obj.name)
            }
          }
          if (gotValidClick === true) { // end routine on response
            continueRoutine = false;
          }
        }
      }
    }
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of end_of_testProcessComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function end_of_testProcessRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'end_of_testProcess' ---
    for (const thisComponent of end_of_testProcessComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // store data for psychoJS.experiment (ExperimentHandler)
    // the Routine "end_of_testProcess" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


var debriefComponents;
function debriefRoutineBegin(snapshot) {
  return async function () {
    TrialHandler.fromSnapshot(snapshot); // ensure that .thisN vals are up to date
    
    //--- Prepare to start Routine 'debrief' ---
    t = 0;
    debriefClock.reset(); // clock
    frameN = -1;
    continueRoutine = true; // until we're told otherwise
    // update component parameters for each repeat
    // setup some python lists for storing info about the next_mouse_end_expt
    next_mouse_end_expt.clicked_name = [];
    gotValidClick = false; // until a click is received
    // keep track of which components have finished
    debriefComponents = [];
    debriefComponents.push(debrief_report);
    debriefComponents.push(next_end_expt);
    debriefComponents.push(next_mouse_end_expt);
    
    for (const thisComponent of debriefComponents)
      if ('status' in thisComponent)
        thisComponent.status = PsychoJS.Status.NOT_STARTED;
    return Scheduler.Event.NEXT;
  }
}


function debriefRoutineEachFrame() {
  return async function () {
    //--- Loop for each frame of Routine 'debrief' ---
    // get current time
    t = debriefClock.getTime();
    frameN = frameN + 1;// number of completed frames (so 0 is the first frame)
    // update/draw components on each frame
    
    // *debrief_report* updates
    if (t >= 0.0 && debrief_report.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      debrief_report.tStart = t;  // (not accounting for frame time here)
      debrief_report.frameNStart = frameN;  // exact frame index
      
      debrief_report.setAutoDraw(true);
    }
    
    
    // *next_end_expt* updates
    if (t >= 0 && next_end_expt.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      next_end_expt.tStart = t;  // (not accounting for frame time here)
      next_end_expt.frameNStart = frameN;  // exact frame index
      
      next_end_expt.setAutoDraw(true);
    }
    
    // *next_mouse_end_expt* updates
    if (t >= 0 && next_mouse_end_expt.status === PsychoJS.Status.NOT_STARTED) {
      // keep track of start time/frame for later
      next_mouse_end_expt.tStart = t;  // (not accounting for frame time here)
      next_mouse_end_expt.frameNStart = frameN;  // exact frame index
      
      next_mouse_end_expt.status = PsychoJS.Status.STARTED;
      next_mouse_end_expt.mouseClock.reset();
      prevButtonState = next_mouse_end_expt.getPressed();  // if button is down already this ISN'T a new click
      }
    if (next_mouse_end_expt.status === PsychoJS.Status.STARTED) {  // only update if started and not finished!
      _mouseButtons = next_mouse_end_expt.getPressed();
      if (!_mouseButtons.every( (e,i,) => (e == prevButtonState[i]) )) { // button state changed?
        prevButtonState = _mouseButtons;
        if (_mouseButtons.reduce( (e, acc) => (e+acc) ) > 0) { // state changed to a new click
          // check if the mouse was inside our 'clickable' objects
          gotValidClick = false;
          for (const obj of [next_end_expt]) {
            if (obj.contains(next_mouse_end_expt)) {
              gotValidClick = true;
              next_mouse_end_expt.clicked_name.push(obj.name)
            }
          }
          if (gotValidClick === true) { // end routine on response
            continueRoutine = false;
          }
        }
      }
    }
    // check for quit (typically the Esc key)
    if (psychoJS.experiment.experimentEnded || psychoJS.eventManager.getKeys({keyList:['escape']}).length > 0) {
      return quitPsychoJS('The [Escape] key was pressed. Goodbye!', false);
    }
    
    // check if the Routine should terminate
    if (!continueRoutine) {  // a component has requested a forced-end of Routine
      return Scheduler.Event.NEXT;
    }
    
    continueRoutine = false;  // reverts to True if at least one component still running
    for (const thisComponent of debriefComponents)
      if ('status' in thisComponent && thisComponent.status !== PsychoJS.Status.FINISHED) {
        continueRoutine = true;
        break;
      }
    
    // refresh the screen if continuing
    if (continueRoutine) {
      return Scheduler.Event.FLIP_REPEAT;
    } else {
      return Scheduler.Event.NEXT;
    }
  };
}


function debriefRoutineEnd(snapshot) {
  return async function () {
    //--- Ending Routine 'debrief' ---
    for (const thisComponent of debriefComponents) {
      if (typeof thisComponent.setAutoDraw === 'function') {
        thisComponent.setAutoDraw(false);
      }
    }
    // store data for psychoJS.experiment (ExperimentHandler)
    // the Routine "debrief" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset();
    
    // Routines running outside a loop should always advance the datafile row
    if (currentLoop === psychoJS.experiment) {
      psychoJS.experiment.nextEntry(snapshot);
    }
    return Scheduler.Event.NEXT;
  }
}


function importConditions(currentLoop) {
  return async function () {
    psychoJS.importAttributes(currentLoop.getCurrentTrial());
    return Scheduler.Event.NEXT;
    };
}


async function quitPsychoJS(message, isCompleted) {
  // Check for and save orphaned data
  if (psychoJS.experiment.isEntryEmpty()) {
    psychoJS.experiment.nextEntry();
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  let complete_url = "https://iu.co1.qualtrics.com/jfe/form/SV_cBXYDpPQBCfKI2G?participant=" + expInfo["participant"] + "&condition=" + expInfo["condition"] + "&bonus=" + hasBonus;
  psychoJS.setRedirectUrls(complete_url, incomplete_url);
  
  
  
  
  
  
  if (typeof rock_info_grid !== 'undefined'){
  psychoJS.experiment.nextEntry();
      for (let rock_index = 0; rock_index < rock_info_grid.length; rock_index++) {
          let row = rock_info_grid[rock_index];
          for (let key in row) {
              psychoJS.experiment.addData(key, row[key]);
          }
          psychoJS.experiment.nextEntry();
      }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  psychoJS.window.close();
  psychoJS.quit({message: message, isCompleted: isCompleted});
  
  return Scheduler.Event.QUIT;
}
