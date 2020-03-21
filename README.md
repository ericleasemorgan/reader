# cord-19

This suite of software will prepare a dataset called "[CORD-19](https://pages.semanticscholar.org/coronavirus-research)" for processing with the [Distant Reader](https://distantreader.org).

CORD-19 is a set of more than 13,000 full text scholarly journal articles surrounding the topic of the COVID-19 pandemic. Each "article" is really a JSON file containing (very) rudimentary bibliographic information, a set of paragraphs, and bibliographic citations. This suite processes the JSON files to extract their identifier, author, title, full text, much of their citations. The whole lot is then zipped up -- along with a metadata file -- and submitted to the Distant Reader for analysis.

To get this software to work for you, configure `./bin/cache.sh`, and the run `./bin/build.sh`.
   
The system will then:

   1. download the JSON files and their associated metadata file
   2. initialize a database
   3. pour the metadata into the the database
   4. read the json files while outputting plain text files
   5. create a Distant Reader metadata file from the database
   6. zip up the plain text and newly created metadata file
   7. copy the zipped file and a Slurm script to the Reader's file system
   8. done
   
The next step would be to submit the Slurm script so Reader can do its good work. When the Reader is done, then each article will have much more metadata -- features -- associated with it, and this will facilitate more nuanced analysis of the corpus -- reading. 

---  
Eric Lease Morgan &lt;emorgan@nd.edu&gt;  
March 20, 2020
