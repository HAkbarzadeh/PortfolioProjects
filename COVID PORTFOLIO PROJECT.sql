
SELECT*
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4


--SELECT*
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths 
-- show the chance of dying if you contract covid in UK

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
AND location like '%kingdom%'
ORDER BY 1,2

-- looking at total cases vs population 
-- What Percent of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- SHowing Countries With Highest Death Count Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%kingdom%'
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- SHowing Continent With Highest Death Count Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
AND location <> 'Upper middle income'
AND location <> 'High income'
AND location <> 'Lower middle income'
AND location <> 'Low income'
GROUP BY location
ORDER BY TotalDeathCount DESC



-- Showing Continents With Highest Death count per population 

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers 

-- per date 
SELECT date, SUM (new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, SUM(CAST(new_deaths AS INT))/SUM (new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group BY date
ORDER BY 1,2

-- Total

SELECT SUM (new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, SUM(CAST(new_deaths AS INT))/SUM (new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
--Group BY date
ORDER BY 1,2


-- Total population VS vaccinations


--CTE 
WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT*, (rollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR (255),
Location NVARCHAR (255),
Date DATETIME,
Population Numeric,
New_Vaccination Numeric,
RollingPeopleVaccinated Numeric
)

InSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT*, (rollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Create view to Store Data For Visualisation 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT* 
FROM PercentPopulationVaccinated