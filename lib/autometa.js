(function() {
  var ejs, fs, getCsvFilename, getEjsFilename, path, readExcelFile, xls, xlsx;

  fs = require('fs');

  path = require('path');

  xlsx = require('xlsx');

  xls = require('xlsjs');

  ejs = require('ejs');

  readExcelFile = function(excelfile) {
    var ext, workbook;
    ext = path.extname(excelfile);
    if (fs.existsSync(excelfile)) {
      if (ext === '.xlsx') {
        workbook = xlsx.readFile(excelfile);
      } else if (ext === '.xls') {
        workbook = xls.readFile(excelfile);
      } else {
        retur(false);
      }
    } else {
      return false;
    }
    return workbook;
  };

  getCsvFilename = function(id) {
    var filename;
    filename = './templates/' + id + '.csv';
    if (!fs.existsSync(filename)) {
      return false;
    }
    return filename;
  };

  getEjsFilename = function(id) {
    var filename;
    filename = './templates/' + id + '.ejs';
    if (!fs.existsSync(filename)) {
      return false;
    }
    return filename;
  };

  exports.generateFile = function(excelfile) {
    var FileName, i, out, output, outputs, sheetnum, _i, _ref;
    if (out = exports.generate(excelfile)) {
      sheetnum = out[0];
      outputs = out[1];
      for (i = _i = 0; 0 <= sheetnum ? _i < sheetnum : _i > sheetnum; i = 0 <= sheetnum ? ++_i : --_i) {
        _ref = outputs[i], FileName = _ref[0], output = _ref[1];
        fs.writeFileSync(FileName, output);
        console.log("Writing " + FileName);
        console.log("Finish.");
      }
      return true;
    } else {
      return false;
    }
  };

  exports.generate = function(excelfile) {
    var csvfile, csvfilename, data, ejsfilename, element, i, id, key, keymap, output, outputs, rowData, sheet, sheetnum, template, workbook, worksheet, _i, _j, _len, _ref, _ref1;
    workbook = readExcelFile(excelfile);
    if (!workbook) {
      return false;
    }
    sheetnum = workbook.SheetNames.length;
    outputs = [];
    _ref = workbook.SheetNames;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      sheet = _ref[_i];
      worksheet = workbook.Sheets[sheet];
      id = worksheet['A1'].w;
      csvfilename = getCsvFilename(id);
      if (!csvfilename) {
        return false;
      }
      ejsfilename = getEjsFilename(id);
      if (!ejsfilename) {
        return false;
      }
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
      output = ejs.render(template, keymap);
      outputs.push([keymap['FileName'], output]);
    }
    return [sheetnum, outputs];
  };

}).call(this);
