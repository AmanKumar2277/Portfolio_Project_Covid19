

select * from PortfolioProject.dbo.Nashville_housing;

*/

Cleaning Data in SQL Queries


*/
--Standarize the Date Format

select SaleDate from PortfolioProject.dbo.Nashville_housing;

select SaleDate, convert(Date,SaleDate) as SaleDate from PortfolioProject.dbo.Nashville_housing;

Update PortfolioProject.dbo.Nashville_housing 
set SaleDate = convert(Date,SaleDate)

ALTER TABLE PortfolioProject.dbo. Nashville_housing
ADD SalesDateConverted Date;
update PortfolioProject.dbo.Nashville_housing
set SalesDateConverted = convert(Date,SaleDate);


select SalesDateConverted from PortfolioProject.dbo.Nashville_housing;


-------Populate Property Address Data

select * from PortfolioProject.dbo.Nashville_housing;

select UniqueID,ParcelID,PropertyAddress from PortfolioProject.dbo.Nashville_housing
--where PropertyAddress is NULL;

--If we observe ParcleID is same then Property address is also same with the help of parcle id we are editing Null Values.

--we are finding the values having same ParcelID in the table we will use self join.

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress from PortfolioProject.dbo.Nashville_housing a 
JOIN 
	PortfolioProject.dbo.Nashville_housing b
	on a.ParcelID=b.ParcelID 
	and a.UniqueID<>b.UniqueID
	where a.PropertyAddress is NULL


---updateing the null Values for address data.
update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress) from
PortfolioProject.dbo.Nashville_housing a 
JOIN 
	PortfolioProject.dbo.Nashville_housing b
	on a.ParcelID=b.ParcelID 
	and a.UniqueID<>b.UniqueID
	where a.PropertyAddress is NULL

---Breaking out address into individual columns (Address,City,State)


select PropertyAddress from PortfolioProject.dbo.Nashville_housing  ;1


select SUBSTRING (propertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as ownerAddress,
	SUBSTRING (propertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as State

from PortfolioProject.dbo.Nashville_housing;


Alter Table PortfolioProject.dbo.Nashville_housing
add PropertySplitAddress Nvarchar(255),City  Nvarchar(255);


update PortfolioProject.dbo.Nashville_housing
set PropertySplitAddress=SUBSTRING (propertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
City=SUBSTRING (propertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));


select PropertySplitAddress,city from PortfolioProject.dbo.Nashville_housing;

select OwnerAddress from PortfolioProject.dbo.Nashville_housing;

--Now we have to split the OwnerAddress in to Address,City,State

--here will be using different method to split teh address that is parse name 

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)

from PortfolioProject.dbo.Nashville_housing;


ALTER TABLE PortfolioProject.dbo. Nashville_housing
ADD OwnerSplitAddress Nvarchar(255);

update PortfolioProject.dbo.Nashville_housing
set  OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3);


ALTER TABLE PortfolioProject.dbo. Nashville_housing
ADD OwnerSplitCity Nvarchar(255);
update PortfolioProject.dbo.Nashville_housing
set  OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2);



ALTER TABLE PortfolioProject.dbo. Nashville_housing
ADD OwnerSplitState Nvarchar(255);
update PortfolioProject.dbo.Nashville_housing
set  OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1);

select OwnerSplitAddress,OwnerSplitCity,OwnerSplitState from PortfolioProject.dbo.Nashville_housing;

----change Y and N to Yes and No in "Sold as Vacant" Field.

select SoldAsVacant  from PortfolioProject.dbo.Nashville_housing;

Select Distinct(SoldAsVacant),count(SoldAsVacant) from PortfolioProject.dbo.Nashville_housing
group by SoldAsVacant order by 2;---to count Yes,Y,No,N values in SoldAsVacant Column


--using case statement

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end
	from PortfolioProject.dbo.Nashville_housing;


update PortfolioProject.dbo.Nashville_housing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end


select SoldAsVacant from PortfolioProject.dbo.Nashville_housing;


--Removing Duplicates

--step1 finding the duplicate using window function 



with RowNumCTE as (
select * ,
ROW_NUMBER() over (
Partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
Order by UniqueID) as row_num from PortfolioProject.dbo.Nashville_housing)

select * from RowNumCTE where row_num>1;

--there are 104 duplicate rows .Now  we havr to delete 

with RowNumCTE as (

select * ,
ROW_NUMBER() over (
Partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
Order by UniqueID) as row_num from PortfolioProject.dbo.Nashville_housing)


Delete  from RowNumCTE where row_num>1;

----Delete Unused Columns from Table

ALTER TABLE PortfolioProject.dbo. Nashville_housing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict;



ALTER TABLE PortfolioProject.dbo. Nashville_housing
DROP COLUMN SaleDate ;
select * from PortfolioProject.dbo. Nashville_housing;