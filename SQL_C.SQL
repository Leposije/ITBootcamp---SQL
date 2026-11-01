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


-- 1.Колики удео у укупном броју голова лиге у сезони 2024/25 има сваки клуб? Ко има највећи
-- удео?




SELECT t.team_name as klub,
    SUM(s.goals_for) as golovi,
    ROUND(100.0 * SUM (s.goals_for) / SUM(SUM(s.goals_for)) over (), 2) as udeo_pct
FROM team_matches as s
JOIN teams as t ON t.team_id = s.team_id
WHERE s.season =  '2024/25'
GRoup by t.team_name
ORDER BY golovi DESC, klub;


-- Kingsbridge City	83	7.60
-- Castlebrook United	82	7.51
-- Northport United	69	6.32
-- Pemberton United	69	6.32

-- 2. Која су три стадиона са највећом просечном посетом у сезони 2024/25?
Select st.stadium_name, st.city,
    COUNT(m.attendance) as utakmice_poseta,
    ROUND(AVG(m.attendance)) as prosecna_poseta,
    st.capacity
FROM matches as m
JOIN stadiums as st ON st.stadium_id = m.stadium_id
WHERE season = '2024/25'
GROUP BY st.stadium_id, st.stadium_name, st.city, st.capacity
ORDER BY prosecna_poseta desc
LIMIT 3;



-- Harbourside Park	Northport	19	44074	52000
-- Kingsbridge Stadium	Kingsbridge	19	37968	47000
-- Northport Arena	Northport	18	36250	41000



-- 3. За сваки клуб, ко је дао последњи гол клуба у сезони 2024/25 и када? Који клуб је последњи
-- гол дао најраније?
WITH golovi AS (
    SELECT e.team_id, p.first_name, p.last_name, e.minute, m.kickoff_ts,
        ROW_NUMBER() OVER (PARTITION BY e.team_id
            ORDER BY m.kickoff_ts DESC, e.minute DESC,
            COALESCE(e.added_time, 0) DESC, e.event_id DESC) AS rn
    FROM match_events e
    JOIN matches m ON m.match_id = e.match_id
    JOIN players p ON p.player_id = e.player_id
    WHERE m.season = '2024/25' AND e.event_type IN ('goal', 'penalty_goal')
),
poslednji AS (
    SELECT t.team_name AS klub, g.first_name, g.last_name, g.kickoff_ts, g.minute
    FROM golovi g
    JOIN teams t ON t.team_id = g.team_id
    WHERE g.rn = 1
)
SELECT klub, first_name, last_name, CAST(kickoff_ts AS DATE) AS datum, minute AS minut,
    RANK() OVER (ORDER BY kickoff_ts) AS r_najranije
FROM poslednji
ORDER BY r_najranije, klub;
-- Poslednji gol su najranije postigao ELmsworth Wanderers,  2025-05-03, Marko Stankovic


-- 4. За домаће утакмице клуба Northport United у сезони 2024/25 прикажите посету и промену у
-- односу на претходну домаћу утакмицу. Где је највећи пад?
WITH domace AS (
    SELECT CAST(m.kickoff_ts AS DATE) AS datum, o.team_name AS protivnik,
        m.attendance AS poseta,
        LAG(m.attendance) OVER (ORDER BY m.kickoff_ts) AS prethodna_poseta
    FROM matches m
    JOIN teams t ON t.team_id = m.home_team_id
    JOIN teams o ON o.team_id = m.away_team_id
    WHERE t.team_name = 'Northport United' AND m.season = '2024/25' AND m.status = 'played'
)
SELECT datum, protivnik, poseta, prethodna_poseta,
    poseta - prethodna_poseta AS promena,
    ROUND(100.0 * (poseta - prethodna_poseta) / prethodna_poseta, 1) AS promena_pct
FROM domace
ORDER BY datum;

-- najveci pad je utakmica protiv CAstlebrook United-a  10267 manje posetioca,  20.8% 


-- 5. Пратите бодове клуба Northport City утакмицу по утакмицу у сезони 2024/25. У којој
-- утакмици по реду и ког датума је прешао 50 бодова?

WITH bodovi AS (
    SELECT s.kickoff_ts, o.team_name AS protivnik, s.venue,
        CONCAT(s.goals_for, ':', s.goals_against) AS rezultat,
        CASE WHEN s.goals_for > s.goals_against THEN 3
            WHEN s.goals_for = s.goals_against THEN 1 ELSE 0 END AS bodova,
        ROW_NUMBER() OVER (ORDER BY s.kickoff_ts) AS utakmica_br,
        SUM(CASE WHEN s.goals_for > s.goals_against THEN 3
                WHEN s.goals_for = s.goals_against THEN 1 ELSE 0 END)
           OVER (ORDER BY s.kickoff_ts ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ukupno_bodova
    FROM team_matches as s
    JOIN teams as t ON t.team_id = s.team_id
    JOIN teams as o ON o.team_id = s.opponent_id
     WHERE t.team_name = 'Northport City' AND s.season = '2024/25'
)
SELECT utakmica_br, CAST(kickoff_ts AS DATE) AS datum, protivnik, venue, rezultat, bodova, ukupno_bodova
FROM bodovi
WHERE ukupno_bodova > 50
ORDER BY utakmica_br
LIMIT 1;

-- 2025-01-12 protiv Ashford,  4-1 rezultat