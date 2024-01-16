select * 
from CovidDeath
order by 3,4

--select *
--from CovidVaccination
--order by 3,4

--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population/10
from CovidDeath
order by 1,2

--looking at total deaths vs total cases

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeath
order by 1,2

--SHOWS DEATHPERCENTAGE OF INDIA
--Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeath
where location like 'India'
order by 1,2

--Looking at totalcase vs population
select location,date,population,total_cases,(total_cases/population)*100 as TotalAffectedPercentage
from CovidDeath
--where location ='India'
order by 1,2

--looking at highest infection rate compared to population
select location,population,max(total_cases) as HighestInfection,(max(total_cases)/population)*100 as PercentPopulationInfected
from CovidDeath
--where location ='India'
Group by population,location 
order by PercentPopulationInfected desc

--showing countries with highest death counts per population
select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeath
where continent is not null
Group by location 
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeath
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

--Create View PercentPopulationVaccinated as
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From CovidDeath dea
--Join CovidVaccination vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
