import sys
import numpy as np

def xx():
    x = int(sys.argv[1]) # takes first arg passed
    y = x * x
    print(str(y))

def main():
    xx()

# this protects code from being executed if
# the program is imported, not executed
if __name__ == '__main__': main()