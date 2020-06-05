# Contributing to Distant Reader

We use the following online resources:

* The
  [GitHub Issues](https://github.com/ericleasemorgan/reader/projects/2?card_filter_query=label%3Acovid-19)
  in this project to track day-to-day tasks.
* The slack channel [distantreader.slack.com](). For an invitation email Eric Lease Morgan <emorgan@nd.edu>   

We have weekly meetings, open by invitation. Please reach out and we will be
happy to include you!

Our workflow is to create or choose an issue in the project's issue tracker.
Assign it to yourself, or leave a comment that you are interested in working on
it. You can then submit a pull request when you are done.

## Background information

The Distant Reader is a suite of repositories. This is the main repository
which provides all of the processing steps. The others handle auxiliary tasks
such as downloading the CORD-19 dataset or creating an index to all the public
carrels.See also

* https://github.com/ericleasemorgan/reader (this repository)
* https://github.com/ericleasemorgan/reader-carrels
* https://github.com/ericleasemorgan/cord-19

If you are trying to understand the reader, 
this is a [good description](https://github.com/ericleasemorgan/reader-workshop/blob/master/README.md)
of the Reader's goals and operation.

### Guide to This Repository

This repository is organized in the following directories:

* `bin/` - all the processing scripts
* `cgi-bin/` - not used
* `css/` - CSS files used by the created HTML files
* `etc/` - template files used to generate the reports, databases, and other output files in each study carrel
* `js/` - Javascript files used be the created HTML files
* `lib/` - Libraries used by the processing scripts

### Processing steps

Distant Reader takes a set of unstructured data as input and outputs a set of
structured data. You could think of it as a glorified back of the book index.
Each carrel is a structured dataset with all having the same structure.

Most of the processing is done using scripts in the `bin/` directory. All the
data in a study carrel is contained in a structured directory (see data
layout, below). The processing is done using the map/reduce paradigm. For the
most part, the map transforms each input file into an output file. And the
reduction step takes all the output files and puts them into a SQLite
database for further ad-hoc queries. After the reduction step a bunch of
reports and HTML pages are created. The website and exported study carrels
are all html files, and the exported carrels are completely self-contained
and don't require a server or network connection.

Key steps in the processing:

* The CORD19 source data is downloaded using the `build.sh` script in the
  companion repository
  [ericleasemorgan/cord-19](https://github.com/ericleasemorgan/cord-19). In the
  CORD19 project we create one big Study Carrel for the whole CORD19 data set.
  We can also create little subsets (for example a study carrel for each Kaggle
  question). This is currently hard-coded to download the following files
  - https://ai2-semanticscholar-cord-19.s3-us-west-2.amazonaws.com/latest/document_parses.tar.gz
  - https://ai2-semanticscholar-cord-19.s3-us-west-2.amazonaws.com/latest/metadata.csv
* bin/cord2carrel.sh - The main script
* bin/initialize-carrel.sh - Creates a study carrel directory structure
* [cord-19:bin/json2corpus.sh](https://github.com/ericleasemorgan/cord-19/blob/master/bin/json2corpus.sh)
  converts the source files (which are JSON documents for CORD19) into plain text
* bin/map.sh - Does the parallel jobs and synchronization
* bin/reduce.sh - Runs the reduction step
* bin/make-pages.sh - Creates the HTML reports
* [cord-19:bin/add-context.pl](https://github.com/ericleasemorgan/cord-19/blob/master/bin/add-context.pl) - handles the _context_ file, which contains human-entered metadata for the carrel

Other files of interest:

* [etc/reader.sql]() - The schema of the created SQLite database

### Data Model

Each study carrel is independent. The files in the exported zip file of a study
carrel are exactly the same as it is stored on disk and how a carrel the
scripts work with the carrel. The results of each processing step is stored in
specific subdirectories of a carrel. Some of the sub-directories are (see
`bin/initialize-carrel.sh` for complete list)

* `cache` - the original source material, with one file for each document or section
* `txt` - holds a plain text file derived from each source document
* `adr` - one TSV file for each document giving a list of addresses found in that document
* `ent` - one TSV file for each document giving a list of named entities extracted from that document
* `pos` - one TSV file for each document giving a list of parts of speech found in that document
* `urls` - one TSV file for each document giving a list of URLs found in that document

After the processing step, the following report directories are created

* `etc` - the generated reports
* `htm` - HTML versions of the generated reports
* `figures` - images generated to support the HTML files
* `css` - CSS to support the generated reports
