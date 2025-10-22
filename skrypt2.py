# !/usr/bin/env python3
import time
import sys



file = sys.argv[1]

with open(file, 'w') as f:
    n = 0
    while True:
        f.write(f"{n}\n")
        f.flush()  
        n += 1
        time.sleep(1)

