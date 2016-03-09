import sys

# 

infile = False
header_done = False
data = open(sys.argv[1])
for i, l in enumerate(data):
    if l.startswith('PRESIDENT'):
        infile = True
        continue
    elif l.startswith('CensusPopAll'):
        infile = False
        continue
    elif l.startswith('Office\tState'):
        if header_done:
            continue
        else:
            print(l)
            header_done = True
            continue


    if l == '\t\r\n':
        continue
    elif infile:
        print(l)


