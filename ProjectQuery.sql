use Portfolio_Project

select * from dbo.CovidDeaths$
where continent is not NULL
order by 3,4


--select the data we are going to use

select Location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths$
order by 1,2

--looking at total cases vs total deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
from dbo.CovidDeaths$
--where Location = 'India'
where continent is not NULL
order by 1,2

--total cases vs population

select Location, date, total_cases, population, (total_cases/Population) *100 as PercentPopulationInfected
from dbo.CovidDeaths$
where Location = 'India'and  continent is not NULL
order by 1,2

--countries with highest infection rate compared to population

select Location,population, max(total_cases) as HighestInfectionCount, max((total_cases/Population)) *100 as PercentPopulationInfected
from dbo.CovidDeaths$
where continent is not NULL
group by population, location
order by PercentPopulationInfected desc

--countries with highest death count per population

select Location, max(cast(total_deaths as int)) as TotalDeathCount
--where Location = 'India'
from dbo.CovidDeaths$
where continent is not NULL
group by  location
order by TotalDeathCount desc

--deaths per continent

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths$
where continent is not NULL
group by  continent
order by TotalDeathCount desc

--showing cntinents with highesr death counts -SAME AS ABOVE

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths$
where continent is not NULL
group by  continent
order by TotalDeathCount desc


--global numbers

select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercent
from dbo.CovidDeaths$
where continent is not NULL
order by 1,2

--LOOKING AT TOTAL POPULATION THAT HAVE BEEN VACINATED

with popvsvacc (continent, location, date, population, new_vaccinations, rollingpeoplevacc)
as 
(select de.continent, de.location, de.date, de.population, va.new_vaccinations,
sum(cast(va.new_vaccinations as int)) over(partition by de.location order by  de.location, de.date) as rollingpeoplevacc 
from dbo.CovidDeaths$ de join dbo.CovidVaccinations$ va on
de.location = va.location and de.date = va.date
where de.continent is not null
)

select *, (rollingpeoplevacc/population) *100 as percentvacc
from popvsvacc
where location = 'India'

--with temp table (same process as above)

drop table if exists #temptable

create table #temptable
(continent nvarchar(255),
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
rollingpeoplevacc numeric
)

insert into #temptable
select de.continent, de.location, de.date, de.population, va.new_vaccinations,
sum(cast(va.new_vaccinations as int)) over(partition by de.location order by  de.location, de.date) as rollingpeoplevacc 
from dbo.CovidDeaths$ de join dbo.CovidVaccinations$ va on
de.location = va.location and de.date = va.date
where de.continent is not null

select *, (rollingpeoplevacc/population) * 100 
from #temptable
order by 1,2

--create view

create view percpeoplevacc
as
select de.continent, de.location, de.date, de.population, va.new_vaccinations,
sum(cast(va.new_vaccinations as int)) over(partition by de.location order by  de.location, de.date) as rollingpeoplevacc 
from dbo.CovidDeaths$ de join dbo.CovidVaccinations$ va on
de.location = va.location and de.date = va.date
where de.continent is not null


select * from percpeoplevacc

 
