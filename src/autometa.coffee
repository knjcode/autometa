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
  TEMPLATES_DIRS = TEMPLATES_DIRS.concat(templates_dirs.split(':'))


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

exports.registerCsv = (csvfile) ->
  console.log 'registerCsv'
  # WIP

exports.registerEjs = (ejsfile) ->
  console.log 'registerEjs'
  # WIP

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

    # map keymap to excel
    keymap = mapKey(keymap, worksheet)

    template = fs.readFileSync(ejsfilename, 'utf8')
    output = ejs.render(template, keymap)

    outputs.push [keymap['FileName'], output]

  return [sheetnum, outputs]

