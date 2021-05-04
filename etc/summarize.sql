-- summarize.sql - a set of SQL used to report on the contents of a database

-- Eric Lease Morgan <emorgan@nd.edu>
-- (c) University of Notre Dame; distributed under a GNU Public License

-- May 14, 2020 - first cut
-- June 3, 2020 - added named entities and keywords


-- configure
.mode tabs

-- introduction
SELECT "";
SELECT "";
SELECT "Summary report";
SELECT "==============";
SELECT "";
SELECT "The following text summarizes the content of the CORD metadata file.";
SELECT "";
SELECT "As you will see, not all records are considered equal; the data is";
SELECT "not necessarily complete nor accurate. For example, some things";
SELECT "are published in the future, and some records have no dates at";
SELECT "all. Some things do not have a title nor an abstract. Actually,";
SELECT "in the big scheme of things, these are not huge issues. We are";
SELECT "not here to do bibliographics; we are here to do natural langauge";
SELECT "processing, and we do have the text. On the other hand, many of";
SELECT "the records do contain useful identifiers which can ultimately be";
SELECT "exploited to fill in the gaps.";
SELECT "";
SELECT "Another problem is there are no distinct keys. The metadata";
SELECT "includes a column named 'cord_uid', which is intended as a key,";
SELECT "but the values in the column are not unique. Consequently, we";
SELECT "have to create a key.";
SELECT "";
SELECT "But there is a more challenging problem. Some of the records";
SELECT "describe (point to) JSON files in a shape called 'pdf_json'.";
SELECT "Some of the records describe (point to) JSON files in a shape";
SELECT "called 'pmc_json'. Some (most) of the records describe (point";
SELECT "to) both types of JSON files. The challenge is, 'Which flavor of";
SELECT "JSON do we use to do our natural langauge processing against?'";
SELECT "";
SELECT "Finally, the metadata is/was delivered as a flat (CSV) file, when";
SELECT "the content is actually relational in nature. The best example is";
SELECT "the authors column; the authors column is really a semi-colon";
SELECT "delimited set of values which could be normalized into a separate";
SELECT "table. Doing so would enable us to count & tabulate author names";
SELECT "more accurately. The same thing holds true for the sha and";
SELECT "sources columns.";
SELECT "";
SELECT "'Librarian work is never done.'";
SELECT "";
SELECT "                                                              --";
SELECT "                              Eric Lease Morgan <emorgan@nd.edu>";
SELECT "                                                    June 3, 2020";
SELECT "";
SELECT "";

SELECT "Database structure";
SELECT "==================";
SELECT "";
.schema
SELECT "";

SELECT "Number of records in the database";
SELECT "=================================";
SELECT COUNT( document_id ) FROM documents;
SELECT "";

SELECT "Number of records sans author values";
SELECT "====================================";
SELECT COUNT( document_id ) FROM documents WHERE authors is 'nan';
SELECT "";

SELECT "Number of records sans title values";
SELECT "===================================";
SELECT COUNT( document_id ) FROM documents WHERE title is 'nan';
SELECT "";

SELECT "Number of records sans date values";
SELECT "==================================";
SELECT COUNT( document_id ) FROM documents WHERE date is 'nan';
SELECT "";

SELECT "Count & tabulation of years";
SELECT "===========================";
SELECT year, COUNT( year ) FROM documents WHERE year != 'nan' GROUP BY year ORDER BY year DESC;
SELECT "";

SELECT "Number of records sans abstract values";
SELECT "======================================";
SELECT COUNT( document_id ) FROM documents WHERE abstract is 'nan';
SELECT "";

SELECT "Number of records sans journal title values";
SELECT "===========================================";
SELECT COUNT( document_id ) FROM documents WHERE journal is 'nan';
SELECT "";

SELECT "Count & tabulation of most frequent 50 journal titles";
SELECT "======================================================";
SELECT COUNT( journal ) AS c, journal FROM documents WHERE journal != 'nan' GROUP BY journal ORDER BY c DESC LIMIT 50;
SELECT "";

SELECT "Count & tabulation of most frequent 50 keywords";
SELECT "===============================================";
SELECT COUNT( w.keyword ) AS c, w.keyword
FROM wrd AS w, documents AS d
WHERE d.document_id = w.document_id 
GROUP BY w.keyword ORDER BY c DESC LIMIT 50;
SELECT "";

SELECT "Count & tabulation of most frequent 50 named entities";
SELECT "======================================================";
SELECT COUNT( e.entity ) AS c, e.entity 
FROM ent AS e, documents AS d 
WHERE d.document_id = e.document_id 
GROUP BY e.entity ORDER BY c DESC LIMIT 50;
SELECT "";

SELECT "Count & tabulation of most frequent 50 named entities types";
SELECT "===========================================================";
SELECT COUNT( e.type ) AS c, e.type 
FROM ent AS e, documents AS d 
WHERE d.document_id = e.document_id 
GROUP BY e.type ORDER BY c DESC LIMIT 50;
SELECT "";

SELECT "Number of records sans source values";
SELECT "=====================================";
SELECT COUNT( document_id ) FROM documents WHERE source is 'nan';
SELECT "";

SELECT "Count & tabulation of most frequent 50 sources";
SELECT "===============================================";
SELECT COUNT( source ) AS c, source FROM documents GROUP BY source ORDER BY c DESC LIMIT 50;
SELECT "";

SELECT "Number of records sans url values";
SELECT "=================================";
SELECT COUNT( document_id ) FROM documents WHERE url is 'nan';
SELECT "";

SELECT "Number of records sans doi values";
SELECT "=================================";
SELECT COUNT( document_id ) FROM documents WHERE doi is 'nan';
SELECT "";

SELECT "Number of records sans license values";
SELECT "======================================";
SELECT COUNT( document_id ) FROM documents WHERE license is 'nan';
SELECT "";

SELECT "Count & tabulation of most frequent 50 license";
SELECT "===============================================";
SELECT COUNT( license ) AS c, license FROM documents GROUP BY license ORDER BY c DESC LIMIT 50;
SELECT "";

SELECT "Number of records with pdf_json values";
SELECT "======================================";
SELECT COUNT( document_id ) FROM documents WHERE pdf_json != 'nan';
SELECT "";

SELECT "Number of records with pmc_json values";
SELECT "======================================";
SELECT COUNT( document_id ) FROM documents WHERE pmc_json != 'nan';
SELECT "";

SELECT "Number of records sans sha values";
SELECT "=================================";
SELECT COUNT( document_id ) FROM documents WHERE sha is 'nan';
SELECT "";

SELECT "Number of records with multiple sha values";
SELECT "===========================================";
SELECT COUNT( document_id ) FROM documents WHERE sha LIKE '%;%';
SELECT "";

SELECT "Number of records with cord_uid values";
SELECT "======================================";
SELECT COUNT( document_id ) FROM documents WHERE cord_uid != 'nan';
SELECT "";

SELECT "Number of distinct cord_uid values";
SELECT "==================================";
SELECT COUNT( DISTINCT cord_uid ) FROM documents WHERE cord_uid != 'nan';
SELECT "";

SELECT "Count & tabulation of some non-distinct cord_uid values";
SELECT "=======================================================";
SELECT COUNT( cord_uid ) AS c, cord_uid FROM documents GROUP BY cord_uid ORDER BY c DESC LIMIT 10;
SELECT "";

SELECT "Number of records with arxiv_id values";
SELECT "======================================";
SELECT COUNT( document_id ) FROM documents WHERE arxiv_id != 'nan';
SELECT "";

SELECT "Number of records with mag_id values";
SELECT "======================================";
SELECT COUNT( document_id ) FROM documents WHERE mag_id != 'nan';
SELECT "";

SELECT "Number of records with pmc_id values";
SELECT "======================================";
SELECT COUNT( document_id ) FROM documents WHERE pmc_id != 'nan';
SELECT "";

SELECT "Number of records with pubmed_id values";
SELECT "=======================================";
SELECT COUNT( document_id ) FROM documents WHERE pubmed_id != 'nan';
SELECT "";

SELECT "Number of records with who_id values";
SELECT "====================================";
SELECT COUNT( document_id ) FROM documents WHERE who_id != 'nan';
SELECT "";


