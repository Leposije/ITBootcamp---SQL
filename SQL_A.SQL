-- 1. Колико утакмица је одиграно у фебруару 2025?
Select Count(*) as broj_utakmica
From matches
WHEre month(kickoff_ts) = 2 and year(kickoff_ts) = 2025;

-- A1 ->  40 utakmica


-- 2. Који стадион има највећи капацитет, а који је највећи стадион неког клуба?
Select capacity, stadium_name
from stadiums
Limit 3;
-- A2 - > Najveci stadion Harbourside Park 52 000 kapacitet

Select capacity, stadium_name
from stadiums
WHere city = 'Valemont'
Limit 1;
-- A2 - > Najveci stadion  27 000 za Valemont United. trazio sam po gradovima. Jer bi ovako mnogo iskomplikovao







-- 3. Колико играча у лиги има српско држављанство (nationality = 'Serbia')?
Select Count(*) as broj_igraca
FROM players
Where nationality = 'Serbia'

-- A3 -> 42 igraca


-- 4. Колико утакмица је завршено резултатом 1:1?
Select count(*) as broj_utakmica
From matches
Where home_goals = 1 and away_goals =1;

-- A4 ->  94 utakmica


-- 5. Колика је просечна посета по сезони?
SELECT season,
       ROUND(AVG(attendance), 0) AS prosek_poseta
FROM matches
GROUP BY season
ORDER BY season;

-- A5 -> 2023/24	24253 prosecna poseta
--       2024/25	24199



-- 6. Колико голова је дато из пенала по сезони?
Select COUNT (*), m.season 
From match_events as e
JOIN matches as m ON e.match_id = m.match_id
Where event_type in ('penalty_goal')
Group by m.season;

-- A6 - >   sezona 2023/24 , 104 golova
--          sezona 2024/25, 109 golova


-- 7. Колико различитих играча је дало бар један гол у сезони 2024/25?
Select COUNT(distinct player_id)
from match_events as e
JOIN matches as m ON m.match_id = e.match_id

WHere m.season = '2024/25' and e.event_type in ('goal', 'penalty_goal');

-- A7 ->  308 razlicitih igraca je dalo bar jedan gol



-- 8. Који судија је највише пута судио утакмице клуба Northport United?

Select m.referee_id, r.referee_name,
    SUM(CASE WHEN m.home_team_id = 1 or m.away_team_id = 1
 THEN 1 ELSE 0 END) AS sudjeno

FROM matches as m 
JOIN referees as r ON m.referee_id = r.referee_id
GROUP by m.referee_id, r.referee_name
ORDER BY sudjeno desc;

-- A8 - > Peter Lindgren 9 utakmica


-- 9. Који судија је у сезони 2024/25 имао највећи удео утакмица у којима је досуђен бар један
-- пенал, дат или промашен?

Select m.referee_id, r.referee_name,
    SUM(CASE WHEN e.event_type in ('penalty_goal', 'penalty_miss')
 THEN 1 ELSE 0 END) AS utakmice_sa_penalima,

    ROUND(100.0 * SUM(CASE WHEN e.event_type in ('penalty_goal', 'penalty_miss')
 THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS procenat
FROM matches as m 
JOIN referees as r ON m.referee_id = r.referee_id
JOIN match_events as e ON m.match_id = e.match_id
Where m.season = '2024/25'
GROUP by m.referee_id, r.referee_name
ORDER BY procenat desc;

-- A9 - > Peter Lindgren  4.4%




-- 10. Који тренер је освојио највише бодова у утакмицама у којима је његов тим губио на
-- полувремену? Рачунајте и домаће и гостујуће утакмице.

