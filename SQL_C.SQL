-- 1.Колики удео у укупном броју голова лиге у сезони 2024/25 има сваки клуб? Ко има највећи
-- удео?


-- 2. Која су три стадиона са највећом просечном посетом у сезони 2024/25?
Select s.sadium_name, s.city,
    COUNT(m.attendance) as utakmice_poseta,
    ROUND(AVG(m.attendance)) as prosecna_poseta,
    s.capacity
FROM matches as m
JOIN sadiums as s ON s.sadium_id = m.sadium_id
WHERE season = '2024/25'
GROUP BY s.sadium_id, s.sadium_name, s.city, s.capacity
ORDER BY prosecna_poseta desc
LIMIT 3;



-- Harbourside Park	Northport	19	44074	52000
-- Kingsbridge sadium	Kingsbridge	19	37968	47000
-- Northport Arena	Northport	18	36250	41000



-- 3. За сваки клуб, ко је дао последњи гол клуба у сезони 2024/25 и када? Који клуб је последњи
-- гол дао најраније?
-- 4. За домаће утакмице клуба Northport United у сезони 2024/25 прикажите посету и промену у
-- односу на претходну домаћу утакмицу. Где је највећи пад?
-- 5. Пратите бодове клуба Northport City утакмицу по утакмицу у сезони 2024/25. У којој
-- утакмици по реду и ког датума је прешао 50 бодова?