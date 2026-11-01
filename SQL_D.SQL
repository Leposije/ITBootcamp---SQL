-- TABELE

-- dim_team
CREATE OR REPLACE TABLE dim_team AS
SELECT team_id, team_name, short_name, city, founded_year, stadium_id
FROM teams;

-- dim_referee
CREATE OR REPLACE TABLE dim_referee AS
SELECT referee_id, referee_name, nationality, debut_season
FROM referees;

-- dim_player
CREATE OR REPLACE TABLE dim_player AS
SELECT player_id, first_name, last_name, known_as, birth_date,
       nationality, position, preferred_foot, height_cm
FROM players
UNION ALL
SELECT -1, 'Nepoznat', 'Nepoznat', CAST(NULL AS STRING), CAST(NULL AS DATE),
       CAST(NULL AS STRING), CAST(NULL AS STRING), CAST(NULL AS STRING), CAST(NULL AS BIGINT);

-- dim_date
CREATE OR REPLACE TABLE dim_date AS
SELECT CAST(date_format(d, 'yyyyMMdd') AS INT) AS date_key,
       d AS full_date,
       year(d) as year, month(d) as month,day(d) AS day,
       date_format(d, 'MMMM')AS month_name,
       date_format(d, 'EEEE') AS day_name,
       CASE WHEN dayofweek(d) IN (1, 7) THEN true ELSE false END AS is_weekend,
       CASE WHEN month(d) >= 8
            THEN concat(year(d), '/', substring(CAST(year(d) +1 AS STRING), 3, 2))
            ELSE concat(year(d) - 1, '/', substring(CAST(year(d) AS STRING), 3, 2))
       END as season
FROM (SELECT explode(sequence(DATE'2023-08-01', DATE'2025-07-31', INTERVAL 1 DAY)) AS d) x;



-- FACT_CARD
CREATE OR REPLACE TABLE fact_card AS
SELECT e.event_id, e.match_id, e.team_id, m.referee_id,
       CAST(date_format(m.kickoff_ts, 'yyyyMMdd') AS INT) AS date_key,
       COALESCE(p.player_id, -1) AS player_id,
       e.event_type AS card_type
FROM match_events e
JOIN matches m ON m.match_id = e.match_id
LEFT JOIN players p ON p.player_id = e.player_id
WHERE e.event_type IN ('yellow_card', 'second_yellow', 'red_card');



-- 2.Упитом покажите да fact_card има исто редова колико има картонских догађаја
SELECT (SELECT COUNT(*) FROM match_events
        WHERE event_type IN('yellow_card', 'second_yellow', 'red_card')) AS kartonskih_dogadjaja,
       (SELECT COUNT(*) FROM fact_card)as redova_u_fact_card;

-- ima isto redova, 2678



-- Колико картона има player_id = -1?
SELECT COUNT(*) AS kartona_nepoznatog_igraca
FROM fact_card
WHERE player_id = -1;

-- ima 2 kartona 
