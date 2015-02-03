chai = require 'chai'
chai.should()
exec = require('child_process').exec
pack = require '../package.json'

cmd = 'node bin/autometa.js '
version = cmd + '-v'
help = cmd + '-h'
output_stdout = cmd + '-o /dev/stdout test/test.xlsx'
output_hyphen = cmd + '-o - test/test.xlsx'
template = cmd + '-o - -t test note-example.xlsx'
ect_support = cmd + '-o - -t test-ect test/test.xlsx'
notexistsfile = cmd + 'not-exists-file'
csv_parse = cmd + '-o - -t test-csv-parse test/test.xlsx'
remove_xml = 'rm -f test.xml'
not_overwrite = cmd + 'test/test.xlsx'
overwrite_confirmation = 'echo y | ' + cmd + 'test/test.xlsx'
no_overwrite_confirmation = cmd + '-f test/test.xlsx'
print_templates_dirs = cmd + '-p'

describe 'autometa command-line interface should return', ->
  this.timeout 5000

  it 'version if -v option specified', (done) ->
    exec version, (error, stdout, stderr) ->
      stdout.should.string(pack['version'])
      done()

  it 'help message if -h option specified', (done) ->
    exec help, (error, stdout, stderr) ->
      stdout.should.string('help')
      done()

  it 'output to stdout if -o /dev/stdout option specified', (done) ->
    exec output_stdout, (error, stdout, stderr) ->
      stdout.should.string(
        '<person>\n  <name>Kenji Doi</name>\n  <age>31</age>\n</person>'
      )
      done()

  it 'output to stdout if -o - option specified', (done) ->
    exec output_hyphen, (error, stdout, stderr) ->
      stdout.should.string(
        '<person>\n  <name>Kenji Doi</name>\n  <age>31</age>\n</person>'
      )
      done()

  it 'output to stdout if -o and -t option specified', (done) ->
    exec template, (error, stdout, stderr) ->
      stdout.should.string(
        '<person>\n  <name>Hanako</name>\n  <age>Taro</age>\n</person>'
      )
      done()

  it 'output if ect template specified', (done) ->
    exec ect_support, (error, stdout, stderr) ->
      stdout.should.string(
        '<person-ect>\n  <name>Kenji Doi</name>\n  <age>31</age>\n</person-ect>'
      )
      done()

  it 'error messsage if not exists file specified', (done) ->
    exec notexistsfile, (error, stdout, stderr) ->
      stderr.should.equal('Failed to generate file.\n')
      done()

  it 'output if cell specified with row and column index', (done) ->
    exec csv_parse, (error, stdout, stderr) ->
      stdout.should.string(
        '<person>\n  <name>Kenji Doi</name>\n  <age>31</age>\n</person>'
      )
      done()

  it 'no overwrite confirmation if output not exists', (done) ->
    exec remove_xml, (error, stdout, stderr) ->
      unless error
        exec not_overwrite, (error, stdout, stderr) ->
          unless error
            stdout.should.string('Writing')
            stdout.should.string('Finish.')
            done()

  it 'overwrite confirmation if output exists', (done) ->
    exec overwrite_confirmation, (error, stdout, stderr) ->
      unless error
        stdout.should.string('Writing')
        stderr.should.string('Error.')
        stdout.should.string('overwrite?')
        done()

  it 'no overwrite confirmation if force option specified', (done) ->
    exec no_overwrite_confirmation, (error, stdout, stderr) ->
      unless error
        stdout.should.string('Writing')
        stdout.should.string('Finish.')
        stdout.should.not.string('overwrite?')
        done()

  it 'templates dirs if print-templates-dirs option specified', (done) ->
    exec print_templates_dirs, (error, stdout, stderr) ->
      unless error
        stdout.should.string('/templates')
        done()

