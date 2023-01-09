	
-- Data Cleaning in SQL
	-- To more easily use the raw data for business purposes 

SELECT *
FROM PortfolioProject..NashvilleHousing

-- 1.
-- Standardizing Date Format using Convert
	-- Could use ALTER TABLE and ADD + UPDATE and SET to Adjust the Dataset as well

SELECT SaleDate, CONVERT(Date, SaleDate) as JustDate
FROM PortfolioProject..NashvilleHousing

-- 2.
-- Populate Property Address Data
	-- Trying to match ParcelID with PropertyAddress when it is null
	-- Using the <> operator to match and ISNULL to distinguish; then UPDATE

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) as SameAddress
FROM PortfolioProject..NashvilleHousing as A
JOIN PortfolioProject..NashvilleHousing as B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing as A
JOIN PortfolioProject..NashvilleHousing as B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

-- 3.
-- Breaking out Addresses into Individual Columns (Address and City)
	-- Eliminating the delimiters; -1 from the index location of the comma, +1 to separate into new column

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing

-- 3a.
-- Altering Table to add two new columns for Address and City
	-- We can't separate original data into new columns w/out create new ones 

ALTER TABLE PortfolioProject..NashvilleHousing 
Add PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- 4.
-- Parcing Owner Address into Address and City
	-- Using REPLACE to look for commas because it usually looks for periods; replaces backwards
		-- Then ALTER TABLE and UPDATE & SET new columns 

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing
WHERE OwnerAddress is not null

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) as State
FROM PortfolioProject..NashvilleHousing
WHERE OwnerAddress is not null

ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing 
Add OwnerSplitCity Nvarchar(255);

ALTER TABLE NashvilleHousing 
Add OwnerSplitState Nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- 5.
-- Change Y and N to Yes and No in "Sold as Vacant" field 
	-- Using Distinct and Count to see what the data uses
		-- Change using a CASE WHEN/THEN ElSE Function 

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	End as New
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- 6.
-- Removing Duplicate Rows of Data
	-- Using a CTE to Query off of to find duplicates
		-- Then DELETE

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
FROM PortfolioProject..NashvilleHousing
)
-- DELETE from here once you confirm you have duplicate data
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- 7.
-- Deleting Unused Columns
	-- Don't use for raw data from your database 

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate


