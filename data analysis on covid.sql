select * from PortfolioProject..CovidDeaths$
select location, total_cases, total_deaths, population
from PortfolioProject..CovidDeaths$

--looking at total cases vs total deaths

select location, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths$
where location like 'india'


-- show waht percentage of population got covid

select location, total_cases, total_deaths, population, (total_cases/population)*100 as deathpercentage
from PortfolioProject..CovidDeaths$
where location like 'india'


-- looking at countries with highest infection rate commpared to population

select location, max(total_cases) as highestinfectionrate, population, max(total_cases/population)*100 as highestinfectionratepopulation
from PortfolioProject..CovidDeaths$
group by location, population 
order by highestinfectionratepopulation desc


-- showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by totaldeathcount desc


-- shows percentage of population that has received at least one covid vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--looking total population vs vaccination

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location

and dea.date = vac.date

where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac



--- global numbers


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
  (new_deaths as int))/ sum(new_cases)*100 as deathpercentage
  from portfolioproject..CovidDeaths$
  where continent is not null
  -- group by date
  order by 1,2

 --temp table
  
DROP TABLE IF EXISTS #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location

and dea.date = vac.date

--where dea.continent is not null
--order by 2,3
select *, (rollingpeoplevaccinated/population)*100 
from #percentpopulationvaccinated
 

 -- creating view to store data for later visualizations


Create View PercentPopulationVaccinateed as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

