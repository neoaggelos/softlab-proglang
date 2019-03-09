/* Pistes.java */

import java.io.*;
import java.util.*;

class Round {
    public int stars;
    public Integer pos;
    public ArrayList<Integer> needs;
    public ArrayList<Integer> gives;

    public Round(int _s, ArrayList<Integer> n, ArrayList<Integer> g) {
        stars = _s;
        needs = n;
        gives = g;
    }

    public void print(int r)
    {
        System.out.println("Round: " + r + " >>> " + stars + " stars - needs: " + needs + " - gives: " + gives);
    }
}

class State {
    public int stars;
    public ArrayList<Integer> not_played;
    public ArrayList<Integer> keys;

    public State(int _s, ArrayList<Integer> _p, ArrayList<Integer> _k) {
        stars = _s;
        not_played = _p;
        keys = _k;
    }

    @Override
    public boolean equals(Object _o) {
        if (_o != null && _o instanceof State) {
            State o = (State)_o;
            return
                o.keys.size() == keys.size()
                && o.not_played.size() == not_played.size()
                && o.keys.equals(keys)
                && o.not_played.equals(not_played)
                && o.stars == stars;
        }
        return false;
    }

    public void debug(){
        System.out.println("Checking state: " + stars + " stars, keys: " + keys + ", not played: " + not_played);
    }
}


public class Pistes { 
    
    public static void main(String[] args) throws Exception {
        String fname = args[0];
        Scanner s = new Scanner(new FileReader(fname));
        ArrayList<Round> pistes = new ArrayList<Round>();
        ArrayList<State> tried = new ArrayList<State>();

        int N = s.nextInt();
        //System.out.println(N);
        for (int i = 0; i < N+1; i++) {
            int num_keys_needed = s.nextInt();
            int num_keys_given = s.nextInt();
            int stars = s.nextInt();

            ArrayList<Integer> keys_needed = new ArrayList<Integer>();
            ArrayList<Integer> keys_given = new ArrayList<Integer>();
            for (int j = 0; j < num_keys_needed; j++) {
                keys_needed.add(s.nextInt());
            }
            for (int j = 0; j < num_keys_given; j++) {
                keys_given.add(s.nextInt());
            }

            // makes sorting states faster later on
            Collections.sort(keys_needed);
            Collections.sort(keys_given);

            pistes.add(new Round(stars, keys_needed, keys_given));

            //pistes.get(i).print(i);
        }

        /* add initial state */
        int max_stars = 0;
        ArrayList<Integer> not_played = new ArrayList<Integer>();
        for (int i = 0; i < pistes.size(); i++)
            not_played.add(i);

        ArrayList<Integer> keys = new ArrayList<Integer>();
        tried.add(new State(0, not_played, keys));

        // for all remaining states
        for(int i = 0; i < tried.size(); i++) {
            State st = tried.get(i);
            max_stars = max_stars > st.stars ? max_stars : st.stars;
            //st.debug();

            // for all rounds not yet played in this state
            for (Integer rou : st.not_played) {
                Round r = pistes.get(rou);
                ArrayList<Integer> new_keys = new ArrayList<Integer>(st.keys);
                int new_stars = st.stars + r.stars;
                ArrayList<Integer> new_not_played = new ArrayList<Integer>(st.not_played);

                // play this round
                new_not_played.remove(rou);

                // check if we have the required keys for this round
                boolean has_required_keys = true;
                for (Integer key : r.needs) {
                    has_required_keys = has_required_keys && new_keys.remove(key);

                    if (!has_required_keys) {
                        break;
                    }
                }

                // We can't play this round, go next
                if (!has_required_keys) continue;

                // If we played all rounds, then we are done
                if (new_not_played.isEmpty()) {
                    // System.out.println("Played all rounds, finishing...");
                    max_stars = new_stars;
                    break;
                }

                // We can play, add the keys that we get from beating it
                for (Integer key : r.gives) {
                    new_keys.add(key);
                }

                // sort keys, makes checking for duplicate states much much faster
                Collections.sort(new_keys);

                // Add the new state in the list if it does not already exist
                State new_state = new State(new_stars, new_not_played, new_keys);

                if (!tried.contains(new_state))
                    tried.add(new_state);
            }
        }
        System.out.println(max_stars);
    }
}