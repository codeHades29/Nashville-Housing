--Nashville Housing 
--I got this data from Alex the Analyst but decided to go first
--before seeing how he worked the data. There will be a comment
--when I begin to follow him. I'm doing it this way to better learn
--how to do this job on my own.

--Checking out the data before getting started
Select distinct UniqueID
from Nashville
--No duplicates
Select *
from Nashville
order by SaleDate desc;

Select *
from Nashville
where UniqueID = '0'
------------------------------------------
Select count(*)
from Nashville
where SoldAsVacant = 0;

------------------------------------------
Select count(*)
from Nashville
where LandUse = 'SINGLE FAMILY'

------------------------------------------
select avg(saleprice), min(saleprice), max(saleprice)
from Nashville

------------------------------------------
select *
from Nashville
where Saleprice = '50.00'

------------------------------------------
with group_year_month as 
(
select datepart(year, saledate) as year,
	datepart(month, saledate) as month,
	saleprice as price
from Nashville
)
select year, month, avg(price) as avg_price
from group_year_month
group by year, month
order by year, month

------------------------------------------
with group_year as 
(
select datepart(year, saledate) as year,
	saleprice as price
from Nashville
)
select year, avg(price) as avg_price
from group_year
group by year
order by year

------------------------------------------
select distinct(taxdistrict)
from Nashville
where TaxDistrict is not null

--Statistics for prices for taxdistricts by year
select taxdistrict as city,
	avg(saleprice) as avg_price, 
	min(saleprice) as min_price, 
	max(saleprice) as max_price,
	DATEPART(year, SaleDate) as year
from Nashville
where TaxDistrict is not null
group by TaxDistrict, DATEPART(year, SaleDate)
order by DATEPART(year, SaleDate), taxdistrict

--In the above query I found lack of data for 2017 and 2018 and only one taxdistrict for 2019
select *
from Nashville
where datepart(year, SaleDate) = '2019'
-- Only two entries for 2019

------------------------------------------
------------Going Off Alex----------------
------------------------------------------

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville a
join Nashville b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--ISNULL checks if it is null and if so populate with a value, can be written
update a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Nashville a
join Nashville b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

------------------------------------------
select distinct(TaxDistrict)
from Nashville

--another way to use SUBSTRING
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address,
CHARINDEX(',', PropertyAddress)
from Nashville
--Use a minus 1 to remove the comma from 'Address'
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
from Nashville
------------------------------------------
--Another way to break up a text value
select 
	parsename(replace(OwnerAddress, ',', '.'), 3),
	parsename(replace(OwnerAddress, ',', '.'), 2),
	parsename(replace(OwnerAddress, ',', '.'), 1)
from Nashville

select *
from Nashville

alter table nashville
add Address nvarchar(255)

alter table nashville
add City nvarchar(255)

alter table nashville
add State nvarchar(255)

update Nashville
set Address = parsename(replace(OwnerAddress, ',', '.'), 3)

update Nashville
set City =  parsename(replace(OwnerAddress, ',', '.'), 2)

update Nashville
set State = parsename(replace(OwnerAddress, ',', '.'), 1)

alter table nashville
drop column OwnerAddress, PropertyAddress

------------------------------------------
--Convert to Natural Language
select distinct(SoldAsVacant), count(SoldAsVacant)
from Nashville	
group by SoldAsVacant

select SoldAsVacant,
CASE WHEN SoldAsVacant = '0' then 'No'
	 WHEN SoldAsVacant = '1' then 'Yes'
	 ELSE SoldAsVacant
	 END
from Nashville
group by SoldAsVacant

update Nashville
set SoldAsVacant = CASE WHEN SoldAsVacant = '0' then 'No'
	 WHEN SoldAsVacant = '1' then 'Yes'
	 ELSE SoldAsVacant
	 END
--Checking work
select SoldAsVacant, count(SoldAsVacant)
from Nashville
--group by SoldAsVacant

------------------------------------------
--Remove Duplicates


--Generally you would make a new table and then delete the columns
with duplicates as 
(
select *,
ROW_NUMBER() OVER(PARTITION BY 
	ParcelID, PropertyAddress, SalePrice,
	SaleDate, LegalReference
	ORDER BY UniqueID
	) as row_num
from Nashville

)
delete
from duplicates
where row_num > 1
--order by SaleDate

------------------------------------------
select *
from Nashville
where OwnerName is null and Address is null