--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DATA ANALYTICS DEVELOPER --> GNANESHWAR SRAVANE
USE Estimates
IF OBJECT_ID ('TEMPDB..#rDocDtl_tbl') IS NOT NULL DROP TABLE #rDocDtl_tbl 
SELECT DISTINCT Rd.versionId, RdToCo.companyId, RdToCo.primaryFlag, Rd.primaryCompanyId, 
Rd.researchContributorId AS rConId, Rd.lastUpdatedDateUTC AS filingDate, 
Rd.headline, Rd.[pageCount], Rd.languageId, RdToRf.researchFocusId,ctc.comment AS UserComment INTO #rDocDtl_tbl 
FROM ComparisonData.dbo.ResearchDocument_tbl Rd (NOLOCK) 
LEFT JOIN   Comparisondata.dbo.ResearchDocumentToCompany_tbl RdToCo (NOLOCK)ON RdToCo.researchDocumentId = Rd.researchDocumentId 
LEFT JOIN   Comparisondata.dbo.ResearchDocumentToResearchFocus_tbl RdToRf (NOLOCK)ON RdToRf.researchDocumentId = Rd.researchDocumentId
LEFT JOIN   WorkflowArchive_Estimates.dbo.CommonTracker_vw CT (NOLOCK) ON Rd.versionId=CT.collectionEntityId
INNER JOIN  WorkflowArchive_Estimates.dbo.collectionStageComment_tbl ctc (NOLOCK) ON ctc.collectionEntityToCollectionStageID=ct.collectionEntityToCollectionStageID
INNER JOIN  CTAdminRepTables.dbo.user_tbl usr (NOLOCK) ON ct.userId = usr.userid
WHERE 
CT.collectionProcessId IN (64)
AND CT.collectionstageId IN (2)
AND CT.userid <>(907321171) 
AND (ctc.collectionCommentTypeId NOT IN (363,364,365,429,10658,10657,15601) OR ctc.collectionCommentTypeId IN (8))
--Please Provide VersionId's here
AND Rd.versionId IN (-2076754012,-1884908730)

SELECT DISTINCT rD.versionId, rD.companyId, Co.companyName, Co.tickerSymbol, rD.primaryFlag, rD.primaryCompanyId, rD.rConId,
contributorName = dbo.researchContributorName_fn (rD.rConId), rD.filingDate, rD.headline, rD.[pageCount], Lg.languageName, 
Cs.collectionStageStatusName AS statusName, Rf.ResearchFocusName AS Focus,rD.UserComment FROM #rDocDtl_tbl rD (NOLOCK) 
LEFT JOIN Comparisondata.dbo.Company_tbl Co (NOLOCK)ON Co.companyId = rD.companyId 
LEFT JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToProcess_tbl CeToP (NOLOCK) ON CeToP.collectionEntityId = rD.versionId AND CeToP.relatedCompanyId = rD.companyId AND CeToP.collectionProcessId = 64
LEFT JOIN WorkflowArchive_Estimates.dbo.CollectionEntityToCollectionStage_tbl CeToCs (NOLOCK) ON CeToCs.collectionEntityToProcessId = CeToP.collectionEntityToProcessId and CeToCs.collectionStageId in (2)
LEFT JOIN WorkflowArchive_Estimates.dbo.CollectionStageStatus_tbl Cs (NOLOCK) ON Cs.collectionStageStatusId = CeToCs.collectionStageStatusId 
LEFT JOIN ComparisonData.dbo.ResearchFocus_tbl Rf (NOLOCK)ON Rf.researchFocusId = rD.researchFocusId 
LEFT JOIN Comparisondata.dbo.Language_tbl Lg (NOLOCK) ON Lg.languageId = rD.languageId
WHERE Cs.collectionStageStatusName IS NOT NULL
