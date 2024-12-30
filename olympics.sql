use olympics;

#1.How many olympics games have been held?

select count(distinct Games) as total_olympics_games from athlete_events;

#2.List down all Olympics games held so far.

select distinct Year,Season,City from athlete_events
order by Year;

#3.Mention the total no of nations who participated in each olympics game?

select Games ,count(distinct NOC) as total_no_of_nations from athlete_events
group by Games;
 
 #4.Which year saw the highest and lowest no of countries participating in olympics
 
 with cte as (
 select Games,region,Medal from athlete_events a
 join noc_regions n
 on a.NOC=n.NOC
 ),
 cte1 as (
 select Games ,count(distinct region) as total_no_of_countries_participated,
 row_number() over(order by count(distinct region)) as 'rank' from cte
group by Games
 ),cte2 as (
 select concat(Games,'-',total_no_of_countries_participated) as temp  from cte1
)
select min(temp) as lowest_countries , max(temp) as highest_countries  from cte2;

 
 #5. Which nation has participated in all of the olympic games
 
 with cte as (
 select Team,count(distinct Games) as total_participated_games from athlete_events
 group by Team)
 select * from cte
 where total_participated_games =(select count(distinct Games) from athlete_events);
 
 #6.Identify the sport which was played in all summer olympics.
 
 with cte as (
 select Sport,count(distinct Games) as total_games_played from athlete_events
 where Season='Summer'
 group by Sport
 )
 select * from cte
 where total_games_played=(select count(distinct games) from athlete_events where Season='Summer');
 
 #7. Which Sports were just played only once in the olympics.
 
  with cte as (
 select Sport,count(distinct Games) as total_games_played from athlete_events
 group by Sport
 )
 select * from cte
 where total_games_played=1;
 
 #8. Fetch the total no of sports played in each olympic games.
 
 select Games,count(distinct Sport) as total_no_of_sports from athlete_events
 group by Games
 order by total_no_of_sports desc;
 
 #9. Fetch oldest athletes to win a gold medal
 
 select * from athlete_events
 where Medal='Gold' and Age=(select max(Age) from athlete_events where Medal='Gold');
 
 #10.Find the Ratio of male and female athletes participated in all olympic games.
 with cte as (
 select COUNT(CASE WHEN Sex='M' THEN 1 ELSE NULL END) as male , COUNT(CASE WHEN Sex='F' THEN 1 ELSE NULL END) as female 
 from athlete_events)
 select concat(round(male/female,2),':1') as male_to_female_ratio from cte;
 
 #11.Fetch the top 5 athletes who have won the most gold medals.
 
 select Name,Team,count(*) as total_gold_medal from athlete_events
 where Medal='Gold'
 group by Name,Team
 order by total_gold_medal desc
 limit 5;
 
 #12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
 
 select Name,Team,count(Medal) as total_medal from athlete_events
 group by Name,Team
 order by total_medal desc
 limit 5;
 
 #13.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
 with cte as (
 select region,Medal from athlete_events a
 join noc_regions n
 on a.NOC=n.NOC
 )
 select region as Country,count(Medal) as total_medal,DENSE_RANK() OVER(ORDER BY count(Medal) DESC) as 'rank' from cte 
 group by region
 order by total_medal desc
 limit 5;
 
 #14.List down total gold, silver and bronze medals won by each country.
 
 with cte as (
 select region,Medal from athlete_events a
 join noc_regions n
 on a.NOC=n.NOC
 )
 select region as Country, count(case when Medal='Gold' then 1 else null end) as no_of_gold,
 count(case when Medal='Silver' then 1 else null end) as no_of_silver,count(case when Medal='Bronze' then 1 else null end) as no_of_bronze
 from cte 
 group by region
 order by no_of_gold desc;

#15.List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
 
 with cte as (
 select Games,region,Medal from athlete_events a
 join noc_regions n
 on a.NOC=n.NOC
 )
 select Games,region as Country, count(case when Medal='Gold' then 1 else null end) as no_of_gold,
 count(case when Medal='Silver' then 1 else null end) as no_of_silver,count(case when Medal='Bronze' then 1 else null end) as no_of_bronze
 from cte 
 group by Games,region
 order by Games asc;
 
 #16. Which countries have never won gold medal but have won silver/bronze medals?
 
 with cte as (
 select region,Medal from athlete_events a
 join noc_regions n
 on a.NOC=n.NOC
 )
 select region as Country, count(case when Medal='Gold' then 1 else null end) as no_of_gold,
 count(case when Medal='Silver' then 1 else null end) as no_of_silver,count(case when Medal='Bronze' then 1 else null end) as no_of_bronze
 from cte 
 group by region
 having no_of_gold=0 ;
 
 #17.In which Sport/event, India has won highest medals.
 
 with cte as (
 select Sport,count(Medal) as total_medals from athlete_events
 where Team='India'
 group by Sport
 )
 select * from cte 
 where total_medals=(select max(total_medals) from cte);
 
 #18.Break down all olympic games where India won medal for Hockey and how many medals in each olympic games
 
 select Team,Sport,Games,count(Medal) as total_medals from athlete_events
 where Team='India'
 group by Team,Sport,Games
 order by total_medals desc ;

#19.List of unique events in the olympics

select distinct Event from athlete_events;

#20.Find the trends in participation events over the years for a specific countries like INDIA .

 with cte as (
 select Event,region,Year from athlete_events a
 join noc_regions n
 on a.NOC=n.NOC
 )
select Year,count(distinct Event) as total_no_event_participated from cte
where region='India'
group by Year
 order by year;
 
 #21.List all events that were introduced in a year 2016 
 
 with cte as (
 select distinct Event,Year from athlete_events where Year=2016)
 select Event from cte
 where Event not in (select distinct Event from athlete_events where Year<2016);
 
 #22.Analyze the correlation between age and medal-winning performance.
 
 with cte as (
 select *,case
 when Age>=1 and Age<=10 then '1-10'
 when Age>=11 and Age<=20 then '11-20'
 when Age>=21 and Age<=30 then '21-30'
 when Age>=31 and Age<=40 then '31-40'
 when Age>=41 and Age<=50 then '41-50'
 when Age>=51 and Age<=60 then '51-60'
 when Age>=61 and Age<=70 then '61-70'
 when Age>=71 and Age<=80 then '71-80'
 when Age>=81 and Age<=90 then '81-90'
 when Age>=91 and Age<=100 then '91-100'
 else 'not_valid_age_or_null'
 end as age_group
 from athlete_events
 )
 select age_group,count(Medal) as Medal_winning from cte
 group by age_group;
 
 #23. Find the top 3 most popular events with the highest number of participants
 
 select Event,count(ID) as number_of_participants from athlete_events
 group by Event
 order by number_of_participants desc
 LIMIT 3;
 
 #24.Rank the top 5 countries with the most gold medals in a specific year
 
 with cte as (
 select Medal,region,Year from athlete_events a
 join noc_regions n
 on a.NOC=n.NOC
 ),cte1 as (
 select Year,region as country,count(*) as gold_medal from cte
 where Medal='Gold'
 group by region,Year
 ),cte2 as(
 select *,dense_rank()over(partition by Year order by gold_medal desc) as ranking
 from cte1
 )
 select * from cte2
 where ranking<=5;
 
 #25.Determine which country has the highest average medals per athlete.
 
 with cte as (
 select ID,Medal,region from athlete_events a
 join noc_regions n
 on a.NOC=n.NOC
 ),cte1 as (
 select region as country, count(Medal) as total_medal,count(distinct ID) as total_participiated from cte
 group by region
 )
 select *,total_medal/total_participiated as average_medals_per_athlete from cte1
 order by average_medals_per_athlete desc;
 
 #26.Find the oldest and youngest athletes who won a medal.
 
	with cte as (
	SELECT MIN(Age) as temp FROM athlete_events WHERE Medal IS NOT NULL
    UNION
	SELECT MAX(Age) as temp FROM athlete_events WHERE Medal IS NOT NULL
    ) 
    select * from athlete_events
    where Age in (select temp from  cte ) and Medal is not null
    order by Age;
 
  #27.Identify the gender distribution of athletes participating in a specific event
  
  select Event,count(case when Sex='M' then 1 else null end) as total_male,count(case when Sex='F' then 1 else null end) as total_female
 from athlete_events
 group by Event;
 
 #28.Identify the gender distribution of athletes participating in a specific Year
 
 select Year,count(case when Sex='M' then 1 else null end) as total_male,count(case when Sex='F' then 1 else null end) as total_female
 from athlete_events
 group by Year
 order by Year;
 
 #29.Find the athlete with the most medals in a single Olympics.
 
 select Year,Name,Sport,Count(Medal) as total_medal from athlete_events
 Group by Year,Name,Sport
 Having total_medal>0
 order by total_medal desc;
 
 #30.Find the athlete with the most medals in a single Olympics from India
 
 with cte as (
 select Name,Year,Sport,Medal,region from athlete_events a
 join noc_regions n
 on a.NOC=n.NOC
 )
 select Year,Name,Sport,Count(Medal) as total_medal from cte
 where region='India'
 Group by Year,Name,Sport
 Having total_medal>0
 order by total_medal desc;
 
 