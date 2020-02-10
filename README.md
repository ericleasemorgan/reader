# Distant Reader

The Distant Reader is a high performance computing (HPC) system which takes an almost arbitrary amount of unstdructured data (text) as input and outputs a set of structured data for analysis -- "reading".

As an HPC, the Distant Reader is not a single computer program but instead a suite of softare comprised of many individual scripts and applications. Personally, I see the scripts and applications akin to collection of poems expressing aspects of the human condition. Really. Seroiusly.

As a collection of scripts and applications, the Distant Reader has only been built by "standing on the shoulders of giants". Listed in no particular order nor necessarily complete, they include:

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

The suite of software making up the Distant Reader takes one of five different types of input:

   1. A URL
   2. A file which is comprised of a list of URLs
   3. A file
   4. A compressed (zip) file made up of many other files
   5. A compressed file with an additional metadata file
   
Given one or another of the possible inputs, the Distant Reader first caches the original content. It then transforms the content into a set of plain text files. Third, the Reader does text mining and natural language processing against the text files for the purpose of feature extraction: n-grams, parts-of-speech, named-entities, etc. The results of this process is a set of tab-delimited text files. The whole of the tab-delimited text files is then distilled into a relational database. A set of tabular and narrative reports is then generated against the database. The cache, transformed plain text files, tab-delimited files, relational database, and reports are then compressed ito a single (zip) file, and returned to the... reader. The returned file is affectionately called a "study carrel".  The student, researcher, or scholar is intended to peruse the study carrel for the purpose of supplementing the more traditional reading process.

For more detail, links of possible interest include:

  * home page - https://distantreader.org
  * "study carrels" - http://carrels.distantreader.org
  * blog postings - http://sites.nd.edu/emorgan/category/distant-reader/
  * Slack channel - http://bit.ly/distantreader-slack
  * Twitter feed - http://twitter.com/readerdistant

If you have any questions, then please don't hesitate to ask.

"Happy reading!"

--- 
Eric Lease Morgan &lt;emorgan@nd.edu&gt;   
Navari Family Center for Digital Scholarship   
Hesburgh Libraries   
University of Notre Dame   

574/631-8604



[1] Just like GNU, the Distant Reader's defintion is rather recursive