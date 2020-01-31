-- queries.sql - a set of SQL statements used to summarize a study carrel

-- Eric Lease Morgan <emorgan@nd.edu>
-- (c) University of Notre Dame; distributed under a GNU Public License

-- May 23, 2019 - calling it version 1.0
-- May 27, 2019 - replaced named-entities with various types of pronouns


-- set mode so sub-results can be copy & pasted into spreadsheets, etc
.mode tabs


-- introduction
select "

Summary of your 'study carrel'
==============================

This is a summary of your Distant Reader 'study carrel'.

The Distant Reader harvested & cached your content into a
collection/corpus. It then applied sets of natural language
processing and text mining against the collection. The results of
this process was reduced to a database file -- a 'study carrel'.
The study carrel can then be queried, thus bringing light
specific characteristics for your collection. These
characteristics can help you summarize the collection as well as
enumerate things you might want to investigate more closely.

                               Eric Lease Morgan <emorgan@nd.edu>
                                                     May 27, 2019";



-- size of collection
select "

Number of items in the collection; 'How big is my corpus?'
----------------------------------------------------------";
select count(id) from bib;


-- average number of words
select '

Average length of all items measured in words; "More or less, how big is each item?"
------------------------------------------------------------------------------------';
select rtrim(round(avg(words)), '.0') from bib;


-- average readability
select "

Average readability score of all items (0 = difficult; 100 = easy)
------------------------------------------------------------------";
select rtrim(round(avg(flesch)), '.0') from bib;


-- keywords
select '

Top 50 statistically significant keywords; "What is my collection about?"
-------------------------------------------------------------------------';
select count(keyword) as c, keyword from wrd group by keyword order by c desc limit 50;


-- nouns
select '

Top 50 lemmatized nouns; "What is discussed?"
---------------------------------------------';
select count(lemma) as c, lemma from pos where pos is 'NN' or pos is 'NNS' group by lemma order by c desc limit 50;


-- proper nouns
select '

Top 50 proper nouns; "What are the names of persons or places?"
--------------------------------------------------------------';
select count(token) as c, token from pos where pos LIKE 'NNP%' group by token order by c desc limit 50;


-- personal pronouns
select '

Top 50 personal pronouns nouns; "To whom are things referred?"
-------------------------------------------------------------';
select count(lower(token)) as c, lower(token) from pos where pos is 'PRP' group by lower(token) order by c desc limit 50;


-- verbs
select '

Top 50 lemmatized verbs; "What do things do?"
---------------------------------------------';
select count(lemma) as c, lemma from pos where pos like 'V%' group by lemma order by c desc limit 50;


-- lemmatized descriptors (adjective or adverb)
select '

Top 50 lemmatized adjectives and adverbs; "How are things described?"
---------------------------------------------------------------------';
select count(lemma) as c, lemma from pos where (pos like 'J%' or pos like 'R%') group by lemma order by c desc limit 50;


-- superlatives (adjective or adverb)
select '

Top 50 lemmatized superlative adjectives; "How are things described to the extreme?"
-------------------------------------------------------------------------';
select count(lemma) as c, lemma from pos where (pos is 'JJS') group by lemma order by c desc limit 50;


-- superlatives (adjective or adverb)
select '

Top 50 lemmatized superlative adverbs; "How do things do to the extreme?"
------------------------------------------------------------------------';
select count(lemma) as c, lemma from pos where (pos is 'RBS') group by lemma order by c desc limit 50;


-- named entities; they don't work so well

-- people
-- select '
-- 
-- Top 50 names of people; "Who is mentioned in the corpus?"
-- ---------------------------------------------------------';
-- select count(entity) as c, entity from ent where type is 'PERSON' group by entity order by c desc limit 50;


-- organizations
-- select '
-- 
-- Top 50 names of organizations; "What group of people are in the corpus?"
-- ------------------------------------------------------------------------';
-- select count(entity) as c, entity from ent where (type is 'ORG') group by entity order by c desc limit 50;


-- places
-- select '
-- 
-- Top 50 names of places; "What locations are mentioned in the corpus?"
-- ---------------------------------------------------------------------';
-- select count(entity) as c, entity from ent where (type is 'GPE' or type is 'LOC') group by entity order by c desc limit 50;


-- domains (from urls)
select '

Top 50 Internet domains; "What Webbed places are alluded to in this corpus?"
----------------------------------------------------------------------------';
select count(lower(domain)) as c, lower(domain) from url group by domain order by c desc limit 50;


-- urls
select '

Top 50 URLs; "What is hyperlinked from this corpus?"
----------------------------------------------------';
select count(url) as c, url from url group by url order by c desc limit 50;


-- email addresses
select '

Top 50 email addresses; "Who are you gonna call?"
-------------------------------------------------';
select count(lower(address)) as c, lower(address) from adr group by address order by c desc limit 50;



-- positive assertions
select '

Top 50 positive assertions; "What sentences are in the shape of noun-verb-noun?"
-------------------------------------------------------------------------------';
SELECT COUNT( LOWER( t.token || ' ' || c.token || ' ' || d.token ) ) AS frequency, ( LOWER( t.token || ' ' || c.token || ' ' || d.token ) ) AS sentence FROM pos AS t JOIN pos AS c ON c.tid=t.tid+1 AND c.sid=t.sid AND c.id=t.id JOIN pos AS d ON d.tid=t.tid+2 AND d.sid=t.sid AND d.id=t.id WHERE t.lemma IN (select lemma from pos where pos like 'N%' group by lemma order by count(lemma) desc limit 30) AND c.lemma in (select lemma from pos where pos like 'V%' group by lemma order by count(lemma) desc limit 30) AND ( d.pos LIKE 'N%' OR d.pos LIKE 'J%' OR d.pos LIKE 'R%' ) GROUP BY sentence ORDER BY frequency DESC, ( LOWER( t.token || ' ' || c.token || ' ' || d.token ) ) ASC LIMIT 50;


-- negative assertions
select '

Top 50 negative assertions; "What sentences are in the shape of noun-verb-no|not-noun?"
---------------------------------------------------------------------------------------';
SELECT COUNT( LOWER( t.token || ' ' || c.token || ' ' || d.token || ' ' || e.token ) ) AS frequency, ( LOWER( t.token || ' ' || c.token || ' ' || d.token || ' ' || e.token ) ) AS sentence FROM pos AS t JOIN pos AS c ON c.tid=t.tid+1 AND c.sid=t.sid AND c.id=t.id JOIN pos AS d ON d.tid=t.tid+2 AND d.sid=t.sid AND d.id=t.id JOIN pos AS e ON e.tid=t.tid+3 AND e.sid=t.sid AND e.id=t.id WHERE t.lemma IN (select lemma from pos where pos like 'N%' group by lemma order by count(lemma) desc limit 30) AND c.lemma in (select lemma from pos where pos like 'V%' group by lemma order by count(lemma) desc limit 30) AND ( d.token IS 'no' OR d.token IS 'not' ) AND ( e.pos LIKE 'N%' OR e.pos LIKE 'J%' or e.pos like 'R%' ) GROUP BY LOWER( t.token || ' ' || c.token || ' ' || d.token || ' ' || e.token ) ORDER BY frequency DESC, ( LOWER( t.token || ' ' || c.token || ' ' || d.token || ' ' || e.token ) ) ASC LIMIT 50;


-- INSERT MORE KEWL GRAMMERS HERE


-- size of items
select '

Sizes of items; "Measures in words, how big is each item?"
----------------------------------------------------------';
select words, id from bib order by words desc;


-- readability of items
select '

Readability of items; "How difficult is each item to read?"
-----------------------------------------------------------';
select rtrim(round(flesch)) as f, id from bib order by f desc;


-- summaries
select '

Item summaries; "In a narrative form, how can each item be abstracted?"
-----------------------------------------------------------------------';
select id, summary || '
' from bib order by id;


