//functions for converting object to csv string
const extractHeaders = (arr) =>
  [...arr.reduce((acc, obj) => {
    Object.keys(obj).forEach((key) => acc.add(key));
    return acc;
  }, new Set())];


const isEmptyValue = value =>
  value === null || value === undefined || Number.isNaN(value);

const serializeValue = (value, delimiter = ',') => {
  if (isEmptyValue(value)) return '';
  value = `${value}`;
  if (
    value.includes(delimiter) ||
    value.includes('\n') ||
    value.includes('"')
  )
    return `"${value.replace(/"/g, '""').replace(/\n/g, '\\n')}"`;
  return value;
};

const serializeRow = (row, delimiter = ',') =>
  row.map(value => serializeValue(value, delimiter)).join(delimiter);

const Object2CSV = (arr, headers = extractHeaders(arr), omitHeaders = false, delimiter = ',') => {
  const headerRow = serializeRow(headers, delimiter);
  const bodyRows = arr.map(obj =>
    serializeRow(headers.map(key => obj[key]), delimiter)
  );
  return omitHeaders
    ? bodyRows.join('\n')
    : [headerRow, ...bodyRows].join('\n');
};

//functions for converting csv string to object
const deserializeRow = (row, delimiter = ',') => {
  const values = [];
  let index = 0, matchStart = 0, isInsideQuotations = false;
  while (true) {
    if (index === row.length) {
      values.push(row.slice(matchStart, index));
      break;
    }
    const char = row[index];
    if (char === delimiter && !isInsideQuotations) {
      values.push(
        row
          .slice(matchStart, index)
          .replace(/^"|"$/g, '')
          .replace(/""/g, '"')
          .replace(/\\n/g, '\n')
      );
      matchStart = index + 1;
    }
    if (char === '"')
      if (row[index + 1] === '"') index += 1;
      else isInsideQuotations = !isInsideQuotations;
    index += 1;
  }
  return values;
};

const CSV2Object = (data, delimiter = ',') => {
  const rows = data.split('\n');
  const headers = deserializeRow(rows.shift(), delimiter);
  return rows.map((row) => {
    const values = deserializeRow(row, delimiter);
    return headers.reduce((obj, key, index) => {
      obj[key] = values[index];
      return obj;
    }, {});
  });
};

async function fetchCSV(filePath) {
  try {
    const response = await fetch(filePath);
    const csvText = await response.text();  // Wait for the response and convert to text
    console.log(csvText);  // Now you have the CSV text and can process it
    return csvText
  } catch (error) {
    console.error('Error fetching the CSV:', error);
  }
};

async function sendCSV(csvString) {
  // Send a POST request to the server with the CSV data
  const response = await fetch('/save-csv', {
    method: 'POST',
    headers: {
      'Content-Type': 'text/csv',
    },
    body: csvString
  });
}