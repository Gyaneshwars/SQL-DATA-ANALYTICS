-----SQL Query Developer---Gnaneshwar Sravane
USE Estimates

IF OBJECT_ID('tempdb..#ContributorFormat_Temp') IS NOT NULL DROP TABLE #ContributorFormat_Temp
SELECT DISTINCT ed.versionid ,ed.companyid,ctl.companyName,contributor=dbo.researchcontributorname_fn(ed.researchcontributorid),ed.effectiveDate AS FilingDate,UT.employeeNumber AS EmpId,UT.firstName + ' '+ UT.lastName AS EmpName,
css.collectionStageStatusName,DATEDIFF(MINUTE,CT.startDate,CT.endDate) AS TimeSpent,vf.Description,l.languageName AS Language,P.priorityName AS Priority,CT.collectionstageId,v.formatID 
INTO #ContributorFormat_Temp FROM Estimates.[dbo].[EstimateDetail_tbl] ed (NOLOCK)
INNER JOIN Estimates.[dbo].[EstFull_vw] edn (NOLOCK) ON ed.estimateDetailId = edn.estimateDetailId
INNER JOIN WorkflowArchive_Estimates.[dbo].[CommonTracker_vw] CT (NOLOCK) ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
INNER JOIN ComparisonData.[dbo].[Currency_tbl] crnc (NOLOCK) ON edn.currencyId = crnc.currencyId
INNER JOIN ComparisonData.[dbo].[Company_tbl] ctl (NOLOCK) ON ed.companyid = ctl.companyId
INNER JOIN CTAdminRepTables.[dbo].[user_tbl] UT (NOLOCK) ON UT.userId=CT.userId
INNER JOIN DocumentRepository.[dbo].[Version_tbl] v (NOLOCK) ON v.versionId=ed.versionid
INNER JOIN ComparisonData.[dbo].ResearchDocument_tbl Rd (NOLOCK) ON  Rd.researchContributorId=ed.researchContributorId AND rd.versionId=ed.versionId
INNER JOIN DocumentRepository.[dbo].[VersionFormat_tbl] vf (NOLOCK) ON vf.FormatID=v.formatID
INNER JOIN Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId=CT.collectionstageStatusId
INNER JOIN Comparisondata.[dbo].Language_tbl l (NOLOCK) ON l.languageId=rd.languageId
INNER JOIN  WorkflowArchive_Estimates.[dbo].[Priority_tbl] p (NOLOCK) ON p.priorityId = CT.PriorityID
WHERE ed.versionId IS NOT NULL
AND CT.collectionstageId IN (2,122)
AND CT.collectionstageStatusId IN (4)
AND UT.employeeNumber NOT IN ('000266','000387','000EF2','000EF3','00000A')
AND ed.versionid IN (-2098794666,-2098795260,-2098798336,-2098798500,-2098798574,-2098798754,-2098798830,-2098799072,-2098855772,-2098856462,-2098856622,-2099064584,-2099064604,-2099064688,-2099064732,-2099065670,-2099065664,-2099066782,-2099066818,-2099066852,-2099066950,-2099067040,-2099067032,-2099067066,-2099067654,-2099116824,-2099117114,-2099117106,-2099167980,-2099168030,-2099168044,-2099168142,-2099168196,-2099168322) -----Provide versionid's here
ORDER BY ed.companyid


---SELECT * FROM #ContributorFormat_Temp

IF OBJECT_ID ('TEMPDB..#SLA1') IS NOT NULL DROP TABLE #SLA1
SELECT a.* INTO #SLA1 FROM #ContributorFormat_Temp a
INNER JOIN #ContributorFormat_Temp b ON a.VersionId=b.VersionId AND a.CompanyId=b.CompanyId
WHERE a.collectionstageId=122 AND b.collectionstageId=2

---SELECT * FROM #SLA1

IF OBJECT_ID ('TEMPDB..#SLA2') IS NOT NULL DROP TABLE #SLA2
SELECT a.* INTO #SLA2 FROM #ContributorFormat_Temp a
INNER JOIN #ContributorFormat_Temp b ON a.VersionId=b.VersionId AND a.CompanyId=b.CompanyId
WHERE a.collectionstageId=2 AND b.collectionstageId=122
ORDER BY a.companyid

---SELECT * FROM #SLA2


SELECT DISTINCT versionId,companyId,companyName,contributor,FilingDate,Priority,collectionStageStatusName AS collectionStatus,TimeSpent AS TimeSpent_In_Minutes,
Description AS VersionFormat,TRIM(EmpName) AS EmpName,EmpId,Language FROM #ContributorFormat_Temp
EXCEPT
SELECT DISTINCT versionId,companyId,companyName,contributor,FilingDate,Priority,collectionStageStatusName AS collectionStatus,TimeSpent AS TimeSpent_In_Minutes,
Description AS VersionFormat,TRIM(EmpName) AS EmpName,EmpId,Language FROM #SLA2


