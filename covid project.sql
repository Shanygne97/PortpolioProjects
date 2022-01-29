select * from PortfolioProject..CovidDeaths
order by 3,4


--select * from PortfolioProject..CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

-- total cases vs total deaths


select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%jamaica%'
and continent is not null
order by 1,2

-- total cases vs population 
-- what percentage of the population got covid
select location,date,population,total_cases,(total_cases/population)*100 as PopulationInfectedPercentage
from PortfolioProject..CovidDeaths
where location like '%jamaica%'
and continent is not null
order by 1,2


-- countries with highest infetction rate compared with infection rate
select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PopulationInfectedPercentage
from PortfolioProject..CovidDeaths
--where location like '%jamaica%'
where continent is not null
group by population,location
order by PopulationInfectedPercentage desc

-- the countries with the highest death count per population
select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%jamaica%'
where continent is not null
group by location
order by TotalDeathCount desc


-- By Continent
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%jamaica%'
where continent is not null
group by continent
order by TotalDeathCount desc

---- By Continent
--select location,MAX(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths
----where location like '%jamaica%'
--where continent is null and location  not like '%income%'
--group by location
--order by TotalDeathCount desc

-- Continent with the highest death count per population
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%jamaica%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select date, SUM(total_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%jamaica%'
WHERE continent is not null
GROUP BY date
order by 1,2


-- Total population vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 1,2,3


-- Total population vs Vaccinations CTE
--number of coulms in cte has to match number of columns in table
With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--view
Create View PercentagePopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3