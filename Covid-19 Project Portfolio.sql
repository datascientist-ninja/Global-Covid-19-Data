select * 
from Projects.dbo.CovidDeaths
where continent is not null 
order by location, date  
 
-- COUNTRY DATA
-- Likelihood of Death After Infection 
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from Projects.dbo.CovidDeaths
where continent is not null
order by location, date 

--Total Infections Across Countries 
select location, population, max(total_cases) as TotalCases, max((total_cases/population)) * 100 as PercentageInfected
from Projects.dbo.CovidDeaths
where continent is not null 
group by location, population
order by PercentageInfected desc 

-- Total Death Across Continents
select location, max(cast (total_deaths as int)) as TotalDeathCount
from Projects.dbo.CovidDeaths
where continent is null 
group by location  
order by TotalDeathCount desc

-- Total Death Across Countries 
select location, max(cast (total_deaths as int)) as TotalDeathCount
from Projects.dbo.CovidDeaths
where continent is not null 
group by location 
order by TotalDeathCount desc 

-- CONTINENTAL DATA 
-- Total Death Across Continents  
select continent, max(cast (total_deaths as int)) as TotalDeathCount
from Projects.dbo.CovidDeaths
where continent is not null 
group by continent  
order by TotalDeathCount desc 

-- Percentage Sum of Global Death 
select sum(new_cases) as TotalCases, sum(cast (new_deaths as int)) as TotalDeath, sum(cast (new_deaths as int))/
sum(new_cases)*100 as GlobalPercentageDeath
from Projects.dbo.CovidDeaths
where continent is not null
 
 -- UNDERSTANDING VACCINATION PROGRESS 
 -- Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations))over 
(partition by dea.location order by dea.location, dea.date) as rolling_vaccination 
from Projects.dbo.CovidDeaths as dea
join Projects.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by dea.location, dea.date

-- Using CTE to perform calculation on Partition By in previous query

with PopVac_Table (continent, location, date, population, new_vaccinations, rolling_vaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations))over 
(partition by dea.location order by dea.location, dea.date) as rolling_vaccination 
from Projects.dbo.CovidDeaths as dea
join Projects.dbo.CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by dea.location, dea.date 
)

select *, (rolling_vaccination/Population)*100 as PercentagePopulationVaccinated
from PopVac_Table 

-- CREATING VIEW FOR LATER VISUALIZATION
create view GlobalCovidDeath as 
select continent, max(cast (total_deaths as int)) as TotalDeathCount
from Projects.dbo.CovidDeaths
where continent is not null 
group by continent  
--order by TotalDeathCount desc 

select *
from GlobalCovidDeath