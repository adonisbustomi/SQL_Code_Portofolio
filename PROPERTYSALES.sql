create database Housing;
use housing;


CREATE TABLE PropertySales (
    UniqueID INTEGER,
    ParcelID TEXT,
    LandUse TEXT,
    PropertyAddress TEXT,
    SaleDate TEXT,
    SalePrice INTEGER,
    LegalReference TEXT,
    SoldAsVacant TEXT,
    OwnerName TEXT,
    OwnerAddress TEXT,
    Acreage INT,
    TaxDistrict TEXT,
    LandValue INTEGER,
    BuildingValue INTEGER,
    TotalValue INTEGER,
    YearBuilt INTEGER,
    Bedrooms INTEGER,
    FullBath INTEGER,
    HalfBath INTEGER
);
LOAD DATA LOCAL INFILE 'C:/Data housing/PropertySales.csv'
INTO TABLE PropertySales
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

select * from propertysales;
select count(distinct uniqueid) from propertysales;
select distinct soldasvacant from propertysales;
SET sql_mode = (SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));
SET SQL_SAFE_UPDATES = 0;

#######################################################################################################################

############################## REMOVING DUPLICATE ROWS #######################################
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
From PROPERTYSALES
order by row_num desc;

with duplicate_cte as
(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
From PROPERTYSALES
order by row_num desc
)
select
	*
from
	duplicate_cte
where
	row_num > 1;
    
-- harus membuat table baru untuk menghapus data duplikatnya. karena CTE tidak updatable
-- MEMBUAT TABLE BARU YANG MENGANDUNG KOLOM ROW_NUM AGAR ROW_NUM YANG > 1 BISA DI DELETE
CREATE TABLE propertysales_staging (
    UniqueID INTEGER,
    ParcelID TEXT,
    LandUse TEXT,
    PropertyAddress TEXT,
    SaleDate TEXT,
    SalePrice INTEGER,
    LegalReference TEXT,
    SoldAsVacant TEXT,
    OwnerName TEXT,
    OwnerAddress TEXT,
    Acreage INT,
    TaxDistrict TEXT,
    LandValue INTEGER,
    BuildingValue INTEGER,
    TotalValue INTEGER,
    YearBuilt INTEGER,
    Bedrooms INTEGER,
    FullBath INTEGER,
    HalfBath INTEGER,
    row_num INTEGER
); 
-- MEMASUKAN DATA PROPERTYSALES KE PROPERTYSALES_STAGING YANG ADA KOLOM ROW NUM NYA
insert into propertysales_staging
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num
From PROPERTYSALES
order by row_num desc;

SELECT * FROM PROPERTYSALES_STAGING;

-- MELAKUKAN DELETE ROW YANG LEBIH DARI 1 ALIAS DUPLIKAT
SELECT
	*
FROM
	propertysales_staging
where
	row_num > 1;
    
DELETE
FROM
	propertysales_staging
where
	row_num > 1;




############################## PREPROCESSING STANDARDIZE DATA ################################
-- MENGUBAH SALEDATE DARI TEXT MENJADI DATE YANG PROPER (saledate)
update propertysales
set saledate = str_to_date(replace(saledate,'.',''), '%M %e %Y');
ALTER TABLE propertysales
MODIFY acreage decimal;


-- MENGUBAH Y,N JADI YES NO SEMUA (soldasvacant)
SELECT DISTINCT soldasvacant from propertysales;
update propertysales
set soldasvacant = case 
	when soldasvacant = 'Y' then 'Yes'
    when soldasvacant = 'N' then 'No'
    else soldasvacant
end;
    
select * from propertysales;
SELECT DISTINCT propertyaddress from propertysales;

-- membuang spasi didepan (propertyaddress)
select
	propertyaddress,
    trim(propertyaddress)
from
	propertysales;
update propertysales
set propertyaddress = trim(propertyaddress);

-- mengganti . menjadi spasi (propertyaddress)
update propertysales
set propertyaddress = replace(propertyaddress,'.','');
-- membuang double space menjadi single space (propertyaddress)
update propertysales
set propertyaddress = replace(propertyaddress,'  ',' ');

-- mengganti . menjadi spasi (parcelid)
select
	distinct parcelid
from
	propertysales;

update propertysales
set parcelid = replace(parcelid,'.', ' ');

-- melakukan hal yang sama seperti propertyaddress
select
	distinct owneraddress
from
	propertysales;
    

update propertysales
set owneraddress = trim(owneraddress);

################################## REMOVE NULL OR BLANK VALUES (INCLUDING POPULATE) ###############################
-- populate propertyaddress yang null atau blank
select * from propertysales;

select
	t1.uniqueid,
    t1.parcelid,
    t1.propertyaddress,
    t2.uniqueid,
    t2.parcelid,
    t2.propertyaddress
from
	propertysales t1
join
	propertysales t2 on t1.parcelid = t2.parcelid
    and t1.uniqueid != t2.uniqueid
where
	t1.propertyaddress is null and t2.propertyaddress is not null;

update propertysales t1
join propertysales t2 on t1.parcelid = t2.parcelid
and t1.uniqueid != t2.uniqueid
set t1.propertyaddress = t2.propertyaddress
where t1.propertyaddress is null
and t2.propertyaddress is not null;

select
	t1.UniqueID,
    t1.ownername,
    t2.uniqueid,
    t2.ownername
from
	propertysales_staging t1
join
	propertysales_staging t2 on t1.parcelid = t2.parcelid
    or t1.uniqueid != t2.uniqueid
where
	t1.ownername is null
    and t2.ownername is not null;
    
    
    
select
	*
from
	propertysales_staging
where
	ownername is null;

update propertysales_staging
set ownername = null
where ownername = '';


