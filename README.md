# cord-19

This suite of software will prepare a data set called "[CORD-19](https://pages.semanticscholar.org/coronavirus-research)" for processing with the [Distant Reader](https://distantreader.org).

CORD-19 is a set of more than 50,000 full text scholarly journal articles surrounding the topic of COVID-19. Each "article" is really a JSON file containing (very) rudimentary bibliographic information, a set of paragraphs, and bibliographic citations. As a pre-processing step for the Distant Reader, the suite processes the CORD-19 metadata and its associated JSON files.

To get this software to work for you, `pip install -r requirements.txt`, configure `./bin/cache.sh`, and the run `./bin/build.sh`. The system will then:

   1. download a zip file and its associated metadata file
   2. uncompress the the zip file
   3. move all the JSON files to a single directory
   4. initialize a database
   5. pour the metadata into the the database
   6. output a simple narrative report summarizing the content of the metadata file

Depending on the network connection, the build process takes less than 7 minutes.
   
The next steps are the creation of two scripts:

   1. Given an SQL SELECT statement, return a list of keys, and use them to initialize a Distant Reader study carrel
   2. Given a JSON file, output a more human-readable version of the same

Wish us luck.

---  
Eric Lease Morgan &lt;emorgan@nd.edu&gt;  
May 14, 2020