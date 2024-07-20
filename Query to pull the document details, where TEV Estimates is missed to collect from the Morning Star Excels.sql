-----SQL Query Developer---Gnaneshwar Sravane
USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-10-09 00:00:00.000'
SET @toDate = '2023-10-30 23:59:59.999'

IF OBJECT_ID('tempdb..#DocumentDetails_Temp') IS NOT NULL DROP TABLE #DocumentDetails_Temp
SELECT DISTINCT ed.versionid ,ed.companyid,ctl.companyName,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),ed.effectiveDate AS FilingDate,edn.dataItemId,
dataitemname=dbo.DataItemName_fn(edn.dataitemid),PEO=dbo.formatPeriodId_fn(ed.estimatePeriodId),edn.dataItemValue,UT.employeeNumber AS EmpId,UT.firstName + ' '+ UT.lastName AS EmpName,
ed.parentFlag,ed.accountingStandardId,css.collectionStageStatusName,vf.Description,v.formatID 
INTO #DocumentDetails_Temp FROM Estimates.[dbo].[EstimateDetail_tbl] ed (NOLOCK)
INNER JOIN Estimates.[dbo].[EstFull_vw] edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId
INNER JOIN WorkflowArchive_Estimates.[dbo].[CommonTracker_vw] CT (NOLOCK) ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
INNER JOIN ComparisonData.[dbo].[Currency_tbl] crnc (NOLOCK) ON edn.currencyId = crnc.currencyId
INNER JOIN ComparisonData.[dbo].[Company_tbl] ctl (NOLOCK) ON ed.companyid = ctl.companyId
INNER JOIN CTAdminRepTables.[dbo].[user_tbl] UT (NOLOCK) ON UT.userId=CT.userId
INNER JOIN DocumentRepository.[dbo].[Version_tbl] v (NOLOCK) ON v.versionId=ed.versionid
INNER JOIN DocumentRepository.[dbo].[VersionFormat_tbl] vf (NOLOCK) ON vf.FormatID=v.formatID
INNER JOIN Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId=CT.collectionstageStatusId
WHERE CT.endDate>= @frDate AND CT.endDate<=@toDate
AND ed.versionId IS NOT NULL
AND CT.collectionstageStatusId IN (4)
AND UT.employeeNumber NOT IN ('000266','000387','000EF2','000EF3','00000A')
AND v.formatID IN (7,63,64,83,157,177,176)
AND ed.researchcontributorid IN (2494)
ORDER BY ed.effectiveDate


---SELECT * FROM #Document_Temp

SELECT DISTINCT versionId,companyId,companyName,contributor,FilingDate,collectionStageStatusName,
Description AS SourceName,EmpName,EmpId FROM #DocumentDetails_Temp
EXCEPT
SELECT DISTINCT versionId,companyId,companyName,contributor,FilingDate,collectionStageStatusName,
Description AS SourceName,EmpName,EmpId FROM #DocumentDetails_Temp WHERE dataItemId IN (21628)

