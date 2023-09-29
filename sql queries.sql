
use [COVID-DataAnalyst-PortfolioProjectSQLData];

select *
from dbo.NashvilleHousing;



---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------



-- Populate property address data

select * 
from dbo.NashvilleHousing
--where PropertyAddress is null;
order by ParcelID



-- copying address to remove NULL values

--select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
--from dbo.NashvilleHousing a
--join dbo.NashvilleHousing b
--	on a.ParcelID = b.ParcelID
--	and a.[UniqueID] <> b.[UniqueID]
--where a.PropertyAddress is null;




-- updating table for NULL values in address

--update a
--SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
--from dbo.NashvilleHousing a
--join dbo.NashvilleHousing b
--	on a.ParcelID = b.ParcelID
--	and a.[UniqueID] <> b.[UniqueID]
--where a.PropertyAddress is null;


---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------



-- Breaking out Address into individual columns(address, city, state)
-- can be done with a python script before insert into database, using regex

select PropertyAddress
from dbo.NashvilleHousing


select 
SUBSTRING(
PropertyAddress, 1, ABS(CHARINDEX(',', PropertyAddress)-1)
) as address,

SUBSTRING(
PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)
) as address

from dbo.NashvilleHousing;




---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------



-- updating table with the splited address number/street and city, separately

--address
alter table dbo.NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, ABS(CHARINDEX(',', PropertyAddress)-1))


--address city
alter table dbo.NashvilleHousing
add PropertySplitCity Nvarchar(255);	

update dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)
);



---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------



-- Breaking out OWNERADDRESS into individual columns(address, city, state)

-- owner address
select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from dbo.NashvilleHousing

-- updating table with the splited OWNERADDRESS number/street and city, separately

--OWNERADDRESS address
alter table dbo.NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);


--OWNERADDRESS city
alter table dbo.NashvilleHousing
add ownerSplitCity Nvarchar(255);	

update dbo.NashvilleHousing
set ownerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);


-- OWNERADDRESS state
alter table dbo.NashvilleHousing
add ownerSplitstate Nvarchar(255);	

update dbo.NashvilleHousing
set ownerSplitstate = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);




---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------



-- change Y and N for YES and NO, in 'sold as vacant' field

-- alter column from binary to char first
--alter table dbo.NashvilleHousing
--alter column soldasvacant nvarchar(10);

-- deleting NULL values, no relative information
--delete from dbo.NashvilleHousing
--where SoldAsVacant is null;


-- visual query
select distinct(SoldAsVacant), count(SoldAsVacant)
from dbo.NashvilleHousing
group by SoldAsVacant
order by 2;


-- THE QUERY
select SoldAsVacant
, case when SoldAsVacant='1' THEN 'Yes'
		when SoldAsVacant='0' THEN 'No'
		ELSE SoldAsVacant
		END
from dbo.NashvilleHousing
order by 2;


-- replacing table column with the YES NO values instead of 0/1
update NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant='1' THEN 'Yes'
		when SoldAsVacant='0' THEN 'No'
		ELSE SoldAsVacant
		END
from dbo.NashvilleHousing
order by 2;




---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------




-- remove duplicates

-- create a CTE(common table expression) to see duplicates
WITH rownumcte as (
select *, 
	ROW_NUMBER() OVER(
	PARTition by parcelid,
				 propertyaddress,
				 saleprice,
				 saledate,
				 legalreference
				 ORDER BY 
					uniqueid
					) row_num

from dbo.NashvilleHousing
)
-- select to show the duplicates rows
--select *
--from rownumcte
--where row_num > 1
--order by PropertyAddress;

-- delete the duplicates 
delete
from rownumcte
where row_num > 1;



---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------



-- remove unused columns

select *
from dbo.NashvilleHousing;

alter table dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress, saledate;

