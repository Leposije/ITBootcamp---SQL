-- Kreirtanje VIEW-a team_matches

CREATE OR REPLACE VIEW team_matches AS
WITH sides AS (
SELECT match_id, season, matchday, kickoff_ts,
home_team_id AS team_id, away_team_id AS opponent_id, 'home' AS
venue,
home_goals AS goals_for, away_goals AS goals_against
FROM matches WHERE status = 'played'
UNION ALL
SELECT match_id, season, matchday, kickoff_ts,
away_team_id, home_team_id, 'away',
away_goals, home_goals
FROM matches WHERE status = 'played'
)
SELECT *,
CASE WHEN goals_for > goals_against THEN 'W'
WHEN goals_for = goals_against THEN 'D' ELSE 'L' END AS result,
CASE WHEN goals_for > goals_against THEN 3
WHEN goals_for = goals_against THEN 1 ELSE 0 END AS points
FROM sides;


-- 1.Преглед сезоне: број утакмица и голова, просечан број голова по утакмици, удео победа
-- домаћина, нерешених и победа гостију.
SELECT count (*) as broj_utakmica,
    SUM(home_goals + away_goals) as golovi,
    ROUND (100.0 * SUM (CASE WHEN home_goals > away_goals then 1 else 0 end)/ COUNT(*),1) 
    as domacin,
    ROUND (100.0 * SUM (CASE WHEN home_goals = away_goals then 1 else 0 end)/ COUNT(*),1) 
    as nereseno,
    ROUND (100.0 * SUM (CASE WHEN home_goals < away_goals then 1 else 0 end)/ COUNT(*),1) 
    as gost
FROM matches as m
JOIN team_matches as t on m.match_id = t.match_id 
WHERE m.season = '2024/25' and m.status = 'played'

-- br. utakmica 760	 golovi 2184	U procentima rezultati  domacin 41.3	neresno 25.0	gost 33.7


-- 2. По месецима: број утакмица и голова по месецима, и просечан број голова по утакмици у
-- сваком месецу. Који месец се издваја?


SELECT month(m.kickoff_ts) as mesec,
    COUNT (*) as utakmica,
    SUM (home_goals + away_goals) as golovi,
    ROUND (AVG(home_goals + away_goals),2) as prosek_golova
FROM matches as m
JOIN team_matches as t  ON m.match_id = t.match_id
WHERE m.season = '2024/25' AND m.status = 'played'
GROUP BY month(m.kickoff_ts)
ORDER BY mesec;

-- Januar , 102 utakmice, 274 golova, prosek 2.69



-- 3. Публика: просечна посета и попуњеност по стадиону; утакмице без податка о посети и
-- утакмица без публике.
SELECT s.stadium_name,
       ROUND(AVG(m.attendance)) AS prosek,
       ROUND(AVG(100 * m.attendance / s.capacity), 1) AS popunjenost_pct,
       COUNT(*) - COUNT(m.attendance) AS bez_podatka,
       COUNT(attendance = 0) as utakmice_bez_publike 
FROM matches m
JOIN teams    t ON m.home_team_id = t.team_id
JOIN stadiums s ON m.stadium_id   = s.stadium_id
WHERE m.season = '2024/25' AND m.status = 'played'
GROUP BY s.stadium_name
ORDER by popunjenost_pct desc;

-- Elmsworth Lane	21746 prosek	90.6 procenat 	1 bez podataka	18 bez publike

-- Drugi problem ,kako moze da racunamo podatke, tj prosek kada memamo podatak o attendance




-- 4. Судије: за сваког судију број утакмица и картони по утакмици.

SELECT r.referee_name,
        COUNT(distinct m.match_id) as broj_utakmica,
    --    SUM(CASE WHEN e.event_type = 'yellow_card'   THEN 1 ELSE 0 END) AS zuti,
    --    SUM(CASE WHEN e.event_type = 'second_yellow' THEN 1 ELSE 0 END) AS drugi_zuti,
    --    SUM(CASE WHEN e.event_type = 'red_card'      THEN 1 ELSE 0 END) AS crveni,
       ROUND(COUNT(e.event_id) / COUNT(distinct(m.match_id)), 2) as karton_po_utakmici
FROM match_events e
JOIN matches m ON e.match_id = m.match_id
JOIN referees   r ON m.referee_id  = r.referee_id
WHERE m.season = '2024/25' AND m.status = 'played'
 AND e.event_type IN ('yellow_card', 'second_yellow', 'red_card')
 Group by r.referee_id, r.referee_name
 ORDER BY karton_po_utakmici desc;


-- Peter Lindgren	    19	    4.47  prosek kartona po utakmici
-- Amir Haddad	        19	    4.32
-- Mark Halsey-Brown    18	    4.17




-- 5. Играчи: пет најбољих стрелаца и пет најбољих асистената.
SELECT p.first_name, p.last_name, COUNT(*) AS golovi
FROM match_events e
JOIN matches m ON e.match_id  = m.match_id
JOIN players p ON e.player_id = p.player_id
JOIN teams   t ON e.team_id   = t.team_id
WHERE m.season = '2024/25' AND e.event_type IN ('goal', 'penalty_goal')
GROUP BY p.player_id, p.first_name, p.last_name
ORDER BY golovi DESC
LIMIT 5;

-- Mattéo	O'Brien	34
-- Leo	Marsh	32
-- José	Muñoz	24
-- Marko	Stanković	17
-- Leo	Marsh	16

-- Potencialni problem ,dva lika sa isto ime. mora player_id


-- Po assistencijama
SELECT p.first_name, p.last_name, COUNT(*) AS asistencija
FROM match_events e
JOIN matches m ON e.match_id  = m.match_id
JOIN players p ON e.related_player_id = p.player_id
JOIN teams   t ON e.team_id   = t.team_id
WHERE m.season = '2024/25' AND e.event_type IN ('goal', 'penalty_goal')
GROUP BY p.player_id, p.first_name, p.last_name
ORDER BY asistencija DESC
LIMIT 5;

-- Pablo	Fernández	9
-- Filip	Petrović	7
-- Eirik	Solberg	7
-- Lucas	Pereira	7
-- Mikkel	Nielsen	6





-- 6. Квалитет података: бар два проблема на која сте наишли у подацима (на пример утакмица
-- чији резултат се не слаже са догађајима, догађаји са непостојећим играчем, дан без
-- тренера), са упитима који их проналазе.

-- Problem: dogadjaji sa nepostojecim igracem
SELECT e.event_id, e.player_id, e.event_type
FROM match_events e LEFT JOIN players p ON e.player_id = p.player_id
WHERE e.player_id IS NOT NULL AND p.player_id IS NULL;

-- 1024	99999	yellow_card
-- 1634	99999	yellow_card

SELECT s.match_id, CAST(s.kickoff_ts AS DATE) as datum,
    t.team_name
FROM team_matches as s
JOIN teams as t ON t.team_id = s.team_id
WHERE NOT EXISTS (
    SELECT 1 from manager_spells as ms
    WHERE ms.team_id = s.team_id
        AND CAST(s.kickoff_ts as DATE) >= ms.start_date
        AND CAST(s.kickoff_ts as date) <= COALESCE(ms.end_date, DATE '9999-12-31')
)
-- DAn bez trenera
-- 2271	2025-03-01	Westmere Town