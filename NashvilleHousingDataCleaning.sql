/*
Cleaning data in SQL queries
*/

Select *
From PortfolioProject2.dbo.NashvilleHousing;



--Standardize Column SaleDate format from datetime to date

Select DateConverted, Convert(date, Saledate)
From PortfolioProject2.dbo.NashvilleHousing;

Alter Table PortfolioProject2.dbo.NashvilleHousing
Add DateConverted date;

Update PortfolioProject2.dbo.NashvilleHousing
Set DateConverted = CONVERT(date, SaleDate);



--Populate property address data
--Under the Column PropertyAddress, some of the values are NULL. Normally a property address should exist and it does not change. By observing the data, a pattern is found that rows with the same ParcelID has the same PropertyAddress.
--What is doing here is to self join the table, compare ParcelID of these two tables, fill the A table's PropertyAddress NULL value with the corresponding B table's PropertyAddress value.

Update a
set a.PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject2.dbo.NashvilleHousing as a
join PortfolioProject2.dbo.NashvilleHousing as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null;

Select PropertyAddress
From PortfolioProject2.dbo.NashvilleHousing
Where PropertyAddress is null;



--Breaking out the Columns that contain addresses into individual columns(Address, City, State)

--Breaking out Column PropertyAddress into column PropertySplitAdress and PropertySplitCity
Select 
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address
,Substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as City
From PortfolioProject2.dbo.NashvilleHousing;

Alter Table NashvilleHousing
Add PropertySplitAdress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAdress=SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1);

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity=Substring(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress));

Select*
From PortfolioProject2.dbo.NashvilleHousing;

--Breaking out the column OwnerAddress into three columns

Select
PARSENAME(Replace(OwnerAddress,',','.'),1) as State
,PARSENAME(Replace(OwnerAddress,',','.'),2) as City
,PARSENAME(Replace(OwnerAddress,',','.'),3) as Address
From PortfolioProject2.dbo.NashvilleHousing;

Alter Table NashvilleHousing
Add OwnerSplitAdress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAdress=PARSENAME(Replace(OwnerAddress,',','.'),3);

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2);

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1);

Select*
From PortfolioProject2.dbo.NashvilleHousing;



--Change Y and N to Yes and No in "Sold as Vacant" field (In the column "Sold as Vacant", the value contains Y, Yes, N, No. So this practise is to replace all Y with Yes, and N with No)

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject2.dbo.NashvilleHousing
Group by SoldAsVacant
Order by Count(SoldAsVacant);

Select SoldAsVacant
,Case 
     When SoldAsVacant='Y' then 'Yes'
     When SoldAsVacant='N' then 'No'
	 Else SoldAsVacant
	 End
	 From PortfolioProject2.dbo.NashvilleHousing;

Update PortfolioProject2.dbo.NashvilleHousing
Set SoldAsVacant = Case 
     When SoldAsVacant='Y' then 'Yes'
     When SoldAsVacant='N' then 'No'
	 Else SoldAsVacant
	 End
From PortfolioProject2.dbo.NashvilleHousing;



--Remove duplicate rows
With RowNumCTE as(
Select *,
ROW_NUMBER() over (
Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 Order by UniqueID
			 ) as RowNum
From PortfolioProject2.dbo.NashvilleHousing)

Delete
From RowNumCTE
where RowNum>1;

Select *
From RowNumCTE
where RowNum>1;



--Delete unused columns(For example: column PropertyAddress, OwnerAddress and SaleDate)

Alter Table PortfolioProject2.dbo.NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, SaleDate
