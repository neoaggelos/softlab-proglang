/* doomsday.cpp */

#include <iostream>
#include <fstream>
#include <cstdlib>
#include <list>

using namespace std;

typedef struct {
    int x, y;       /* position */
    int t;          /* time */
    char c;         /* '+', '-' */
} move_t;

typedef list<move_t> moves_t;

/* live with honor, die with glory */
void die(string msg = "")
{
    cerr << "Too bad: " << msg << endl;
    exit(-1);
}

void print_world(char grid[1000][1000], int N, int M)
{
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) cout << grid[j][i];
        cout << endl;
    }
}

int main(int argc, char** argv)
{
    if (argc != 2)
        die("no input");

    ifstream fin(argv[1]);
    if (!fin.is_open())
        die("bad input file");

    moves_t remaining_moves;
    char grid[1000][1000];

    /* create initial world */
    char c;
    int x=0, N=0, M=0;
    while (fin.get(c)) {
        if (c == '\n') {
            M = x; x = 0; N++;
        } else if (c == 'X') {
            grid[x][N] = 'X';
            x++;
        } else if (c == '+' || c == '-' || c == '.') {
            if (c != '.') remaining_moves.push_back({x, N, 0, c});
            grid[x][N] = '.';
            x++;
        } else {
            die("bad input");
        }
    }

    /* while there are more moves */
    int doom_time = 0;
    while(!remaining_moves.empty()) {
        move_t p = remaining_moves.front();
        remaining_moves.pop_front();

        if (doom_time && p.t > doom_time)
            break;

        /*
        grid[p.x][p.y] -> existing symbol in place
        p.x,p.y -> place we want to put the character
        p.c -> character we want to put in place
        p.t -> time that character was set
        */

        if (grid[p.x][p.y] == p.c)
            continue;

        //cout << "Trying to put symbol " << p.c << " in place " << p.x << "," << p.y << "-- time is " << p.t << endl;

        if (grid[p.x][p.y] + p.c == '+' + '-') {        // it's fast, does it work?
            doom_time = p.t;
            grid[p.x][p.y] = '*';
        } else if (grid[p.x][p.y] != '*') {
            grid[p.x][p.y] = p.c;
        }

        // left
        if (p.x > 0 && grid[p.x-1][p.y] != p.c && grid[p.x-1][p.y] != '*' && grid[p.x-1][p.y] != 'X') {
            remaining_moves.push_back({p.x-1, p.y, p.t+1, p.c});
        }
        
        // right
        if (p.x < M-1 && grid[p.x+1][p.y] != p.c && grid[p.x+1][p.y] != '*' && grid[p.x+1][p.y] != 'X') {
            remaining_moves.push_back({p.x+1, p.y, p.t+1, p.c});
        }

        // up
        if (p.y >0 && grid[p.x][p.y-1] != p.c && grid[p.x][p.y-1] != '*' && grid[p.x][p.y-1] != 'X') {
            remaining_moves.push_back({p.x, p.y-1, p.t+1, p.c});
        }

        // down
        if (p.y < N-1 && grid[p.x][p.y+1] != p.c && grid[p.x][p.y+1] != '*' && grid[p.x][p.y+1] != 'X') {
            remaining_moves.push_back({p.x, p.y+1, p.t+1, p.c});
        }
    }

    if (doom_time) {
        cout << doom_time << endl;
    } else {
        cout << "the world is saved" << endl;
    }

    print_world(grid, N, M);

    return 0;
}
