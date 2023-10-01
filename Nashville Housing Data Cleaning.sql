SELECT *
FROM [SQL Tutorial]..[NashvilleHousing]

-- Standardize Date Format
SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM [SQL Tutorial]..[NashvilleHousing]

ALTER TABLE [SQL Tutorial]..NashvilleHousing
ADD SaleDateConverted DATE

UPDATE [SQL Tutorial]..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDateConverted
FROM [SQL Tutorial]..[NashvilleHousing]

-- Populate Property Address data
SELECT *
FROM [SQL Tutorial]..[NashvilleHousing]
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [SQL Tutorial]..NashvilleHousing a
JOIN [SQL Tutorial]..NashvilleHousing b ON b.ParcelID = a.ParcelID AND
	b.UniqueID <> a.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [SQL Tutorial]..NashvilleHousing a 
JOIN [SQL Tutorial]..NashvilleHousing b ON b.ParcelID = a.ParcelID AND
	b.UniqueID <> a.UniqueID
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) Address, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) State
FROM [SQL Tutorial]..[NashvilleHousing]

ALTER TABLE [SQL Tutorial]..NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE [SQL Tutorial]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [SQL Tutorial]..NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE [SQL Tutorial]..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM [SQL Tutorial]..NashvilleHousing

SELECT *
FROM [SQL Tutorial]..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'),3) OwnerSplitAddress, PARSENAME(REPLACE(OwnerAddress, ',','.'),3) OwnerSplitCity,
		PARSENAME(REPLACE(OwnerAddress, ',','.'),3) OwnerSplitState
FROM [SQL Tutorial]..NashvilleHousing

ALTER TABLE [SQL Tutorial]..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE [SQL Tutorial]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE [SQL Tutorial]..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE [SQL Tutorial]..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE [SQL Tutorial]..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE [SQL Tutorial]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

-- Change Y and N to Yes and No in 'Sold As Vacant' field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [SQL Tutorial]..NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
		CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
		END
FROM [SQL Tutorial]..NashvilleHousing

UPDATE [SQL Tutorial]..NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
						 END

SELECT *
FROM [Project Portfolio]..NashvilleHousing

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER(
		PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_number
FROM [SQL Tutorial]..NashvilleHousing
)
SELECT*
FROM RowNumCTE
WHERE row_number >1
ORDER BY PropertyAddress

-- Delete Unused Columns
SELECT *
FROM [SQL Tutorial]..NashvilleHousing

ALTER TABLE [SQL Tutorial]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
