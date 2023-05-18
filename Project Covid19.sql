 --How did South Korean Data Collecting Policies contribute in keeping the Covid case and death rate low?

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--The likelihood of dying if you contact Covid in South Korea

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'South Korea'
ORDER BY 1,2

--Total_Cases vs Total Population
--Shows what Percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'South Korea'
ORDER BY 1,2

--Countries with highest infection rate per population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Countries with highest deaths rate per population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Let’s break things down by continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers per day
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, 
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Global numbers in total
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, 
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE (The Common Table Expression to simplify a query)
WITH PopvsVac (continent, location, date, population, New_vaccinations, 
	RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE (Temporary Tables)

DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating VIEW to store data for data visualisations

--Total Population vs Vaccination from the above 

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, 
	dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated


