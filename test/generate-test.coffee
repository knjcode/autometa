chai = require 'chai'
assert = chai.assert
autometa = require '../src/autometa.coffee'

describe 'autometa test', ->
  it 'generate', (done) ->
    assert.deepEqual autometa.generate('./test/test.xlsx') , ['test.xml', '<person>\n  <name>Kenji Doi</name>\n  <age>31</age>\n</person>\n']
    done()

