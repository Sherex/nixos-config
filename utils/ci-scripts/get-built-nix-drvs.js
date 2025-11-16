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

console.log(`Starting Nix build log parsing...`);
console.log(`Input files: ${inputFiles.join(', ')}`);
console.log(`Output file: ${outputFile}`);

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
  try {
    const content = fs.readFileSync(inputFile, 'utf8');
    const lines = content.split('\n');
    console.log(`Processing ${inputFile}: ${lines.length} lines`);

    for (const line of lines) {
      processLine(line);
    }
  } catch (error) {
    console.error(`Error reading file ${inputFile}: ${error.message}`);
    process.exit(1);
  }
}

// Log the total number of expected derivations when exiting the reading state
if (!readingDrvs) {
  console.log(`Total derivations expected to be built: ${buildingDrvs.size}`);
}

if (lastBuilding) successfulDrvs.add(`${lastBuilding}.drv`);

console.log(`Found ${successfulDrvs.size} successful derivations`);

try {
    fs.writeFileSync(outputFile, Array.from(successfulDrvs).join('\n') + '\n');
    console.log(`Successfully wrote ${successfulDrvs.size} entries to ${outputFile}`);
} catch (error) {
    console.error(`Error writing to output file ${outputFile}: ${error.message}`);
    process.exit(1);
}
