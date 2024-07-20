
--Python,PBI & SQL ETL Developer-GNANESHWAR SRAVANE

USE Estimates
IF OBJECT_ID('TEMPDB..#Versioniddta') IS NOT NULL DROP TABLE #Versioniddta
SELECT DISTINCT ed.versionid,ed.feedfileid,ed.companyid,ed.researchcontributorid,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),ed.effectiveDate,ed.tradingItemId,
ed.accountingStandardId,edn.dataitemid,dataitemname=dbo.DataItemName_fn(edn.dataitemid),l.languageName,CTI.IndustryName AS Industry,PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),ed.flavorTypeId 
INTO #Versioniddta FROM EstimateDetail_tbl ED (NOLOCK)
INNER JOIN EstimatePeriod_tbl EP (NOLOCK) ON ED.estimatePeriodId = ep.estimatePeriodId
INNER JOIN Estimates.[dbo].[EstFull_vw] edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId
INNER JOIN ComparisonData.[dbo].ResearchDocument_tbl Rd (NOLOCK) ON  Rd.researchContributorId=ed.researchContributorId AND rd.versionId=ed.versionId
INNER JOIN Comparisondata.[dbo].Language_tbl l (NOLOCK) ON l.languageId=rd.languageId
LEFT JOIN  CompanyMaster.[dbo].CompanyInfoMaster cm (NOLOCK) ON cm.CIQCompanyId=ed.companyid
LEFT JOIN  Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] CTI (NOLOCK) ON cm.IndustryID = CTI.IndustryId
WHERE ed.versionid IN (1580025966,-2060143774,-2060956820,-2061613648,-2070354858)
--AND ed.feedfileid IN ()
ORDER BY ed.effectiveDate DESC

IF OBJECT_ID('TEMPDB..#Final') IS NOT NULL DROP TABLE #Final
SELECT DISTINCT versionid,companyid,contributor,effectiveDate,languageName,Industry,COUNT(dataitemid) AS No_Of_DataPoints,CASE WHEN flavorTypeId IN (3,4) THEN COUNT(dataitemid) ELSE 0 END AS NonPeriodic,
CASE WHEN flavorTypeId IN (1,2) THEN COUNT(dataitemid) ELSE 0 END AS Periodic INTO #Final FROM #Versioniddta
GROUP BY versionid,companyid,contributor,effectiveDate,languageName,Industry,flavorTypeId

SELECT DISTINCT versionid,companyid,contributor,effectiveDate,languageName,Industry,SUM(No_Of_DataPoints) AS TotalDataPoints,SUM(NonPeriodic) AS NonPeriodics,SUM(Periodic) AS Periodics FROM #Final
GROUP BY versionid,companyid,contributor,effectiveDate,languageName,Industry
ORDER BY effectiveDate

SELECT DISTINCT versionid,feedfileid,companyid,contributor,effectiveDate,languageName,Industry,dataitemid,dataitemname,PEO FROM #Versioniddta
ORDER BY versionid,feedfileid,companyid



