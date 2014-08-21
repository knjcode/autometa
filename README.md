# autometa [![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url]

Generate various data from Excel spreadsheet.

## Overview

![overview](images/overview.png)

1. Extract "A1" cell value as "Template ID" from each Excel worksheet
2. Extract all cells value according to [Template ID].csv
3. Embed these values into [Template ID].ejs
4. Save as FileName specified in Excel worksheet

## Installation

via [npm (node package manager)](http://github.com/isaacs/npm)

    $ npm install -g autometa

## Examples

### Basic example

Generate test-note.xml from note-example.xlsx as mentioned in overview above.

    $ autometa note-example.xlsx

### Horizontal repetitive elements example

Generate data from Excel spreadsheet includes element repeated horizontally.

    $ autometa test-repeat.xlsx

test-repeat.xlsx

![test-repeat.xlsx](images/test-repeat.png)

templates/catalog.csv

    FileName,B2
    Title,B3
    Artist,B4
    Country,B5
    Company,B6
    Price,B7
    Year,B8

templates/catalog.ejs

    <CATALOG>
    <% for (i=0; i<Title.length; i++) { -%>
      <CD>
        <TITLE><%- Title[i] %></TITLE>
        <ARTIST><%- Artist[i] %></ARTIST>
        <COUNTRY><%- Country[i] %></COUNTRY>
        <COMPANY><%- Company[i] %></COMPANY>
        <PRICE><%- Price[i] %></PRICE>
        <YEAR><%- Year[i] %></YEAR>
      </CD>
    <% } -%>
    </CATALOG>

### Vertical repetitive elements example

Generate data from Excel spreadsheet includes element repeated vertically.

test-repeat2.xlsx

![test-repeat2.xlsx](images/test-repeat2.png)

templates/catalog-v.csv

    FileName,A2
    Title,A4
    Artist,B4
    Country,C4
    Company,D4
    Price,E4
    Year,F4

templates/catalog-v.ejs (same as catalog.ejs)

    <CATALOG>
    <% for (i=0; i<Title.length; i++) { -%>
      <CD>
        <TITLE><%- Title[i] %></TITLE>
        <ARTIST><%- Artist[i] %></ARTIST>
        <COUNTRY><%- Country[i] %></COUNTRY>
        <COMPANY><%- Company[i] %></COMPANY>
        <PRICE><%- Price[i] %></PRICE>
        <YEAR><%- Year[i] %></YEAR>
      </CD>
    <% } -%>
    </CATALOG>

## Horizontal and vertical repetitive elements

Of course, you can generate data from Excel spreadsheet includes elements repeated horizontally and vertically.

## Multiple worksheets

You can generate data from each worksheet of Excel spreadsheet.

## Templates directory

If you want to change templates directory, set AUTOMETA_TEMPLATES environment variable.

    $ export AUTOMETA_TEMPLATES="/path/to/your/templates"

## Original Templates

If you want to define original templates, create [Template ID].csv, [Template ID].ejs and place these on templates directory. 

    $ autometa -r [Template ID].ejs
    $ Register success: [Template ID].ejs placed on [templates direcotry]

## Usage manual

    $ autometa -h
      Usage: autometa [options] <Excel spreadsheet>

      Options:

        -h, --help                      output usage information
        -v, --version                   output the version number
        -o, --stdout                    place output on stdout
        -r, --register <template file>  register templates
    
    Environment variable:
    AUTOMETA_TEMPLATES         Set ':'-separeted list of directories,
                               if you want to change templates directory.

## Dependencies

commander, ect, ejs, xlsjs, xlsx

## References

Example data in reference to [XML Examples]

## License

Copyright &copy; 2014 [Kenji Doi (knjcode)](https://github.com/knjcode)  
Licensed under the [Apache License, Version 2.0][Apache]

[npm-url]: https://npmjs.org/package/autometa
[npm-image]: https://badge.fury.io/js/autometa.svg
[travis-url]: https://travis-ci.org/knjcode/autometa
[travis-image]: https://travis-ci.org/knjcode/autometa.svg?branch=master
[Apache]: http://www.apache.org/licenses/LICENSE-2.0
[XML Examples]: http://www.w3schools.com/xml/xml_examples.asp

