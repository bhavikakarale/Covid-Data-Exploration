--check if data is imported properly
select * from DataAnalysisUsingSQL..CovidDeaths
where continent is not null
order by 3,4

select * from DataAnalysisUsingSQL..CovidVaccinations
order by 3,4
-- order by 3,4  orders the results based on the values in the third and fourth columns of the selected data. The numbers 3 and 4 refer to the positions of the columns in the result set.



--select data to be used
select location, date, total_cases, new_cases, total_deaths, population
from DataAnalysisUsingSQL..CovidDeaths
order by 1,2



--look at total cases and total deaths
--shows likelihood of dying if you get affected by covid in a specific country
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from DataAnalysisUsingSQL..CovidDeaths
where location like '%states%'
order by 1,2



--looking at total cases vs population
--shows what % of population got covid
select location, date, total_cases, new_cases, population, (total_cases/population)*100 as affectedby_percentage
from DataAnalysisUsingSQL..CovidDeaths
where location like '%states%'
order by 1,2



--look at countries having highest infection rate compared to population
select location, max(total_cases) as max_total_cases, population,  max((total_cases/population))*100 as max_percent_infected
from DataAnalysisUsingSQL..CovidDeaths
group by location, population
order by max_percent_infected desc




--show countries with highest death counts
select location, max(cast(total_deaths as int)) as max_total_deaths
from DataAnalysisUsingSQL..CovidDeaths
where continent is not null
group by location
order by max_total_deaths desc



--show continents with highest death counts
select location,  max(cast(total_deaths as int)) as max_total_deaths
from DataAnalysisUsingSQL..CovidDeaths
where continent is null
group by location
order by max_total_deaths desc



--getting global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from DataAnalysisUsingSQL..CovidDeaths
where continent is not null
group by date
order by 1,2


--get overall cases, deaths and %
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from DataAnalysisUsingSQL..CovidDeaths
where continent is not null
--group by date
order by 1,2



--join 2 tables
select * from DataAnalysisUsingSQL..CovidDeaths dea
join DataAnalysisUsingSQL..CovidVaccinations vac
on dea.location = vac.location and
	dea.date = vac.date


--look at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, dea.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from DataAnalysisUsingSQL..CovidDeaths dea
join DataAnalysisUsingSQL..CovidVaccinations vac
on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
order by 2,3


--use CTE
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, dea.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from DataAnalysisUsingSQL..CovidDeaths dea
join DataAnalysisUsingSQL..CovidVaccinations vac
on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (rolling_people_vaccinated/Population)*100
from PopvsVac


--use temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
rolling_people_vaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, dea.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from DataAnalysisUsingSQL..CovidDeaths dea
join DataAnalysisUsingSQL..CovidVaccinations vac
on dea.location = vac.location and
	dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * , (rolling_people_vaccinated/Population)*100
from #PercentPopulationVaccinated




--creating view to store data for visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, dea.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from DataAnalysisUsingSQL..CovidDeaths dea
join DataAnalysisUsingSQL..CovidVaccinations vac
on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null


select * from PercentPopulationVaccinated

