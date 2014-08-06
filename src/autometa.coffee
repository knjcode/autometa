fs = require 'fs'
path = require 'path'
xlsx = require 'xlsx'
xls = require 'xlsjs'
ejs = require 'ejs'

exports.generateFile = (excelfile) ->
  [FileName, out] = exports.generate(excelfile)

  fs.writeFileSync(FileName, out)
  console.log "Writing " + FileName
  console.log "Finish."

exports.generate = (excelfile) ->
  ext = path.extname(excelfile)

  # read workbook
  if ext is '.xlsx'
    workbook = xlsx.readFile(excelfile)
  else if ext is '.xls'
    workbook = xls.readFile(excelfile)
  else
    console.log "Error. Check input filename."
    return

  # loop all sheets
  for sheet in workbook.SheetNames

    worksheet = workbook.Sheets[sheet]

    # read template ID  
    id =  worksheet['A1'].w

    # make csv filename
    csvfilename = './templates/' + id + '.csv'

    # make ejs file name
    ejsfilename = './templates/' + id + '.ejs'

    # read csv file
    csvfile = fs.readFileSync(csvfilename, 'utf8')

    # parse csv
    keymap = []
    rowData = csvfile.split(String.fromCharCode(10))
    for i in [0...rowData.length]
      data = rowData[i].split(',')
      if data[0] isnt ''
        keymap[data[0]] = data[1]

    # mapping keymap to excel
    for key, element of keymap
      if key isnt ''
        keymap[key] = worksheet["#{element}"].w
      else
        delete keymap[key]

    template = fs.readFileSync(ejsfilename, 'utf8')
    out = ejs.render(template, keymap)

    return [keymap['FileName'], out]
