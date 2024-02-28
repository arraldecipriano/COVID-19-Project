SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

--SELECT * 
--FROM CovidVaccinations
--ORDER BY 3, 4;

-- Selecting the data

SELECT location,
date,
total_cases,
new_cases,
total_deaths,
population
FROM CovidDeaths
ORDER BY 1, 2;

-- Total Cases vs. Total Deaths
-- Shows chances of dying if infected in your country

SELECT location,
date,
total_cases,
total_deaths,
(total_deaths / total_cases) * 100 AS 'DeathPercentage'
FROM CovidDeaths
WHERE location = 'Argentina'
ORDER BY 1, 2;

-- Total Cases vs Population
-- Shows percentage of infected population

SELECT location,
date,
total_cases,
population,
(total_cases / population) * 100 AS 'InfectedPercentage'
FROM CovidDeaths
WHERE location = 'Argentina'
AND continent IS NOT NULL
ORDER BY 1, 2;

-- Highest infection rate vs Population

SELECT location,
MAX(total_cases) AS 'HighestInfectionCount',
population,
MAX((total_cases / population)) * 100 AS 'InfectedPercentage'
FROM CovidDeaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC;

-- Highest Death Rate vs Population

SELECT location,
MAX(CAST(total_deaths AS int)) AS 'TotalDeaths'
-- Using CAST, total_deaths type is varchar
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeaths DESC;

-- Highest Death Rate vs Continent

SELECT continent,
MAX(CAST(total_deaths AS int)) AS 'TotalDeaths'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC;

SELECT location,
MAX(CAST(total_deaths AS int)) AS 'TotalDeaths'
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeaths DESC;


-- Global Death Percentage

SELECT date,
SUM(new_cases) AS 'TotalCases',
SUM(CAST(new_deaths AS int)) AS 'TotalDeaths',
SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS 'GlobalDeathPercentage'
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


-- Joining the two tables

SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date =	vac.date;

-- Population vs Vaccination

SELECT dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date =	vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- By Location

-- CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
AS (
SELECT dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'RollingVaccionations'
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date =	vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,
(RollingVaccinations / population) * 100
FROM PopVsVac;


-- Temporal table
DROP TABLE IF EXISTS #PopulationVaccinatedPercentage;

CREATE TABLE #PopulationVaccinatedPercentage
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric)

INSERT INTO #PopulationVaccinatedPercentage
SELECT dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'RollingVaccionations'
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date =	vac.date
WHERE dea.continent IS NOT NULL

SELECT *,
(RollingVaccinations / population) * 100
FROM #PopulationVaccinatedPercentage;

-- View table for visualization

CREATE VIEW VaccinatedPopulationPercentage AS
SELECT dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'RollingVaccionations'
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date =	vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM VaccinatedPopulationPercentage;

