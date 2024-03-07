USE HousingSocietyData
GO

SELECT *
FROM HousingSocietyData.dbo.HousingDataset

-----------------------------------------------------------------------------

-- Standardize Data Format


-- Select saleDateConverted, CONVERT(Date,SaleDate)
-- From PortfolioProject.dbo.NashvilleHousing

-- Update NashvilleHousing
-- SET SaleDate = CONVERT(Date,SaleDate)

SELECT SaleDate
FROM HousingSocietyData.dbo.HousingDataset

---------------------------------------------------------------
-- Populate Property Address

SELECT *
FROM HousingSocietyData.dbo.HousingDataset
-- WHERE PropertyAddress IS NULL
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingSocietyData.dbo.HousingDataset a
JOIN HousingSocietyData.dbo.HousingDataset b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingSocietyData.dbo.HousingDataset a
JOIN HousingSocietyData.dbo.HousingDataset b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM HousingSocietyData.dbo.HousingDataset
-- WHERE PropertyAddress IS NULL
order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM HousingSocietyData.dbo.HousingDataset

ALTER TABLE HousingDataset
ADD PropertySplitAddress NVARCHAR(255)

UPDATE HousingDataset
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE HousingDataset
ADD PropertySplitCity NVARCHAR(255)

UPDATE HousingDataset
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Spliting data with PARSE & REPLACE method

SELECT OwnerAddress
FROM HousingSocietyData.dbo.HousingDataset

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
FROM HousingSocietyData.dbo.HousingDataset

ALTER TABLE HousingDataset
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE HousingDataset
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

ALTER TABLE HousingDataset
ADD OwnerSplitCity NVARCHAR(255)

UPDATE HousingDataset
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE HousingDataset
ADD OwnerSplitState NVARCHAR(255)

UPDATE HousingDataset
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingSocietyData.dbo.HousingDataset
GROUP BY SoldAsVacant

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
						) row_num
FROM HousingSocietyData.dbo.HousingDataset
-- ORDER BY ParcelID
)

-- DELETE 
SELECT *
FROM RowNumCTE
WHERE row_num > 1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
--  As we have already split the addresses so we are going to delete the actual column

ALTER TABLE HousingSocietyData.dbo.HousingDataset
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress



SELECT *
FROM HousingSocietyData.dbo.HousingDataset


