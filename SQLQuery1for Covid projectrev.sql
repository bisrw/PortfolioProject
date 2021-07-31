--select * 
--from
--[dbo].[COVID_Vaccination$]
--Order by 3,4

select * 
from
 [dbo].[COVID_Death]
Order by 3,4

--- to Show the continent without the null value

select * 
from
 [dbo].[COVID_Death]
where continent is not null
Order by 3,4


-- Selecting data that we are going to be using 

Select Location,date,total_cases,new_cases,total_deaths,population 
from
[dbo].[COVID_Death]
order by 1,2

--- Looking at total cases VS total deaths

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from
[dbo].[COVID_Death]
where location like '%state%'
order by 1,2

--Looking at total_cases VS population 

Select Location,date,total_cases,population,(total_cases/population)*100 as case_percentage
from
[dbo].[COVID_Death]
where location like '%state%'
order by 1,2

---- Looking at countries with the highest infection rate compared to population

Select Location,MAX(total_cases) as maxinfectioncases,population,MAX((total_cases/population))*100 as max_case_percentage
from
[dbo].[COVID_Death]
Group by Location,Population
order by max_case_percentage desc

----Showing countries with the highest death rate compared to population


Select Location,MAX(cast(total_deaths as int)) as maxdeathcount
from
[dbo].[COVID_Death]
where continent is not null
Group by Location 
order by maxdeathcount desc

----To break down in to the continent

Select continent,MAX(cast(total_deaths as int)) as maxdeathcount
from
[dbo].[COVID_Death]
--where continent is not null
Group by continent 
order by maxdeathcount desc

----  Global case counts


Select date,sum(new_cases),sum(cast(new_deaths as int)),sum(cast(new_deaths as int))/sum(total_cases)*100 as death_percentage
from
[dbo].[COVID_Death]
--where location like '%state%'
group by date
order by 1,2

select * 
from

[dbo].[COVID_Vaccination$]

Select * 
from [dbo].[COVID_Death] dea
Join [dbo].[COVID_Vaccination$] vac
on
dea.location = vac.location and dea.date = vac.date

---Looking at population VS vaccination

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from [dbo].[COVID_Death] dea
Join [dbo].[COVID_Vaccination$] vac
on
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

use [Portfolioproject]
go

---- Looking at daybyday vaccinations

select dea.location, dea.date,sum(cast(vac.new_vaccinations as int)) as daybyday_vac
from [dbo].[COVID_Death] dea
Join [dbo].[COVID_Vaccination$] vac
on
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
group by dea.location,dea.date
order by 1,2

---Looking at the total vaccinations by rolling up


select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) 
OVER (PARTITION BY dea.location order by dea.location, dea.date) as Rolling_Vaccinations
from [dbo].[COVID_Death] dea
Join [dbo].[COVID_Vaccination$] vac
on
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

With popvsvac (continent,location, date, population,new_vaccinations,rolling_vaccinations)
as
(select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) 
OVER (PARTITION BY dea.location order by dea.location, dea.date) as Rolling_Vaccinations
from [dbo].[COVID_Death] dea
Join [dbo].[COVID_Vaccination$] vac
on
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)

select *,(Rolling_Vaccinations/population)*100
from  popvsvac 
order by location,date

----temp table
Drop table if exists #Populationvsvaccinations

create table #Populationvsvaccinations
(continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric)

insert into
 #Populationvsvaccinations
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) 
OVER (PARTITION BY dea.location order by dea.location, dea.date) as Rolling_Vaccinations
from [dbo].[COVID_Death] dea
Join [dbo].[COVID_Vaccination$] vac
on
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *,(Rolling_Vaccinations/population)*100
from  #Populationvsvaccinations
order by location,date

----- creating views for later visualization

create view vaccinations as

select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) 
OVER (PARTITION BY dea.location order by dea.location, dea.date) as Rolling_Vaccinations
from [dbo].[COVID_Death] dea
Join [dbo].[COVID_Vaccination$] vac
on
dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
