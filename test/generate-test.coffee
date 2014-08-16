chai = require 'chai'
chai.should()
autometa = require '../src/autometa.coffee'

describe 'autometa generate function test', ->

  it 'return 1 sheet data if input Excel spreadsheet with 1 sheet', ->
    autometa.generate('./test/test.xlsx').should.deep.equal(
      [1,
        [
          ['test.xml',
           '<person>\n  <name>Kenji Doi</name>\n  <age>31</age>\n</person>\n'
          ]
        ]
      ]
    )

  it 'return 2 sheets data if input Excel spreadsheet with 2 sheets', ->
    autometa.generate('./test/test-2sheets.xlsx').should.deep.equal(
      [2,
        [
          ['test-2sheets-1.xml',
           '<person>\n  <name>Kenji Doi 1</name>\n  <age>31</age>\n</person>\n'
          ],
          ['test-2sheets-2.xml',
           '<person>\n  <name>Kenji Doi 2</name>\n  <age>31</age>\n</person>\n'
          ]
        ]
      ]
    )

  it 'return repeat data if elements repeated only horizontally', ->
    string = autometa.generate('./test/test-repeat.xlsx')[1][0][1]
    string.should.have.contain('Bob Dylan')
    string.should.have.contain('Bonnie Tyler')
    string.should.have.contain('Dolly Parton')
    string.should.have.contain('Gary Moore')
    string.should.have.contain('Eros Ramazzotti')

  it 'return repeat data if elements repeated only vertically', ->
    string = autometa.generate('./test/test-repeat2.xlsx')[1][0][1]
    string.should.have.contain('Bob Dylan')
    string.should.have.contain('Bonnie Tyler')
    string.should.have.contain('Dolly Parton')
    string.should.have.contain('Gary Moore')
    string.should.have.contain('Eros Ramazzotti')

  it 'return false if invalid filename specified', ->
  it 'return false if invalid filename specified', ->
    autometa.generate('not-exist-file').should.to.be.false

  it 'return false if no filename specified', ->
    autometa.generate('').should.to.be.false

  it 'return false if invalid template ID specified in Excel spreadsheet', ->
    autometa.generate('./test/test-invalid-templateid.xlsx').should.to.be.false

