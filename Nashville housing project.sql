USE PortfolioProject.

Select *
from PortfolioProject..[Nashville Housing]


---------------------------------------------------------------------
-- standarize date format




Select SaleDateConverted , convert(date, SaleDate)
from PortfolioProject..[Nashville Housing]

update [Nashville Housing]
SET SaleDate = convert(date, SaleDate)

alter table [Nashville Housing]
add SaleDateConverted Date;

update [Nashville Housing]
SET SaleDateConverted = convert(date, SaleDate)




--------------------------------------------------------------------
-- populate property address data




select *
from PortfolioProject..[Nashville Housing]
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
-- IS NULL allows me to search null cells (first parameter), and replace with another column (second parameter)
from PortfolioProject..[Nashville Housing] a
JOIN PortfolioProject..[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

-- updating table a for removing null cells
update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject..[Nashville Housing] a
JOIN PortfolioProject..[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null





-------------------------------------------------------------------------------------------
-- breaking out address into individual columns (Address, City, State)
 




 select PropertyAddress
 from PortfolioProject..[Nashville Housing]
 --where PropertyAddressis null
 -- order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
 
 -- This search in propertyaddress, from the first value until the comma.
 -- i put -1 in order to search until the comma, and not include it.
 from PortfolioProject..[Nashville Housing]

alter table PortfolioProject..[Nashville Housing]
add PropertySplitAddress nvarchar(255)

update PortfolioProject..[Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

alter table PortfolioProject..[Nashville Housing]
add PropertySplitCity Nvarchar(255);

update PortfolioProject..[Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select * 
from PortfolioProject..[Nashville Housing]




----------------------------------------------------------------------------
-- Separating the owner address in three different columns.

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..[Nashville Housing]


alter table PortfolioProject..[Nashville Housing]
add OwnerSplitAddress nvarchar(255)

update PortfolioProject..[Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

alter table PortfolioProject..[Nashville Housing]
add OwnerSplitCity Nvarchar(255);

update PortfolioProject..[Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

alter table PortfolioProject..[Nashville Housing]
add OwnerSplitState Nvarchar(255);

update PortfolioProject..[Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

-- Note that is much more useful to have addresses separated by street, city and state




---------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" column

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..[Nashville Housing]
group by SoldAsVacant
order by 2
-- distinct to visualize the different values in the column


Select SoldAsVacant 
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject..[Nashville Housing]

update PortfolioProject..[Nashville Housing]
SET 
SoldAsVacant =  CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

select distinct(SoldAsVacant)
from PortfolioProject..[Nashville Housing]



-----------------------------
-- Remove Duplicates
WITH RowNumCTE as(
Select *, 
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
						UniqueID
						) row_num

from PortfolioProject..[Nashville Housing]
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress
-- Visualizo las filas duplicadas

WITH RowNumCTE as(
Select *, 
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
						UniqueID
						) row_num

from PortfolioProject..[Nashville Housing]
)
DELETE 
from RowNumCTE
where row_num > 1

-- Las elimino.





-----------------------------------
-- Delete Unused Columns




ALTER TABLE PortfolioProject..[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..[Nashville Housing]
DROP COLUMN SaleDate

select * from PortfolioProject..[Nashville Housing]





