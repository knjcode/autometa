fs = require 'fs'
path = require 'path'
xlsx = require 'xlsx'
xls = require 'xlsjs'
ejs = require 'ejs'

exports.generate = (excelfile) ->
  console.log "Input excel filename:", excelfile
  ext  = path.extname excelfile
  console.log "extname:", ext

  # read workbook
  if ext is '.xlsx'
    workbook = xlsx.readFile(excelfile)
  else if ext is '.xls'
    workbook = xls.readFile excelfile
  else
    console.log "error. check input filename."
    return

  # loop all sheets
  for sheet in workbook.SheetNames
    # print sheet name 
    console.log "SheetName: " + sheet

    worksheet = workbook.Sheets[sheet]

    # read template ID  
    id =  worksheet['A1'].w
    console.log "TemplateID: " + id

    # make csv filename
    csvfilename = './' + id + '.csv'
    console.log "CSV FileName: " + csvfilename

    # make ejs file name
    ejsfilename = './' + id + '.ejs'
    console.log "EJS FileName: " + ejsfilename

    # read csv file
    csvfile = fs.readFileSync csvfilename, 'utf8'

    # parse csv
    keymap = []
    rowData = csvfile.split(String.fromCharCode(10))
    for i in [0...rowData.length]
      data = rowData[i].split(',')
      if data[0] isnt ''
        keymap[data[0]] = data[1]

    # print keymap
    console.log "KeyMap:"
    console.log keymap

    # mapping keymap to excel
    for key, element of keymap
      if key isnt ''
        keymap[key] = worksheet["#{element}"].w
      else
        delete keymap[key]

    # print mapped keymap
    console.log "ExcelMappedKeyMap:"
    console.log keymap

    template = fs.readFileSync ejsfilename, 'utf8'
    out = ejs.render template, keymap
    console.log "Output:"
    console.log out

  console.log "end."

