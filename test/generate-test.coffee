chai = require 'chai'
chai.should()
autometa = require '../src/autometa.coffee'

describe 'autometa generate function test', ->

  it 'return output filename and data if valid filename specified', ->
    autometa.generate('./test/test.xlsx').should.deep.equal(
      ['test.xml',
       '<person>\n  <name>Kenji Doi</name>\n  <age>31</age>\n</person>\n'
      ]
    )

  it 'return false if invalid filename specified', ->
    autometa.generate('not-exist-file').should.to.be.false

  it 'return false if no filename specified', ->
    autometa.generate('').should.to.be.false

