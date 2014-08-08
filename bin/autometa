#!/usr/bin/env node

var program = require('commander');
var autometa = require('../lib/autometa.js');
var package = require('../package.json');

program
  .version(package['version'], '-v, --version')
  .usage('[options] <Excel spreadsheet>')
  .option('-o, --stdout', 'place output on stdout')
  .parse(process.argv);

var filename = program.args[0];

if(!program.args.length) {
  program.help();
} else if(program.stdout) {
  output = autometa.generate(filename);
  if(output) {
    console.log(output[1]);
    process.exit(0);
  } else {
    console.log("Error. Check input file.");
    process.exit(1);
  }
} else {
  if(autometa.generateFile(filename)) {
    process.exit(0);
  } else {
    console.log("Error. Check input file.");
    process.exit(1);
  }
}

