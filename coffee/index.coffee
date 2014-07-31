fs = require 'fs'
xlsx = require 'xlsx'
ejs = require 'ejs'

console.log "Input excel filename:", process.argv[2]
excelfile = process.argv[2]
console.log "options:", process.argv[3...process.argv.length]

# read workbook
workbook = xlsx.readFile(excelfile)

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

