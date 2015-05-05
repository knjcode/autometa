(function() {
  var HORIZONTAL_MARK, TEMPLATES_DIRS, VERTICAL_MARK, decodeCell, decodeCol, decodeRow, ect, ejs, encodeCell, encodeCol, encodeRow, file_dir, fs, getTemplateFilePath, mapKey, moveCell, parseCsv, path, readExcelFile, readlineSync, registerTemplate, specified_template_id, splitCell, templates_dirs, valid, xls, xlsx;

  fs = require('fs');

  path = require('path');

  readlineSync = require('readline-sync');

  xlsx = require('xlsx');

  xls = require('xlsjs');

  ejs = require('ejs');

  ect = require('ect');

  HORIZONTAL_MARK = '*';

  VERTICAL_MARK = '#';

  TEMPLATES_DIRS = [path.resolve(__dirname, '../templates')];

  templates_dirs = process.env.AUTOMETA_TEMPLATES;

  if (templates_dirs) {
    TEMPLATES_DIRS = templates_dirs.split(':').concat(TEMPLATES_DIRS);
  }

  valid = {
    "yes": true,
    "y": true,
    "YES": true,
    "Y": true,
    "no": false,
    "n": false,
    "NO": false,
    "N": false
  };

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

  registerTemplate = function(template, filename, overwrite) {
    var answer, basename, err, j, len, targetFile, template_dir;
    for (j = 0, len = TEMPLATES_DIRS.length; j < len; j++) {
      template_dir = TEMPLATES_DIRS[j];
      template_dir = path.resolve(template_dir);
      if (fs.existsSync(template_dir)) {
        targetFile = path.join(template_dir, filename);
        basename = path.basename(targetFile);
        console.log("Writing " + targetFile);
        try {
          if (fs.existsSync(targetFile)) {
            if (!overwrite) {
              console.error('Error. ' + basename + ' already exists.');
              answer = readlineSync.question('overwrite? [y/n] ');
              if (!valid[answer]) {
                return false;
              }
            }
          }
          fs.writeFileSync(targetFile, fs.readFileSync(template));
        } catch (_error) {
          err = _error;
          return false;
        }
        console.log('Register success: ' + filename + ' placed on ' + template_dir);
        return true;
      }
    }
    return false;
  };

  exports.registerTemplates = function(templates, overwrite) {
    var ext, filename, j, len, results, template;
    results = [];
    for (j = 0, len = templates.length; j < len; j++) {
      template = templates[j];
      template = path.resolve(template);
      filename = path.basename(template);
      if (fs.existsSync(template)) {
        ext = path.extname(template);
        if ((ext === '.csv') || (ext === '.ejs') || (ext === '.ect')) {
          if (!registerTemplate(template, filename, overwrite)) {
            results.push(console.error('Failed to generate file.'));
          } else {
            results.push(void 0);
          }
        } else {
          results.push(console.error('Error. ' + filename + ' is not template.'));
        }
      } else {
        results.push(console.error('Error. Input file does not exist.'));
      }
    }
    return results;
  };

  exports.getTemplatesDirs = function() {
    return TEMPLATES_DIRS;
  };

  exports.setTemplateID = function(template_id) {
    if (!specified_template_id) {
      specified_template_id = template_id;
      return true;
    }
    return false;
  };

  getTemplateFilePath = function(id, ext) {
    var dir, filepath, j, len;
    filepath = path.resolve(file_dir, id + ext);
    if (fs.existsSync(filepath)) {
      return filepath;
    }
    for (j = 0, len = TEMPLATES_DIRS.length; j < len; j++) {
      dir = TEMPLATES_DIRS[j];
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
    var d, i, j, ref;
    d = 0;
    for (i = j = 0, ref = colstr.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
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
    var cell, ref, ref1;
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
    if (!((0 <= (ref = cell.r) && ref < 1048576))) {
      return false;
    }
    if (!((0 <= (ref1 = cell.c) && ref1 < 16384))) {
      return false;
    }
    return encodeCell(cell);
  };

  parseCsv = function(csvfile) {
    var cell, d, data, j, keymap, len, rowData;
    keymap = [];
    rowData = csvfile.split(String.fromCharCode(10));
    for (j = 0, len = rowData.length; j < len; j++) {
      d = rowData[j];
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
    var cell, element, elementarray, i, j, k, key, lhm, lvm, nextcell, ref, ref1, repcount;
    lhm = HORIZONTAL_MARK.length;
    lvm = VERTICAL_MARK.length;
    for (key in keymap) {
      cell = keymap[key];
      element = worksheet["" + cell].w;
      if (element.slice(0, lhm) === HORIZONTAL_MARK) {
        repcount = parseInt(element.slice(lhm));
        nextcell = cell;
        elementarray = [];
        for (i = j = 0, ref = repcount; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
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
        for (i = k = 0, ref1 = repcount; 0 <= ref1 ? k < ref1 : k > ref1; i = 0 <= ref1 ? ++k : --k) {
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

  exports.generateFile = function(excelfile, filename, overwrite) {
    var FileName, answer, basename, err, i, j, out, output, outputs, ref, sheetnum;
    out = exports.generate(excelfile);
    if (out) {
      sheetnum = out[0];
      outputs = out[1];
      if (filename) {
        if ((filename === "/dev/stdout") || (filename === "-")) {
          process.stdout.write(outputs[0][1]);
        } else {
          filename = path.resolve(filename);
          basename = path.basename(filename);
          console.log("Writing " + filename);
          try {
            if (fs.existsSync(filename)) {
              if (!overwrite) {
                console.error('Error. ' + basename + ' already exists.');
                answer = readlineSync.question('overwrite? [y/n] ');
                if (!valid[answer]) {
                  return false;
                }
              }
            }
            fs.writeFileSync(filename, outputs[0][1]);
          } catch (_error) {
            err = _error;
            return false;
          }
          console.log("Finish.");
        }
        return true;
      }
      for (i = j = 0, ref = sheetnum; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        FileName = outputs[i][0];
        output = outputs[i][1];
        FileName = path.resolve(FileName);
        basename = path.basename(FileName);
        console.log("Writing " + FileName);
        try {
          if (fs.existsSync(FileName)) {
            if (!overwrite) {
              console.error('Error. ' + basename + ' already exists.');
              answer = readlineSync.question('overwrite? [y/n] ');
              if (!valid[answer]) {
                continue;
              }
            }
          }
          fs.writeFileSync(FileName, output);
        } catch (_error) {
          err = _error;
          return false;
        }
        console.log("Finish.");
      }
      return true;
    } else {
      return false;
    }
  };

  exports.generate = function(excelfile) {
    var csvfile, csvfilename, ext, id, j, keymap, len, output, outputs, ref, renderer, sheet, sheetnum, template, tmplfilename, workbook, worksheet;
    workbook = readExcelFile(excelfile);
    if (!workbook) {
      return false;
    }
    sheetnum = workbook.SheetNames.length;
    outputs = [];
    ref = workbook.SheetNames;
    for (j = 0, len = ref.length; j < len; j++) {
      sheet = ref[j];
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
      tmplfilename = getTemplateFilePath(id, '.ejs');
      if (!tmplfilename) {
        tmplfilename = getTemplateFilePath(id, '.ect');
        if (!tmplfilename) {
          return false;
        }
      }
      csvfile = fs.readFileSync(csvfilename, 'utf8');
      keymap = parseCsv(csvfile);
      keymap = mapKey(keymap, worksheet);
      if (!keymap) {
        return false;
      }
      ext = path.extname(tmplfilename);
      if (ext === '.ejs') {
        template = fs.readFileSync(tmplfilename, 'utf8');
        output = ejs.render(template, keymap);
      } else if (ext === '.ect') {
        renderer = ect({
          root: path.dirname(tmplfilename),
          ext: '.ect'
        });
        output = renderer.render(path.basename(tmplfilename), keymap);
      } else {
        return false;
      }
      outputs.push([keymap.FileName, output]);
    }
    return [sheetnum, outputs];
  };

}).call(this);
