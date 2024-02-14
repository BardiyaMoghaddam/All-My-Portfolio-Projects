select*
from Covid19.dbo.CovidDeaths
order by 3,4

select*
from Covid19.dbo.CovidVaccinations
order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from Covid19.dbo.CovidDeaths
order by 1,2

--Total cases diagnosed with covid19 in different countries and how many of them are dead per day

select location,date,total_cases,new_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
from Covid19.dbo.CovidDeaths
order by 1,2

--lets see what is the percentage of death in Norway per day. The percentage shows the likelihood of daying due to covid19 in Norway per day.

select location,date,total_cases,new_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
from Covid19.dbo.CovidDeaths
where location='Norway'
order by 1,2

--Looking at the total cases vs the population per day
select location,date,total_cases, population,(total_cases/population)*100 AS got_Covid19
from Covid19.dbo.CovidDeaths
order by 1,2
--what percentage of population got Covid19 in Norway per day
select location,date,total_cases, population,(total_cases/population)*100 AS got_Covid19
from Covid19.dbo.CovidDeaths
where location='Norway'
order by 1,2

--What countries had the highest inffected covid19 based on the population

select location,max(total_cases) AS HighestInfection, population,MAX((total_cases/population)*100) AS got_Covid19
from Covid19.dbo.CovidDeaths
GROUP BY location, population
order by  got_Covid19 DESC

--what is the highest percentage of inffected people in Norway based on the population
select location,max(total_cases) AS HighestInfection, population,MAX((total_cases/population)*100) AS got_Covid19
from Covid19.dbo.CovidDeaths
where location='Norway'
GROUP BY location, population
order by  got_Covid19 DESC

select location,date, max(total_cases) AS HighestInfection, population,MAX((total_cases/population)*100) AS percent_got_Covid19
from Covid19.dbo.CovidDeaths
--where location='Norway'
GROUP BY location, population, date
order by  percent_got_Covid19 DESC

--what is the highest percentage of death due to covid19 based on the population
select location,max(total_deaths) AS HighestDeath, population
from Covid19.dbo.CovidDeaths
GROUP BY location, population
order by  HighestDeath DESC

--it looks the data type for HighestDeath is not Correct and we have to cast the total death to int because right now it is varchar format which is text and is not numeric
select location,max(cast(total_deaths as int)) AS HighestDeath, population
from Covid19.dbo.CovidDeaths
GROUP BY location, population
order by  HighestDeath DESC

--there is a problem with the data location it includes not only the countries but also the continents

select*
from Covid19.dbo.CovidDeaths

--the data shows the continents as the location so we have to set the data where the continent is not null because when it is null it shows the continents in the country list
select location,max(cast(total_deaths as int)) AS HighestDeath, population
from Covid19.dbo.CovidDeaths
where continent is not null
GROUP BY location, population
order by  HighestDeath DESC

--which continents have higher death count per population

select continent, max(cast(total_deaths as int)) as HighestDeath
from Covid19.dbo.CovidDeaths
where continent is not null
GROUP BY continent
order by  HighestDeath DESC


--how many people around the world got covid-19 per day?

select date,sum(new_cases) as New_Infected
from Covid19.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

select location, sum(cast(new_deaths as int)) as Total_deaths
from Covid19.dbo.CovidDeaths
where continent is null
and location  not in ('world','European Union', 'International')
group by location
order by Total_deaths desc

--Here I look at not only the new infected but also the new deaths per date in the world and the percentage of deaths. if you look at the columns information in the left side of SQL software, you can see that total_deaths is varchar whereas new cases is float that is why new cases can be sum but new_deaths can not. so we have to cast new_death as int to be able to sum it.
select date,sum(new_cases) as New_Infected, sum(cast(new_deaths as int)) as New_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Covid19.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

--now I wanna see exactly the same information but based on the total cases not per day. i just need to remove date and the rest is the same
select sum(new_cases) as New_Infected, sum(cast(new_deaths as int)) as New_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Covid19.dbo.CovidDeaths
where continent is not null
order by 1,2
--the result is not that much bad I guess, it is 2.1% 

--Now I wanna use JOIN function by using vaccination table together with death table based on location and date

select*
from CovidDeaths
JOIN CovidVaccinations
on CovidDeaths.location=CovidVaccinations.location
and
CovidDeaths.date=CovidVaccinations.date

--Now I wanna see How many of the people got vaccination based on the total population? here we have to specify from which table we wanna these data to extract from as they exist in both tables
select coviddeaths.continent,  coviddeaths.location,  coviddeaths.date,   coviddeaths.population, covidvaccinations.new_vaccinations, 
SUM(cast(covidvaccinations.new_vaccinations as int)) OVER (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as Accumulated_vaccinatedFolk
from CovidDeaths
JOIN CovidVaccinations
on CovidDeaths.location=CovidVaccinations.location
and
CovidDeaths.date=CovidVaccinations.date
where coviddeaths.continent is not null
order by 2,3


--Now I wanna use CTE to sort Accumulated_vaccinatedFolk and other columns I make so I dont need to make these columns everytime I wanna use them. so i use exactly the same columns from select part
with PopulationVacc (continent,location, date, population, new_vaccinations, Accumulated_vaccinatedFolk)
as
(
select coviddeaths.continent,  coviddeaths.location,  coviddeaths.date,   coviddeaths.population, covidvaccinations.new_vaccinations, 
SUM(cast(covidvaccinations.new_vaccinations as int)) OVER (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as Accumulated_vaccinatedFolk
from CovidDeaths
JOIN CovidVaccinations
on CovidDeaths.location=CovidVaccinations.location
and
CovidDeaths.date=CovidVaccinations.date
where coviddeaths.continent is not null
)
select*
from PopulationVacc

--now i can use Accumulated_vaccinatedFolk 
with PopulationVacc (continent,location, date, population, new_vaccinations, Accumulated_vaccinatedFolk)
as
(
select coviddeaths.continent,  coviddeaths.location,  coviddeaths.date,   coviddeaths.population, covidvaccinations.new_vaccinations, 
SUM(cast(covidvaccinations.new_vaccinations as int)) OVER (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as Accumulated_vaccinatedFolk
from CovidDeaths
JOIN CovidVaccinations
on CovidDeaths.location=CovidVaccinations.location
and
CovidDeaths.date=CovidVaccinations.date
where coviddeaths.continent is not null
)
select*, (Accumulated_vaccinatedFolk/population)*100
from PopulationVacc

--another way is to make Temp Table so:

create table PercentagePopulationVaccinated
(
Continent nvarchar (300),
Location nvarchar (300),
Date datetime,
Population Numeric,
New_vaccinations numeric,
Accumulated_vaccinatedFolk numeric
)
 insert into PercentagePopulationVaccinated
select coviddeaths.continent,  coviddeaths.location,  coviddeaths.date,   coviddeaths.population, covidvaccinations.new_vaccinations, 
SUM(cast(covidvaccinations.new_vaccinations as int)) OVER (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as Accumulated_vaccinatedFolk
from CovidDeaths
JOIN CovidVaccinations
on CovidDeaths.location=CovidVaccinations.location
and
CovidDeaths.date=CovidVaccinations.date
where coviddeaths.continent is not null

select*, (Accumulated_vaccinatedFolk/population)*100
from PercentagePopulationVaccinated

--if you wanna remove PercentagePopulationVaccinated table, you just need to run this code below

drop table if exists PercentagePopulationVaccinated

--Now I wanna create view to store data for visualization in Tableau or Power BI
create view PercentPopulationVaccinated as 
select coviddeaths.continent,  coviddeaths.location,  coviddeaths.date,   coviddeaths.population, covidvaccinations.new_vaccinations, 
SUM(cast(covidvaccinations.new_vaccinations as int)) OVER (partition by coviddeaths.location order by coviddeaths.location, coviddeaths.date) as Accumulated_vaccinatedFolk
from CovidDeaths
JOIN CovidVaccinations
on CovidDeaths.location=CovidVaccinations.location
and
CovidDeaths.date=CovidVaccinations.date
where coviddeaths.continent is not null

--after refreshing the view on the right hand side of ssms we see our view. this is permenant not like Temp Table

select*
from PercentPopulationVaccinated

--next step is to visualize this data in Tableau or power BI
