# tutorial: http://scienceblogs.de/diaxs-rake/2012/11/18/big-data-1-einfaches-word-count-beispiel-in-python/?all=1

import sys

def mapper():
    # sys.stdin is the system standard input
    for line in sys.stdin:
        # strip() deletes leading and trailing characters, in this case " "
        # split() splits the words
        pp = line.strip().split()
        for p in pp:
            print(p, 1)

if __name__ == '__main__':
    mapper()

# go to console and cat input.txt|python map.py
    # for Windows: type input.txt|python map.py
