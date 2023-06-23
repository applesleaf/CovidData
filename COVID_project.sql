


--Retrieve COVID-19 death data for all continents, ordered by the third and fourth columns.
Select*
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Retrieve COVID-19 death data for all locations, including total cases, new cases, total deaths, and population, ordered by location and date.
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Calculate the death rate for COVID-19 cases in each US state, showing the likelihood of dying if infected, ordered by location and date.
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / CONVERT(float, total_cases)) *100 AS death_rate
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Calculate the percentage of COVID-19 cases compared to the population for each location, ordered by location and date.
SELECT location, date,  population, total_cases, (CONVERT(float, total_cases) / CONVERT(float, population)) *100 AS percent_of_cases
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

--Identify countries with the highest infection rate relative to their population, showing the population, highest infection count, and percentage of population infected, ordered by the percentage.
SELECT location,  population, MAX(total_cases) as HigestInfectionCount, MAX((CONVERT(float,total_cases ) / CONVERT(float, population))) *100 AS percentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location,  population
order by percentOfPopulationInfected desc

--Group the total death counts by continent, showing the continent and total death count, ordered by the total death count in descending order.
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Identify countries with the highest death counts per population, showing the location and total death count, ordered by the total death count in descending order.
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Group the total death counts by continent, showing the continent and total death count per population, ordered by the total death count in descending order.
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global numbers
--Calculate global COVID-19 statistics, including total cases, total deaths, and death rate, ordered by total cases and total deaths.
SELECT  SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths,  CASE
    WHEN SUM(new_cases) <> 0 THEN (SUM(new_deaths) / SUM(new_cases)) * 100
    ELSE 0 --  CASE statement calculates the death rate as a percentage, but if the sum of new cases is zero (to avoid division by zero), it returns 0 as the result.
  END AS Deathrate
FROM PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2

--use cte
-- Calculate the percentage of the population vaccinated for each location, considering the rolling number of vaccinated people over time.
With PopVsVac ( continent, Location, Date, Population, new_vaccinations, Rolling_people_Vaccinated)
as(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as Rolling_people_Vaccinated
--,(Rolling_people_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select*,( Rolling_people_Vaccinated/Population)*100
From PopVsVac


--Temp Table
--Store the results of Query 10 in a temporary table for further use.
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_people_Vaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as Rolling_people_Vaccinated
--,(Rolling_people_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*,( Rolling_people_Vaccinated/Population)*100
From #PercentPopulationVaccinated

--Create a view named "PercentPopulationVaccinated" to store the data from Query 10 and Query 11.
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as Rolling_people_Vaccinated
--,(Rolling_people_Vaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--Retrieve the data from the view "PercentPopulationVaccinated" for further analysis or visualization.
Select*
From PercentPopulationVaccinated
