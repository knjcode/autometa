(function() {
  var HORIZONTAL_MARK, TEMPLATES_DIRS, VERTICAL_MARK, decodeCell, decodeCol, decodeRow, ejs, encodeCell, encodeCol, encodeRow, file_dir, fs, getTemplateFilePath, mapKey, moveCell, parseCsv, path, readExcelFile, registerTemplate, specified_template_id, splitCell, templates_dirs, xls, xlsx;

  fs = require('fs');

  path = require('path');

  xlsx = require('xlsx');

  xls = require('xlsjs');

  ejs = require('ejs');

  HORIZONTAL_MARK = '*';

  VERTICAL_MARK = '#';

  TEMPLATES_DIRS = ['./templates'];

  templates_dirs = process.env.AUTOMETA_TEMPLATES;

  if (templates_dirs) {
    TEMPLATES_DIRS = templates_dirs.split(':').concat(TEMPLATES_DIRS);
  }

  file_dir = '';

  specified_template_id = '';

  readExcelFile = function(excelfile) {
    var ext, workbook;
    excelfile = path.resolve(excelfile);
    if (fs.existsSync(excelfile)) {
      file_dir = excelfile;
      ext = path.extname(excelfile);
      ext = ext.toLowerCase();
      switch (ext) {
        case '.xlsx':
        case '.xlsm':
        case '.xlsb':
          workbook = xlsx.readFile(excelfile);
          break;
        case '.xls':
          workbook = xls.readFile(excelfile);
          break;
        default:
          return false;
      }
    } else {
      file_dir = '';
      return false;
    }
    return workbook;
  };

  registerTemplate = function(template, filename) {
    var targetFile, template_dir, _i, _len;
    for (_i = 0, _len = TEMPLATES_DIRS.length; _i < _len; _i++) {
      template_dir = TEMPLATES_DIRS[_i];
      template_dir = path.resolve(template_dir);
      if (fs.existsSync(template_dir)) {
        targetFile = path.join(template_dir, filename);
        fs.writeFileSync(targetFile, fs.readFileSync(template));
        console.log('Register success: ' + filename + ' placed on ' + template_dir);
        return true;
      }
    }
    return false;
  };

  exports.registerTemplates = function(templates) {
    var ext, filename, template, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = templates.length; _i < _len; _i++) {
      template = templates[_i];
      template = path.resolve(template);
      filename = path.basename(template);
      if (fs.existsSync(template)) {
        ext = path.extname(template);
        if (ext === '.csv' || ext === '.ejs') {
          if (!registerTemplate(template, filename)) {
            _results.push(console.log('Error. Can not write file.'));
          } else {
            _results.push(void 0);
          }
        } else {
          _results.push(console.log('Error. ' + filename + ' is not template.'));
        }
      } else {
        _results.push(console.log('Error. Input file does not exist.'));
      }
    }
    return _results;
  };

  exports.setTemplateID = function(template_id) {
    if (!specified_template_id) {
      specified_template_id = template_id;
      return true;
    }
    return false;
  };

  getTemplateFilePath = function(id, ext) {
    var dir, filepath, _i, _len;
    filepath = path.resolve(file_dir, id + ext);
    if (fs.existsSync(filepath)) {
      return filepath;
    }
    for (_i = 0, _len = TEMPLATES_DIRS.length; _i < _len; _i++) {
      dir = TEMPLATES_DIRS[_i];
      filepath = path.resolve(dir, id + ext);
      if (fs.existsSync(filepath)) {
        return filepath;
      }
    }
    return false;
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
    var cell, _ref, _ref1;
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
    if (!((0 <= (_ref = cell.r) && _ref < 1048576))) {
      return false;
    }
    if (!((0 <= (_ref1 = cell.c) && _ref1 < 16384))) {
      return false;
    }
    return encodeCell(cell);
  };

  parseCsv = function(csvfile) {
    var cell, d, data, keymap, rowData, _i, _len;
    keymap = [];
    rowData = csvfile.split(String.fromCharCode(10));
    for (_i = 0, _len = rowData.length; _i < _len; _i++) {
      d = rowData[_i];
      data = d.split(',');
      if (data.length === 2) {
        if (data[0] !== '') {
          keymap[data[0]] = data[1];
        }
      } else if (data.length === 3) {
        if (data[0] !== '') {
          cell = {
            r: parseInt(data[1]),
            c: parseInt(data[2])
          };
          keymap[data[0]] = encodeCell(cell);
        }
      }
    }
    return keymap;
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
          if (nextcell) {
            elementarray.push(worksheet["" + nextcell].w);
          } else {
            return false;
          }
        }
        keymap[key] = elementarray;
      } else if (element.slice(0, lvm) === VERTICAL_MARK) {
        repcount = parseInt(element.slice(lvm));
        nextcell = cell;
        elementarray = [];
        for (i = _j = 0; 0 <= repcount ? _j < repcount : _j > repcount; i = 0 <= repcount ? ++_j : --_j) {
          nextcell = moveCell(nextcell, "down");
          if (nextcell) {
            elementarray.push(worksheet["" + nextcell].w);
          } else {
            return false;
          }
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
    var csvfile, csvfilename, ejsfilename, id, keymap, output, outputs, sheet, sheetnum, template, workbook, worksheet, _i, _len, _ref;
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
      if (specified_template_id) {
        id = specified_template_id;
      } else {
        id = worksheet.A1.w;
      }
      csvfilename = getTemplateFilePath(id, '.csv');
      if (!csvfilename) {
        return false;
      }
      ejsfilename = getTemplateFilePath(id, '.ejs');
      if (!ejsfilename) {
        return false;
      }
      csvfile = fs.readFileSync(csvfilename, 'utf8');
      keymap = parseCsv(csvfile);
      keymap = mapKey(keymap, worksheet);
      if (!keymap) {
        return false;
      }
      template = fs.readFileSync(ejsfilename, 'utf8');
      output = ejs.render(template, keymap);
      outputs.push([keymap.FileName, output]);
    }
    return [sheetnum, outputs];
  };

}).call(this);
