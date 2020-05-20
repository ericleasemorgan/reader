-- schema.sql - a data model for the CORD metadata

-- Eric Lease Morgan <emorgan@nd.edu>
-- (c) University of Notre Dame; distributed under a GNU Public License

-- May 14, 2020 - first documentation


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


CREATE TABLE authors (

	document_id  INTEGER,
	author       TEXT

);

CREATE TABLE wrd (

	document_id  INTEGER,
	keyword      TEXT

);

