/*
cleaning data */

select *
from [portifolio].[dbo].[nashvilehousing]

/*standadizing the data*/
select SaleDate , convert(Date ,SaleDate)
from [portifolio].[dbo].[nashvilehousing]

update [portifolio].[dbo].[nashvilehousing]
set SaleDate =convert(Date,SaleDate)

alter table [portifolio].[dbo].[nashvilehousing]
add SaleDateConverted Date;

update [portifolio].[dbo].[nashvilehousing]
set SaleDateConverted =convert(Date,SaleDate)

select SaleDateConverted , convert(Date ,SaleDate)
from [portifolio].[dbo].[nashvilehousing]



--Populating property adress
select tb1.ParcelID,tb1.PropertyAddress ,tb2.ParcelID, tb2.PropertyAddress , isnull(tb1.PropertyAddress,tb2.PropertyAddress)
--where PropertyAddress is null
from [portifolio].[dbo].[nashvilehousing] tb1
JOIN [portifolio].[dbo].[nashvilehousing] tb2
	on tb1.ParcelID=tb2.ParcelID
	AND tb1.[UniqueID] <>tb2.[UniqueID]
where tb1.PropertyAddress is null 

UPDATE tb1
SET PropertyAddress = isnull(tb1.PropertyAddress,tb2.PropertyAddress)
from [portifolio].[dbo].[nashvilehousing] tb1
JOIN [portifolio].[dbo].[nashvilehousing] tb2
	on tb1.ParcelID=tb2.ParcelID
	AND tb1.[UniqueID] <>tb2.[UniqueID]
where tb1.PropertyAddress is null 




--breaking out addree into individual column  (adress, city,state)
select 
substring(PropertyAddress , 1,CHARINDEX(',',PropertyAddress)-1) as theaddress
,substring(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as city
from [portifolio].[dbo].[nashvilehousing]

alter table [portifolio].[dbo].[nashvilehousing]
add PropertymainAddress Nvarchar(255);

update [portifolio].[dbo].[nashvilehousing]
set PropertymainAddress =substring(PropertyAddress , 1,CHARINDEX(',',PropertyAddress)-1) 

alter table [portifolio].[dbo].[nashvilehousing]
add PropertyCity Nvarchar(255);

update [portifolio].[dbo].[nashvilehousing]
set PropertyCity =substring(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))




--breaking out addree into individual column  (adress, city,state) for owner address
select OwnerAddresss
from [portifolio].[dbo].[nashvilehousing]

select 
PARSENAME(REPLACE(OwnerAddress,',','.') ,3)
,PARSENAME(REPLACE(OwnerAddress,',','.') ,2)
,PARSENAME(REPLACE(OwnerAddress,',','.') ,1)
from [portifolio].[dbo].[nashvilehousing]



alter table [portifolio].[dbo].[nashvilehousing]
add OwnermainAddress Nvarchar(255);

update [portifolio].[dbo].[nashvilehousing]
set OwnermainAddress =PARSENAME(REPLACE(OwnerAddress,',','.') ,3)

alter table [portifolio].[dbo].[nashvilehousing]
add OwnerCity Nvarchar(255);

update [portifolio].[dbo].[nashvilehousing]
set OwnerCity=PARSENAME(REPLACE(OwnerAddress,',','.') ,2)

alter table [portifolio].[dbo].[nashvilehousing]
add OwnerState Nvarchar(255);

update [portifolio].[dbo].[nashvilehousing]
set OwnerState =PARSENAME(REPLACE(OwnerAddress,',','.') ,1)




--deleting unused columns
alter table [portifolio].[dbo].[nashvilehousing]
drop column  OwnerAddress,TaxDistrict,PropertyAddress

alter table [portifolio].[dbo].[nashvilehousing]
drop column SaleDate




--change y and n to yyes and no in sold as vacant
/*checkin to see which one is popula*/
select distinct(SoldAsVacant),count(SoldAsVacant)
from [portifolio].[dbo].[nashvilehousing]
group by SoldAsVacant
order by 2
/*working on makin all look as the popular one*/
select SoldAsVacant
,case when SoldAsVacant ='Y' then 'Yes'
	  when SoldAsVacant ='N' then 'No'
	  else SoldAsVacant
	  end
from [portifolio].[dbo].[nashvilehousing]

update [portifolio].[dbo].[nashvilehousing]
set SoldAsVacant=case when SoldAsVacant ='Y' then 'Yes'
				when SoldAsVacant ='N' then 'No'
				else SoldAsVacant
				end




--removing the dupplicates
with rownumcte  as(
select *,
  ROW_NUMBER() over(
		partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order by
						UniqueID
						)row_numbr

from [portifolio].[dbo].[nashvilehousing]
)

delete
from  rownumcte
where row_numbr >1
--order by PropertyAddress