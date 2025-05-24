-- First, to find the relevant report:
select *
from crime_scene_report
where date = 20180115 and city like 'SQL city' and type like 'murder';
/*
The description was:
Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on "Franklin Ave".
*/

--Will look for both:
--First witness:
select *
from person
where address_street_name like 'Northwestern Dr'
order by address_number desc
limit 1;
--Got me the name Morty Schapiro, id = 14887, license - 118009

--Second witness:
select *
from person
where address_street_name like 'Franklin Ave' and name like '%Annabel%';
--Info: name - Annabel Miller, id – 16371, license - 490173

--Will look at their interview:
select *
from interview
where person_id in (14887, 16371);
/*
Description:
Morty:  I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".
Anabel: I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.

We know the man is a member of the "Get Fit Now Gym", his membership number starts with “48Z”, he is a gold member, he was there on 20180109 and the car number includes “H42W”.
*/

--From the gym table we get:
select *
from get_fit_now_check_in gym join get_fit_now_member member on gym.membership_id = member.id
where gym.membership_id like '48Z%' and gym.check_in_date = 20180109 and lower(member.membership_status) like '%gold%'
/*
Our suspects are:
Id – 28819, name - Joe Germuska, membership id - 48Z7A
Id – 67318, name - Jeremy Bowers, membership id - 48Z55
*/

--From the driver license table:
select *
from drivers_license
where id in (28819,67318) and plate_number like '%H42W%';
--Return no results so from looking at :

select *
from drivers_license
where plate_number like '%H42W%';
--We got 3 ids: 183779, 423327, 664760. 2 males (black and brown hair) and 1 female (blonde).

--We’ll look at the interview of those 5 and their info:
select *
from interview
where person_id in (183779, 423327, 664760, 28819,67318);
/*
We got only 1 interview of Jeremy Bowers saying the following:
I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017
*/

--By looking at the drivers table once again and joining to get personal info:
select *
from person p join (select *
from drivers_license
where gender like 'female' and car_make like 'Tesla' and car_model like '%S' and hair_color like 'red'
  and height between 65 and 67) s on p.license_id = s.id;
--We get 3 new suspects

--Will look at the facebook event:
select *
from facebook_event_checkin f join
(select *
from person p join (select *
from drivers_license
where gender like 'female' and car_make like 'Tesla' and car_model like '%S' and hair_color like 'red'
  and height between 65 and 67) s on p.license_id = s.id) suspect
on f.person_id = suspect.id
--We get 3 records, only Miranda Priestly, id – 99716 and all her records are from SQL Symphony Concert events at Dec 2017 as Jeremy said.

--Her interview:
select *
from interview
where person_id = 99716;

/*
We have no interview with her.

Out current suspect are Miranda Priestly and Jeremy Bowers who was hired by her.
And it is indeed Miranda Priestly.
*/