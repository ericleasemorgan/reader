-- schema.sql - a data model for the CORD metadata

-- Eric Lease Morgan <emorgan@nd.edu>
-- (c) University of Notre Dame; distributed under a GNU Public License

-- May  14, 2020 - first documentation
-- May  26, 2020 - added quite a number of tables
-- June 14, 2021 - views


CREATE TABLE documents (

	document_id  INTEGER PRIMARY KEY,
	authors      TEXT,
	title        TEXT,
	date         TEXT,
	year         INT,
	journal      TEXT,
	source       TEXT,
	abstract     TEXT,
	license      TEXT,
	pdf_json     TEXT,
	pmc_json     TEXT,
	sha          TEXT,
	url          TEXT,
	doi          TEXT,
	arxiv_id     TEXT,
	cord_uid     TEXT,
	mag_id       TEXT,
	pmc_id       TEXT,
	pubmed_id    TEXT,
	who_id       TEXT
    
);

-- a copule of indexes
CREATE INDEX documents_sha_i ON documents (sha);
CREATE INDEX documents_pmc_id_i ON documents (pmc_id);

-- name entitites
CREATE TABLE ent (

    document_id  INT,
    sid          INT,
    eid          INT,
    entity       TEXT,
    type         TEXT
    
);

CREATE TABLE authors (

	document_id  INTEGER,
	author       TEXT

);

CREATE TABLE sources (

	document_id  INTEGER,
	source       TEXT

);

CREATE TABLE shas (

	document_id  INTEGER,
	sha          TEXT

);

CREATE TABLE urls (

	document_id  INTEGER,
	url          TEXT

);

CREATE TABLE wrd (

	document_id  INTEGER,
	keyword      TEXT

);

-- cool views by Art Rhyno
CREATE VIEW view_authors AS SELECT document_id, GROUP_CONCAT(REPLACE(author,',','_')) as authors FROM authors GROUP BY document_id;

CREATE VIEW view_keywords AS SELECT document_id, GROUP_CONCAT(keyword) as keywords FROM wrd GROUP BY document_id;

CREATE VIEW view_entities AS SELECT document_id, GROUP_CONCAT(DISTINCT(entity)) as entities FROM ent GROUP BY document_id;

CREATE VIEW view_types AS SELECT document_id, GROUP_CONCAT(DISTINCT(type)) as types FROM ent GROUP BY document_id;

CREATE VIEW view_sources AS SELECT document_id, GROUP_CONCAT(source) as sources FROM sources GROUP BY document_id;

CREATE VIEW view_urls AS SELECT document_id, GROUP_CONCAT(REPLACE(url,' ','')) as urls FROM urls GROUP BY document_id;


