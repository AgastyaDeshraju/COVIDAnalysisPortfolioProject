USE COVIDAnalysis

select * 
from COVIDAnalysis..CovidDeaths
order by 3,4;


select * 
from COVIDAnalysis..CovidVaccinations
order by 3,4;


--Selecting the data that we will be using for the Exploratory Data Analysis
select location, date, total_cases, new_cases, total_deaths, population
from COVIDAnalysis..CovidDeaths
order by 1,2;


--Looking at the total cases vs total deaths
--Likelihood of not surviving if contracted with COVID-1, latest recorded death percentage seems to be about 1.1%
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from COVIDAnalysis..CovidDeaths
where location like '%states%'
order by 1,2;


--Percentage of population that has been infected with COVID-19
--Latest trends show that about 30% of the population has contracted the vaccine
select location, date, total_cases, population, (total_cases/population) * 100 as PercentageOfCases
from COVIDAnalysis..CovidDeaths
where location like '%states%'
order by 1,2;


--Countries with highest infection rates compared with the population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) * 100 as PercentOfPopulationInfected
from COVIDAnalysis..CovidDeaths
group by population, location
order by PercentOfPopulationInfected desc;


--Countries with the highest death count
select location, max(cast(Total_deaths as int)) as TotalDeathCount
from COVIDAnalysis..CovidDeaths
where continent is not null		--issue with the dataset, when "continent is null" is allowed, continents show up in the location column as well
group by Location
order by TotalDeathCount desc;

--Continents with the highest death counts
select continent, max(cast(Total_deaths as int)) as TotalDeathCount		
from COVIDAnalysis..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;


--Global Numbers for new cases vs deaths on a daily basis (As of January 4th, 2023)
select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, (sum(cast(new_deaths as int))/sum(new_cases)) * 100 as DeathPercentage
from COVIDAnalysis..CovidDeaths
where continent is not null
group by date
order by 1,2;


--Total Cases and deaths as of January 4th 2023
select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, (sum(cast(new_deaths as int))/sum(new_cases)) * 100 as DeathPercentage
from COVIDAnalysis..CovidDeaths
where continent is not null
order by 1,2;



--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from COVIDAnalysis..CovidDeaths dea
join COVIDAnalysis.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;


--Using CTE to perform Calculation on Partition By in previous query

With PopVsVac(continet, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from COVIDAnalysis..CovidDeaths dea
join COVIDAnalysis.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from COVIDAnalysis..CovidDeaths dea
join COVIDAnalysis.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating views for visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from COVIDAnalysis..CovidDeaths dea
join COVIDAnalysis.. CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
