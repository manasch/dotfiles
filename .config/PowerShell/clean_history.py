import sys

path = sys.argv[1]
with open(path) as f:
    data = f.readlines()

res = set(data)
with open(path, "w") as f:
    f.write("".join(res))
