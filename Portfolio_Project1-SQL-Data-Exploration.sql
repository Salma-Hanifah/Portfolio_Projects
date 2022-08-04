--see all columns of the queried tables

select * FROM PortfolioProject..CovidDeaths$
order by 1,2

select * FROM PortfolioProject..CovidDeaths$ 
order by 3,4

select * FROM PortfolioProject..CovidVaccinations$
order by 3,4


--Select the Data that we are going to using 

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$ 
order by 1,2


-- Looking at all the recorded continent using distinct
SELECT distinct continent FROM PortfolioProject..CovidDeaths$ 


-- Looking at all recorded location with the continent using distinct
SELECT distinct location, continent FROM PortfolioProject..CovidDeaths$ 
ORDER BY location, continent


-- Looking at all recorded location with the continent using GROUP BY
SELECT location, continent FROM PortfolioProject..CovidDeaths$ 
GROUP BY location, continent ORDER BY location, continent


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$ 
Where location like '%german%'
order by 1,2


-- Looking at Total Cases vs Population 
Select Location, date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths$ 
Where location like '%german%'
order by 2


-- Looking at countries with Highest Infection Rate compared to Population 
Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX(total_cases/population)*100 AS MaxInfectedPercentage
FROM PortfolioProject..CovidDeaths$ 
Where location like '%german%'
Group by Location, Population 
order by MaxInfectedPercentage desc


-- Showing countries with highest Death Count per Population 
Select Location, MAX(cast(total_deaths as int)) as HighestTotalDeathsCount
FROM PortfolioProject..CovidDeaths$ 
--Where location like '%german%'
where continent is not null
Group by Location
order by HighestTotalDeathsCount desc


-- showing continent with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as HighestTotalDeathsCount
FROM PortfolioProject..CovidDeaths$ 
--Where location like '%german%'
where continent is not null
Group by continent
order by HighestTotalDeathsCount desc


-- Global Numbers each day
Select date, SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeath, SUM(cast(New_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage
--, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$ 
--Where location like '%german%'
where continent is not null
group by date
order by 1,2

-- Global Numbers total 

Select SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeath, SUM(cast(New_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage
--, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$ 
--Where location like '%german%'
where continent is not null
order by 1,2


-- Join table and looking at total Population vs vaccination
select * 
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidDeaths$ vac
	on dea.location = vac.location 
	and dea.date = vac.date


-- Looking at Total Population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidDeaths$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Looking at Total Vactionations per location and day
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.
Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidDeaths$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
With PopulationVsVac(Continent, Location, Date, Population, new_vaccination, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.
Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidDeaths$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as precentagepopulationVaccinated
From PopulationVsVac


--Temp Table
DROP Table if exists PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.
Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidDeaths$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as precentagepopulationVaccinated
From #PercentagePopulationVaccinated


-- Create View to store data for later visualization
create view PercentPopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.
Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidDeaths$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


-- Look the the View we just created
select * From PercentPopulationvaccinated
