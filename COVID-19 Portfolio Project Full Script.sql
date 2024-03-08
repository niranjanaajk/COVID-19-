SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2

--Total Cases vs Total Deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
ORDER BY 1,2


--Total Cases vs Population

select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
ORDER BY 1,2


--Countries with highest infection rate w.r.t population

select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
    PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null 
--where location like '%states%'
Group by Location, Population
ORDER BY PercentPopulationInfected desc


--Countries with highest Death count

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
ORDER BY TotalDeathCount desc

select Sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage  
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
--group by date
ORDER BY 1,2


--Total Population vs Vaccinations 

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Creating a temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated