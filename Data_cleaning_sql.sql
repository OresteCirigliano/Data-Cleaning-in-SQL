/*

Cleaning Data in SQL

*/

-- Standardize Date Format- Altered the table and added the SaleDateConverted, a new column, with Date Format instead of the Date time format, which is more useful for our scope of work


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate);

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing;


SELECT SaleDateConverted
FROM Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing

-- Populate Property Address data

-- 1)Check the null values

SELECT PropertyAddress
FROM Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

Select *
From Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing
WHERE ParcelID IN
(Select ParcelID
from Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing
group by ParcelID
having count(*) > 1);


-- 1)As we can see with the query above when the ParcelID column has the same value more than 1 the  PropertyAdrress has the same value as the previous one.

-- 3) Assuming this we can now join and see if it is correct and populate the PropertyAddress column

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing a
JOIN Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing a
JOIN Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing a
JOIN Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

--Splitting Address into Individaul Columns such as Address, City and State

Select PropertyAddress
FROM Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

/* I'm doing the same but for the OwnerAddress and using Parsename (Parsename find the periodo so we need also use replace to change from comma to period) 

ALTER TABLE  Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR (255);

UPDATE  Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
*/



-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant, count(SoldAsVacant) 
FROM Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant
, CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing

update Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing
Set SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

--Remove the duplicates, using Row_number() Over( Partition by, we can find out the duplicates and then we CTE we can delete the row_num > 2 (the duplicates in this case)

with RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

FROM Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing
)

DELETE
From RowNumCTE
WHERE row_num > 1

-- Delete Unused Columns

ALTER TABLE Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


Select *
FROM Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project_Data_Cleaning.dbo.NashvilleHousing
DROP COLUMN SaleDate
