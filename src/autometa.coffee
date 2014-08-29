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

# if AUTOMETA_TEMPLATES is set, add specified directories into TEMPLATES_DIRS
templates_dirs = process.env.AUTOMETA_TEMPLATES
if(templates_dirs)
  TEMPLATES_DIRS = templates_dirs.split(':').concat(TEMPLATES_DIRS)

# Directory of input file
file_dir = ''

# Template ID specified manually
specified_template_id = ''

readExcelFile = (excelfile) ->
  excelfile = path.resolve(excelfile)
  # read excelfile
  if fs.existsSync(excelfile)
    file_dir = excelfile
    ext = path.extname(excelfile)
    if ext is '.xlsx'
      workbook = xlsx.readFile(excelfile)
    else if ext is '.xls'
      workbook = xls.readFile(excelfile)
    else
      return false
  else
    file_dir = ''
    return false
  return workbook

registerTemplate = (template, filename) ->
  # copy template file to template path
  for template_dir in TEMPLATES_DIRS
    template_dir = path.resolve(template_dir)
    if fs.existsSync(template_dir)
      targetFile = path.join(template_dir,filename)
      fs.writeFileSync(targetFile, fs.readFileSync(template))
      console.log 'Register success: ' + filename + ' placed on ' + template_dir
      return true
  return false

exports.registerTemplates = (templates) ->
  for template in templates
    template = path.resolve(template)
    filename = path.basename(template)
    
    if fs.existsSync(template)
      ext = path.extname(template)
      if ext is '.csv' or ext is '.ejs'
        if not registerTemplate(template, filename)
          console.log 'Error. Can not write file.'
      else
        console.log 'Error. ' + filename + ' is not template.'
    else
      console.log 'Error. Input file does not exist.'

exports.setTemplateID = (template_id) ->
  if not specified_template_id
    specified_template_id = template_id
    return true
  return false

getTemplateFilePath = (id, ext) ->
  # Search input file directory
  filepath = path.resolve(file_dir, id + ext)
  if fs.existsSync(filepath)
    return filepath

  # Search TEMPLATE_DIRS
  for dir in TEMPLATES_DIRS
    filepath = path.resolve(dir, id + ext)
    if fs.existsSync(filepath)
      return filepath
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

  if not (0 <= cell.r < 1048576)
    return false
  if not (0 <= cell.c < 16384)
    return false

  return encodeCell(cell)

parseCsv = (csvfile) ->
  keymap = []
  rowData = csvfile.split(String.fromCharCode(10))
  for d in rowData
    data = d.split(',')
    if data.length == 2
      if data[0] isnt ''
        keymap[data[0]] = data[1]
    else if data.length == 3
      if data[0] isnt ''
        cell = { r:parseInt(data[1]), c:parseInt(data[2]) }
        keymap[data[0]] = encodeCell(cell)
  return keymap

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
        if nextcell
          elementarray.push(worksheet["#{nextcell}"].w)
        else
          return false
      keymap[key] = elementarray
    else if element.slice(0,lvm) is VERTICAL_MARK
      repcount = parseInt(element.slice(lvm))
      nextcell = cell
      elementarray = []
      for i in [0...repcount]
        nextcell = moveCell(nextcell,"down")
        if nextcell
          elementarray.push(worksheet["#{nextcell}"].w)
        else
          return false
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

    # set template ID
    if specified_template_id
      id = specified_template_id
    else
      id = worksheet.A1.w

    # make csv filename
    csvfilename = getTemplateFilePath(id, '.csv')
    if not csvfilename
      return false

    # make ejs file name
    ejsfilename = getTemplateFilePath(id, '.ejs')
    if not ejsfilename
      return false

    # read csv file
    csvfile = fs.readFileSync(csvfilename, 'utf8')

    # parse csv
    keymap = parseCsv(csvfile)

    # map keymap to excel
    keymap = mapKey(keymap, worksheet)
    if not keymap
      return false

    template = fs.readFileSync(ejsfilename, 'utf8')
    output = ejs.render(template, keymap)

    outputs.push [keymap.FileName, output]

  return [sheetnum, outputs]

