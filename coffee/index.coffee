fs = require 'fs'
xlsx = require 'xlsx'
ejs = require 'ejs'

console.log "Input excel filename:", process.argv[2]
excelfile = process.argv[2]
console.log "options:", process.argv[3...process.argv.length]

workbook = xlsx.readFile(excelfile)
console.log workbook.SheetNames
for sheet in workbook.SheetNames
  console.log sheet
  console.log JSON.stringify workbook.Sheets[sheet]
return

data = {"name":"Kenji Doi", "age":"31"}

template = fs.readFileSync file, 'utf8'
out = ejs.render template, data 
console.log out

