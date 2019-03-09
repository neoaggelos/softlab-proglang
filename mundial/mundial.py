# mundial.py

from math import log
from sys import argv

class Match:
    def __init__(self, teama, teamb, scorea, scoreb):
        self.teams = [teama, teamb]
        self.scores = [scorea, scoreb]

    def __repr__(self):
        return self.teams[0] + "-" + self.teams[1] + " " + str(self.scores[0]) + "-" + str(self.scores[1])

class TournamentState:
    def __init__(self):
        self.round = 1
        self.matches = []           # matches so far
        self.stats = {}                     # TeamStats for remaining teams
        self.loser_teams = []               # teams that lose this round
        self.winner_teams = []              # teams that also play next round
        self.not_played_this_round = []

        self.parent = None

    def clone(self):
        t = TournamentState()
        t.round = self.round+1
        t.matches = list(self.matches)

        t.stats = {}
        for k in self.stats:
            v = self.stats[k]
            t.stats[k] = TeamStats([k, v.num_matches, v.goals_for, v.goals_against])

        t.loser_teams = list(self.loser_teams)
        t.winner_teams = list(self.winner_teams)

        t.not_played_this_round = list(self.not_played_this_round)

        t.parent = self
        return t

class TeamStats:
    def __init__(self, contents):
        self.num_matches = int(contents[1])
        self.goals_for = int(contents[2])
        self.goals_against = int(contents[3])

    def __repr__(self):
        return str.format('M: {}, GF: {}, GA: {}', self.num_matches, self.goals_for, self.goals_against)

with open(argv[1]) as fin:
    N = int(fin.readline())
    rounds = int(log(N,2))

    # input
    state = TournamentState()

    #new
    finalists = []
    #endnew

    for line in fin:
        contents = line.split(' ')

        # add team stats
        teamname = contents[0]

        #new
        if int(contents[1]) == rounds:
            finalists.append(teamname)
        #endnew

        state.stats[teamname] = TeamStats(contents)

        # add to losing or winner teams
        if state.stats[teamname].num_matches == 1:
            state.loser_teams.append(teamname)
        else:
            state.winner_teams.append(teamname)
            state.not_played_this_round.append(teamname)

result_state = None
state.parent = state
found = 0

# input is initial state
states = [state]


for s in states:
    # last two teams, if possible add final match and finish
    if len(s.winner_teams) == 2 and len(s.loser_teams) == 0:
        #print(s.winner_teams, s.loser_teams)
        stats_1 = s.stats[s.winner_teams[0]]
        stats_2 = s.stats[s.winner_teams[1]]
        if (stats_1.goals_against == stats_2.goals_for) and (stats_1.goals_for == stats_2.goals_against) and stats_1.goals_against != stats_1.goals_for: #new new condition added and one was removed#endnew
            s.matches.append(Match(s.winner_teams[0], s.winner_teams[1], stats_1.goals_for, stats_1.goals_against))
            result_state = s
            found = 1
            break

    elif len(s.loser_teams) == 0:
        for winner in s.winner_teams:
            if s.stats[winner].num_matches == 1:
                s.winner_teams.remove(winner)
                s.loser_teams.append(winner)

        s.not_played_this_round = list(s.winner_teams)

    if len(s.loser_teams) == 0:
        continue
    loser = s.loser_teams[0]
    stats_l = s.stats[loser]
    temp = list(s.not_played_this_round)

    for winner in temp: #new iter at temp #newend
        stats_w = s.stats[winner]
        #print(stats_w, s.parent.stats[winner])

        if (stats_l.goals_for <= stats_w.goals_against) and (stats_l.goals_against + max(0, stats_w.num_matches - 2) <= stats_w.goals_for) and stats_l.goals_against != stats_l.goals_for:
            new_state = s.clone()

            m = Match(winner, loser, stats_l.goals_against, stats_l.goals_for)

            new_state.matches.append(m)

            # update winner
            new_state.stats[winner].num_matches -= 1
            new_state.stats[winner].goals_for -= stats_l.goals_against
            new_state.stats[winner].goals_against -= stats_l.goals_for

            new_state.not_played_this_round.remove(winner)

            new_state.stats.pop(loser)
            new_state.loser_teams.remove(loser)

            # add to new states (if not already there?)
            states.append(new_state)


# output
for m in result_state.matches:
    print(m)