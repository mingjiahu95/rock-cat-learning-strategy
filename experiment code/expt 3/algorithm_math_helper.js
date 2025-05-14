function calcClassScore(categories, responses, reference, keys = [...new Set(categories)]) {
    const count = (arr, predicate) => arr.filter(predicate).length;
    keys.sort();

    // Calculate OPS for each key
    const OPS = keys.map(key => {
        const count_cat = count(categories, cat => cat === key);
        const count_noncat = categories.length - count_cat;

        if (count_cat == 0 || count_noncat == 0) {
            return undefined;
        }

        const TP = count(categories, (_, idx) => (categories[idx] === key && responses[idx] === key));
        const FP = count(categories, (_, idx) => (categories[idx] !== key && responses[idx] === key));

        const TPR = TP / count_cat;// TP/(TP + FN)
        const FPR = FP / count_noncat; // FP/(FP + TN)

        return TPR - FPR;
    });

    // Calculate HS for each key
    const HS = keys.map(key => {
        const count_cat = count(categories, cat => cat === key);
        if (count_cat == 0) {
            return undefined;
        }
        const TP = count(categories, (_, idx) => (categories[idx] === key && responses[idx] === key));
        const TPR = TP / count_cat;// TP/(TP + FN)
        return TPR;
    });

    // Calculate FAS for each key based on the reference category
    var CS
    if (reference === undefined) {
        CS = undefined;
    } else {
        CS = keys.map(key => {
            // confusion is not defined for the key category
            if (key === reference) {
                return undefined;
            }

            const FN_cat = count(responses, (_, idx) => (categories[idx] === reference && responses[idx] === key));
            const FN_total = count(responses, (_, idx) => (categories[idx] === reference && responses[idx] !== reference));
            // categories with zero miss are considered uninformative to the algorithm
            if (FN_total === 0) {
                return null;
            }
            FN_cat_prop = FN_cat / FN_total;
            return FN_cat_prop;
        });
    }

    return { OPS, HS, CS };
}

function calcWgtAverage(priorValues, decayFactor) {
    const numCategories = priorValues[0].length;
    const weightedAverages = new Array(numCategories).fill(undefined);

    // Loop over each category by index
    for (let i = 0; i < numCategories; i++) {
        const hasUndefined = priorValues.some(values => values[i] === undefined);
        if (!hasUndefined) {
            const cat_vals = priorValues.map(values => values[i]).filter(value => value != null);
            if (cat_vals.length > 0) {
                const numBlocks = cat_vals.length;
                const weightedSum = math.sum(cat_vals.map((cat_val, blockIndex) =>
                    cat_val * math.exp(-decayFactor * (numBlocks - blockIndex - 1))
                ));
                const totalWeight = math.sum(cat_vals.map((_, blockIndex) =>
                    math.exp(-decayFactor * (numBlocks - blockIndex - 1))
                ));
                weightedAverages[i] = weightedSum / totalWeight;
            }
        }
    }
    return weightedAverages;
}

function NormalizeTopK(raw_values, k) {

    // Pair each defined value with its index
    const valueIndexPairs = raw_values
        .map((value, index) => ({ value, index }))
        .filter(pair => pair.value !== undefined);

    const numDefined = valueIndexPairs.length;

    // Edge cases
    if (k >= numDefined) {
        const sumAll = math.sum(valueIndexPairs.map(pair => pair.value));
        return raw_values.map(x => x !== undefined ? x / sumAll : 0);
    }

    // Sort pairs in descending order based on value
    const sortedPairs = valueIndexPairs.sort((a, b) => b.value - a.value);;

    // Determine the cutoff value (kth value)
    const cutoffValue = sortedPairs[k - 1].value;

    // Separate pairs into greater than cutoff and equal to cutoff
    const [greaterThanCutoff, equalToCutoff] = [
        sortedPairs.filter(pair => pair.value > cutoffValue),
        sortedPairs.filter(pair => pair.value === cutoffValue)
    ];

    const numSelected = greaterThanCutoff.length;
    const numNeeded = k - numSelected;

    // Randomly select the required number from tied values
    const selectedFromEqual = numNeeded > 0
        ? shuffleList(equalToCutoff).slice(0, numNeeded)
        : [];

    // Combine the selected pairs
    const selected = [...greaterThanCutoff, ...selectedFromEqual];

    // Calculate the sum of selected values for normalization
    const sumSelected = math.sum(selected.map(pair => pair.value));

    // Initialize R_prob with zeros
    const normalized_values = Array(raw_values.length).fill(0);

    // Assign normalized values to the selected indices
    selected.forEach(pair => {
        normalized_values[pair.index] = pair.value / sumSelected;
    });

    return normalized_values;
}

// function prop_to_count(proportions, target_sum) {
//     target_values = proportions.map(prop => prop * target_sum);
//     current_values = target_values.map(value => util.round(value));
//     current_sum = util.sum(current_values);
//     current_diff = target_values.map((num, index) => num - current_values[index]);
//     maxIterations = 1000; // Set a maximum number of iterations to prevent infinite loop
//     iteration = 0;
//     function findRandomIndexOfExtreme(list, extremeFunc) {
//       const extremeVal = extremeFunc(...list);
//       const extremeIndices = list
//           .map((value, index) => value === extremeVal ? index : -1)
//           .filter(index => index !== -1);
//       return extremeIndices[Math.floor(Math.random() * extremeIndices.length)];
//     };

//     while (current_sum !== target_sum && iteration < maxIterations) {
//             while (current_sum > target_sum){
//                 let i = findRandomIndexOfExtreme(current_diff, Math.min);
//                 current_values[i] -= 1;
//                 current_diff[i] += 1;
//                 current_sum -= 1;
//             }
//             while (current_sum < target_sum){
//                 let i = findRandomIndexOfExtreme(current_diff, Math.max);
//                 current_values[i] += 1;
//                 current_diff[i] -= 1;
//                 current_sum += 1;
//             }
//         }
//         iteration++;
//     return current_values;
// };

function prop_to_count(proportions, target_sum) {

    const target_values = proportions.map(prop => prop * target_sum);
    const floored_values = target_values.map(value => Math.floor(value));
    const current_sum = math.sum(floored_values);
    let remaining = target_sum - current_sum;

    if (remaining == 0) {
        return floored_values;
    }
    const remainders = target_values.map((value, index) => ({
        index,
        remainder: value - floored_values[index]
    }));

    // Step 6: Group indices by remainder
    const remainderGroups = {};
    remainders.forEach(({ index, remainder }) => {
        const key = math.round(remainder, 10); // Use a precision to group similar remainders
        if (!remainderGroups[key]) {
            remainderGroups[key] = [];
        }
        remainderGroups[key].push(index);
    });

    // Step 7: Sort the unique remainders in descending order
    const sortedRemainderKeys = Object.keys(remainderGroups)
        .map(key => parseFloat(key))
        .sort((a, b) => b - a);

    // Step 8: Allocate remaining units
    for (const remainder of sortedRemainderKeys) {
        const indices = remainderGroups[remainder];

        shuffleList(indices);
        for (const index of indices) {
            if (remaining > 0) {
                floored_values[index] += 1;
                remaining -= 1;
            } else {
                break;
            }
        }
        if (remaining == 0) {
            break;
        }
    }

    return floored_values;
}


function getTopKIndices(arr, k) {
    const indices = arr.map((_, index) => index);
    indices.sort((a, b) => {
        if (arr[b] === arr[a]) {
            // If values are tied, sort randomly
            return Math.random() - 0.5;
        }
        return arr[b] - arr[a];
    })
    return indices.slice(0, k);
};

function getBotKIndices(arr, k) {
    const indices = arr.map((_, index) => index);
    indices.sort((a, b) => {
        if (arr[a] === arr[b]) {
            // If values are tied, sort randomly
            return Math.random() - 0.5;
        }
        return arr[a] - arr[b];
    });
    return indices.slice(0, k);
}