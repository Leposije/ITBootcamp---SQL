# ITBootcamp---SQL

Ime i prezime:
Aleksa Lepović

Radimo projekat na času, koji se sadrži od tri dela.




Za deo pod D (В)


Svaki red u fact_card sadrzi informaciju o jeddnom kartonu sa meča 
(yellow_card, second_yellow или red_card) koji je dat u toj utakmici.
Tabela treba da ima onoliki broj redova koliko je match_events tabela
ima dogadjaja za kartone (2687).

Veze:
Primary kez je  event_id, uzeli smo ga iz match_events. 
A foreign ključevi su:
team_id (dim_team)
plazer_id (dim_player)
referee_id (dim_referee)
date_kez (dim_date)

Kartoni imaju svoju tabelu jer je to poseban dogadjaj. U match_events imamo mnogo razlicitih događaja pomešano. Imamo više tipova vezana za golove (goal, penalty goal, penalty_miss), izmene igrača.
Tako da bi svaki put morali da filtriramo query za vrstu događaja.

Ovako imamo tabelu gde je svaki red vezan za karton.
Ako je potrebno mozemo lakše dodavati nove dimenzije na primer golovi ili stadion