#!/usr/bin/env node

var program = require('commander');
var autometa = require('../lib/autometa.js');
var package = require('../package.json');

program
  .version(package.version, '-v, --version')
  .usage('[options] <Excel spreadsheet>')
  .option('-o, --stdout', 'place output of first sheet on stdout')
  .option('-r, --register <template file>', 'register templates', String)
  .option('-t, --template <Template ID>', 'set a Template ID manually', String);

program.on('--help', function () {
  console.log("  Environment variable:");
  console.log("  AUTOMETA_TEMPLATES       Set ':'-separeted list of directories,");
  console.log("                           If you want to change templates directory.");
});

program.parse(process.argv);

if(process.version === 'v0.10.31') {
  var msgs = [
    "node v0.10.31 is known to crash on OSX and Linux, refusing to proceed.",
    "see https://github.com/joyent/node/issues/8208 for the relevant node issue"
  ];
  msgs.forEach(function(m) { console.error(m); });
  process.exit(1);
}

var templates = [];

// if secified template option
if(program.template) {
  if(!autometa.setTemplateID(program.template)){
    console.log("Failed to set the Template ID.");
    process.exit(1);
  }
}

// if specified register option
if(program.register) {
  templates.push(program.register);
  templates = templates.concat(program.args);
  autometa.registerTemplates(templates);
  process.exit(0);
}

if(!program.args.length) { // No filename found
  program.help();
} else { // filename found
  if(program.stdout) {
    //console.log(program.args[0]);
    output = autometa.generate(program.args[0]);
    if(output) {
      console.log(output[1][0][1]); // Print only output of first sheet
      process.exit(0);
    } else {
      console.log("Error. Check input file.");
      process.exit(1);
    }
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

