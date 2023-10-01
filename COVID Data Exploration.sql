SELECT *
FROM [Project Portfolio]..CovidDeaths
ORDER BY 3,4

SELECT *
FROM [Project Portfolio]..CovidVaccinations
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Project Portfolio]..CovidDeaths
ORDER BY 1,2

-- Shows Total Cases and Total Deaths from Covid per Country
SELECT location, COUNT(total_cases) total_cases, COUNT(total_deaths) total_deaths
FROM [Project Portfolio]..CovidDeaths
GROUP BY location
ORDER BY 1

-- Shows Covid Cases, Died from Covid Cases, and Death Percentage in the Philippines from time-to-time
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths as FLOAT)/total_cases)*100 AS DeathPercentage
FROM [Project Portfolio]..CovidDeaths
WHERE location LIKE '%Philippines%'
ORDER BY 1,2

-- Shows Covid Cases over Population in the Philippines from time-to-time
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationCasesPercentage
FROM [Project Portfolio]..CovidDeaths
WHERE location LIKE '%Philippines%'
ORDER BY 1,2

-- Shows Highest Infection Count per Country
SELECT location, population, MAX(total_cases) HighestInfectionCount
FROM [Project Portfolio]..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY HighestInfectionCount desc

-- Shows Highest Death Count per Country
SELECT location, population, MAX(total_deaths) HighestDeathCount
FROM [Project Portfolio]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestDeathCount DESC

-- Shows Highest Death Count per Continent
SELECT location, MAX(total_deaths) HighestDeathCount
FROM [Project Portfolio]..CovidDeaths
WHERE continent IS NULL and location <> 'International'
GROUP BY location
ORDER BY HighestDeathCount DESC

SELECT continent, SUM(new_deaths) TotalDeaths
FROM [Project Portfolio]..CovidDeaths
WHERE continent != ''
GROUP BY continent
ORDER BY TotalDeaths DESC

-- Shows Total Covid Cases and Total Death Cases from time-to-time across the world
SELECT date, SUM(new_cases) CasesPerDay , SUM(new_deaths) DeathsPerDay, (CAST(SUM(new_deaths) AS FLOAT)/SUM(new_cases))*100 DeathPercentagePerDay
FROM [Project Portfolio]..CovidDeaths
WHERE continent IS NOT NULL and new_cases IS NOT NULL
GROUP BY date
ORDER BY date

-- Displays Amount of People that got Vaccinated by Continent
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) RollingPeopleVaccinated
FROM [Project Portfolio]..CovidDeaths cd
JOIN [Project Portfolio]..CovidVaccinations cv ON cv.location = cd.location and cv.date = cd.date
WHERE cd.continent IS NOT NULL 
ORDER BY 1,2,3

WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date)
FROM [Project Portfolio]..CovidDeaths cd
JOIN [Project Portfolio]..CovidVaccinations cv ON cv.location = cd.location and cv.date = cd.date
WHERE cd.continent IS NOT NULL
)
SELECT *
FROM PopvsVac

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
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) RollingPeopleVaccinated
FROM [Project Portfolio]..CovidDeaths cd
JOIN [Project Portfolio]..CovidVaccinations cv ON cv.location = cd.location and cv.date = cd.date
WHERE cd.continent IS NOT NULL

CREATE VIEW PercentPopulationVaccinated AS
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) RollingPeopleVaccinated
FROM [Project Portfolio]..CovidDeaths cd
JOIN [Project Portfolio]..CovidVaccinations cv ON cv.location = cd.location and cv.date = cd.date
WHERE cd.continent IS NOT NULL