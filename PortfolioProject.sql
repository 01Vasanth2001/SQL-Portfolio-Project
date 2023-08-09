---This SQL project delves into a comprehensive dataset that encompasses COVID-19 deaths and vaccination statistics, 
---aiming to unravel insights through a spectrum of queries ranging from beginner to advanced levels. 
---As we navigate through the dataset, we will harness the power of SQL to manipulate, aggregate, and analyze data, providing a hands-on journey 
---for both beginners and experienced data enthusiasts. From basic queries that extract key statistics to complex analyses that 
---uncover intricate patterns, this project offers an opportunity to not only enhance SQL skills but also 
---contribute to the broader understanding of the pandemic's progression and the response to it. 
---Join us in this endeavor to transform raw data into meaningful information, gaining valuable insights into one of the most impactful events of our time.

---------------------------------------------------------------------------------------------------------------------------------------------
--showing tables

---CovidDeaths Table
select *
from PortfolioProject.dbo.CovidDeaths
order by 3,4

---CovidVaccination Table

select *
from PortfolioProject.dbo.CovidVaccinations
order by 3,4

-----------------------------------------------------------------------------------------------------------------------------------------

---Selecting the data that we are going to be using

select location,date,Total_Cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2 

------------------------------------------------------------------------------------------------------------------------------------------

--changing datatype as required
alter table coviddeaths
alter column total_cases float

alter table coviddeaths
alter column total_deaths float

alter table coviddeaths
alter column new_cases varchar

alter table covidvaccinations
alter column new_vaccinations float

--------------------------------------------------------------------------------------------------------------------------------


--looking at total cases vs total death%
---shows liklihood of dying if you contract covid in your country

select location,date,total_cases ,total_deaths ,(total_deaths/total_cases )*100 as deathpercentage
from PortfolioProject..CovidDeaths
where location like '%india%' 
order by 3,4 

---------------------------------------------------------------------------------------------------------------------------------------

---looking at total cases vs population
---shows what % of population got covid

select location,date,total_cases ,population ,(population/total_cases )*100 as infectedaccpopulation
from PortfolioProject..CovidDeaths
--where location like '%india%' 
order by 3,4 desc

-------------------------------------------------------------------------------------------------------------------------------

--looking at countries with highest infectin rate -population

select location,population,max(total_cases) as MaxInfCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location,population
order by PercentPopulationInfected desc

--------------------------------------------------------------------------------------------------------------------------------

--showing countries with highest death count per population

select location,max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%india%'
group by location,population
order by TotalDeathCount desc

--- in the above code , the where statement is used to remove the rows having data of a whole continent but only countries

---showing countries with highest death count per population
select continent,max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%india%'
group by continent,population
order by TotalDeathCount desc


------------------------------------------------------------------------------------------------------------


---GLOBAL NUMBERS
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum (new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
group by date
order by 1,2

-------------------------------------------------------------------------------------------------------------

--Joining Two Tables
select*
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date

--------------------------------------------------------------------------------------------------

---looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is null
order by rollingpeoplevaccinated

---partition by is added so that a new column named rollingpeoplevaccinated is created which
--shows the cumulative sum of the number of vaccinations taken by people the very next day !!!

----------------------------------------------------------------------------------------------------

--USE CTE

with PopvsVac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated) as 
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is null
)
select * ,(rollingpeoplevaccinated/population)*100 as populationvsvaccination
from PopvsVac

---------------------------------------------------------

--TEMP Table

Drop Table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
pupulation numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)



INSERT into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *,(rollingpeoplevaccinated/population)*100 
from #percentpopulationvaccinated

-----

---CREATING VIEW  to store dayta for later visualizations

create view percentpopulationvaccinated as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

---All The Above Above Codes And Queries Contain The Major Queries From Beginner To advanced Level--


-----------------------------------------------------------THE END ----------------------------------------------------------------------------------
)




