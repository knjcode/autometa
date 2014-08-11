fs = require 'fs'
path = require 'path'
xlsx = require 'xlsx'
xls = require 'xlsjs'
ejs = require 'ejs'

readExcelFile = (excelfile) ->
  ext = path.extname(excelfile)

  # read workbook
  if fs.existsSync(excelfile)
    if ext is '.xlsx'
      workbook = xlsx.readFile(excelfile)
    else if ext is '.xls'
      workbook = xls.readFile(excelfile)
    else
      retur false
  else
    return false

  return workbook


getCsvFilename = (id) ->
  filename = './templates/' + id + '.csv'
  if not fs.existsSync(filename)
    return false
  return filename


getEjsFilename = (id) ->
  filename = './templates/' + id + '.ejs'
  if not fs.existsSync(filename)
    return false
  return filename


exports.generateFile = (excelfile) ->
  if out = exports.generate(excelfile)
    sheetnum = out[0]
    outputs = out[1]

    for i in [0...sheetnum]
      [FileName, output] = outputs[i]

      fs.writeFileSync(FileName, output)
      console.log "Writing " + FileName
      console.log "Finish."

    return true
  else
    return false

exports.generate = (excelfile) ->
  workbook = readExcelFile(excelfile)
  if not workbook
    return false

  sheetnum = workbook.SheetNames.length
  outputs = []

  # loop all sheets
  for sheet in workbook.SheetNames

    worksheet = workbook.Sheets[sheet]

    # read template ID  
    id = worksheet['A1'].w

    # make csv filename
    csvfilename = getCsvFilename(id)
    if not csvfilename
      return false

    # make ejs file name
    ejsfilename = getEjsFilename(id)
    if not ejsfilename
      return false

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
    output = ejs.render(template, keymap)

    outputs.push [keymap['FileName'], output]

  return [sheetnum, outputs]

