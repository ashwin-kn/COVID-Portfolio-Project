/*
COVID 19 Data Study/Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4



-- Select the Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2



-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India' AND continent IS NOT NULL
ORDER BY 1, 2



-- Shows the likelihood of dying if you contract COVID in UnitedStates

 SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeaths
 WHERE location LIKE '%states%' AND continent IS NOT NULL
 ORDER BY 1, 2



-- Total Cases vs Population in India
-- Shows what percentage of the population was infected with COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'India' AND continent IS NOT NULL
ORDER BY 1, 2



-- Countries with Highest Infection Rate as compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS HighestPercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestPercentPopulationInfected desc



-- Countries with the Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS HighestTotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestTotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestTotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestTotalDeathCount desc



-- GLOBAL NUMBERS

-- Shows Percentage of Population dying each day as compared to New Cases each day

SELECT date, SUM(new_cases) AS NewCases, SUM(CAST(new_deaths AS INT)) AS NewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Shows Percentage of Population died as compared to the Total Cases

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2



-- Total Population vs Vaccinations
-- Shows the Percentage of the Population that has received at least one dose of Covid Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3



-- Using CTE to perform Calculation on Partition By in the previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageRollingPeopleVaccinated
FROM PopvsVac



-- Using TEMP TABLE to perform Calculation on Partition By in the previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageRollingPeopleVaccinated
FROM #PercentPopulationVaccinated



-- Creating View to store data for later Visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3
SELECT *
FROM PercentPopulationVaccinated



-- Creating View for the Countries with the Highest Death Count per Population

CREATE VIEW HighestDeathCount AS
SELECT location, MAX(CAST(total_deaths AS int)) AS HighestTotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
-- ORDER BY HighestTotalDeathCount desc
