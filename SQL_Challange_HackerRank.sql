-- Link Challange 1: Top Competitors (https://www.hackerrank.com/challenges/full-score/problem)

SELECT h.hacker_id,h.name 
FROM hackers h, challenges c, difficulty d, submissions s 
WHERE h.hacker_id = s.hacker_id
    and c.challenge_id = s.challenge_id
    and c.difficulty_level = d.difficulty_level
    and s.score = d.score
GROUP BY h.hacker_id, h.name 
HAVING COUNT(h.hacker_id) > 1
ORDER BY COUNT(c.challenge_id) DESC, h.hacker_id

-- Link Challange 2: Placements (https://www.hackerrank.com/challenges/placements/problem)

SELECT S.Name
FROM (Students S 
       JOIN Friends F ON S.ID = F.ID
       JOIN Packages P1 ON S.ID = P1.ID
       JOIN Packages P2 ON F.Friend_ID = P2.ID)
WHERE P2.Salary > P1.Salary
ORDER BY P2.Salary;

-- Link Challange 3: New companies (https://www.hackerrank.com/challenges/the-company/problem)

SELECT c.company_code, 
    c.founder, 
    COUNT(DISTINCT e.lead_manager_code), 
    COUNT(DISTINCT e.senior_manager_code), 
    COUNT(DISTINCT e.manager_code), 
    COUNT(DISTINCT e.employee_code)
FROM company c
    INNER JOIN employee e ON e.company_code = c.company_code
GROUP BY c.company_code, c.founder
ORDER BY c.company_code;

--Link Challange 5: SQL Project Planning (https://www.hackerrank.com/challenges/sql-projects/problem)

SET sql_mode = '';
SELECT Start_Date, End_Date
FROM 
    (SELECT Start_Date FROM Projects WHERE Start_Date NOT IN (SELECT End_Date FROM Projects)) a,
    (SELECT End_Date FROM Projects WHERE End_Date NOT IN (SELECT Start_Date FROM Projects)) b 
WHERE Start_Date < End_Date
GROUP BY Start_Date 
ORDER BY DATEDIFF(End_Date, Start_Date), Start_Date

--Link Challange 6: Interviews (https://www.hackerrank.com/challenges/interviews/problem)

SELECT con.contest_id, con.hacker_id, con.name, 
    SUM(sg.total_submissions), SUM(sg.total_accepted_submissions), 
    SUM(vg.total_views), SUM(vg.total_unique_views)
FROM Contests AS con

JOIN Colleges AS col 
ON con.contest_id = col.contest_id

JOIN Challenges AS cha 
ON cha.college_id = col.college_id

LEFT JOIN 
    (SELECT ss.challenge_id, SUM(ss.total_submissions) AS total_submissions,
    SUM(ss.total_accepted_submissions) AS total_accepted_submissions 
     FROM Submission_Stats AS ss 
     GROUP BY ss.challenge_id) AS sg
ON cha.challenge_id = sg.challenge_id

LEFT JOIN
    (SELECT vs.challenge_id, SUM(vs.total_views) AS total_views,                                
    SUM(vs.total_unique_views) AS total_unique_views
     FROM View_Stats AS vs 
     GROUP BY vs.challenge_id) AS vg
ON cha.challenge_id = vg.challenge_id

GROUP BY con.contest_id, con.hacker_id, con.name
HAVING SUM(sg.total_submissions) +
       SUM(sg.total_accepted_submissions) +
       SUM(vg.total_views) +
       SUM(vg.total_unique_views) > 0
ORDER BY con.contest_id;

--Link Challange 7: Symmetric Pairs (https://www.hackerrank.com/challenges/symmetric-pairs/problem)

SELECT f1.X, f1.Y FROM Functions f1
INNER JOIN Functions f2 ON f1.X=f2.Y AND f1.Y=f2.X
GROUP BY f1.X, f1.Y
HAVING COUNT(f1.X) > 1 or f1.X < f1.Y
ORDER BY f1.X

--Link Challange 8: Contest Leaderboard (https://www.hackerrank.com/challenges/contest-leaderboard/problem)

SELECT h.hacker_id, h.name, SUM(tong) 
FROM(
    SELECT hacker_id, challenge_id, MAX(score) AS tong 
    FROM SUBMISSIONS
    GROUP BY hacker_id, challenge_id
) t 
JOIN Hackers h on t.hacker_id = h.hacker_id
GROUP BY h.hacker_id, h.name
HAVING SUM(tong) > 0
ORDER BY SUM(tong) desc, h.hacker_id

--Link Challage 9: Draw The Triangle

SET @number = 21;
SELECT REPEAT('* ', @number := @number - 1) 
FROM information_schema.tables;

SET @row := 0;
SELECT REPEAT('* ', @row := @row + 1) 
FROM information_schema.tables 
WHERE @row < 20

--Link Challage 10: The PADS (https://www.hackerrank.com/challenges/the-pads/problem)

SELECT CONCAT(NAME, "(", LEFT(OCCUPATION, 1), ")") 
FROM OCCUPATIONS 
ORDER BY NAME ASC;

SELECT CONCAT("There are a total of ", COUNT(OCCUPATION), " ", LOWER(OCCUPATION), "s.") 
FROM OCCUPATIONS 
GROUP BY OCCUPATION 
ORDER BY COUNT(OCCUPATION) ASC, OCCUPATION ASC

--Link Challage 11: Weather Observation 20 - Find Median (https://www.hackerrank.com/challenges/weather-observation-station-20/problem)

SELECT round(S.LAT_N,4) 
FROM station as S 
WHERE (SELECT COUNT(Lat_N) 
       FROM station WHERE Lat_N < S.LAT_N ) = (SELECT COUNT(Lat_N) 
                                               FROM station WHERE Lat_N > S.LAT_N)