chai = require 'chai'
chai.should()
cp = require 'child_process'
pack = require '../package.json'
cmd_version = 'node bin/autometa.js -v'
cmd_help = 'node bin/autometa.js -h'
cmd_stdout = 'node bin/autometa.js -o test/test.xlsx'
cmd_notexistsfile = 'node bin/autometa.js not-exists-file'

describe 'autometa command-line interface should return', ->

  it 'version if -v option specified', (done) ->
    cp.exec cmd_version, (error, stdout, stderr) ->
      stdout.toString().should.string(pack['version'])
      done()

  it 'help message if -h option specified', (done) ->
    cp.exec cmd_help, (error, stdout, stderr) ->
      stdout.toString().should.string('help')
      done()

  it 'output to stdout if -o option specified', (done) ->
    cp.exec cmd_stdout, (error, stdout, stderr) ->
      stdout.toString().should.string('test.xml')
      done()

  it 'error messsage if not exists file specified', (done) ->
    cp.exec cmd_notexistsfile, (error, stdout, stderr) ->
      stdout.toString().should.equal('Error. Check input file.\n')
      done()

