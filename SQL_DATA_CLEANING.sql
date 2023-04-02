/*
SQL Data Cleaning 

Dataset used - nashville_housing_data at https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data 

Skills demonstrated - DATE_FORMAT, SUBSTRING, CHARINDEX, ISNULL, PARSENAME, WINDOW FUNCTION ROW_NUMBER(), CTE
*/

SELECT * FROM nashville_housing_data;

-- Standardize date format
UPDATE nashville_housing_data SET SaleDate = DATE_FORMAT(SaleDate,'%d-%m-%Y');

-- Dealing with missing values

/* for ParcelID without propertyAddress, we check for ParceID that have the same ID with it 
and has address, use the address of the second ParceID to replace the null values */

-- ISNULL() function -- When a.propertyaddress isnull, input b.propertyaddress

UPDATE nashville_housing_data a
JOIN nashville_housing_data b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress is null;

-- Splitting PropertyAddress into individual columns (HouseAddress, City)

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX( ',', PropertyAddress) -1) AS HouseAddress
, SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM nashville_housing_data;

-- UPDATING THE HOUSING TABLE
ALTER TABLE nashville_housing_data
Add HouseAddress Varchar(255);

UPDATE nashville_housing_data
SET HouseAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX( ',', PropertyAddress) -1);

/* adding the city column */
ALTER TABLE nashville_housing_data
Add City Varchar(255);

UPDATE nashville_housing_data
SET City = SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress) +1, LEN(PropertyAddress));

-- DELETING THE PropertyAddress Column
ALTER TABLE nashville_housing_data
DROP COLUMN PropertyAddress;

-- Splitting OwnerAddress into individual columns (OwnerAddress, OwnerCity, OwnerState)

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.') , 3) AS OwnersAddress
,PARSENAME(REPLACE(OwnerAddress,',', '.') , 2) As OwnersCity
,PARSENAME(REPLACE(OwnerAddress,',', '.') , 1) As OwnersState
FROM nashville_housing_data;

-- UPDATING THE TABLE BY SPLITING THE OwnerAddress INTO THREE COLUMNS OwnerAddress, OWnerCity, OwnerState
ALTER TABLE nashville_housing_data
Add Owner_Address Varchar(255);

UPDATE nashville_housing_data
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress,',', '.') , 3);

/* adding the Ownercity column */
ALTER TABLE nashville_housing_data
Add OwnerCity Varchar(255);

UPDATE nashville_housing_data
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',', '.') , 2);

/* adding the OwnerState column */
ALTER TABLE nashville_housing_data
Add OwnerState Varchar(255);

UPDATE nashville_housing_data
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',', '.') , 1);



-- Standardizing format. Change Y and N to Yes and No in SoldASVacant Column using the case statement
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM nashville_housing_data
GROUP by SoldAsVacant
ORDER by 2;
/* Y = 52, N = 399, Yes = 4623, No= 51403 */

SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
FROM nashville_housing_data;

-- remove duplicates
with RowNumCTE AS(
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
FROM nashville_housing_data
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1;
/* 104 Duplicate rows removed */

-- Confirm that there are no duplicates
with RowNumCTE AS(
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
FROM nashville_housing_data
)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1;


-- Delete unused columns
ALTER TABLE nashville_housing_data
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate;


-- TOTAL NUMBER OF COLUMNS
SELECT count(*) AS NUMBEROFCOLUMNS FROM information_schema.columns
    WHERE table_name ='nashville_housing_data';