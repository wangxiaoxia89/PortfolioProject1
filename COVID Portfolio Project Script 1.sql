
Select *
From PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4


--Select *
--From PortfolioProject1..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Where continent is not null
order by 1,2


-- Examining Total Cases VS Total Deaths
-- Likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%china%'
and continent is not null
order by 1,2

-- Total Cases VS Population
-- Illustrate the percentage of population affected

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
Where location like '%china%'
Where continent is not null
order by 1,2

-- Countries With Highest Infection Rate Compared to Population

Select Location,  Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location like '%china%'
Group by Location, Population 
order by PercentPopulationInfected desc


-- Illustrate Countries With Hightest Death Count per Population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%china%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- BREAK DOWN BY CONTINENT 

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%china%'
Where continent is not null
Group by continent 
order by TotalDeathCount desc

-- Illustrate continents with  the highest death count per population 

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%china%'
Where continent is not null
Group by continent 
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%china%'
where continent is not null
--Group By date
order by 1,2


-- Total Population VS Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
   On dea.location = vac.location 
   and dea.date = vac.date 
where dea.continent is not null
order by 1,2,3


-- The Number of New Vaccinated per Day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea. Location, dea. Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population )*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
   On dea.location = vac.location 
   and dea.date = vac.date 
where dea.continent is not null
order by 2,3





-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea. Location, dea. Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population )*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
   On dea.location = vac.location 
   and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac





--TIMP TABLE 

DROP Table if exists ##PercentPopulationVaccinated 
Create Table ##PercentPopulationVaccinated 
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric 
)

Insert into ##PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea. Location, dea. Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
   On dea.location = vac.location 
   and dea.date = vac.date 
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From ##PercentPopulationVaccinated 



-- Creating View to Store Data for Later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea. Location, dea. Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
   On dea.location = vac.location 
   and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated