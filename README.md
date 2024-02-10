# COVID-Portfolio-Project

Dashboard Link: [COVID Data Dashboard](https://public.tableau.com/views/CovidDashboard_16483666804760/Dashboard1?:language=en-US&:display_count=n&:origin=viz_share_link)
---
<br></br>
## Introduction
The COVID-19 pandemic has had profound effects globally, impacting various aspects of society including public health, economy, and social dynamics. In response to this crisis, extensive data collection and analysis have been undertaken to understand the spread of the virus, its impact on different populations, and the effectiveness of mitigation strategies. The COVID Portfolio Project aims to leverage SQL tools and techniques to explore and analyze COVID-19 data, providing insights into infection rates, mortality rates, vaccination progress, and other relevant metrics.

## Table of Contents
1. [Initial Data Exploration](#initial-data-exploration)
2. [Total Cases vs Total Deaths](#total-cases-vs-total-deaths)
3. [Total Cases vs Population in India](#total-cases-vs-population-in-india)
4. [Countries with Highest Infection Rate](#countries-with-highest-infection-rate)
5. [Countries with Highest Death Count per Population](#countries-with-highest-death-count-per-population)
6. [Continent-wise Death Count](#continent-wise-death-count)
7. [Global Numbers](#global-numbers)
8. [Total Population vs Vaccinations](#total-population-vs-vaccinations)
9. [Using Common Table Expressions (CTEs)](#using-common-table-expressions-ctes)
10. [Using Temporary Tables](#using-temporary-tables)
11. [Creating Views](#creating-views)

---

## Initial Data Exploration <a name="initial-data-exploration"></a>
```sql
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4
```
This query retrieves all columns from the CovidDeaths table, filtering out records where the continent is not specified. The data is sorted by the third and fourth columns.

## Total Cases vs Total Deaths <a name="total-cases-vs-total-deaths"></a>
```sql
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India' AND continent IS NOT NULL
ORDER BY 1, 2
```
This query calculates the percentage of deaths in India relative to total cases, providing insight into the mortality rate.

## Total Cases vs Population in India <a name="total-cases-vs-population-in-india"></a>
```sql
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'India' AND continent IS NOT NULL
ORDER BY 1, 2
```
This query determines the percentage of India's population infected with COVID-19 over time, based on reported cases.

## Countries with Highest Infection Rate <a name="countries-with-highest-infection-rate"></a>
```sql
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS HighestPercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestPercentPopulationInfected desc
```
This query identifies countries with the highest infection rates relative to their population.

## Countries with Highest Death Count per Population <a name="countries-with-highest-death-count-per-population"></a>
```sql
SELECT location, MAX(CAST(total_deaths AS int)) AS HighestTotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestTotalDeathCount desc
```
This query lists countries with the highest death counts per population.

## Continent-wise Death Count <a name="continent-wise-death-count"></a>
```sql
SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestTotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestTotalDeathCount desc
```
This query displays the continents with the highest death counts.

## Global Numbers <a name="global-numbers"></a>
```sql
SELECT date, SUM(new_cases) AS NewCases, SUM(CAST(new_deaths AS INT)) AS NewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2
```
These queries provide various global statistics including daily new cases, deaths, and death percentage.
* The CAST() function in SQL is used to convert an expression from one data type to another. The CAST() function is applied to new_deaths, converting its data type to INT, which stands for integer. This conversion ensures that the values in the new_deaths column, which is stored in nvarchar data type is treated as integers. 
* The SUM() function then aggregates the converted values of new_deaths, summing up the total number of new deaths across all records.


## Total Population vs Vaccinations <a name="total-population-vs-vaccinations"></a>
```sql
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3
```
This query analyzes the progress of COVID-19 vaccinations relative to population size. Here's a breakdown of the code:

1. **SELECT statement**:
   - It selects specific columns from two tables, `CovidDeaths` and `CovidVaccinations`.
   - Additionally, it calculates the rolling sum of new vaccinations using the `SUM()` function with the `OVER` clause. This rolling sum is partitioned by location and ordered by location and date. The result is aliased as `RollingPeopleVaccinated`.

2. **FROM clause**:
   - It specifies the tables from which data will be retrieved: `PortfolioProject..CovidDeaths` and `PortfolioProject..CovidVaccinations`.
   - The `dea` and `vac` are aliases assigned to the `CovidDeaths` and `CovidVaccinations` tables, respectively.

3. **JOIN condition**:
   - It joins the `CovidDeaths` and `CovidVaccinations` tables based on the location and date columns.
   - This ensures that the vaccination data corresponds to the same location and date as the COVID-19 data.

4. **WHERE clause**:
   - Filters out records where the continent is not specified, ensuring that only relevant data is included in the analysis.

5. **ORDER BY clause**:
   - Orders the results primarily by location (`location`) and then by date (`date`) in ascending order.

## Using Common Table Expressions (CTEs) <a name="using-common-table-expressions-ctes"></a>
```sql
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
```
This code utilizes a Common Table Expression (CTE) named `PopvsVac` to calculate the percentage of the population vaccinated. Here's a concise explanation:

1. **CTE Definition (PopvsVac)**:
   - The CTE defines columns `continent`, `location`, `date`, `population`, `new_vaccinations`, and `RollingPeopleVaccinated`.
   - It selects data from `CovidDeaths` and `CovidVaccinations` tables, joining them on the location and date.
   - The `SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated` calculates the rolling sum of new vaccinations partitioned by location and ordered by location and date.

2. **Main Query**:
   - The main query selects all columns from the CTE (`PopvsVac`).
   - It calculates the percentage of rolling people vaccinated by dividing `RollingPeopleVaccinated` by `Population` and multiplying by 100.

Overall, this query provides a concise and efficient way to calculate the percentage of the population vaccinated by leveraging a CTE for intermediate calculations.

## Using Temporary Tables <a name="using-temporary-tables"></a>
```sql
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
SELECT *, (RollingPeopleVaccinated/Population)*

100 AS PercentageRollingPeopleVaccinated
FROM #PercentPopulationVaccinated
```
This code showcases the utilization of temporary tables to store intermediate results and execute subsequent calculations. Here's a brief overview:

1. **Temporary Table Creation**:
   - It starts by dropping the temporary table `#PercentPopulationVaccinated` if it already exists to ensure a clean slate.
   - Then, it creates a new temporary table `#PercentPopulationVaccinated` with specified columns: `Continent`, `Location`, `Date`, `Population`, `New_vaccinations`, and `RollingPeopleVaccinated`.

2. **Data Insertion**:
   - Next, it inserts data into the temporary table.
   - The data is selected from a query that joins data from two tables, `CovidDeaths` and `CovidVaccinations`, based on location and date.
   - The `RollingPeopleVaccinated` column is calculated as a rolling sum of new vaccinations partitioned by location and ordered by location and date.

3. **Main Query**:
   - After populating the temporary table, a subsequent SELECT statement is executed.
   - This SELECT statement retrieves all columns from the temporary table (`#PercentPopulationVaccinated`).
   - Additionally, it calculates the percentage of rolling people vaccinated by dividing `RollingPeopleVaccinated` by `Population` and multiplying by 100.

In summary, this code segment employs temporary tables to store intermediate results, facilitating the execution of further calculations or data manipulation operations on the stored data.

## Creating Views <a name="creating-views"></a>
```sql
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

CREATE VIEW HighestDeathCount AS
SELECT location, MAX(CAST(total_deaths AS int)) AS HighestTotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
-- ORDER BY HighestTotalDeathCount desc
```
This code snippet creates two views, `PercentPopulationVaccinated` and `HighestDeathCount`, to store data for subsequent visualization or analysis. Here's a concise explanation:

1. **Creating the View `PercentPopulationVaccinated`**:
   - This view is created using the `CREATE VIEW` statement.
   - It selects specific columns (`continent`, `location`, `date`, `population`, `new_vaccinations`) from the joined tables `CovidDeaths` and `CovidVaccinations`.
   - The `SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated` calculates the rolling sum of new vaccinations partitioned by location and ordered by location and date.
   - The `WHERE` clause filters out records where the continent is not specified.
   - There is a commented-out `ORDER BY` clause which isn't functional within a view.

2. **Creating the View `HighestDeathCount`**:
   - This view is also created using the `CREATE VIEW` statement.
   - It selects the `location` column and calculates the maximum value of `total_deaths`, cast as an integer, for each location.
   - The `WHERE` clause filters out records where the continent is not specified.
   - The results are grouped by location.
   - Similar to the first view, there is a commented-out `ORDER BY` clause which isn't functional within a view.

Overall, these views simplify complex queries and facilitate data reuse by storing specific subsets of data from the `CovidDeaths` and `CovidVaccinations` tables. They can be queried directly like tables, making it easier to analyze or visualize the data they contain.
