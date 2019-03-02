
# configure
WORD2PHRASE='word2phrase'
WORD2VEC='word2vec'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# initialize
NAME=$1
CARREL="/export/reader/carrels/$NAME"
CORPUS="$CARREL/etc/reader.txt"
MODEL="$CARREL/etc/reader.vec"

# initialize
rm -rf $CORPUS

# build corpus
find "$CARREL/txt" -name '*.txt' -exec cat {} >> $CORPUS \;
sed -e "s/[[:punct:]]\+//g" $CORPUS > ./tmp/corpus.001
tr '[:upper:]' '[:lower:]' < ./tmp/corpus.001 > ./tmp/corpus.002
tr '[:digit:]' ' ' < ./tmp/corpus.002 > ./tmp/corpus.003
tr '\n' ' ' < ./tmp/corpus.003 > ./tmp/corpus.004
tr -s ' ' < ./tmp/corpus.004 > $CORPUS

# create a model
$WORD2PHRASE -train $CORPUS -output ./tmp/phrases-01.txt >&2
$WORD2PHRASE -train ./tmp/phrases-01.txt -output ./tmp/phrases-02.txt >&2
$WORD2VEC -train ./tmp/phrases-02.txt -output $MODEL -sq 1 -size 10 -window 10 -negative 10 -hs 0 -sample 1e-5 -threads 40 -binary 1 -iter 3 -min-count 10 >&2

# done
exit