/* agora.cpp */

#include <iostream>
#include <fstream>
#include <cstdlib>

using namespace std;
typedef long long Long;

Long gcd(Long a, Long b)
{
    return b == 0 ? a : gcd(b, a%b);
}

Long lcm(Long a, Long b)
{
    return a / gcd(a,b) * b;
}

/* live with honor, die with glory */
void die(string msg = "")
{
    cerr << "Too bad: " << msg << endl;
    exit(-1);
}

int main(int argc, char** argv)
{
    if (argc != 2)
        die("no input file");

    ifstream fin(argv[1]);
    if (!fin.is_open())
        die("bad input file");

    int n;
    fin >> n;
    if (n <= 1)
        die("obscure error");

    Long *x = new Long[n];
    for (int i = 0; i < n; i++) {
        fin >> x[i];
    }

    Long* lcm_r = new Long[n];
    Long* lcm_l = new Long[n];
    lcm_r[0] = x[0];
    lcm_l[n-1] = x[n-1];
    for (int i = 1; i < n; i++) {
        lcm_r[i] = lcm(lcm_r[i-1], x[i]);
        lcm_l[n-1-i] = lcm(lcm_l[n-i], x[n-1-i]);
    }

    Long* lcm_without = new Long[n];
    lcm_without[0] = lcm_l[1];
    lcm_without[n-1] = lcm_r[n-2];

    int index = lcm_without[0] < lcm_without[n-1] ? 0 : n-1;
    for(int i = 1; i < n-1; i++) {
        lcm_without[i] = lcm(lcm_r[i-1], lcm_l[i+1]);

        index = lcm_without[i] < lcm_without[index] ? i : index;
    }

    if (lcm_without[index] % x[index] == 0) {
        cout << lcm_without[index] << " " << 0 << endl;
    } else {
        cout << lcm_without[index] << " " << index+1 << endl;
    }
    
    return 0;
}
