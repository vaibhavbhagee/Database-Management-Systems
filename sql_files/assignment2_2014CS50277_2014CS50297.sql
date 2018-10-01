--1--

SELECT player_name FROM player WHERE batting_hand = 'Left-hand bat' AND country_name = 'England' ORDER BY player_name;

--2--

SELECT player_name, player_age FROM (	SELECT player_name, date_part('year', age('2018-02-12', dob)) AS player_age		FROM player		WHERE bowling_skill = 'Legbreak googly') AS p WHERE player_age >= 28 ORDER BY player_age DESC, player_name ASC;

--3--

SELECT match_id, toss_winner FROM match WHERE toss_decision = 'bat' ORDER BY match_id;

--4--

WITH t1 AS (SELECT over_id, innings_no, sum(runs_scored) AS runs_scored FROM batsman_scored WHERE match_id = 335987 GROUP BY over_id, innings_no), t2 AS (SELECT over_id, innings_no, sum(extra_runs) AS extra_runs FROM extra_runs WHERE match_id = 335987 GROUP BY over_id, innings_no), t3 AS (SELECT t1.over_id AS over_id, t1.innings_no AS innings_no, runs_scored, CASE WHEN t2.extra_runs IS NULL         THEN 0     ELSE t2.extra_runs END AS extra_runs FROM  t1 LEFT OUTER JOIN t2 ON (t1.over_id, t1.innings_no) = (t2.over_id, t2.innings_no) ORDER BY innings_no, over_id) SELECT over_id, (runs_scored + extra_runs) as runs_scored FROM t3 WHERE runs_scored + extra_runs <= 7 ORDER BY (runs_scored + extra_runs) DESC, over_id;

--5--

SELECT DISTINCT player_name FROM player, wicket_taken WHERE player.player_id = wicket_taken.player_out AND (kind_out = 'bowled')  ORDER BY player_name;

--6--

SELECT match_id, t2.name AS team_1, t3.name AS team_2, t1.name AS winning_team_name, win_margin FROM match, team AS t1, team AS t2, team AS t3 WHERE match.match_winner = t1.team_id AND match.team_1 = t2.team_id AND match.team_2 = t3.team_id AND win_type = 'runs' AND win_margin >= 60 ORDER BY win_margin, match_id;

--7--

SELECT player_name FROM player WHERE batting_hand = 'Left-hand bat' AND date_part('year', age('2018-02-12',dob)) < 30 ORDER BY player_name;

--8--

WITH t1 AS  (SELECT match_id, sum(runs_scored) AS runs_scored FROM batsman_scored GROUP BY match_id), t2 AS (SELECT match_id, sum(extra_runs) AS extra_runs FROM extra_runs GROUP BY match_id), t3 AS (SELECT t1.match_id AS match_id, runs_scored, CASE WHEN t2.extra_runs IS NULL         THEN 0     ELSE t2.extra_runs END AS extra_runs FROM  t1 LEFT OUTER JOIN t2 ON (t1.match_id) = (t2.match_id) ORDER BY match_id) SELECT match_id, (runs_scored + extra_runs) AS total_runs FROM t3 ORDER BY match_id;

--9--

WITH t1 AS  (SELECT match_id, over_id, innings_no, sum(runs_scored) AS runs_scored FROM batsman_scored GROUP BY match_id, over_id, innings_no), t2 AS (SELECT match_id, over_id, innings_no, sum(extra_runs) AS extra_runs FROM extra_runs GROUP BY match_id, over_id, innings_no), t3 AS (SELECT t1.match_id AS match_id, t1.over_id AS over_id, t1.innings_no AS innings_no, runs_scored, CASE WHEN t2.extra_runs IS NULL         THEN 0     ELSE t2.extra_runs END AS extra_runs FROM  t1 LEFT OUTER JOIN t2 ON (t1.match_id, t1.over_id, t1.innings_no) = (t2.match_id, t2.over_id, t2.innings_no) ORDER BY match_id, innings_no, over_id), t4 AS  (SELECT match_id, over_id, innings_no, (runs_scored + extra_runs) AS total_runs, bowler FROM t3 NATURAL JOIN ball_by_ball GROUP BY match_id, over_id, innings_no, (runs_scored + extra_runs), bowler) SELECT t_1.match_id AS match_id, maximum_runs, player_name FROM 	(SELECT match_id, MAX(runs_scored + extra_runs) AS maximum_runs 	FROM t3 	GROUP BY match_id) AS t_1, t4, player WHERE t_1.match_id = t4.match_id AND t_1.maximum_runs = t4.total_runs AND t4.bowler = player.player_id ORDER BY t_1.match_id, over_id;

--10--

SELECT player_name, CASE WHEN runouts.number IS NULL         THEN 0        ELSE runouts.number END AS number FROM player LEFT OUTER JOIN (SELECT player_out, count(ball_id) AS number 				FROM wicket_taken 				GROUP BY player_out, kind_out 				HAVING kind_out = 'run out') AS runouts ON player.player_id = runouts.player_out ORDER BY number DESC, player_name;

--11--

SELECT kind_out AS out_type, count(ball_id) AS number FROM wicket_taken GROUP BY kind_out ORDER BY count(ball_id) DESC, kind_out;

--12--

SELECT name, count(man_of_the_match) AS number FROM 	(SELECT man_of_the_match, match.match_id, team.team_id, name 	FROM match, player_match, team 	WHERE match.match_id = player_match.match_id AND man_of_the_match = player_id AND player_match.team_id = team.team_id) AS t GROUP BY name ORDER BY name;

--13--

SELECT venue FROM extra_runs, match WHERE extra_runs.extra_type = 'wides' AND extra_runs.match_id = match.match_id GROUP BY venue ORDER BY count(extra_type) DESC, venue LIMIT 1;

--14--

SELECT venue FROM match WHERE ((match_winner = toss_winner) AND (toss_decision = 'field')) OR ((match_winner <> toss_winner) AND (toss_decision = 'bat')) GROUP BY venue ORDER BY count(*) DESC, venue;

--15--

WITH  t_1 AS  (SELECT match_id, over_id, innings_no, bowler, sum(runs_scored) AS total_runs_scored FROM batsman_scored NATURAL JOIN ball_by_ball GROUP BY match_id, over_id, innings_no, bowler), t_2 AS  (SELECT match_id, over_id, innings_no, bowler, sum(extra_runs) AS extra_runs_scored FROM extra_runs NATURAL JOIN ball_by_ball GROUP BY match_id, over_id, innings_no, bowler), t_3 AS (SELECT t_1.match_id AS match_id, t_1.over_id AS over_id, t_1.innings_no AS innings_no, t_1.bowler AS bowler, total_runs_scored, CASE WHEN t_2.extra_runs_scored IS NULL         THEN 0     ELSE t_2.extra_runs_scored END AS extra_runs_scored FROM t_1 LEFT OUTER JOIN t_2 ON (t_1.match_id, t_1.over_id, t_1.innings_no, t_1.bowler) = (t_2.match_id, t_2.over_id, t_2.innings_no, t_2.bowler)), t_4 AS  (SELECT bowler, sum(total_runs_scored+extra_runs_scored) AS runs_given FROM t_3 GROUP BY bowler), t_5 AS (SELECT bowler, count(player_out) AS num_wickets FROM ball_by_ball NATURAL JOIN wicket_taken GROUP by bowler) SELECT player_name FROM 	(SELECT t_4.bowler AS bowler, player_name, round(1.0*runs_given/num_wickets,3) AS average 	FROM 		t_4, t_5, player 	WHERE player.player_id = t_4.bowler AND t_4.bowler = t_5.bowler) AS t1  ORDER BY average LIMIT 1;

--16--

SELECT player_name, name FROM match, player_match, player, team WHERE  	role = 'CaptainKeeper'  	AND match.match_id = player_match.match_id  	AND match_winner = player_match.team_id  	AND player_match.player_id = player.player_id  	AND player_match.team_id = team.team_id ORDER BY player_name, name;

--17--

SELECT player_name, runs_scored FROM 	( 	(SELECT DISTINCT striker 	FROM ball_by_ball NATURAL JOIN batsman_scored 	GROUP BY match_id, striker 	HAVING sum(runs_scored) >= 50) AS t1 	NATURAL JOIN 	(SELECT striker, sum(runs_scored) AS runs_scored 	FROM ball_by_ball NATURAL JOIN batsman_scored 	GROUP BY striker) AS t2) AS t3,  	player WHERE striker = player_id ORDER BY runs_scored DESC, player_name;

--18--

SELECT player_name FROM 	(SELECT striker, match_id 	FROM ball_by_ball NATURAL JOIN batsman_scored 	GROUP BY match_id, striker 	HAVING sum(runs_scored) >= 100) AS t1, 	player_match, match, player WHERE  	t1.match_id = player_match.match_id 	AND match.match_id = t1.match_id 	AND player_match.player_id = striker 	AND striker = player.player_id 	AND player_match.team_id <> match.match_winner ORDER BY player_name;

--19--

SELECT match_id, venue FROM match, team WHERE team.name = 'Kolkata Knight Riders' AND ( 	(team_id = team_1 AND team_2 = match_winner) 	OR 	(team_id = team_2 AND team_1 = match_winner) 	) ORDER BY match_id;

--20--

WITH t1 AS (SELECT striker, sum(runs_scored) AS runs_scored FROM (ball_by_ball NATURAL JOIN batsman_scored) as t, match WHERE t.match_id = match.match_id AND season_id = 5 GROUP BY striker), t2 AS (SELECT player_id as striker, ball_by_ball.match_id AS match_id FROM ball_by_ball, player, match WHERE (player.player_id = ball_by_ball.striker OR player.player_id = ball_by_ball.non_striker) AND match.match_id = ball_by_ball.match_id AND season_id = 5), t3 AS (SELECT striker, count(DISTINCT match_id) AS num_matches FROM t2 GROUP BY striker) SELECT player_name FROM 	(SELECT striker, round(1.0*runs_scored/num_matches,3) AS average 	FROM t1 NATURAL JOIN t3) AS t4, player WHERE player.player_id = t4.striker ORDER BY average DESC, player_name LIMIT 10;

--21--

WITH t1 AS (SELECT striker, sum(runs_scored) AS runs_scored FROM (ball_by_ball NATURAL JOIN batsman_scored) as t, match WHERE t.match_id = match.match_id GROUP BY striker), t2 AS (SELECT player_id as striker, ball_by_ball.match_id AS match_id FROM ball_by_ball, player, match WHERE (player.player_id = ball_by_ball.striker OR player.player_id = ball_by_ball.non_striker) AND match.match_id = ball_by_ball.match_id), t3 AS (SELECT striker, count(DISTINCT match_id) AS num_matches FROM t2 GROUP BY striker), t4 AS (SELECT striker as player_id, round(1.0*runs_scored/num_matches,3) AS average  FROM t1 NATURAL JOIN t3), t5 AS  (SELECT country_name, sum(average) AS avg_sum FROM player NATURAL JOIN t4 GROUP BY country_name), t6 AS (SELECT country_name, count(*) AS num_players FROM player GROUP BY country_name), t7 AS (SELECT * from t5 NATURAL JOIN t6), t8 AS (SELECT country_name, round(1.0*avg_sum/num_players,3) AS country_avg FROM t7 ORDER BY country_avg DESC), t9 AS (SELECT DISTINCT country_avg FROM t8 ORDER BY country_avg DESC LIMIT 5) SELECT country_name FROM t8 WHERE country_avg IN (SELECT * FROM t9);
