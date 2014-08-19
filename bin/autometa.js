#!/usr/bin/env node

var program = require('commander');
var autometa = require('../lib/autometa.js');
var package = require('../package.json');

program
  .version(package.version, '-v, --version')
  .usage('[options] <Excel spreadsheet>')
  .option('-o, --stdout', 'place output on stdout')
  .option('-r, --register <template file>', 'register templates', String)
  .parse(process.argv);

var templates = [];

if(!program.args.length) { // No filename found
  if(program.register) {
    templates.push(program.register);
    console.log("Input templates: " + templates);
    autometa.registerTemplates(templates);
    process.exit(0);
  } else {
    program.help();
  }
} else { // filename found
  if(program.stdout) {
    output = autometa.generate(program.args[0]);
    if(output) {
      console.log(output[1]); // Print only 1st data
      process.exit(0);
    } else {
      console.log("Error. Check input file.");
      process.exit(1);
    }
  } else if(program.register) { // Count strings as templates
    templates.push(program.register);
    templates = templates.concat(program.args);
    console.log("Input templates: " + templates);
    autometa.registerTemplates(templates);
    process.exit(0);
  } else {
    // Only filename specified
    if(autometa.generateFile(program.args[0])) { // Success to generate file
      process.exit(0);
    } else { // Failed to generate file
      console.log("Error. Check input file.");
      process.exit(1);
    }
  }
}

