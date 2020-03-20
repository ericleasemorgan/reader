# covid-19

This suite of software will prepare a dataset called "[CORD-19](https://pages.semanticscholar.org/coronavirus-research)" for processing with the [Distant Reader](https://distantreader.org).

CORD-19 is a set of more than 13,000 full text scholarly journal articles surrounding the topic of the COVID-19 pandemic. Each "article" is really a JSON file containing (very) rudimentary bibliographic information, a set of paragraphs, and bibliographic citations. This suite processes the JSON files to extract their identifier, author, title, full text, much of their citations. The whole lot is then zipped up -- along with a metadata file -- and submitted to the Distant Reader for analysis.

To get this software to work for you, then:

   1. clone this repository
   2. download the four full text data sets: 1) Commercial use subset, 2) Non-commercial use subset, 3) PMC custom license subset, and 4) bioRxiv/medRxiv subset
   3. create a directory called "json"
   4. uncompress each dataset and move the newly created directories to the json directory
   5. run `./bin/build.sh`
   
The system will then:

   1. read the json files while outputting both plain text and SQL
   2. create an SQLite database file
   3. populate the database with the SQL
   4. create a metadata file from the database
   5. zip up the plain text and metadata file
   6. copy the zipped file and a Slurm script to the Reader's file system
   7. done
   
The next step would be to submit the Slurm script so Reader can do its good work. When the Reader is done, then each article will have much more metadata -- features -- associated with it, and this will facilitate more nuanced analysis of the corpus -- reading. 

---  
Eric Lease Morgan &lt;emorgan@nd.edu&gt;  
March 16, 2020
