# activerecord-fast-import

Loads data from text files into tables using fast native MySQL [LOAD DATA INFILE](http://dev.mysql.com/doc/refman/5.1/en/load-data.html) query.

## Examples

### Loading data from tab delimited log file

Suppose you have an ActiveRecord model LogEntry defined as `LogEntry happened_at:datetime url:string` and a log file with tab delimited columns like this:

    2009-09-30 12:32:43<tab>http://github.com/
    2009-09-30 13:36:13<tab>http://facebook.com/

To import data from this log file, you have to use

    LogEntry.fast_import('huge.log')

That's it! 

Of course in real world you will also need more advanced features. Read on...


### Changing delimiters and ignoring some rows

Of course not all log files are delimited by tabs and newlines. Just pass custom delimiters to options. If you want to ignore first 10 lines, just use `:ignore_lines`

    import_options = {
        :fields_terminated_by => ',',
        :lines_terminated_by => ';',
        :ignore_lines => 10
    }

### Changing order of columns and ignoring columns

Now, imagine you want to import data from a huge log file with following format:

    http://github.com/<tab>Mozilla<tab>2009-09-30 12:32:43
    http://facebook.com/<tab>Opera<tab>2009-09-30 13:36:13

It is clear that columns are in different order and we even want to ignore the second column. Let's do it

    import_options = {:columns => ["url", "@dummy", "happened_at"]}
    LogEntry.fast_import('huge.log', import_options)

The special `@dummy` loads that column into a local variable and when unused (in a transformation) is just ignored.

### Transforming data

Now imagine we have a log file like this:

    2009-09-30 12:32:43<tab>http://github.com/<tab>image.jpg
    2009-09-30 13:36:13<tab>http://facebook.com/<tab>styles/default.css

We want to concatenate those two columns into one.

    import_options = {
        :columns => ["happened_at", "@domain", "@file"],
        :mapping => { :url => "CONCAT(@domain, @file)" }
    }
    LogEntry.fast_import('huge.log', import_options)

Of course you can use any of those shiny [MySQL functions](http://dev.mysql.com/doc/refman/5.1/en/functions.html).

## Copyright

Copyright (c) 2009 Jan Suchal. See LICENSE for details.
