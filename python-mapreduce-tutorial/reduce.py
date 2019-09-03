import sys

def reducer():
    counter = {}
    # sys.stdin is the system standard input
    for line in sys.stdin:
        # split the words by " "
        pp = line.strip().split()
        if len(pp):
            # count word number
            counter[pp[0]] = counter.get(pp[0], 0) + int(pp[1])

    for word, count in sorted(counter.items(), key=lambda x: x[1]):
        print(word, count)

if __name__ == '__main__':
    reducer()

# go to console and type:
    # unix: cat input.txt | python map.py | sort | python reduce.py
    # windows: type input.txt | python map.py | sort | python reduce.py
