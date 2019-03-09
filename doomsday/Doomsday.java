/* Doomsday.java */

import java.io.*;
import java.util.*;

class Move {
    public int i, j, t;
    public char c;

    Move next;

    public Move(int _i, int _j, int _t, char _c)
    {
        i = _i; j = _j; t = _t; c = _c;
    }
}

class MovesList {
    private Move head;
    private Move tail;
    public int length;

    public MovesList() {
        length = 0;
    }

    public void append(Move m) {
        if (length > 0) {
            tail.next = m;
            tail = m;
        } else {
            head = tail = m;
        }
        length ++;
    }

    public Move pop() {
        if (length > 0) {
            Move m = head;
            head = head.next;
            length--;

            return m;
        }
        // never gonna happen, sry :)
        return new Move(0,0,0,'a');
    }

    public boolean contains(int i, int j, int t, char c) {
        if (length <= 0) return false;
        Move m = head;
        int l = length;
        while (l-- > 0) {
            if (m.i == i && m.j == j && m.t == t && m.c == c)
                return true;

            m = m.next;
        }
        return false;
    }

    public void debug() {
        if (length > 0) {
            Move m = head;
            int l = length;
            while(l-- > 0) {
                System.out.println(m.i + "-" + m.j + "-" + m.t + "-" + m.c);
                m = m.next;
            }
        }
    }
}

public class Doomsday {
    static void printGrid(int N, int M, char[][] grid) {
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < M; j++) {
                System.out.print(grid[i][j]);
            }
            System.out.print('\n');
        }
    }

    public static void main(String[] args) throws FileNotFoundException, IOException
    {
        String fname = args[0];

        String line;
        int N = 0, M = 0;

        BufferedReader br = new BufferedReader(new FileReader(fname));
        char[][] grid = new char[1000][1000];

        MovesList moves = new MovesList();

        /* Loading */
        line = br.readLine();
        while(line != null) {
            M = line.length();
            for(int j = 0; j < M; j++) {
                char c = line.charAt(j);
                if (c == '+' || c == '-') {
                    grid[N][j] = '.';
                    moves.append(new Move(N, j, 0, c));
                } else {
                    grid[N][j] = c;
                }
            }
            N++;

            line = br.readLine();
        }

        /* Play */
        int doom = 0;
        while (moves.length > 0) {
            Move m = moves.pop();
            char o = grid[m.i][m.j];

            if (doom > 0 && m.t > doom)
                break;

            if (o == m.c)
                continue;

            if ((o == '+' && m.c == '-') || (o == '-' && m.c == '+')) {
                doom = m.t;
                grid[m.i][m.j] = '*';
            } else if (o != '*') {
                grid[m.i][m.j] = m.c;
            }

            // up
            if (m.i > 0 && grid[m.i-1][m.j] != 'X' && grid[m.i-1][m.j] != '*'
                && !moves.contains(m.i-1,m.j,m.t+1,m.c)
            ) { moves.append(new Move(m.i-1, m.j, m.t+1, m.c)); }

            // down
            if (m.i < N-1 && grid[m.i+1][m.j] != 'X' && grid[m.i+1][m.j] != '*'
                && !moves.contains(m.i+1,m.j,m.t+1,m.c)
            ) { moves.append(new Move(m.i+1, m.j, m.t+1, m.c)); }

            // left
            if (m.j > 0 && grid[m.i][m.j-1] != 'X' && grid[m.i][m.j-1] != '*'
                && !moves.contains(m.i,m.j-1,m.t+1,m.c)
            ) { moves.append(new Move(m.i, m.j-1, m.t+1, m.c)); }

            // down
            if (m.j < M-1 && grid[m.i][m.j+1] != 'X' && grid[m.i][m.j+1] != '*'
                && !moves.contains(m.i,m.j+1,m.t+1,m.c)
            ) { moves.append(new Move(m.i, m.j+1, m.t+1, m.c)); }
        }

        if (doom == 0) {
            System.out.println("the world is saved");
        } else {
            System.out.println(doom);
        }

        //printGrid(N,M,grid);
        for (int i = 0; i < N; i++) {
            for (int j = 0; j < M; j++) {
                System.out.print(grid[i][j]);
            }
            System.out.print('\n');
        }
    }
}