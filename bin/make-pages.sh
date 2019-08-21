#!/usr/bin/env bash


# configure
CARREL2ABOUT='/export/reader/bin/carrel2about.py'
CARREL2SEARCH='/export/reader/bin/carrel2search.pl'
CARRELS='/export/reader/carrels'
CORPUS2FILE='/export/reader/bin/corpus2file.sh'
LISTQUESTIONS='/export/reader/bin/list-questions.sh'
TSV2COMPLEX='/export/reader/bin/tsv2htm-complex.py'
TSV2ENTITIES='/export/reader/bin/tsv2htm-entities.py'
TSV2HTM='/export/reader/bin/tsv2htm.py'
TSV2QUESTIONS='/export/reader/bin/tsv2htm-questions.py'
CARREL2JSON='/export/reader/bin/carrel2json.py'
TXT='txt/*.txt'

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

# list questions
echo -e "identifier\tquestion"      > ./tsv/questions.tsv
$LISTQUESTIONS $CARREL             >> ./tsv/questions.tsv
$TSV2QUESTIONS ./tsv/questions.tsv  > ./htm/questions.htm

# create search page
$CARREL2SEARCH $CARREL > ./htm/search.htm

# create data and page for topic modeling
find $TXT | parallel $CORPUS2FILE {} > ./etc/model-data.txt
cp /export/reader/etc/template-model.htm ./htm/topic-model.htm

# create cool network diagram ("Thanks, Team JAMS!")
$CARREL2JSON > ./etc/network-graph.json
cp /export/reader/etc/template-diagram.htm ./htm/network-diagram.htm


# done
wait
exit
