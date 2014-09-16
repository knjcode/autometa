#!/usr/bin/env node

var program = require('commander');
var autometa = require('../lib/autometa.js');
var package = require('../package.json');
var templates = [];
var overwrite = false;

program
  .version(package.version, '-v, --version')
  .usage('[options] <Excel spreadsheet>')
  .option('-f, --force', 'overwrite existing files')
  .option('-o, --output <filename>', 'set output file name of first sheet manually', String)
  .option('-r, --register <template file>', 'register templates', String)
  .option('-t, --template <Template ID>', 'set a Template ID manually', String);

program.on('--help', function () {
  console.log("  Environment variable:");
  console.log("  AUTOMETA_TEMPLATES       Set \":\"-separeted list of directories,");
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

// if specified template option
if(program.template) {
  if(!autometa.setTemplateID(program.template)){
    console.error("Failed to set the Template ID.");
    process.exit(1);
  }
}

// if specified force option
if(program.force) {
  overwrite = true;
}

// if specified register option
if(program.register) {
  templates.push(program.register);
  templates = templates.concat(program.args);
  autometa.registerTemplates(templates,overwrite);
  process.exit(0);
}

if(!program.args.length) { // No filename found
  program.help();
} else { // Filename found
  if(autometa.generateFile(program.args[0],program.output,overwrite)) {
    // Success to generate file
    process.exit(0);
  } else {
    console.error("Failed to generate file.");
    process.exit(1);
  }
}

