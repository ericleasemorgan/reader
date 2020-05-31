# Distant Reader CORD

The Distant Reader CORD is a high performance computing (HPC) system which: 1) takes an almost arbitrary amount of unstructured data (text) as input and outputs a set of structured data for analysis, and 2) does this work against a specific data set called [CORD-19](https://www.semanticscholar.org/cord19). (Reader CORD is based on a different software suite called [Distant Reader Classic](https://github.com/ericleasemorgan/reader-classic) which is designed for more generic sets of input.)

To do this work, the Distant Reader CORD first caches the data set. It then transforms the content into a set of plain text files. Third, the Reader does text mining and natural language processing against the text files for the purpose of feature extraction: n-grams, parts-of-speech, named-entities, etc. The results of this process is a set of tab-delimited text files. The whole of the tab-delimited text files is then distilled into a relational database. A set of tabular and narrative reports is then generated against the database. The cache, transformed plain text files, tab-delimited files, relational database, and reports are then compressed ito a single (zip) file, and returned to the... reader. [1]

The returned file is affectionately called a "study carrel".  The student, researcher, or scholar is intended to peruse the study carrel for the purpose of supplementing the more traditional reading process. For more detail, links of possible interest include:

  * home page - https://cord.distantreader.org
  * fledgling study carrels - https://cord.distantreader.org/carrels/
  * blog postings - http://sites.nd.edu/emorgan/category/distant-reader/
  * Slack channel - http://bit.ly/distantreader-on-slack
  * Twitter feed - http://twitter.com/readerdistant

As an HPC, the Distant Reader CORD is not a single computer program but instead a suite of software comprised of many individual scripts and applications. Personally, I see the scripts and applications akin to collection of poems used to make the output of human expression more cogent. Really. Seroiusly.

As a collection of scripts and applications, the Distant Reader has only been built by "standing on the shoulders of giants". Cited [here](https://distantreader.org/software-reference/) in no particular order nor necessarily complete, they include these below and more:

   * the Perl-based LWP modules - this software is a significant part of harvesting process
   * Wget - an absolutely wonderful Internt spidering application
   * Tika - a Java-based library which transforms just about any file into plain text
   * Spacy - a Python module which simplifies natural language processing operations
   * Gensim - another Python module for natural language processing
   * Textacy - a Python module building on the good work of Spacey
   * SQLite - a cross-platform, SQL-compliant relational database library/application
   * OpenStack - a tool for building virtual machines
   * Slurm - a tool for instantiating a cluster of computer nodes and what runs on them
   * Airivata - a Web-based suite of software used to monitor computing jobs on a cluster
   * Other Python Libraries - sqlalchemy, pandas, itertools, wordcloud, scipy, sklearn, networkx, textatistic, nltk
   * Other Perl Modules - DBI, JSON, Archive::Zip, WebService::Solr, XML::XPath, CGI, File::Basename, File::Copy, HTML::Entities, HTML::Escape
   * Javascript Libraries - bootstap, jquery 
   * Other Programs - csvstack

If you have any questions, then please don't hesitate to ask.

"Happy reading!"

[1] Just like GNU, the Distant Reader's defintion is rather recursive

--- 
Eric Lease Morgan &lt;emorgan@nd.edu&gt;   
Navari Family Center for Digital Scholarship   
Hesburgh Libraries   
University of Notre Dame   
574/631-8604

Created: June 28, 2018   
Updated: May 31, 2020



