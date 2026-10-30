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
-- 4. За домаће утакмице клуба Northport United у сезони 2024/25 прикажите посету и промену у
-- односу на претходну домаћу утакмицу. Где је највећи пад?
-- 5. Пратите бодове клуба Northport City утакмицу по утакмицу у сезони 2024/25. У којој
-- утакмици по реду и ког датума је прешао 50 бодова?