--Create database
CREATE Database PortfoliO

ALTER Database PortfoliO Modify Name = Portfolio

Use Portfolio


SELECT TOP(10) * 
FROM CovidDeaths$ 
Order by 3,4

SELECT TOP(10) * 
FROM CovidVaccinations$ 
Order by 3,4

--Change data type
ALTER TABLE CovidDeaths$ ALTER COLUMN total_deaths bigint
ALTER TABLE CovidDeaths$ ALTER COLUMN total_cases bigint
ALTER TABLE CovidVaccinations$ ALTER COLUMN new_vaccinations bigint

--1)Show percentage of death in specific country 
SELECT location, total_deaths1, total_cases1, 100.0*total_deaths1/total_cases1 as Death_Percentage
FROM(
SELECT location, sum(total_deaths) as total_deaths1, sum(total_cases) as total_cases1
FROM CovidDeaths$ 
WHERE NOT (total_deaths is null OR total_cases is null OR continent is null) 
GROUP BY location
) as death
ORDER BY 1

--2)Show percentage of death in country daily
Select Location, date, total_cases,total_deaths, 100.0*total_deaths/total_cases as DeathPercentage
From CovidDeaths$
ORDER BY 1,2

--3)Show percentage of total cases in certain population 
SELECT location, sum(total_cases) as total_cases, MAX(population) as population, MAX((total_cases/population)*100) as PercentPopulationInfected   
From CovidDeaths$
GROUP BY location
ORDER BY 1

--4)Show percentage of total cases in certain population daily
SELECT Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths$
order by 1,2

--5)Country with highest infection rate per population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc

--6)Country with highest death rate per population
Select Location, Population, MAX(total_deaths) as HighestDeathCount,  Max((total_deaths/population))*100 as PercentPopulationDeaths
From CovidDeaths$
Group by Location, Population
order by PercentPopulationDeaths desc

--7)Continent with highest death count
Select continent, MAX(total_deaths) as TotalDeathCount
From CovidDeaths$
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--8)Show global total cases, total death & death percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
where continent is not null 
order by 1,2

--9)Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT continent, location, date, population, new_vaccinations, RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100 as PercentageReceivedVaccine
FROM
(SELECT dea.continent as continent, dea.location as location, dea.date as date, dea.population as population, vac.new_vaccinations as new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
)as vaccine
ORDER BY 1,2,3

--10)Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT continent, location, date, population, new_vaccinations, RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100 as PercentageReceivedVaccine
FROM
(SELECT dea.continent as continent, dea.location as location, dea.date as date, dea.population as population, vac.new_vaccinations as new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
)as vaccine
