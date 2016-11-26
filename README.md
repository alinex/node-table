Alinex Table: Readme
=================================================

[![GitHub watchers](
  https://img.shields.io/github/watchers/alinex/node-table.svg?style=social&label=Watch&maxAge=2592000)](
  https://github.com/alinex/node-table/subscription)
<!-- {.hidden-small} -->
[![GitHub stars](
  https://img.shields.io/github/stars/alinex/node-table.svg?style=social&label=Star&maxAge=2592000)](
  https://github.com/alinex/node-table)
[![GitHub forks](
  https://img.shields.io/github/forks/alinex/node-table.svg?style=social&label=Fork&maxAge=2592000)](
  https://github.com/alinex/node-table)
<!-- {.hidden-small} -->
<!-- {p:.right} -->

[![npm package](
  https://img.shields.io/npm/v/alinex-table.svg?maxAge=2592000&label=latest%20version)](
  https://www.npmjs.com/package/alinex-table)
[![latest version](
  https://img.shields.io/npm/l/alinex-table.svg?maxAge=2592000)](
  #license)
<!-- {.hidden-small} -->
[![Travis status](
  https://img.shields.io/travis/alinex/node-table.svg?maxAge=2592000&label=develop)](
  https://travis-ci.org/alinex/node-table)
[![Coveralls status](
  https://img.shields.io/coveralls/alinex/node-table.svg?maxAge=2592000)](
  https://coveralls.io/r/alinex/node-table?branch=master)
[![Gemnasium status](
  https://img.shields.io/gemnasium/alinex/node-table.svg?maxAge=2592000)](
  https://gemnasium.com/alinex/node-table)
[![GitHub issues](
  https://img.shields.io/github/issues/alinex/node-table.svg?maxAge=2592000)](
  https://github.com/alinex/node-table/issues)
<!-- {.hidden-small} -->


This package contains methods for working with table like data. It collects all
methods for working with such a data type:

- read and write at various positions
- convert from and to this data type
- rearranging everything with flip, filter, sort and more
- optimizing for display
- and export/dump as table

As a new data type you may also use it's methods on an instance or statically.

> It is one of the modules of the [Alinex Namespace](https://alinex.github.io/code.html)
> following the code standards defined in the [General Docs](https://alinex.github.io/develop).

__Read the complete documentation under
[https://alinex.github.io/node-table](https://alinex.github.io/node-table).__
<!-- {p: .hidden} -->


Install
-------------------------------------------------

[![NPM](https://nodei.co/npm/node-table.png?downloads=true&downloadRank=true&stars=true)
 ![Downloads](https://nodei.co/npm-dl/node-table.png?months=9&height=3)
](https://www.npmjs.com/package/node-table)

The easiest way is to let npm add the module directly to your modules
(from within you node modules directory):

``` sh
npm install alinex-table --save
```

And update it to the latest version later:

``` sh
npm update alinex-table --save
```

Always have a look at the latest [changes](Changelog.md).


Usage
-------------------------------------------------

To use these methods include the package first:

``` coffee
Table = require 'alinex-table'

example = [
  ['ID', 'Name']
  [1, 'one']
  [2, 'two']
  [3, 'three']
]
```

Then this module gives you a lot of methods with which you may work and manipulate
this table.

### Class vs Static

You may use both. As an instance each method will return the instance itself if no need
to return something else. So you may concatenate most calls.

You can call each method on an instance like:

``` coffee
table = new Table example
record = table.shift()
```

Or you may use them statically on your own data objects:

``` coffee
record = Table.shift example
```

The class oriented approach often is more readable if multiple manipulations on
the data object are done, specially if you use command concatenation.

To initialize a new Table instance from an existing RecordList use:

``` coffee
table = (new Table()).fromRecordList records
```

See the [supported data types](src/data.md) to see how such structures may look like.

Additionally as an one way conversion you may dump into a visible table using the
[report](http://alinex.github.io/node-report) package:

``` coffee
Report = require 'alinex-report'
report = new Report()
report.table example
console.log report.toString()
```

This will result in a markdown text displaying a table which can easily be
converted to ascii art using `toConsole()` or an html table using `toHtml()`.


Debugging
-------------------------------------------------
If you have any problems you may debug the code with the predefined flags. It uses
the debug module to let you define what to debug.

Call it with the DEBUG environment variable set:

``` bash
DEBUG=table <command>   # general information and checking schema
```

Additional value checking will be done if the debugging for `table` is enabled.


License
-------------------------------------------------

(C) Copyright 2016 Alexander Schilling

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

>  <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
