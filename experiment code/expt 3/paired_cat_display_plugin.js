var jsPsychPairedCatDisplay = (function (jspsych) {

  const info = {
    name: "paired-cat-display",
    version: "1.0.0",
    parameters: {
      stimulus: {
        type: jspsych.ParameterType.COMPLEX,
        default: undefined,
        description: 'List of categories, each containing images with file paths, width and height in pixel'
      },
      practice_mode: {
        type: jspsych.ParameterType.BOOL,
        default: false,
        description: 'a flag indicating whether a trial is a practice or for real'
      }
    },
    data: {}
  };

  class jsPsychPairedCatDisplay_plugin {
    constructor(JsPsych) {
      this.jsPsych = jsPsych;
    }

    trial(display_element, trial) {
      let currentStage = 1;  // Initialize stage 1
      let num_columns = trial.stimulus.length;
      let shrink_factor = 0.8;
      let time_record = [];

      const render = () => {
        display_element.innerHTML = '';  // Clear the display

        // Initialize the container styles
        let containerHTML = `<div style="display: flex; flex-direction:column; margin-top: -2cm; user-select: none;">\n`;


        // Loop over categories and render content based on the current stage
        for (let categoryObj of trial.stimulus) {
          let catname_selected = categoryObj.category;

          // Generate the category HTML
          let categoryHTML = '';
          if (currentStage == 2) {
            categoryHTML = '<div style="display: flex; flex-direction: column;">';
          }
          categoryHTML += '<div style="display: flex; flex-direction: column; align-self:flex-start; gap: 0.2cm; width:100%;">';


          // Add category label
          categoryHTML += `<div><h3 style="text-align: center; font-size: 0.7cm; margin: 0.1cm">${catname_selected}</h3></div>`
          categoryHTML += '<div id="image_row" style="display: flex; flex-direction: row; justify-content: center; align-items: center; align-self:flex-start; gap: 0.5cm; margin: auto">';
          // Add images
          for (let rock of categoryObj.images) {
            let width_cm = 4.3;//adjust the physical size of rock images
            let height_cm = width_cm / rock.aspect_ratio;
            if (currentStage === 2) {
              width_cm *= shrink_factor;
              height_cm *= shrink_factor;
            }

            // Generate the image div HTML
            categoryHTML += `<img src="${rock.file_path}" style="width: ${width_cm}cm; height: ${height_cm}cm; object-fit: contain;" />\n`;
          };

          // Add text box in stage 2 and 3
          if (currentStage > 1) {
            categoryHTML += `</div>\n`;//close the div for the image column
            categoryHTML += `<div style="display: flex; flex-direction: row; justify-content: center;">\n`;
            if (currentStage == 2) {
              let placeholder_txt = `Describe what features you think can be used to identify ${catname_selected.toLowerCase()}\n(Enter at least 3 words to proceed)`;
              categoryHTML += `<textarea id="rock-input-${catname_selected}" placeholder="${placeholder_txt}" style="width: 100%; height:3cm; resize: vertical;"></textarea>\n`;
            } else {
              categoryHTML += `<textarea id="rock-input-${catname_selected}" style="width: 80%; height:3cm; resize: vertical;">Enter response for ${catname_selected}</textarea>\n`;
            }
            categoryHTML += `</div>\n`;
          }


          // Append the category HTML to the container
          containerHTML += categoryHTML + `</div> </div>\n`;
        };

        // Close the container div
        containerHTML += `</div>\n`;

        // Set the container HTML
        display_element.innerHTML = containerHTML;
        time_record.push(performance.now());

        // add button at the bottom
        let buttonText = (trial.practice_mode == true && currentStage == 2) ? 'Click here for an example of description' : 'Next';
        let text_display_mode = (currentStage == 2) ? 'none' : 'block';
        let buttonHTML = `<button id="button_trans_stage" class="jspsych-btn-nxt" style="display:none; margin-top: 0.5cm;">${buttonText}</button>`;
        let TextHTML = `<p id="text_trans_stage" style="display:${text_display_mode}; font-size:0.8cm; text-align:center; width: 100%;">A button to proceed will appear here in 5 seconds</p>`;
        display_element.innerHTML += `<div style="display:flex;">` + buttonHTML + TextHTML + `</div>`;
        console.log('button:', buttonHTML, 'text:', TextHTML);

        if (currentStage == 2) {
          let validWordCount = new Array(num_columns).fill(false);

          for (let i = 0; i < num_columns; i++) {
            let categoryObj = trial.stimulus[i];
            let catname_selected = categoryObj.category;
            let inputElement = document.getElementById(`rock-input-${catname_selected}`);

            // Add event listener to check word count in real-time
            inputElement.addEventListener('input', () => {
              let wordCount = inputElement.value.trim().split(/\s+/).filter(word => word.length > 0).length;
              validWordCount[i] = wordCount >= 3;

              // If all inputs have valid word count, show the button
              if (validWordCount.every(x => x)) {
                document.getElementById("text_trans_stage").style.display = "none";
                document.getElementById("button_trans_stage").style.display = "block";
              }
            });
          }
        }

        // Add the button at the bottom
        var timeoutId;
        const buttonShow = () => {
          // console.log('start of buttonShow function:', this);
          if (currentStage != 2) {
            document.getElementById("text_trans_stage").style.display = "none";
            document.getElementById("button_trans_stage").style.display = "block";
            console.log('after 5 secs...');
            console.log('button:', buttonHTML, 'text:', TextHTML);
          }
          // Add event listener for the button
          document.getElementById("button_trans_stage").addEventListener("click", () => {
            time_record.push(performance.now());
            if (currentStage == 1) {
              clearTimeout(timeoutId);
              currentStage += 1;
              render(); // Re-render for stage 2
            } else if (currentStage == 2 && trial.practice_mode == true) {
              currentStage += 1;
              console.log(currentStage);
              render(); // Re-render for stage 3
            } else {
              // Collect responses and end trial
              let text_response = {};
              for (let categoryObj of trial.stimulus) {
                let catname_selected = categoryObj.category;
                let inputElement = document.getElementById(`rock-input-${catname_selected}`);
                text_response[`text_${catname_selected}`] = inputElement.value;
              }
              let trial_data = {
                ...text_response,
                time_obs: time_record[1] - time_record[0],
                time_resp: time_record[3] - time_record[2],
                trialType: 'paired_cat_display'
              };
              this.jsPsych.finishTrial(trial_data);
            }
          });
        };


        if (currentStage === 1) {
          timeoutId = setTimeout(buttonShow, 5000);//adjust time taken for button to show up
        } else {
          buttonShow(); // Ensure button is set up for other stages
        }
      }
      render();
    }
  };
  jsPsychPairedCatDisplay_plugin.info = info;
  return jsPsychPairedCatDisplay_plugin;

})(jsPsychModule);


