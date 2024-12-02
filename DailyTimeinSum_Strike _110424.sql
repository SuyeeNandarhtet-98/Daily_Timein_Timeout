set nocount ON
Declare @StartDate datetime = '1/Apr/2024',--DATEADD(MM, DATEDIFF(MM, 0, GETDATE()),0),
	    @EndDate datetime = '30/Apr/2024' --DATEADD(mm, DATEDIFF(mm, -1, GETDATE()),-1)
--SELECT @StartDate,@EndDate

/***** Product *****/
select 
	p.PRD_CD,
	p.PRD_DESC,
	p.PRD_DESC2,
	P.PRDCAT_KEY as 'SKU',
	PC.PRDCAT2_CD as 'Brand',
	PC.PRDCAT3_CD,
	Case
		when p.STATUS='I' then 'Inactive'
		when p.STATUS='A' then 'Active'
	End Status
into #Product_MASter
from mst_prd p
left join MST_PRDCAT_REF pc on p.prdcat_key=pc.prdcat_key
where p.selling_ind='1' 
and p.status='A'
and pc.prdcat2_cd in ('A','B')

/*****Saleman*****/
SELECT 
	SLSMAN_CD
into #Salemen
FROM mst_slsman s
WHERE syncoperatiON !='D'
and slsman_status = '1'
and slsman_cd not like ('%FL%') 
and slsman_cd not like ('%FM%') 
and slsman_cd not like ('%OTO')
and slsman_cd not like ('%RG')
and slsman_cd not like ('%SD')
and slsman_cd not like ('%BOS')
and slsman_cd not like ('%KA%') 
and slsman_cd not like ('%HCC')

Select 
	distinct a.CUST_CD,
	c.Cust_name as Customer_Name,
	concat(c.addr_1,' ',c.addr_2,' , ',c.addr_3) as Address,
	--c.ADDR_1 as Address,
	c.ADDR_4 as Distint,
	c.CUST_HIER2 as Channel,
	a.VISIT_KEY as S_VisitKey,
	a.DIST_CD,
	a.SLSMAN_CD,
	a.INV_DT,
	d.TIME_IN,
	d.TIME_OUT,
	d.TIME_SPENT,
	d.VISIT_DT, 
	format (d.VISIT_DT, 'dd/MMM') as Visit_Date,
	d.VISIT_KEY,
	pm.prd_cd as SKU,
	sum (b.PRD_QTY) as Total_Qty,
	CAST(d.[TIME_IN] AS TIME) AS dailytimein,
    CAST(d.[TIME_OUT] AS TIME) AS dailytimeout,
    CASE
		WHEN DATEPART(hour, [TIME_IN]) >= 6 AND DATEPART(hour, [TIME_IN]) < 7 THEN '6am - 7am'
		WHEN DATEPART(hour, [TIME_IN]) >= 7 AND DATEPART(hour, [TIME_IN]) < 8 THEN '7am - 8am'
        WHEN DATEPART(hour, [TIME_IN]) >= 8 AND DATEPART(hour, [TIME_IN]) < 9 THEN '8am - 9am'
        WHEN DATEPART(hour, [TIME_IN]) >= 9 AND DATEPART(hour, [TIME_IN]) < 10 THEN '9am - 10am'
        WHEN DATEPART(hour, [TIME_IN]) >= 10 AND DATEPART(hour, [TIME_IN]) < 11 THEN '10am - 11am'
		WHEN DATEPART(hour, [TIME_IN]) >= 11 AND DATEPART(hour, [TIME_IN]) < 12 THEN '11am - 12pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 12 AND DATEPART(hour, [TIME_IN]) < 13 THEN '12pm - 1pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 13 AND DATEPART(hour, [TIME_IN]) < 14 THEN '1pm - 2pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 14 AND DATEPART(hour, [TIME_IN]) < 15 THEN '2pm - 3pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 15 AND DATEPART(hour, [TIME_IN]) < 16 THEN '3pm - 4pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 16 AND DATEPART(hour, [TIME_IN]) < 17 THEN '4pm - 5pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 17 AND DATEPART(hour, [TIME_IN]) < 18 THEN '5pm - 6pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 18 AND DATEPART(hour, [TIME_IN]) < 19 THEN '6pm - 7pm'
		else 'other'
    END AS TimeRange
	  
FROM TXN_INVOICE a  
LEFT JOIN TXN_INVDTL b ON a.INV_KEY = b.INV_KEY
left join M_DAILYTIMINGSUM d on a.VISIT_KEY = d.VISIT_KEY
left join MST_CUST c on a.cust_cd = c.CUST_CD
left join #Product_MASter pm  on pm.PRD_CD = b.PRD_CD
--left join #Product_MASter pm on pm.PRD_CD = a.PRD_DISC_TTL

WHERE a.INV_DT between @StartDate and @EndDate
and a.slsman_cd in (SELECT slsman_cd FROM #Salemen)
and b.prd_cd in (SELECT prd_cd FROM #Product_MASter)
and a.INV_STATUS = 'S' 
and b.prd_slstype='s'
and a.CUST_CD not like ('NC%')	


group by 
	 a.CUST_CD,
    c.Cust_name,
    c.ADDR_1,
    c.ADDR_2,
    c.ADDR_3,
    c.ADDR_4,
    c.CUST_HIER2,
    a.VISIT_KEY,
    a.DIST_CD,
    a.SLSMAN_CD,
    a.INV_DT,
    d.TIME_IN,
    d.TIME_OUT,
    d.TIME_SPENT,
    d.VISIT_DT,
    d.VISIT_KEY,
    pm.PRD_CD,
	--sum b.PRD_QTY,
	CAST(d.[TIME_IN] AS TIME),
    CAST(d.[TIME_OUT] AS TIME),
   CASE
		WHEN DATEPART(hour, [TIME_IN]) >= 6 AND DATEPART(hour, [TIME_IN]) < 7 THEN '6am - 7am'
		WHEN DATEPART(hour, [TIME_IN]) >= 7 AND DATEPART(hour, [TIME_IN]) < 8 THEN '7am - 8am'
        WHEN DATEPART(hour, [TIME_IN]) >= 8 AND DATEPART(hour, [TIME_IN]) < 9 THEN '8am - 9am'
        WHEN DATEPART(hour, [TIME_IN]) >= 9 AND DATEPART(hour, [TIME_IN]) < 10 THEN '9am - 10am'
        WHEN DATEPART(hour, [TIME_IN]) >= 10 AND DATEPART(hour, [TIME_IN]) < 11 THEN '10am - 11am'
		WHEN DATEPART(hour, [TIME_IN]) >= 11 AND DATEPART(hour, [TIME_IN]) < 12 THEN '11am - 12pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 12 AND DATEPART(hour, [TIME_IN]) < 13 THEN '12pm - 1pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 13 AND DATEPART(hour, [TIME_IN]) < 14 THEN '1pm - 2pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 14 AND DATEPART(hour, [TIME_IN]) < 15 THEN '2pm - 3pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 15 AND DATEPART(hour, [TIME_IN]) < 16 THEN '3pm - 4pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 16 AND DATEPART(hour, [TIME_IN]) < 17 THEN '4pm - 5pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 17 AND DATEPART(hour, [TIME_IN]) < 18 THEN '5pm - 6pm'
		WHEN DATEPART(hour, [TIME_IN]) >= 18 AND DATEPART(hour, [TIME_IN]) < 19 THEN '6pm - 7pm'
		else 'other'
    END 
ORDER BY TimeRange, a.INV_DT, d.TIME_IN
drop table #Product_MASter,#Salemen
