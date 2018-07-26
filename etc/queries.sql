.mode tabs


select "
number of items in the collection
=================================";
select count(id) from bib;


-- summaries
select "
bibliographics (id, number of words, number of sentences, readabilty score, summary)
====================================================================================";
select id, words, sentences, flesch, summary, "
" from bib order by id;


-- average number of words
select "
average length in words
=======================";
select rtrim(round(avg(words)), '.0') from bib;


-- average readability
select "
average readability score
=========================";
select rtrim(round(avg(flesch)), '.0') from bib;


select "
tabulations of keywords
=======================";
select count(keyword) as c, keyword from wrd group by keyword order by c desc;


-- tabulate urls
select "
tabulation of urls
==================";
select count(url) as c, url from url group by url order by c desc;


-- domains (from urls)
select "
top 10 domains from urls
========================";
select count(lower(domain)) as c, lower(domain) from url group by domain order by c desc;


-- tabulate email addresses
select "
top 10 email addresses
======================";
select count(lower(address)) as c, lower(address) from adr group by address order by c desc;


-- top 10 lemmatized nouns
select "
top 10 lemmatized nouns
=======================";
select count(lemma) as c, lemma from pos where pos like 'N%' group by lemma order by c desc limit 10;


-- top 10 lemmatized verbs
select "
top 10 lemmatized verbs
=======================";
select count(lemma) as c, lemma from pos where pos like 'V%' group by lemma order by c desc limit 10;


-- top 10 lemmatized descriptors (adjective or adverb)
select "
top 10 lemmatized ajectives or adverbs
======================================";
select count(lemma) as c, lemma from pos where (pos like 'J%' or pos like 'R%') group by lemma order by c desc limit 10;


-- top 10 people
select "
top 10 people
=============";
select count(entity) as c, entity from ent where type is 'PERSON' group by entity order by c desc limit 10;


-- top 10 places
select "
top 10 places
=============";
select count(entity) as c, entity from ent where (type is 'GPE' or type is 'LOC') group by entity order by c desc limit 10;


-- top 10 organizations
select "
top 10 organizations
====================";
select count(entity) as c, entity from ent where (type is 'ORG') group by entity order by c desc limit 10;


-- positive assertions
select "
positive assertions
===================";
SELECT COUNT( LOWER( t.token || ' ' || c.token || ' ' || d.token ) ) AS frequency, ( LOWER( t.token || ' ' || c.token || ' ' || d.token ) ) AS sentence FROM pos AS t JOIN pos AS c ON c.tid=t.tid+1 AND c.sid=t.sid AND c.id=t.id JOIN pos AS d ON d.tid=t.tid+2 AND d.sid=t.sid AND d.id=t.id WHERE t.lemma IN (select lemma from pos where pos like 'N%' group by lemma order by count(lemma) desc limit 30) AND c.lemma in (select lemma from pos where pos like 'V%' group by lemma order by count(lemma) desc limit 30) AND ( d.pos LIKE 'N%' OR d.pos LIKE 'J%' OR d.pos LIKE 'R%' ) GROUP BY sentence ORDER BY frequency DESC, ( LOWER( t.token || ' ' || c.token || ' ' || d.token ) ) ASC;


-- negative assertions
select "
negative assertions
===================";
SELECT COUNT( LOWER( t.token || ' ' || c.token || ' ' || d.token || ' ' || e.token ) ) AS frequency, ( LOWER( t.token || ' ' || c.token || ' ' || d.token || ' ' || e.token ) ) AS sentence FROM pos AS t JOIN pos AS c ON c.tid=t.tid+1 AND c.sid=t.sid AND c.id=t.id JOIN pos AS d ON d.tid=t.tid+2 AND d.sid=t.sid AND d.id=t.id JOIN pos AS e ON e.tid=t.tid+3 AND e.sid=t.sid AND e.id=t.id WHERE t.lemma IN (select lemma from pos where pos like 'N%' group by lemma order by count(lemma) desc limit 30) AND c.lemma in (select lemma from pos where pos like 'V%' group by lemma order by count(lemma) desc limit 30) AND ( d.token IS 'no' OR d.token IS 'not' ) AND ( e.pos LIKE 'N%' OR e.pos LIKE 'J%' or e.pos like 'R%' ) GROUP BY LOWER( t.token || ' ' || c.token || ' ' || d.token || ' ' || e.token ) ORDER BY frequency DESC, ( LOWER( t.token || ' ' || c.token || ' ' || d.token || ' ' || e.token ) ) ASC;


-- INSERT MORE KEWL GRAMMERS HERE


