# autometa [![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url]

Generate various data from Excel spreadsheets.

## Overview

![overview](images/overview.png)

1. Extract "A1" cell value as "Template ID" from each Excel worksheet
2. Extract all cells value according to [Template ID].csv
3. Embed these values into [Template ID].ejs
4. Save as FileName specified in Excel worksheet

## Installation

via [npm (node package manager)](http://github.com/isaacs/npm)

    $ npm install -g autometa

## Example

Generate test-note.xml from note-example.xlsx as mentioned in overview above.

    $ autometa note-example.xlsx

## Usage manual

    $ autometa -h
      Usage: autometa [options] <Excel spreadsheet>
      
      Options:
      
        -h, --help     output usage information
        -v, --version  output the version number
        -o, --stdout   place output on stdout

## License

Copyright &copy; 2014 [Kenji Doi (knjcode)](https://github.com/knjcode)  
Licensed under the [Apache License, Version 2.0][Apache]

[npm-url]: https://npmjs.org/package/autometa
[npm-image]: https://badge.fury.io/js/autometa.svg
[travis-url]: https://travis-ci.org/knjcode/autometa
[travis-image]: https://travis-ci.org/knjcode/autometa.svg?branch=master
[Apache]: http://www.apache.org/licenses/LICENSE-2.0
