chai = require 'chai'
chai.should()
cp = require 'child_process'
pack = require '../package.json'
cmd_version = 'node bin/autometa.js -v'
cmd_help = 'node bin/autometa.js -h'
cmd_output_stdout = 'node bin/autometa.js -o /dev/stdout test/test.xlsx'
cmd_output_hyphen = 'node bin/autometa.js -o - test/test.xlsx'
cmd_template =
  'node bin/autometa.js -o - -t test note-example.xlsx'
cmd_notexistsfile = 'node bin/autometa.js not-exists-file'
cmd_csv_parse =
  'node bin/autometa.js -o - -t test-csv-parse test/test.xlsx'

describe 'autometa command-line interface should return', ->
  this.timeout 5000

  it 'version if -v option specified', (done) ->
    cp.exec cmd_version, (error, stdout, stderr) ->
      stdout.toString().should.string(pack['version'])
      done()

  it 'help message if -h option specified', (done) ->
    cp.exec cmd_help, (error, stdout, stderr) ->
      stdout.toString().should.string('help')
      done()

  it 'output to stdout if -o /dev/stdout option specified', (done) ->
    cp.exec cmd_output_stdout, (error, stdout, stderr) ->
      stdout.toString().should.string(
        '<person>\n  <name>Kenji Doi</name>\n  <age>31</age>\n</person>'
      )
      done()

  it 'output to stdout if -o - option specified', (done) ->
    cp.exec cmd_output_hyphen, (error, stdout, stderr) ->
      stdout.toString().should.string(
        '<person>\n  <name>Kenji Doi</name>\n  <age>31</age>\n</person>'
      )
      done()

  it 'output to stdout if -o and -t option specified', (done) ->
    cp.exec cmd_template, (error, stdout, stderr) ->
      stdout.toString().should.string(
        '<person>\n  <name>Hanako</name>\n  <age>Taro</age>\n</person>'
      )
      done()

  it 'error messsage if not exists file specified', (done) ->
    cp.exec cmd_notexistsfile, (error, stdout, stderr) ->
      stdout.toString().should.equal('Error. Check input file.\n')
      done()

  it 'output if cell specified with row and column index', (done) ->
    cp.exec cmd_csv_parse, (error, stdout, stderr) ->
      stdout.toString().should.string(
        '<person>\n  <name>Kenji Doi</name>\n  <age>31</age>\n</person>'
      )
      done()

