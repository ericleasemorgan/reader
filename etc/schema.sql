CREATE TABLE articles (

	article_id  INTEGER PRIMARY KEY,
	title       TEXT,
	date        TEXT,
	journal     TEXT,
	source      TEXT,
	abstract    TEXT,
	license     TEXT,
	pdf_json    TEXT,
	pmc_json    TEXT,
	sha         TEXT,
	url         TEXT,
	doi         TEXT,
	arxiv_id    TEXT,
	cord_uid    TEXT,
	mag_id      TEXT,
	pmc_id      TEXT,
	pubmed_id   TEXT,
	who_id      TEXT
    
);


CREATE TABLE authors (

	article_id INTEGER,
	author     TEXT

);

