import sys
from PIL import Image

def decode():
  image = Image.open(sys.argv[1])

  size = 60
  image = image.resize((size, size))
  # image = image.resize((108, 31)) # width, height
  pixels = image.load()
  res = [0] * size
  # res = [0] * 31
  for row in range(size):
  # for row in range(31):
    res[row] = [0] * size
    # res[row] = [0] * 108

  for x in range(image.height):
    for y in range(image.width):
      # r,g,b = pixels[y,x]
      r,g,b,a = pixels[y, x]
      # print(r,g,b,a, " ")
      val = 1 if r < 100 and r > 0 else 0
      res[x][y] = str(val)

  return res

arr = decode()

with open(sys.argv[2], 'a') as f:
  for row in arr:
    f.write(" ".join(row))
    f.write("\n")
