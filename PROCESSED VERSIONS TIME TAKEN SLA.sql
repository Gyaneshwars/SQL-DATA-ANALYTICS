
USE Estimates

DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2023-09-28 00:00:00.000'
SET @todate='2023-09-30 23:59:59.999'

IF OBJECT_ID ('TEMPDB..#SLA') IS NOT NULL DROP TABLE #SLA
SELECT DISTINCT ct.collectionEntityId AS VersionId,cet.collectionEntityTypeName AS EntityType,FORMAT(CONVERT(datetime, ct.insertedDate), 'yyyy-MM-dd hh:mm:ss tt') AS ProcessInsertedDate,
FORMAT(CONVERT(datetime, ct.stageInsertedDate), 'yyyy-MM-dd hh:mm:ss tt') AS StageInsertedDate,FORMAT(CONVERT(datetime, ed.effectiveDate), 'yyyy-MM-dd hh:mm:ss tt') AS FilingDate,
DocumentSource=dbo.researchcontributorname_fn(ed.researchcontributorid),l.languageName AS Language,vf.Description AS VersionFormat,ct.relatedcompanyid AS CompanyId,
cp.collectionProcessName AS CollectionProcess,cs.collectionStageName AS CollectionStage,css.collectionStageStatusName AS CollectionStageStatus,p.priorityName AS Priority,
ist.issueSourceName AS IssueSource,usr.employeeNumber,usr.firstName+' '+usr.lastName AS UserName,ct.startDate,ct.endDate,CTI.IndustryName AS Industry,ct.collectionstageId, 
DATEDIFF(DAY,FORMAT(CONVERT(datetime, ed.effectiveDate), 'yyyy-MM-dd hh:mm:ss tt'),FORMAT(CONVERT(datetime, ct.endDate), 'yyyy-MM-dd hh:mm:ss tt')) AS TIME_TAKEN_TO_COMMIT_InDays, 
DATEDIFF(DAY,FORMAT(CONVERT(datetime, ed.effectiveDate), 'yyyy-MM-dd hh:mm:ss tt'),FORMAT(CONVERT(datetime, ct.insertedDate), 'yyyy-MM-dd hh:mm:ss tt')) AS GAP_BETWEEN_FD_AND_ID_InDays INTO #SLA 
FROM          WorkflowArchive_Estimates.[dbo].CommonTracker_vw ct (NOLOCK)
LEFT JOIN     WorkflowArchive_Estimates.dbo.CollectionEntityToProcessToDataPoint_tbl ctdp (NOLOCK) ON ctdp.collectionEntityToProcessId=ct.collectionEntityToProcessId and ctdp.datapointId=1887
LEFT JOIN     Estimates.dbo.Estimates_IndustrySubTypeToCollectionProcess_tbl est (NOLOCK) ON est.industrySubTypeId=ctdp.value
LEFT JOIN     WorkflowArchive_Estimates.dbo.CollectionProcess_tbl cp (NOLOCK) ON cp.collectionProcessId=isnull(est.collectionProcessId,ct.collectionProcessId)
LEFT JOIN     CTAdminRepTables.[dbo].user_tbl usr (NOLOCK) ON ct.userId = usr.userid
LEFT JOIN     Workflow_Estimates.[dbo].[IssueSource_tbl] ist (NOLOCK) ON ist.issueSourceId=ct.issueSourceId 
LEFT JOIN     Workflow_Estimates.[dbo].[CollectionStage_tbl] cs (NOLOCK) ON cs.collectionStageId=ct.collectionstageId
LEFT JOIN     Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId=ct.collectionstageStatusId
LEFT JOIN     WorkflowArchive_Estimates.[dbo].[Priority_tbl] p (NOLOCK) ON p.priorityId = ct.PriorityID
LEFT JOIN     Estimates.[dbo].estimatedetail_tbl ed (NOLOCK) ON ct.collectionEntityId = ISNULL(ed.versionid,ed.feedFileId)
LEFT JOIN     CompanyMaster.[dbo].CompanyInfoMaster cm (NOLOCK) ON cm.CIQCompanyId=ct.relatedCompanyId
LEFT JOIN	  Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] CTI (NOLOCK) ON cm.IndustryID = CTI.IndustryId
LEFT JOIN     DocumentRepository.[dbo].[Version_tbl] v (NOLOCK) ON v.versionId=ed.versionid
LEFT JOIN     DocumentRepository.[dbo].[VersionFormat_tbl] vf (NOLOCK) ON vf.FormatID=v.formatID
LEFT JOIN     ComparisonData.[dbo].ResearchDocument_tbl Rd (NOLOCK) ON  Rd.versionId= ct.collectionEntityId
LEFT JOIN     DocumentRepositoryProcessing.dbo.DocumentElementCache_tbl b (NOLOCK) ON  b.versionid=isnull(rd.versionId,ct.collectionentityid) 
LEFT JOIN     Comparisondata.[dbo].Language_tbl l (NOLOCK) ON l.languageId=isnull(rd.languageId,b.originalLanguageId)
LEFT JOIN     Workflow_Estimates.[dbo].[CollectionEntityType_tbl] cet (NOLOCK) ON cet.collectionEntityTypeId=ct.collectionEntityTypeId
WHERE         ed.effectiveDate>=@frdate AND ed.effectiveDate<=@todate
AND           ct.collectionProcessId IN (64,1062,4861,4862,4863,4864,4899,4900,4901,4902,4903,4904,4905,4906,4907)
AND           ct.collectionstageId IN (2,122)
AND           ct.collectionstageStatusId IN (4)
AND           ct.collectionEntityId IS NOT NULL
AND           ct.relatedcompanyid IS NOT NULL
AND           ct.startDate IS NOT NULL
AND           usr.employeeNumber NOT IN ('000387','000266','000EF2','000EF3','00000A')

---SELECT * FROM #SLA

IF OBJECT_ID ('TEMPDB..#SLA1') IS NOT NULL DROP TABLE #SLA1
SELECT a.* INTO #SLA1 FROM #SLA a
INNER JOIN #SLA b ON a.VersionId=b.VersionId AND a.CompanyId=b.CompanyId
WHERE a.collectionstageId=122 AND b.collectionstageId=2

---SELECT * FROM #SLA1

IF OBJECT_ID ('TEMPDB..#SLA2') IS NOT NULL DROP TABLE #SLA2
SELECT a.* INTO #SLA2 FROM #SLA a
INNER JOIN #SLA b ON a.VersionId=b.VersionId AND a.CompanyId=b.CompanyId
WHERE a.collectionstageId=2 AND b.collectionstageId=122

---SELECT * FROM #SLA2


SELECT DISTINCT VersionId,EntityType,ProcessInsertedDate,StageInsertedDate,FilingDate,DocumentSource,Language,VersionFormat,CompanyId,CollectionProcess,CollectionStage,
CollectionStageStatus,Priority,IssueSource,employeeNumber,UserName,startDate,endDate,Industry,collectionstageId,TIME_TAKEN_TO_COMMIT_InDays,GAP_BETWEEN_FD_AND_ID_InDays FROM #SLA
EXCEPT
SELECT DISTINCT VersionId,EntityType,ProcessInsertedDate,StageInsertedDate,FilingDate,DocumentSource,Language,VersionFormat,CompanyId,CollectionProcess,CollectionStage,
CollectionStageStatus,Priority,IssueSource,employeeNumber,UserName,startDate,endDate,Industry,collectionstageId,TIME_TAKEN_TO_COMMIT_InDays,GAP_BETWEEN_FD_AND_ID_InDays FROM #SLA2



--select distinct top 100 * from WorkflowArchive_Estimates.dbo.CommonTracker_vw ct
--left join WorkflowArchive_Estimates.dbo.CollectionEntityToProcessToDataPoint_tbl cdp on cdp.collectionEntityToProcessId=ct.collectionEntityToProcessId
--left join Estimates.dbo.Estimates_IndustrySubTypeToCollectionProcess_tbl est on est.industrySubTypeId=cdp.value
--left join WorkflowArchive_Estimates.dbo.CollectionProcess_tbl cp on cp.collectionProcessId=isnull(est.collectionProcessId,ct.collectionProcessId)
--where datapointId=1887 and ct.collectionstageId=2 --and ct.collectionProcessId=64
--and ct.collectionEntityId=-2105850936