
--Data Cleansing 

Select SaleDateConverted, CONVERT (Date,saledate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT (Date,saledate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (Date,saledate)


	-- Populate Property Adress Data 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



	--Breaking out adress Into Individual Colums (Adress,City,State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1) AS Adress
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS CITY
FROM NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR (255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress) -1) 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR (255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing

 -- Seprating Owner Adress 

SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR (255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR (255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR (255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM NashvilleHousing


-- Change Y and N to Yes and No in "Sold As Vacant" Column

SELECT DISTINCT (SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
Order BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


	-- Remove Duplicate 

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
	) row_num
FROM NashvilleHousing
)
SELECT*
FROM RowNumCTE
WHERE row_num > 1


   -- Delete Unused Columns for Visualisation 

SELECT*
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate