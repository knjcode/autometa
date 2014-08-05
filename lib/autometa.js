(function() {
  var ejs, fs, path, xls, xlsx;

  fs = require('fs');

  path = require('path');

  xlsx = require('xlsx');

  xls = require('xlsjs');

  ejs = require('ejs');

  exports.generateFile = function(excelfile) {
    var FileName, out, _ref;
    _ref = exports.generate(excelfile), FileName = _ref[0], out = _ref[1];
    fs.writeFileSync(FileName, out);
    console.log("Writing " + FileName);
    return console.log("Finish.");
  };

  exports.generate = function(excelfile) {
    var csvfile, csvfilename, data, ejsfilename, element, ext, i, id, key, keymap, out, rowData, sheet, template, workbook, worksheet, _i, _j, _len, _ref, _ref1;
    ext = path.extname(excelfile);
    if (ext === '.xlsx') {
      workbook = xlsx.readFile(excelfile);
    } else if (ext === '.xls') {
      workbook = xls.readFile(excelfile);
    } else {
      console.log("Error. Check input filename.");
      return;
    }
    _ref = workbook.SheetNames;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      sheet = _ref[_i];
      worksheet = workbook.Sheets[sheet];
      id = worksheet['A1'].w;
      csvfilename = './templates/' + id + '.csv';
      ejsfilename = './templates/' + id + '.ejs';
      csvfile = fs.readFileSync(csvfilename, 'utf8');
      keymap = [];
      rowData = csvfile.split(String.fromCharCode(10));
      for (i = _j = 0, _ref1 = rowData.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
        data = rowData[i].split(',');
        if (data[0] !== '') {
          keymap[data[0]] = data[1];
        }
      }
      for (key in keymap) {
        element = keymap[key];
        if (key !== '') {
          keymap[key] = worksheet["" + element].w;
        } else {
          delete keymap[key];
        }
      }
      template = fs.readFileSync(ejsfilename, 'utf8');
      out = ejs.render(template, keymap);
      return [keymap['FileName'], out];
    }
  };

}).call(this);
