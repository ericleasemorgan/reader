#!/usr/bin/env python

# word2vec.py - cli to word2vec functions

# Eric Lease Morgan <emorgan@nd.edu>
# June 22, 2018 - first investigations


# configure
N = 10

# require
from gensim.models import KeyedVectors
import sys, os

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <file>\n" )
	quit()

# initialize
model        = KeyedVectors.load_word2vec_format( sys.argv[ 1 ], binary=True )
menu_actions = {}  


# main menu
def main_menu() :
    print ("\nWord2vec functions:" )
    print ("1) Similar words w/ positive & negative (analogies)" )
    print ("2) Doesn't match" )
    print ("3) Words closer than" )
    print ("4) Similarity of words" )
    print ("5) Similarity of sets of words" )
    print ("6) Similar words" )
    print ("\n0) Done" )
    choice = input(">> ")
    exec_menu(choice)
    return

# execute menu
def exec_menu( choice ) :
    ch = choice.lower()
    if ch == '' : menu_actions['main_menu']()
    else :
        try : menu_actions[ch]()
        except KeyError :
            print ("Invalid selection, please try again.\n" )
            menu_actions['main_menu']()
    return

# analogy, sort of
def menu1():
	print()
	positive = input( "Positive words (ex: paris england): " )
	negative = input( "Negative words (ex: london): " )
	print( 'Most similar words:' )
	for word, score in ( model.most_similar( positive=positive.split(), negative=negative.split(), topn = N ) ) :
		print( '  * ' + word + ' (' + str( score ) + ')' )
	main_menu()
	return


# Menu 2
def menu2():
	print()
	words = input( "List of words: " )
	os.system('clear')
	print( '\nMost dissimilar word: ' + model.doesnt_match( words.split() ) )
	main_menu()
	return

# Menu 3
def menu3():
	words = input( "Two words: " ).split()
	os.system('clear')
	words = ( model.words_closer_than( words[0], words[1] ) )
	for word in words[:N] : print( '  * ' + word )
	main_menu()
	return

# Menu 4
def menu4():
	words = input( "Two words: " ).split()
	os.system('clear')
	print( '\nSimilarity score: ' + str( model.similarity( words[0], words[1] ) ) )
	main_menu()
	return

# Menu 5
def menu5():
	set01 = input( "First set: " ).split()
	set02 = input( "Second set: " ).split()
	os.system('clear')
	print( '\nSet similarity score: ' + str( model.n_similarity( set01, set02 ) ) )
	main_menu()
	return

# Menu 6
def menu6():
	word = input( "One word: " )
	for word, score in ( model.similar_by_word( word, topn = N ) ) :
		print( '  * ' + word + ' (' + str( score ) + ')' )
	main_menu()
	return

# Back to main menu
def back():
    menu_actions['main_menu']()

# Exit program
def exit():
    sys.exit()

# =======================
#    MENUS DEFINITIONS
# =======================

# Menu definition
menu_actions = {
    'main_menu': main_menu,
    '1': menu1,
    '2': menu2,
    '3': menu3,
    '4': menu4,
    '5': menu5,
    '6': menu6,
    '9': back,
    '0': exit,
}

# =======================
#      MAIN PROGRAM
# =======================

# Main Program
if __name__ == "__main__":
    # Launch main menu
    main_menu()
    