# autometa [![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url]

Generate various data from Excel spreadsheets.

## Overview

![overview](images/overview.png)

1. Extract 'A1' cell value as Template ID from each Excel worksheet
2. Extract cell values according to [Template ID].csv
3. Embed those values into [Template ID].ejs
4. Save as FileName specified in Excel worksheet

## Installation

via [npm (node package manager)](http://github.com/isaacs/npm)

    $ npm install -g autometa

## Usage manual

    $ autometa -h
      Usage: autometa [options] <Excel spreadsheet>
      
      Options:
      
        -h, --help     output usage information
        -v, --version  output the version number
        -o, --stdout   place output on stdout

## Author

[knjcode](https://github.com/knjcode)

[npm-url]: https://npmjs.org/package/autometa
[npm-image]: https://badge.fury.io/js/autometa.svg
[travis-url]: https://travis-ci.org/knjcode/autometa
[travis-image]: https://travis-ci.org/knjcode/autometa.svg?branch=master
