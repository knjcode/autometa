(function() {
  var ejs, fs, path, xls, xlsx;

  fs = require('fs');

  path = require('path');

  xlsx = require('xlsx');

  xls = require('xlsjs');

  ejs = require('ejs');

  exports.generate = function(excelfile) {
    var csvfile, csvfilename, data, ejsfilename, element, ext, i, id, key, keymap, out, rowData, sheet, template, workbook, worksheet, _i, _j, _len, _ref, _ref1;
    console.log("Input excel filename:", excelfile);
    ext = path.extname(excelfile);
    console.log("extname:", ext);
    if (ext === '.xlsx') {
      workbook = xlsx.readFile(excelfile);
    } else if (ext === '.xls') {
      workbook = xls.readFile(excelfile);
    } else {
      console.log("error. check input filename.");
      return;
    }
    _ref = workbook.SheetNames;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      sheet = _ref[_i];
      console.log("SheetName: " + sheet);
      worksheet = workbook.Sheets[sheet];
      id = worksheet['A1'].w;
      console.log("TemplateID: " + id);
      csvfilename = './' + id + '.csv';
      console.log("CSV FileName: " + csvfilename);
      ejsfilename = './' + id + '.ejs';
      console.log("EJS FileName: " + ejsfilename);
      csvfile = fs.readFileSync(csvfilename, 'utf8');
      keymap = [];
      rowData = csvfile.split(String.fromCharCode(10));
      for (i = _j = 0, _ref1 = rowData.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
        data = rowData[i].split(',');
        if (data[0] !== '') {
          keymap[data[0]] = data[1];
        }
      }
      console.log("KeyMap:");
      console.log(keymap);
      for (key in keymap) {
        element = keymap[key];
        if (key !== '') {
          keymap[key] = worksheet["" + element].w;
        } else {
          delete keymap[key];
        }
      }
      console.log("ExcelMappedKeyMap:");
      console.log(keymap);
      template = fs.readFileSync(ejsfilename, 'utf8');
      out = ejs.render(template, keymap);
      console.log("Output:");
      console.log(out);
    }
    return console.log("end.");
  };

}).call(this);
