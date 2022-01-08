/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..[covid-deaths]
Order by 3,4 


-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[covid-deaths]
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the United States

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..[covid-deaths]
Where Location like '%states%' and continent is not null
order by 1,2


-- Looking at Total Cases vs Population 
-- shows what percentage of population got covid in United States

Select Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulcationInfected
From PortfolioProject..[covid-deaths]
Where Location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compated to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..[covid-deaths]
--Where Location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with the Highest Death Count Per Poplulation

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[covid-deaths]
--Where Location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


-- Breaking things down by continent 
-- showing continents with the highest death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[covid-deaths]
--Where Location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc


-- Global Numbers

-- Cases and deaths per day

Select date, SUM(total_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..[covid-deaths]
--Where Location like '%states%'
where continent is not null
Group by date
order by 1,2


-- total cases and death as of today

Select SUM(total_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From PortfolioProject..[covid-deaths]
--Where Location like '%states%'
where continent is not null
--Group by date
order by 1,2



-- Looking at Total Population vs Vaccinations

Using Temp Table to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..[covid-vaccinations] vac
Join PortfolioProject..[covid-deaths] dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)


Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..[covid-vaccinations] vac
Join PortfolioProject..[covid-deaths] dea
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3


Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..[covid-vaccinations] vac
Join PortfolioProject..[covid-deaths] dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
from PercentPopulationVaccinated
