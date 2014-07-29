fs = require 'fs'
ejs = require 'ejs'

console.log "Input filename:", process.argv[2]
file = process.argv[2]
console.log "options:", process.argv[3...process.argv.length]

data = {"name":"Kenji Doi", "age":"31"}

template = fs.readFileSync file, 'utf8'
out = ejs.render template, data 
console.log out

