---------------------------------------------------------------------------------------------------------------------------------------------------
--Cleaning Data with SQL queries in Nashville Housing Data--
---------------------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------------------------
--1 Changing Date Format--
---------------------------------------------------------------------------------------------------------------------------------------------------

--Current Date format for SaleDate Column to new column as ConvertedSaleDate is 2013-04-09 00:00:00.000, we will change to 09-04=2013

select SaleDate,convert(date,SaleDate) from Nashville;

ALTER TABLE nashville add ConvertedSaleDate Date;

UPDATE Nashville SET ConvertedSaleDate=CONVERT(Date,SaleDate);

-- Deleting SaleDate Column

ALTER TABLE Nashville DROP COLUMN SaleDate;
---------------------------------------------------------------------------------------------------------------------------------------------------==================================================================================================================================================

---------------------------------------------------------------------------------------------------------------------------------------------------==================================================================================================================================================
--2 Populate Property Address data
---------------------------------------------------------------------------------------------------------------------------------------------------==================================================================================================================================================
SELECT * FROM nashville WHERE PropertyAddress IS NULL;

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville a join Nashville b
on a.ParcelID=b.ParcelID AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville a join Nashville b
on a.ParcelID=b.ParcelID AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress IS NULL
---------------------------------------------------------------------------------------------------------------------------------------------------==================================================================================================================================================

---------------------------------------------------------------------------------------------------------------------------------------------------==================================================================================================================================================
--3 Breaking out Address into Individual Columns (Address, City, State)
---------------------------------------------------------------------------------------------------------------------------------------------------==================================================================================================================================================
--PropertyAddress
-----------------

SELECT PropertyAddress FROM Nashville;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
FROM Nashville;


ALTER TABLE Nashville ADD Address NVARCHAR(255);
UPDATE Nashville SET ADDRESS=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

ALTER TABLE Nashville ADD City NVARCHAR(255);
UPDATE Nashville SET City=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,len(PropertyAddress ));

---------------
Owner Address
---------------
SELECT OwnerAddress FROM Nashville;

ALTER TABLE Nashville ADD OwnLocalAddress NVARCHAR(255);
Update Nashville
SET OwnLocalAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE Nashville ADD OwnerCity NVARCHAR(255);
Update Nashville
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Nashville ADD OwnerState NVARCHAR(255);
Update Nashville
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
---------------------------------------------------------------------------------------------------------------------------------------------------==================================================================================================================================================


---------------------------------------------------------------------------------------------------------------------------------------------------==================================================================================================================================================
--4 Change Y and N to Yes and No in "Sold as Vacant" field
---------------------------------------------------------------------------------------------------------------------------------------------------==================================================================================================================================================
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END as SoldAsVacant
From Nashville;

UPDATE Nashville
SET SoldAsVacant= CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
--5 Remove Duplicates
---------------------------------------------------------------------------------------------------------------------------------------------------
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 CovertedSaleDate,
				 LegalReference
				 ORDER BY
					UniqueID)
					as row_num

From Nashville
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

DELETE FROM RowNumCTE WHERE RowNum > 1;
---------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------
--6 Delete Unused Columns
---------------------------------------------------------------------------------------------------------------------------------------------------
Select *
From NashVille;

ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;
---------------------------------------------------------------------------------------------------------------------------------------------------

















