
USE Estimates

DECLARE @frdate AS DATETIME,@todate AS DATETIME
SET @frdate='2023-09-19 00:00:00.000'
SET @todate='2023-09-30 23:59:59.999'

IF OBJECT_ID ('TEMPDB..#SLA') IS NOT NULL DROP TABLE #SLA
SELECT DISTINCT ct.collectionEntityId AS VersionId,ct.relatedcompanyid AS CompanyId,FORMAT(CONVERT(datetime, ct.insertedDate), 'yyyy-MM-dd hh:mm:ss tt') AS ProcessInsertedDate,
FORMAT(CONVERT(datetime, ct.stageInsertedDate), 'yyyy-MM-dd hh:mm:ss tt') AS StageInsertedDate,FORMAT(CONVERT(datetime, ed.effectiveDate), 'yyyy-MM-dd hh:mm:ss tt') AS FilingDate,
DATEDIFF(HOUR,FORMAT(CONVERT(datetime, ed.effectiveDate), 'yyyy-MM-dd hh:mm:ss tt'),FORMAT(CONVERT(datetime, GETDATE()), 'yyyy-MM-dd hh:mm:ss tt')) AS SLA_CROSS_TIME_HR,
cp.collectionProcessName AS CollectionProcess,CTI.IndustryName AS Industry,
vf.Description AS VersionFormat,l.languageName AS Language,
cs.collectionStageName AS CollectionStage,css.collectionStageStatusName AS CollectionStageStatus,p.priorityName AS Priority,ist.issueSourceName AS IssueSource,
ct.collectionstageId INTO #SLA 
FROM           WorkflowArchive_Estimates.[dbo].CommonTracker_vw ct (NOLOCK)
LEFT JOIN      WorkflowArchive_Estimates.dbo.CollectionEntityToProcessToDataPoint_tbl ctdp (NOLOCK) ON ctdp.collectionEntityToProcessId=ct.collectionEntityToProcessId AND ctdp.datapointId=1887
LEFT JOIN      Estimates.dbo.Estimates_IndustrySubTypeToCollectionProcess_tbl est (NOLOCK) ON est.industrySubTypeId=ctdp.value
LEFT JOIN      WorkflowArchive_Estimates.dbo.CollectionProcess_tbl cp (NOLOCK) ON cp.collectionProcessId=ISNULL(est.collectionProcessId,ct.collectionProcessId)
LEFT JOIN      Workflow_Estimates.[dbo].[IssueSource_tbl] ist (NOLOCK) ON ist.issueSourceId=ct.issueSourceId 
LEFT JOIN      Workflow_Estimates.[dbo].[CollectionStage_tbl] cs (NOLOCK) ON cs.collectionStageId=ct.collectionstageId
LEFT JOIN      Workflow_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId=ct.collectionstageStatusId
LEFT JOIN      WorkflowArchive_Estimates.[dbo].[Priority_tbl] p (NOLOCK) ON p.priorityId = ct.PriorityID
LEFT JOIN      Estimates.[dbo].estimatedetail_tbl ed (NOLOCK) ON ct.collectionEntityId = ISNULL(ed.versionid,ed.feedFileId)
LEFT JOIN      CompanyMaster.[dbo].CompanyInfoMaster cm (NOLOCK) ON cm.CIQCompanyId=ct.relatedCompanyId
LEFT JOIN	   Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] CTI (NOLOCK) ON cm.IndustryID = CTI.IndustryId
LEFT JOIN      DocumentRepository.[dbo].[Version_tbl] v (NOLOCK) ON v.versionId=ed.versionid
LEFT JOIN      DocumentRepository.[dbo].[VersionFormat_tbl] vf (NOLOCK) ON vf.FormatID=v.formatID
LEFT JOIN      ComparisonData.[dbo].ResearchDocument_tbl Rd (NOLOCK) ON  Rd.versionId= ct.collectionEntityId
LEFT JOIN      DocumentRepositoryProcessing.dbo.DocumentElementCache_tbl b (NOLOCK) ON  b.versionid=ISNULL(rd.versionId,ct.collectionentityid)     
LEFT JOIN      Comparisondata.[dbo].Language_tbl l (NOLOCK) ON l.languageId=ISNULL(rd.languageId,b.originalLanguageId)
WHERE          ed.effectiveDate>=@frdate AND ed.effectiveDate<=@todate
AND            ct.collectionProcessId IN (64,1062,4861,4862,4863,4864,4899,4900,4901,4902,4903,4904,4905,4906,4907)
AND            ct.collectionstageId IN (2,122)
AND            ct.collectionstageStatusId IN (1,3)
AND            ct.collectionEntityId IS NOT NULL



SELECT DISTINCT * FROM #SLA ORDER BY SLA_CROSS_TIME_HR,CollectionProcess



--left join ComparisonData..ResearchDocument_tbl rd on rd.versionid=ctv.collectionentityid
--left JOIN DocumentRepositoryProcessing.dbo.DocumentElementCache_tbl b on  b.versionid=isnull(rd.versionId,ctv.collectionentityid)
--left join ComparisonData..Language_tbl l on l.languageId=isnull(rd.languageId,b.originalLanguageId)