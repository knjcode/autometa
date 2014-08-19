(function() {
  var HORIZONTAL_MARK, TEMPLATES_DIRS, VERTICAL_MARK, decodeCell, decodeCol, decodeRow, ejs, encodeCell, encodeCol, encodeRow, fs, getCsvFilename, getEjsFilename, mapKey, moveCell, path, readExcelFile, registerCsv, registerEjs, splitCell, templates_dirs, xls, xlsx;

  fs = require('fs');

  path = require('path');

  xlsx = require('xlsx');

  xls = require('xlsjs');

  ejs = require('ejs');

  HORIZONTAL_MARK = '*';

  VERTICAL_MARK = '#';

  TEMPLATES_DIRS = ['./templates'];

  templates_dirs = process.env.NODE_AM_TEMPLATES;

  if (templates_dirs) {
    TEMPLATES_DIRS = templates_dirs.split(':').concat(TEMPLATES_DIRS);
  }

  readExcelFile = function(excelfile) {
    var ext, workbook;
    excelfile = path.resolve(excelfile);
    if (fs.existsSync(excelfile)) {
      ext = path.extname(excelfile);
      if (ext === '.xlsx') {
        workbook = xlsx.readFile(excelfile);
      } else if (ext === '.xls') {
        workbook = xls.readFile(excelfile);
      } else {
        return false;
      }
    } else {
      return false;
    }
    return workbook;
  };

  exports.registerTemplates = function(templates) {
    var ext, filename, template, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = templates.length; _i < _len; _i++) {
      template = templates[_i];
      template = path.resolve(template);
      filename = path.basename(template);
      console.log('Registering: ' + filename);
      if (fs.existsSync(template)) {
        ext = path.extname(template);
        console.log('Templates dir: ' + TEMPLATES_DIRS);
        if (ext === '.csv') {
          _results.push(console.log('register file is csv'));
        } else if (ext === '.ejs') {
          _results.push(console.log('register file is ejs'));
        } else {
          _results.push(console.log('Error. ' + filename + ' is not template'));
        }
      } else {
        _results.push(console.log('Input file does not exist'));
      }
    }
    return _results;
  };

  getCsvFilename = function(id) {
    var dir, filename, _i, _len;
    for (_i = 0, _len = TEMPLATES_DIRS.length; _i < _len; _i++) {
      dir = TEMPLATES_DIRS[_i];
      filename = path.resolve(dir, id + '.csv');
      if (fs.existsSync(filename)) {
        return filename;
      }
    }
    return false;
  };

  getEjsFilename = function(id) {
    var dir, filename, _i, _len;
    for (_i = 0, _len = TEMPLATES_DIRS.length; _i < _len; _i++) {
      dir = TEMPLATES_DIRS[_i];
      filename = path.resolve(dir, id + '.ejs');
      if (fs.existsSync(filename)) {
        return filename;
      }
    }
    return false;
  };

  registerCsv = function(csvfile) {
    return console.log('registerCsv');
  };

  registerEjs = function(ejsfile) {
    return console.log('registerEjs');
  };

  decodeRow = function(rowstr) {
    return parseInt(rowstr, 10) - 1;
  };

  encodeRow = function(row) {
    return "" + (row + 1);
  };

  decodeCol = function(colstr) {
    var d, i, _i, _ref;
    d = 0;
    for (i = _i = 0, _ref = colstr.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      d = 26 * d + colstr.charCodeAt(i) - 64;
    }
    return d - 1;
  };

  encodeCol = function(col) {
    var s;
    s = "";
    col += 1;
    while (col) {
      s = String.fromCharCode(((col - 1) % 26) + 65) + s;
      col = Math.floor((col - 1) / 26);
    }
    return s;
  };

  splitCell = function(cellstr) {
    return cellstr.replace(/(\$?[A-Z]*)(\$?\d*)/, "$1,$2").split(",");
  };

  decodeCell = function(cellstr) {
    var sp;
    sp = splitCell(cellstr);
    return {
      c: decodeCol(sp[0]),
      r: decodeRow(sp[1])
    };
  };

  encodeCell = function(cell) {
    return encodeCol(cell.c) + encodeRow(cell.r);
  };

  moveCell = function(cellstr, direction) {
    var cell;
    cell = decodeCell(cellstr);
    switch (direction) {
      case 'up':
        cell.r -= 1;
        break;
      case 'down':
        cell.r += 1;
        break;
      case 'left':
        cell.c -= 1;
        break;
      case 'right':
        cell.c += 1;
    }
    return encodeCell(cell);
  };

  mapKey = function(keymap, worksheet) {
    var cell, element, elementarray, i, key, lhm, lvm, nextcell, repcount, _i, _j;
    lhm = HORIZONTAL_MARK.length;
    lvm = VERTICAL_MARK.length;
    for (key in keymap) {
      cell = keymap[key];
      element = worksheet["" + cell].w;
      if (element.slice(0, lhm) === HORIZONTAL_MARK) {
        repcount = parseInt(element.slice(lhm));
        nextcell = cell;
        elementarray = [];
        for (i = _i = 0; 0 <= repcount ? _i < repcount : _i > repcount; i = 0 <= repcount ? ++_i : --_i) {
          nextcell = moveCell(nextcell, "right");
          elementarray.push(worksheet["" + nextcell].w);
        }
        keymap[key] = elementarray;
      } else if (element.slice(0, lvm) === VERTICAL_MARK) {
        repcount = parseInt(element.slice(lvm));
        nextcell = cell;
        elementarray = [];
        for (i = _j = 0; 0 <= repcount ? _j < repcount : _j > repcount; i = 0 <= repcount ? ++_j : --_j) {
          nextcell = moveCell(nextcell, "down");
          elementarray.push(worksheet["" + nextcell].w);
        }
        keymap[key] = elementarray;
      } else if (key !== '') {
        keymap[key] = worksheet["" + cell].w;
      } else if (key === '') {
        delete keymap[key];
      }
    }
    return keymap;
  };

  exports.generateFile = function(excelfile) {
    var FileName, i, out, output, outputs, sheetnum, _i;
    out = exports.generate(excelfile);
    if (out) {
      sheetnum = out[0];
      outputs = out[1];
      for (i = _i = 0; 0 <= sheetnum ? _i < sheetnum : _i > sheetnum; i = 0 <= sheetnum ? ++_i : --_i) {
        FileName = outputs[i][0];
        output = outputs[i][1];
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
    var csvfile, csvfilename, data, ejsfilename, i, id, keymap, output, outputs, rowData, sheet, sheetnum, template, workbook, worksheet, _i, _j, _len, _ref, _ref1;
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
      id = worksheet.A1.w;
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
      keymap = mapKey(keymap, worksheet);
      template = fs.readFileSync(ejsfilename, 'utf8');
      output = ejs.render(template, keymap);
      outputs.push([keymap.FileName, output]);
    }
    return [sheetnum, outputs];
  };

}).call(this);
