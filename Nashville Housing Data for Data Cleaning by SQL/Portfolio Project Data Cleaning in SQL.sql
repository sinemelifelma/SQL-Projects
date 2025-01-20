
/* Cleaning Data in SQL Queries */

select*
from PortfolioProject.dbo.NashvilleHousing



--Standardize Date Format

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)



--Populate Property Address Data

select*
from PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is null

select*
from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(A.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(A.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--Breaking out Address into Individual Columns (Address, City, State)

--1

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select*
From PortfolioProject.dbo.NashvilleHousing

--2

select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

select*
From PortfolioProject.dbo.NashvilleHousing



--Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

select SoldAsVacant,
CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 END



--Remove Duplicates

WITH RowNumCTE AS(
select*, ROW_NUMBER () OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
order by UniqueID) row_num
From PortfolioProject.dbo.NashvilleHousing
)

Select *
from RowNumCTE
WHERE row_num > 1
Order by PropertyAddress



--Deleting Unused Columns

select*
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate