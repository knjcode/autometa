fs = require 'fs'
path = require 'path'
xlsx = require 'xlsx'
xls = require 'xlsjs'
ejs = require 'ejs'

# Default horizontal and vertical mark
HORIZONTAL_MARK = '*'
VERTICAL_MARK = '#'

# Default templates directory is './templates'
TEMPLATES_DIRS = ['./templates']

# if NODE_AM_TEMPLATES is set, add specified directories into TEMPLATES_DIRS
templates_dirs = process.env.NODE_AM_TEMPLATES
if(templates_dirs)
  TEMPLATES_DIRS = templates_dirs.split(':').concat(TEMPLATES_DIRS)


readExcelFile = (excelfile) ->
  excelfile = path.resolve(excelfile)
  # read excelfile
  if fs.existsSync(excelfile)
    ext = path.extname(excelfile)
    if ext is '.xlsx'
      workbook = xlsx.readFile(excelfile)
    else if ext is '.xls'
      workbook = xls.readFile(excelfile)
    else
      return false
  else
    return false
  return workbook

exports.registerTemplates = (templates) ->
  for template in templates
    template = path.resolve(template)
    filename = path.basename(template)
    console.log 'Registering: ' + filename
    # read template
    if fs.existsSync(template)
      ext = path.extname(template)
      console.log 'Templates dir: ' + TEMPLATES_DIRS
      if ext is '.csv'
        console.log 'register file is csv'
      else if ext is '.ejs'
        console.log 'register file is ejs'
      else
        console.log 'Error. ' + filename + ' is not template'
    else
      console.log 'Input file does not exist'

getCsvFilename = (id) ->
  for dir in TEMPLATES_DIRS
    filename = path.resolve(dir, id + '.csv')
    if fs.existsSync(filename)
      return filename
  return false

getEjsFilename = (id) ->
  for dir in TEMPLATES_DIRS
    filename = path.resolve(dir, id + '.ejs')
    if fs.existsSync(filename)
      return filename
  return false

registerCsv = (csvfile) ->
  console.log 'registerCsv'
  # WIP

registerEjs = (ejsfile) ->
  console.log 'registerEjs'
  # WIP

decodeRow = (rowstr) -> parseInt(rowstr, 10) - 1

encodeRow = (row) -> "" + (row + 1)

decodeCol = (colstr) ->
  d = 0
  for i in [0...colstr.length]
    d = 26*d + colstr.charCodeAt(i) - 64
  return d - 1

encodeCol = (col) ->
  s = ""
  col += 1
  while col
    s = String.fromCharCode(((col-1)%26) + 65) + s
    col = Math.floor((col-1)/26)
  return s

splitCell = (cellstr) ->
  return cellstr.replace(/(\$?[A-Z]*)(\$?\d*)/,"$1,$2").split(",")

decodeCell = (cellstr) ->
  sp = splitCell(cellstr)
  return { c:decodeCol(sp[0]), r:decodeRow(sp[1]) }

encodeCell = (cell) ->
  return encodeCol(cell.c) + encodeRow(cell.r)

moveCell = (cellstr, direction) ->
  cell = decodeCell(cellstr)
  switch direction
    when 'up'
      cell.r -= 1
    when 'down'
      cell.r += 1
    when 'left'
      cell.c -= 1
    when 'right'
      cell.c += 1
  # Write error handling code when out of range

  return encodeCell(cell)

mapKey = (keymap, worksheet) ->
  # Length of HORIZONTAL_MARK
  lhm = HORIZONTAL_MARK.length
  # Length of VERTICAL_MARK
  lvm = VERTICAL_MARK.length

  for key, cell of keymap
    element = worksheet["#{cell}"].w
    if element.slice(0,lhm) is HORIZONTAL_MARK
      repcount = parseInt(element.slice(lhm))
      nextcell = cell
      elementarray = []
      for i in [0...repcount]
        nextcell = moveCell(nextcell,"right")
        elementarray.push(worksheet["#{nextcell}"].w)
      keymap[key] = elementarray
    else if element.slice(0,lvm) is VERTICAL_MARK
      repcount = parseInt(element.slice(lvm))
      nextcell = cell
      elementarray = []
      for i in [0...repcount]
        nextcell = moveCell(nextcell,"down")
        elementarray.push(worksheet["#{nextcell}"].w)
      keymap[key] = elementarray
    else if key isnt ''
      keymap[key] = worksheet["#{cell}"].w
    else if key is ''
      delete keymap[key]
  return keymap

exports.generateFile = (excelfile) ->
  out = exports.generate(excelfile)
  if out
    sheetnum = out[0]
    outputs = out[1]

    for i in [0...sheetnum]
      FileName = outputs[i][0]
      output = outputs[i][1]

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
    id = worksheet.A1.w

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

    # map keymap to excel
    keymap = mapKey(keymap, worksheet)

    template = fs.readFileSync(ejsfilename, 'utf8')
    output = ejs.render(template, keymap)

    outputs.push [keymap.FileName, output]

  return [sheetnum, outputs]

