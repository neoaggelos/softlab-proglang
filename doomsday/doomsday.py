# doomsday.py

from sys import argv

def doomsday(fname):
  moves = []
  grid = []

  with open(fname, 'r') as f:
    for i, line in enumerate(f):
      line = line[:-1]
      newline = []

      for j, c in enumerate(line):
        if c == '+' or c == '-':
          moves.append((i, j, 0, c))
          newline.append('.')
        else:
          newline.append(c)
      
      grid.append(newline)

  N = i+1
  M = len(grid[0])

  # grid is a list of N strings, each string is a line with length M
  # moves are tuples (i, j, time, character)
  doom = 0
  while moves:
    i, j, t, c = moves.pop(0)
    o = grid[i][j]

    if doom > 0 and t > doom:
      break

    # o = grid[i][j] -> existing symbol
    # t -> time of change
    # c -> new character

    if grid[i][j] == c:
      continue

    if (o == '+' and c == '-') or (o == '-' and c == '+'):
      doom = t
      grid[i][j] = '*'
    elif o != '*':
        grid[i][j] = c

    # up
    if (i > 0) and (grid[i-1][j] not in ['X','*']) and ((i-1,j,t+1,c) not in moves):
      moves.append((i-1,j,t+1,c))

    # down
    if (i < N-1) and (grid[i+1][j] not in ['X','*']) and ((i+1,j,t+1,c) not in moves):
      moves.append((i+1,j,t+1,c))

    # right
    if (j < M-1) and (grid[i][j+1] not in ['X','*']) and ((i,j+1,t+1,c) not in moves):
      moves.append((i,j+1,t+1,c))

    # left
    if (j > 0) and (grid[i][j-1] not in ['X','*']) and ((i,j-1,t+1,c) not in moves):
      moves.append((i,j-1,t+1,c))


  if doom == 0:
    print('the world is saved')
  else:
    print(doom)

  for line in grid:
    print(''.join(line))

doomsday(argv[1])