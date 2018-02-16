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

SELECT match_id, sum(runs_scored) AS total_runs
FROM batsman_scored
GROUP BY match_id
ORDER BY match_id;

-- Q9 <Look at some better way :P>

SELECT t1.match_id AS match_id, maximum_runs, player_name
FROM
	(SELECT match_id, MAX(total_runs) AS maximum_runs
	FROM
		(SELECT match_id, over_id, innings_no, SUM(runs_scored) AS total_runs
		FROM batsman_scored
		GROUP BY match_id, over_id, innings_no) AS t
	GROUP BY match_id) AS t1, 
	(SELECT match_id, over_id, innings_no, bowler, SUM(runs_scored) AS total_runs
		FROM batsman_scored NATURAL JOIN ball_by_ball
		GROUP BY match_id, over_id, innings_no, bowler) AS t,
	player
WHERE t1.match_id = t.match_id AND t1.maximum_runs = t.total_runs AND t.bowler = player.player_id
ORDER BY t1.match_id, over_id;

-- Q10 <ALSO consider players who have been run out 0 times>

SELECT player_name, number
FROM player, (SELECT player_out, count(ball_id) AS number
				FROM wicket_taken
				GROUP BY player_out, kind_out
				HAVING kind_out = 'run out') AS runouts
WHERE player.player_id = runouts.player_out
ORDER BY number DESC, player_name;

-- Q11

SELECT kind_out AS out_type, count(ball_id) AS number
FROM wicket_taken
GROUP BY kind_out
ORDER BY count(ball_id) DESC, kind_out;

-- Q12

SELECT name, count(man_of_the_match) AS number
FROM
	(SELECT man_of_the_match, match.match_id, team.team_id, name
	FROM match, player_match, team
	WHERE match.match_id = player_match.match_id AND man_of_the_match = player_id AND player_match.team_id = team.team_id) AS t
GROUP BY name
ORDER BY name;

-- Q13

SELECT venue
FROM extra_runs, match
WHERE extra_runs.extra_type = 'wides' AND extra_runs.match_id = match.match_id
GROUP BY venue
ORDER BY count(extra_type) DESC, venue
LIMIT 1;

-- Q14 <ordering is DESC or ASC>

SELECT venue
FROM match
WHERE ((match_winner = toss_winner) AND (toss_decision = 'field')) OR ((match_winner <> toss_winner) AND (toss_decision = 'bat'))
GROUP BY venue
ORDER BY count(*), venue;

-- Q15 <CHECK the output>

SELECT player_name
FROM
	(SELECT bowler, round(1.0*runs_given/num_wickets,3) AS average
	FROM
		(SELECT bowler, sum(runs_scored) AS runs_given
		FROM ball_by_ball NATURAL JOIN batsman_scored
		GROUP BY bowler) AS t1
		NATURAL JOIN
		(SELECT bowler, count(player_out) AS num_wickets
		FROM ball_by_ball NATURAL JOIN wicket_taken
		GROUP by bowler) AS t2) AS t3,
	player
WHERE player.player_id = t3.bowler 
ORDER BY average
LIMIT 1;

-- Q16 ???????????????????????? order by team name?

SELECT player_name, name
FROM match, player_match, player, team
WHERE 
	role = 'CaptainKeeper' 
	AND match.match_id = player_match.match_id 
	AND match_winner = player_match.team_id 
	AND player_match.player_id = player.player_id 
	AND player_match.team_id = team.team_id
GROUP BY player_name, name
ORDER BY player_name;

-- Q17 <runs scored means total runs or runs in every match>

SELECT player_name, runs_scored
FROM
	(
	(SELECT DISTINCT striker
	FROM ball_by_ball NATURAL JOIN batsman_scored
	GROUP BY match_id, striker
	HAVING sum(runs_scored) >= 50) AS t1
	NATURAL JOIN
	(SELECT striker, sum(runs_scored) AS runs_scored
	FROM ball_by_ball NATURAL JOIN batsman_scored
	GROUP BY striker) AS t2) AS t3, 
	player
WHERE striker = player_id
ORDER BY runs_scored DESC, player_name;

-- Q18

SELECT player_name
FROM
	(SELECT striker, match_id
	FROM ball_by_ball NATURAL JOIN batsman_scored
	GROUP BY match_id, striker
	HAVING sum(runs_scored) >= 100) AS t1,
	player_match, match, player
WHERE 
	t1.match_id = player_match.match_id
	AND match.match_id = t1.match_id
	AND player_match.player_id = striker
	AND striker = player.player_id
	AND player_match.team_id <> match.match_winner
ORDER BY player_name;

-- Q19

SELECT match_id, venue
FROM match, team
WHERE team.name = 'Kolkata Knight Riders'
AND (
	(team_id = team_1 AND team_2 = match_winner)
	OR
	(team_id = team_2 AND team_1 = match_winner)
	)
ORDER BY match_id;

-- Q20

SELECT player_name
FROM
	(SELECT striker, round(1.0*runs_scored/num_matches,3) AS average
	FROM
		(SELECT striker, sum(runs_scored) AS runs_scored
		FROM (ball_by_ball NATURAL JOIN batsman_scored) as t, match
		WHERE t.match_id = match.match_id AND season_id = 5
		GROUP BY striker) AS t1
		NATURAL JOIN
		(SELECT player_id as striker, count(role) AS num_matches
		FROM player_match, match
		WHERE match.match_id = player_match.match_id AND season_id = 5
		GROUP by player_id) AS t2) AS t3,
	player
WHERE player.player_id = t3.striker
ORDER BY average DESC, player_name
LIMIT 10;

-- Q21

SELECT country_name
FROM
	(SELECT striker as player_id, round(1.0*runs_scored/num_matches,3) AS average
	FROM
		(SELECT striker, sum(runs_scored) AS runs_scored
		FROM (ball_by_ball NATURAL JOIN batsman_scored) as t
		GROUP BY striker) AS t1
		NATURAL JOIN
		(SELECT player_id as striker, count(role) AS num_matches
		FROM player_match
		GROUP by player_id) AS t2) AS t3
	NATURAL JOIN player
GROUP BY country_name
ORDER BY round(AVG(average),3) DESC;