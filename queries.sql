-- Q1

-- SELECT player_name
-- FROM player
-- WHERE batting_hand = 'Left-hand bat' AND country_name = 'England'
-- ORDER BY player_name;

-- Q2

-- SELECT player_name, age
-- FROM (	SELECT player_name, date_part('year', age(dob)) AS age
-- 		FROM player
-- 		WHERE bowling_skill = 'Legbreak googly') AS p
-- WHERE age >= 28
-- ORDER BY age DESC, player_name ASC;

-- Q3

-- SELECT match_id, toss_winner
-- FROM match
-- WHERE toss_decision = 'bat'
-- ORDER BY match_id;

-- Q4 ???????????????????

-- SELECT over_id, sum(runs_scored) AS runs
-- FROM batsman_scored
-- WHERE match_id = 335987
-- GROUP BY over_id, innings_no
-- HAVING sum(runs_scored) <= 7
-- ORDER BY sum(runs_scored) DESC, over_id

-- Q5

-- SELECT DISTINCT player_name
-- FROM player, wicket_taken
-- WHERE player.player_id = wicket_taken.player_out AND (kind_out = 'bowled' OR kind_out = 'caught and bowled') 
-- ORDER BY player_name;

-- Q6

-- SELECT match_id, team_1, team_2, match_winner, win_margin
-- FROM match
-- WHERE win_type = 'runs' AND win_margin >= 60
-- ORDER BY win_margin, match_id;

-- Q7

-- SELECT player_name
-- FROM player
-- WHERE batting_hand = 'Left-hand bat' AND date_part('year', age('2018-12-02',dob)) < 30
-- ORDER BY player_name;

-- Q8

-- SELECT match_id, sum(runs_scored) as total_runs
-- FROM batsman_scored
-- GROUP BY match_id
-- ORDER BY match_id;

-- Q9 ?????????????????????????????????????????

-- SELECT match_id, MAX(total_runs)
-- FROM
-- 	(SELECT match_id, over_id, innings_no, bowler, SUM(runs_scored) as total_runs
-- 	FROM batsman_scored JOIN ball_by_ball USING (match_id, over_id, innings_no, ball_id)
-- 	GROUP BY match_id, over_id, innings_no, bowler
-- 	ORDER BY match_id, over_id, innings_no) AS t
-- GROUP BY match_id
-- ORDER BY match_id;

-- Q10

-- SELECT player_name, num_of_times
-- FROM player, (SELECT player_out, count(ball_id) as num_of_times
-- 				FROM wicket_taken
-- 				GROUP BY player_out, kind_out
-- 				HAVING kind_out = 'run out') as runouts
-- WHERE player.player_id = runouts.player_out
-- ORDER BY num_of_times DESC, player_name;

-- Q11

-- SELECT kind_out as out_type, count(ball_id) as num
-- FROM wicket_taken
-- GROUP BY kind_out
-- ORDER BY count(ball_id) DESC, kind_out;

-- Q12

-- SELECT name, count
-- FROM team, 
-- 	(SELECT team_id, count(man_of_the_match) as count
-- 	FROM (SELECT match.match_winner as team_id, match.man_of_the_match
-- 		FROM match JOIN player_match
-- 		ON match.match_winner = player_match.team_id 
-- 			AND match.man_of_the_match = player_match.player_id 
-- 			AND match.match_id = player_match.match_id) as t
-- 	GROUP BY team_id) as t1
-- WHERE team.team_id = t1.team_id
-- ORDER BY name;