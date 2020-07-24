-- schema.sql - a data model for the CORD metadata

-- Eric Lease Morgan <emorgan@nd.edu>
-- (c) University of Notre Dame; distributed under a GNU Public License

-- May 14, 2020 - first documentation
-- May 26, 2020 - added quite a number of tables


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

