use layoff;
SET SQL_SAFE_UPDATES = 0;
################################### PREPROCESSING STEPS #########################################
-- 1. REMOVE DUPLICATE
-- 2. STANDARDIZE
-- 3. REMOVE NULL OR BLANK VALUES (INLCUDING POPULATE)
-- 4. REMOVE UNNCESSARY COLUMNS

####################### PREPROCESSING REMOVING DUPLICATES #########################
-- 1.MEMBUAT TABLE DUPLIKAT AGAR DATA YANG ASLI TIDAK TERKOTAK KATIK
select
	*
from
	layoffs;

create table layoff_staging
LIKE layoffs;

insert into layoff_staging
select
	*
from
	layoffs;
    
select
	*
from
	layoff_staging;
    
-- 2.cek data yang duplikat dengan window function row number
select
	*,
    ROW_NUMBER() OVER(
    PARTITION BY
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    date,
    stage,
    country,
    funds_raised_millions) as row_num
from
	layoff_staging;
    
-- 3. simpan di cte agar mudah untuk dipanggil
with duplicate_cte as
(
select
	*,
    ROW_NUMBER() OVER(
    PARTITION BY
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    date,
    stage,
    country,
    funds_raised_millions) as row_num
from
	layoff_staging
)

select
	*
from
	duplicate_cte
where
	row_num >1;

DELETE
FROM duplicate_cte
where row_num > 1; #QUERY INI TIDAK AKAN WORKS KARENA CTE TIDAK BISA DI UPDATE, DAN DELETE MERUPAKAN STATEMENT DELETE
# MAKA HARUS MEMBUAT TABLE BARU YANG MENGANDUNG KOLOM ROW_NUM
-- 4. MEMBUAT TABLE BARU YANG MENGANDUNG KOLOM ROW_NUM AGAR ROW_NUM YANG > 1 BISA DI DELETE
CREATE TABLE layoff_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  date TEXT,
  stage TEXT,
  country TEXT,
  funds_raise_millions INT DEFAULT NULL,
  row_num INT -- ini adalah kolom tambahan
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoff_staging2
select
	*,
    ROW_NUMBER() OVER(
    PARTITION BY
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    date,
    stage,
    country,
    funds_raised_millions) as row_num
from
	layoff_staging;
    
select
	*
from
	layoff_staging2
where
	row_num > 1;
    
-- 5.DELETE ROW_NUM YANG LEBIH DARI 1
DELETE
FROM layoff_staging2
where row_num > 1;

select
	*
from
	layoff_staging2;
    
##################################### PREPROCESSING STANDARDIZE DATA ###########################################
-- CHECK kolom company
select
	distinct company
from
	layoff_staging2
order by company;
-- MEMBUANG SPASI DI DEPAN
SELECT
	distinct company,
    trim(company)
from 
	layoff_staging2;

update layoff_staging2
set company = trim(company);

-- CHECK kolom industry
select
	distinct industry
from
	layoff_staging2
where
	industry is not null and industry != ''
order by
	industry;
    
-- MENGGABUNGKAN NAMA yang mirip dengan crypto seperti cryptocurrency, menjadi 'Crypto' saja
update layoff_staging2
set industry = 'Crypto'
where industry LIKE 'Crypto%';

-- MENGGANTI KOLOM DATE YANG BERTIPE TEXT MENJADI DATE
select
	date,
	str_to_date(date, '%m/%d/%Y')
from
	layoff_staging2;
    
update layoff_staging2
set date = str_to_date(date, '%m/%d/%Y');

alter table layoff_staging2
modify column date DATE;


-- CHECK kolom Country
SELECT
	distinct country
FROM
	layoff_staging2
ORDER BY
	country;

-- MENGGABUNGKAN NAMA yang mirip United States seperti United States.
update layoff_staging2
set country = 'United States'
where country LIKE 'United States%';

-- CHECK kolom stage
select
	distinct stage
from
	layoff_staging2
where
	stage is not null
order by
	stage;

################################ PREPROCESSING REMOVING NULL OR BLANK VALUES #########################
SELECT
	*
FROM
	layoff_staging2 t1
JOIN
	layoff_staging t2 on t1.company = t2.company
    and t1.location = t2.location
WHERE
	(t1.industry is null or t1.industry ='')
    or t2.industry is not null or t2.industry !=''; # QUERY INI ANOMALI, MAKA HARUS MENGGANTI BLANK VALUES MENJADI NULL
    
-- MENGGANTI BLANK VALUES MENJADI NULL VALUES
update layoff_staging2
set industry = null
where industry ='';


-- MELAKUKAN POPULATE INDUSTRY YANG NULL
SELECT
	*
FROM
	layoff_staging2 t1
JOIN
	layoff_staging2 t2 on t1.company = t2.company
    and t1.location = t2.location
WHERE
	t1.industry is null 
    and t2.industry is not null;
    
update layoff_staging2 t1
join layoff_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

-- MENGHAPUS ROWS YANG TOTAL LAID OFF DAN PERCENTAGE LAID OFF NYA NULL
SELECT
	*
from
	layoff_staging2
where
	total_laid_off is null
    and percentage_laid_off is null;
    
delete
from
	layoff_staging2
where
	total_laid_off is null
    and percentage_laid_off is null;
    
################################### DROP THE UNNECESSARY COLUMN ##############################
alter table layoff_staging2
drop column row_num;

select * from layoff_staging2;






