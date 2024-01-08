select * from Covid_Deaths where continent is not null; --85171 rows
select * from Covid_Vaccinations where continent is not null; --85171rows 
select Location,date,total_cases,new_cases,total_deaths,population from Covid_Deaths where continent is not null order by 1,2 ;

--Looking at Total Cases Versus Total Deaths
--Shows a likelihood of dying if you goty covid.

select Location,date,total_cases,total_deaths,
round((total_deaths/total_cases)*100,2) as death_rate from Covid_Deaths where continent is not null;

select Location,date,total_cases,total_deaths,
round((total_deaths/total_cases)*100,2) as death_rate from Covid_Deaths 
where location like '%state%' and  continent is not null;

--Looking at total_cases versus Population
--what % of population got covid.

select Location,date,total_cases,total_deaths,round((total_cases/population)*100,5)as infection_rate
from Covid_Deaths where continent is not null;

select Location,date,total_cases,total_deaths,round((total_cases/population)*100,5)as infection_rate
from Covid_Deaths where continent is not null and location like '%state%';

--Countries with highest Infection Rate.

select 
	Location,
	population,
	max(total_cases) as highest_case,
	max(round((total_cases/population)*100,5)) as infection_rate
from 
	Covid_Deaths where continent is not null
group by 
	Location,population 
order by 
	infection_rate desc 
	OFFSET 0 ROWS
	FETCH FIRST 10 ROWS ONLY;
	

--Countries with Highest Death Count per Population.

select 
	Location,
	max(cast(total_deaths as int)) as highest_death,
	max(round((total_deaths/population)*100,5)) as death_rate
from 
	Covid_Deaths where continent is not null
group by 
	Location 
order by 
	highest_death desc 
	OFFSET 0 ROWS
	FETCH FIRST 10 ROWS ONLY;


------------continent------------------------------------------


--showing the continents with highest death count per poulation.

select 
	continent,
	max(cast(total_deaths as int)) as highest_death,
	max(round((total_deaths/population)*100,5)) as death_rate
from 
	Covid_Deaths where continent is not null
group by 
	 continent
order by 
	highest_death desc ;


--GLOBAL NUMBERS--


--World death percentage versus cases date wise.
select date,SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int))as total_deaths,
		SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS Death_Percentage 
From Covid_Deaths where continent is not null

Group by 
	date 
Order by date
	

--Overall world death rate and deaths.

select SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int))as total_deaths,
		SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS Death_Percentage 
From Covid_Deaths where continent is not null


--Covid Vaccination

-- joining Covid_Death table to Covid_Vaccinations

select * from Covid_Deaths as CD
  join
Covid_Vaccinations as CV
on CD.location=CV.location and CD.date=CV.date;
 
--Looking total Population Vs Vaccinations
with PopsvsVac(
location,continent,date,population,new_vaccinations,RollingPeopleVaccinated)as
(
Select CD.location,CD.continent,CD.date,CD.population,CV.new_vaccinations,
sum(convert(int,CV.new_vaccinations)) over ( partition by CD.location order by CD.location,CD.date)
as RollingPeopleVaccinated

from Covid_Deaths CD 
join
Covid_Vaccinations as CV  
on CD.location=CV.location and CD.date=CV.date where CD.continent is not null
)
select *,((RollingPeopleVaccinated/population)*100  )as percentage_vaccination
from PopsvsVac;

-----Creating View to stotre Data fro further visualizations---

create view percentpopulationvaccinated as
Select CD.location,CD.continent,CD.date,CD.population,CV.new_vaccinations,
sum(convert(int,CV.new_vaccinations)) over ( partition by CD.location order by CD.location,CD.date)
as RollingPeopleVaccinated
from Covid_Deaths CD 
join
Covid_Vaccinations as CV  
on CD.location=CV.location and CD.date=CV.date where CD.continent is not null;

                
select * from percentpopulationvaccinated;
