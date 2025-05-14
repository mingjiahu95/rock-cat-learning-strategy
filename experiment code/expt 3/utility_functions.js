function isUpper(str) { return /^[A-Z]+$/.test(str); }

function isLower(str) { return /^[a-z]+$/.test(str); }

function extract_rock_info(filePath) {
  var rock_type, token, rock_info;
  var fileName = filePath.split(/(\/|\\)/).pop();
  rock_type = fileName.split("_")[1];
  token = fileName.split(".")[0].split("_").slice((- 1))[0];
  if (isUpper(rock_type[0]) && isLower(rock_type.slice(1)) && !isNaN(token)) {
    rock_info = { "type": rock_type, "token": token };
    return rock_info;
  }
  return null;
}

function shuffleList(list) {
  // Loop over the array elements starting from the last
  for (let i = list.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [list[i], list[j]] = [list[j], list[i]];
  }
  return list;
}

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
  filteredList = shuffleList(filteredList);
  filteredList.forEach((num, i) => {
    partitions[i % 2].push(num);
  });

  return partitions;
}

function requestFullscreen_all_browsers(){
  if (document.documentElement.requestFullscreen) {
    document.documentElement.requestFullscreen();
  } else if (document.documentElement.mozRequestFullScreen) { // Firefox
    document.documentElement.mozRequestFullScreen();
  } else if (document.documentElement.webkitRequestFullscreen) { // Chrome, Safari, Opera
    document.documentElement.webkitRequestFullscreen();
  } else if (document.documentElement.msRequestFullscreen) { // IE/Edge
    document.documentElement.msRequestFullscreen();
  }
}