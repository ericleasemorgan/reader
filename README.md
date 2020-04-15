# Distant Reader

The Distant Reader is a high performance computing (HPC) system which takes an almost arbitrary amount of unstructured data (text) as input and outputs a set of structured data for analysis -- "reading".

As an HPC, the Distant Reader is not a single computer program but instead a suite of software comprised of many individual scripts and applications. Personally, I see the scripts and applications akin to collection of poems used to make the output of human expression more cogent. Really. Seroiusly.

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

The Distant Reader takes one of five different types of input:

   1. a URL - good for blogs, single journal articles, or long reports
   2. a list of URLs - the most scalable, but creating the list can be problematic
   3. a file - good for that long PDF document on your computer
   4. a zip file - the zip file can contain just about any number of files from your computer
   5. a zip file plus a metadata file - with the metadata file, the reader’s analysis is more complete
   
Given one or another of the possible inputs, the Distant Reader first caches the original content. It then transforms the content into a set of plain text files. Third, the Reader does text mining and natural language processing against the text files for the purpose of feature extraction: n-grams, parts-of-speech, named-entities, etc. The results of this process is a set of tab-delimited text files. The whole of the tab-delimited text files is then distilled into a relational database. A set of tabular and narrative reports is then generated against the database. The cache, transformed plain text files, tab-delimited files, relational database, and reports are then compressed ito a single (zip) file, and returned to the... reader. [1]

The returned file is affectionately called a "study carrel".  The student, researcher, or scholar is intended to peruse the study carrel for the purpose of supplementing the more traditional reading process. Use cases include:

   * the undergraduate student who needs to read everything for Sociology 101
   * the Ph.D. student who needs to understand the totality of their dissertation's bibliography
   * the scientist who is doing a literature review
   * the humanist who is studying all the works of a given genre

For more detail, links of possible interest include:

  * home page - https://distantreader.org
  * "study carrels" - http://carrels.distantreader.org
  * blog postings - http://sites.nd.edu/emorgan/category/distant-reader/
  * Slack channel - http://bit.ly/distantreader-slack
  * Twitter feed - http://twitter.com/readerdistant

If you have any questions, then please don't hesitate to ask.

"Happy reading!"

[1] Just like GNU, the Distant Reader's defintion is rather recursive

--- 
Eric Lease Morgan &lt;emorgan@nd.edu&gt;   
Navari Family Center for Digital Scholarship   
Hesburgh Libraries   
University of Notre Dame   
574/631-8604

February 9, 2020




