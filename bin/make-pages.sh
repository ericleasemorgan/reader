#!/usr/bin/env bash


# configure
CARREL2ABOUT='/export/reader/bin/carrel2about.py'
TSV2HTM='/export/reader/bin/tsv2htm.py'
TSV2COMPLEX='/export/reader/bin/tsv2htm-complex.py'
TSV2ENTITIES='/export/reader/bin/tsv2htm-entities.py'
CARRELS='/export/reader/carrels'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <carrel>" >&2
	exit
fi

# get input
CARREL=$1

# make sane
cd "$CARRELS/$CARREL"

# begin the work; index page
$CARREL2ABOUT > index.htm

# htm files
$TSV2HTM adjective   ./tsv/adjectives.tsv   > ./htm/adjectives.htm   &
$TSV2HTM adverb      ./tsv/adverbs.tsv      > ./htm/adverbs.htm      &
$TSV2HTM bigram      ./tsv/bigrams.tsv      > ./htm/bigrams.htm      &
$TSV2HTM keyword     ./tsv/keywords.tsv     > ./htm/keywords.htm     &
$TSV2HTM noun        ./tsv/nouns.tsv        > ./htm/nouns.htm        &
$TSV2HTM pronoun     ./tsv/pronouns.tsv     > ./htm/pronouns.htm     &
$TSV2HTM proper      ./tsv/proper-nouns.tsv > ./htm/proper-nouns.htm &
$TSV2HTM quadgram    ./tsv/quadgrams.tsv    > ./htm/quadgrams.htm    &
$TSV2HTM trigram     ./tsv/trigrams.tsv     > ./htm/trigrams.htm     &
$TSV2HTM unigram     ./tsv/unigrams.tsv     > ./htm/unigrams.htm     &
$TSV2HTM verb        ./tsv/verbs.tsv        > ./htm/verbs.htm        &

# more complex tsv files
$TSV2COMPLEX noun      verb ./tsv/noun-verb.tsv       > ./htm/noun-verb.htm      &
$TSV2COMPLEX adjective noun ./tsv/adjective-noun.tsv  > ./htm/adjective-noun.htm &

# named entities
$TSV2ENTITIES ./tsv/entities.tsv  > ./htm/entities.htm &

# done
wait
exit
