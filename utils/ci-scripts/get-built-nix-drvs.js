#!/usr/bin/env node

/**
 * Nix Build Log Parser
 * 
 * The script parses Nix build logs to identify successfully completed derivations (skipping failed ones) 
 * and writes them to an output file. It tracks which derivations are expected to be built and correlates 
 * build start/end events to determine which ones completed successfully.
 * 
 * 1. Read all input files and process their lines
 * 2. Create a Set to store derivations that will be built (from the "these N derivations will be built" section)
 * 3. Track the currently building derivation in `currentBuilding`
 * 4. For each line:
 *    - If it's a "will be built" list item, add to the Set
 *    - If it's a "building..." line, add the previous build to successful set (if any) and store current as building (if it's in our Set)
 *    - If it's a "failed" line, clear the currently building (if it's in our Set)
 * 5. After processing all lines, add any remaining build to successful set
 * 6. Write all successful derivations to output file at once
 */

const fs = require('fs');

const args = process.argv.slice(2);
const outputFile = args.pop();
const inputFiles = args;

if (!inputFiles.length || !outputFile) {
  console.error('Usage: node script.js <input-file1> [input-file2...] <output-file>');
  process.exit(1);
}

const buildingDrvs = new Set();
let readingDrvs = false;
let lastBuilding = null;
const successfulDrvs = new Set();

function processLine(line) {
  if (readingDrvs) {
    const drv = line.match(/^  (.*)\.drv$/);
    if (drv) buildingDrvs.add(drv[1]);
    else readingDrvs = false;
  }

  if (line.includes('derivations will be built:')) {
    readingDrvs = true;
  }

  const building = line.match(/^building '(.*)\.drv'\.\.\.$/);
  if (building && buildingDrvs.has(building[1])) {
    if (lastBuilding) successfulDrvs.add(`${lastBuilding}.drv`);
    lastBuilding = building[1];
  }

  const failed = line.match(/^error: build of '(.*)\.drv' failed$/);
  if (failed && buildingDrvs.has(failed[1])) {
    lastBuilding = null;
  }
}

for (const inputFile of inputFiles) {
  const lines = fs.readFileSync(inputFile, 'utf8').split('\n');
  for (const line of lines) {
    processLine(line);
  }
}

if (lastBuilding) successfulDrvs.add(`${lastBuilding}.drv`);

fs.writeFileSync(outputFile, Array.from(successfulDrvs).join('\n') + '\n');

