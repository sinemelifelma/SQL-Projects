SELECT*
FROM PortfolioProject..CovidDeaths
Where continent is not NULL
ORDER BY 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not NULL
ORDER BY 1,2

--Looking at Total Cases vs. Total Deaths
--Shows the likelihood of dying if you contract covid in the Netherlands

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%net%' and continent is not NULL
ORDER BY 1,2

--Looking at Total Cases vs. Population
--Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not NULL
ORDER BY 1,2

--Looking at Countries with the Highest Infection Rate Compared to Population

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not NULL
Group by Location, population
ORDER BY InfectionPercentage desc

--Looking at Countries with the Highest Death Count per Population 

Select Location, max(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not NULL
Group by Location
ORDER BY HighestDeathCount desc

--Showing the Continents with the Highest Death Count per Population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not NULL
Group by continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not NULL
--Group by date
ORDER BY 1,2

--Looking at Total Population vs. Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
ORDER BY 2, 3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not NULL
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to Store Data for Later Visualizations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select*
From #PercentPopulationVaccinated