--PYTHO,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
USE Estimates

IF OBJECT_ID('TEMPDB..#PublicComp') IS NOT NULL DROP TABLE #PublicComp
SELECT DISTINCT ed.companyId,c.companyName,ct.companyTypeId,ct.companyTypeName,ed.effectiveDate,et.eventTypeId,etp.eventTypeName
INTO #PublicComp FROM Estimates.[dbo].EstimateDetail_tbl ed
INNER JOIN ComparisonData.[dbo].Company_tbl c (NOLOCK) ON c.companyId=ed.companyId
INNER JOIN ComparisonData.[dbo].CompanyType_tbl ct (NOLOCK) ON ct.companyTypeId=c.companyTypeId 
INNER JOIN Estimates.[dbo].[Event_tbl] et WITH (NOLOCK) ON et.companyId = ed.companyId AND Convert(DATE, ed.effectiveDate) = (SELECT MAX(Convert(DATE, et2.effectiveDate)) FROM Estimates.[dbo].[Event_tbl] et2 WHERE et2.companyId = et.companyId)
INNER JOIN Estimates.[dbo].[EventType_tbl] etp ON et.eventTypeId=etp.eventTypeId
WHERE c.companyTypeId IN (4) AND ed.companyId IN (9237218,742365) --ed.effectiveDate>GETDATE()-365

IF OBJECT_ID('TEMPDB..#PrivateComp') IS NOT NULL DROP TABLE #PrivateComp
SELECT DISTINCT ed.companyId,c.companyName,ct.companyTypeId,ct.companyTypeName,ed.effectiveDate,et.eventTypeId,etp.eventTypeName
INTO #PrivateComp FROM Estimates.[dbo].EstimateDetail_tbl ed
INNER JOIN ComparisonData.[dbo].Company_tbl c (NOLOCK) ON c.companyId=ed.companyId
INNER JOIN ComparisonData.[dbo].CompanyType_tbl ct (NOLOCK) ON ct.companyTypeId=c.companyTypeId
INNER JOIN Estimates.[dbo].[Event_tbl] et WITH (NOLOCK) ON et.companyId = ed.companyId AND Convert(DATE, ed.effectiveDate) = (SELECT MAX(Convert(DATE, et2.effectiveDate)) FROM Estimates.[dbo].[Event_tbl] et2 WHERE et2.companyId = et.companyId)
INNER JOIN Estimates.[dbo].[EventType_tbl] etp ON et.eventTypeId=etp.eventTypeId
WHERE c.companyTypeId IN (5) AND ed.companyId IN (9237218,742365) --ed.effectiveDate>GETDATE()-365 --ed.companyId IN (9237218,742365) --


SELECT DISTINCT pbc.companyId,pbc.companyName,pbc.companyTypeId,pvc.companyTypeName AS companyTypeName_Previous,pbc.companyTypeName AS companyTypeName_Current,pbc.effectiveDate FROM #PublicComp pbc
INNER JOIN #PrivateComp pvc ON pvc.companyId=pbc.companyId
WHERE pbc.effectiveDate>pvc.effectiveDate


SELECT companyId,companyName,companyTypeId,companyTypeName,MAX(effectiveDate) AS Latest_EffectiveDate FROM #PublicComp
GROUP BY companyId,companyName,companyTypeId,companyTypeName 
UNION ALL
SELECT companyId,companyName,companyTypeId,companyTypeName,MAX(effectiveDate) AS Latest_EffectiveDate FROM #PrivateComp
GROUP BY companyId,companyName,companyTypeId,companyTypeName 
ORDER BY companyId

