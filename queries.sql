-- Q1

SELECT player_name
FROM player
WHERE batting_hand = 'Left-hand bat' AND country_name = 'England'
ORDER BY player_name;

-- Q2

SELECT player_name, player_age
FROM (	SELECT player_name, date_part('year', age('2018-12-02', dob)) AS player_age
		FROM player
		WHERE bowling_skill = 'Legbreak googly') AS p
WHERE player_age >= 28
ORDER BY player_age DESC, player_name ASC;

-- Q3

SELECT match_id, toss_winner AS match_winner
FROM match
WHERE toss_decision = 'bat'
ORDER BY match_id;

-- Q4 <innings_no should also have been asked>

SELECT over_id, sum(runs_scored) AS runs_scored
FROM batsman_scored
WHERE match_id = 335987
GROUP BY over_id, innings_no
HAVING sum(runs_scored) <= 7
ORDER BY sum(runs_scored) DESC, over_id;

-- Q5

SELECT DISTINCT player_name
FROM player, wicket_taken
WHERE player.player_id = wicket_taken.player_out AND (kind_out = 'bowled') 
ORDER BY player_name;

-- Q6

SELECT match_id, team_1, team_2, name AS winning_team_name, win_margin
FROM match, team
WHERE match.match_winner = team.team_id AND win_type = 'runs' AND win_margin >= 60
ORDER BY win_margin, match_id;

-- Q7

SELECT player_name
FROM player
WHERE batting_hand = 'Left-hand bat' AND date_part('year', age('2018-12-02',dob)) < 30
ORDER BY player_name;

-- Q8

SELECT match_id, sum(runs_scored) as total_runs
FROM batsman_scored
GROUP BY match_id
ORDER BY match_id;

-- Q9 <Look at some better way :P>

SELECT t1.match_id AS match_id, maximum_runs, player_name
FROM
	(SELECT match_id, MAX(total_runs) AS maximum_runs
	FROM
		(SELECT match_id, over_id, innings_no, SUM(runs_scored) as total_runs
		FROM batsman_scored
		GROUP BY match_id, over_id, innings_no) AS t
	GROUP BY match_id) AS t1, 
	(SELECT match_id, over_id, innings_no, bowler, SUM(runs_scored) as total_runs
		FROM batsman_scored NATURAL JOIN ball_by_ball
		GROUP BY match_id, over_id, innings_no, bowler) AS t,
	player
WHERE t1.match_id = t.match_id AND t1.maximum_runs = t.total_runs AND t.bowler = player.player_id
ORDER BY t1.match_id, over_id;

-- Q10

SELECT player_name, number
FROM player, (SELECT player_out, count(ball_id) as number
				FROM wicket_taken
				GROUP BY player_out, kind_out
				HAVING kind_out = 'run out') as runouts
WHERE player.player_id = runouts.player_out
ORDER BY number DESC, player_name;

-- Q11

SELECT kind_out as out_type, count(ball_id) as number
FROM wicket_taken
GROUP BY kind_out
ORDER BY count(ball_id) DESC, kind_out;

-- Q12

SELECT name, count(man_of_the_match) AS number
FROM
	(SELECT man_of_the_match, match.match_id, team.team_id, name
	FROM match, player_match, team
	WHERE match.match_id = player_match.match_id AND man_of_the_match = player_id AND player_match.team_id = team.team_id) as t
GROUP BY name
ORDER BY name;