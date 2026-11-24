use
world_layoffs;

#creo la una tabla para poder manipular los datos 
create table layoffs_staging
like layoffs;

#inserto informacion en la tabla 
insert layoffs_staging
select * from layoffs;

select * from layoffs_staging;


with duplicate_cte as 
(
select *,
row_number()over(
partition by company ,location ,industry,total_laid_off,
percentage_laid_off, `date`,stage,country ,funds_raised_millions ) as row_num from layoffs_staging
)
select* from duplicate_cte
where row_num >1;

# se debe crear otra tabla que contenga la columna row_num para poder eliminar
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

#Remover duplicados
insert into layoffs_staging2
select *,
row_number()over(
partition by company ,location ,industry,total_laid_off,
percentage_laid_off, `date`,stage,country ,funds_raised_millions ) as row_num from layoffs_staging;

#elimino los duplicados
delete
from layoffs_staging2
where row_num > 1;

#Estandarizacion de datos 
select distinct(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct(industry)
from layoffs_staging2
order by industry asc;

select *
from layoffs_staging2
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

update layoffs_staging2
set `date`= str_to_date(`date`, '%m/%d/%Y');

select `date`
from layoffs_staging2;

alter table layoffs_staging2
modify column `date` date;

#Nulls y espacios en blanco 
select* 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select company , industry
from layoffs_staging2
where industry is null
or industry='';


select t1.company, t2.company , t1.industry, t2.industry
from layoffs_staging2 t1 
join layoffs_staging2 t2
  on t1.company = t2.company
where (t1.industry is null or t1.industry ='')
and t2.industry is not null and t2.industry !='';

update layoffs_staging2 t1
join layoffs_staging2 t2
  on t1.company = t2.company
set t1.industry = t2.industry
where (t1.industry is null or t1.industry ='')
and t2.industry is not null and t2.industry !='';

select*
from layoffs_staging2
where company = "Bally's Interactive";

#Eliminar columnas innecesarias 
select count(*) 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select*
from layoffs_staging2;


alter table layoffs_staging2
drop column row_num;




