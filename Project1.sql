SELECT *
FROM CovidDeaths
ORDER BY 3,4

--Lets check the percentage of people who go infection
SELECT Location,date,total_cases,population,(total_cases/population) AS InfectionRate
FROM CovidDeaths
WHERE Location LIKE '%India%'
ORDER BY 1,2

--Lets look at the maximum of the the infection per poulation in this world
SELECT location,population ,MAX(total_cases)as InfectionCount,Max((total_cases/population))*100 AS MaxInfectionRate
FROM CovidDeaths
GROUP BY location,population
ORDER BY MaxInfectionRate DESC


--lets look with highest death count 
SELECT location,MAX(total_deaths)as MaxDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MaxDeathCount DESC

--lets look with highest death count per continent
SELECT location,MAX(total_deaths)as MaxDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY MaxDeathCount DESC

--lets look with highest death count per population in a continent
SELECT location,population,MAX(total_deaths/population)as MaxDeathCountPerContinent
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location,population
ORDER BY MaxDeathCountPerContinent DESC

--checking everything globally 
SELECT date,SUM(cast(new_cases as int)) AS TotalCases ,SUM(new_deaths) as Totaldeaths,(SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS DeathPerDay
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1

ALTER TABLE dbo.CovidVaccinations
ALTER Column date INT


--Lets look in other table and see total vaccinations vs population
SELECT vac.continent ,vac.date,vac.location,vac.population,vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY vac.location ORDER BY vac.date,vac.location) AS TotalVaccination 
FROM CovidVaccinations vac
JOIN CovidDeaths dea
	ON vac.date=dea.date
	AND vac.location=dea.location
WHERE vac.continent is NOT NULL
ORDER BY 3,2


--Calculationing the vaccination percentage

--USING CTE
WITH CTE_Vaccination (continent,date,location,population,newvac,totalvac) as
(SELECT vac.continent ,vac.date,vac.location,vac.population,vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY vac.location ORDER BY vac.date,vac.location) AS TotalVaccination 
FROM CovidVaccinations vac
JOIN CovidDeaths dea
	ON vac.date=dea.date
	AND vac.location=dea.location
WHERE vac.continent IS NOT NULL

)

SELECT *,(totalvac/population)*100 AS percentage
FROM CTE_Vaccination ct



--USING TEMP TABLE
DROP TABLE if exists #TempVaccination
CREATE TABLE #TempVaccination
(continent varchar(255),date nvarchar(255) ,location varchar(255),population BIGINT ,newvac BIGINT,totalvac BIGINT)

INSERT INTO #TempVaccination
SELECT vac.continent ,vac.date,vac.location,vac.population,vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY vac.location ORDER BY vac.date,vac.location) AS TotalVaccination 
FROM CovidVaccinations vac
JOIN CovidDeaths dea
	ON vac.date=dea.date
	AND vac.location=dea.location
WHERE vac.continent IS NOT NULL

SELECT*,((totalvac/population)*100) AS Percentage
FROM #TempVaccination




