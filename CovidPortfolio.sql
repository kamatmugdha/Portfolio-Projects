select * from coviddeaths 
order by 3,4 

--select * from covidvaccinations 
--order by 3,4

select location,date,total_cases, new_cases,total_deaths,population
from coviddeaths 
order by location,date

---Total Cases vs Total Deaths

select location,date,total_cases, total_deaths , (total_deaths::numeric /total_cases::numeric)*100 as DeathPercentage
from coviddeaths 
order by location,date

--Likelihood of dying if infected with Covid in States
select location,date,total_cases, total_deaths , (total_deaths::numeric /total_cases::numeric)*100 as DeathPercentage
from coviddeaths 
where location like '%States%'
order by location,date

--Total Cases vs Population
--Percentage of population who got covid
select location,date,total_cases, population , (total_cases ::numeric /population ::numeric)*100 as DeathPercentage
from coviddeaths 
where location like '%States%'
order by location,date

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases::numeric /population::numeric))*100 as PercentPopulationInfected
From coviddeaths 
--Where location like '%states%'
where total_cases is not null and population  is not null 
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From coviddeaths 
--Where location like '%states%'
Where total_deaths is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent , MAX(cast(Total_deaths as int)) as TotalDeathCount
From coviddeaths 
--Where location like '%states%'
Where continent is not null and total_deaths is not null 
Group by continent 
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From coviddeaths c2 
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Total population vs Vaccinations
select dea.location ,dea.date, dea.population ,sum(vac.new_vaccinations )
from coviddeaths dea
join  covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
group by dea.location ,dea.date , dea.population , vac.new_vaccinations 

--Total population vs Vaccinations
select dea.continent , dea.location ,dea.date, dea.population ,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join  covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--CTE
with PopvsVac (Continent,Loaction,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as 
(
select dea.continent , dea.location ,dea.date, dea.population ,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join  covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where not ((dea.continent= '' OR  dea.continent IS NULL))
order by 2,3
)
select * , (RollingPeopleVaccinated :: numeric /Population::numeric)*100 as rollingpercentvaccinated

--Create View
create view PercentPopulationVaccinated as
select dea.continent , dea.location ,dea.date, dea.population ,vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join  covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where not ((dea.continent= '' OR  dea.continent IS NULL))
order by 2,3
from PopvsVac
