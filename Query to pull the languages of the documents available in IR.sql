--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNYANESHWAR SRAVANE
USE ComparisonData  

DECLARE @frDate AS DATE, @toDate AS DATE
SET @frdate='2023-08-01 00:00:00.000'
SET @todate='2023-09-29 23:59:59.999'

IF OBJECT_ID('TEMPDB..#IRVersionids') IS NOT NULL DROP TABLE #IRVersionids
SELECT DISTINCT RDC.CompanyID, C.CompanyName,C.tickerSymbol,RC.ContributorShortName AS ContributorName, RD.VersionID,
RD.LastUpdatedDateUTC AS FilingDate,L.LanguageName AS Language,RD.primaryCompanyId AS PrimaryCID,versionFormatId,RC.ResearchContributorID AS ContributorID,
Rd.headline, Rd.[pageCount],ff.researchFocusName,c.companyTypeId,rv.researchEventId INTO #IRVersionids --,css.collectionStageStatusName
FROM ComparisonData.[dbo].ResearchDocument_tbl RD (NOLOCK)
INNER JOIN ComparisonData.[dbo].ResearchContributor_tbl RC (NOLOCK) ON RD.ResearchContributorID = RC.ResearchContributorID
LEFT JOIN  ComparisonData.[dbo].ResearchDocumentToCompany_tbl RDC (NOLOCK) ON RD.ResearchDocumentID = RDC.ResearchDocumentID
LEFT JOIN  ComparisonData.[dbo].Company_tbl C (NOLOCK) ON  RDC.CompanyID = C.CompanyID
LEFT JOIN  ComparisonData.[dbo].Language_tbl L (NOLOCK) ON L.LanguageID = RD.LanguageID
LEFT JOIN  ComparisonData.[dbo].ResearchDocumentToResearchFocus_tbl F (NOLOCK) ON F.researchDocumentId = RD.researchDocumentId
LEFT JOIN  ComparisonData.[dbo].ResearchFocus_tbl FF (NOLOCK) ON FF.researchFocusId = F.researchFocusId
--LEFT JOIN  DocumentRepository.[dbo].ContentSearchResult_tbl CSR (NOLOCK) ON CSR.versionId = RD.versionId
LEFT JOIN  ComparisonData.[dbo].[ResearchDocumentToResearchEvent_tbl]  RV (NOLOCK) ON RV.researchDocumentId = RD.researchDocumentId
--LEFT JOIN  WorkflowArchive_Estimates.[dbo].CommonTracker_vw ct (NOLOCK) ON ct.collectionEntityId = RD.VersionID AND RDC.CompanyID=ct.relatedcompanyid
--LEFT JOIN  WorkflowArchive_Estimates.[dbo].[CollectionStageStatus_tbl] css (NOLOCK) ON css.collectionStageStatusId=ct.collectionstageStatusId
WHERE
estimateContributorStatusTypeId=1
AND RD.LastUpdatedDateUTC BETWEEN @frDate AND @toDate
ORDER BY FilingDate DESC


SELECT DISTINCT VersionID,CompanyID,PrimaryCID,ContributorName,FilingDate,Language,versionFormatId,ContributorID,
headline, [pageCount],researchFocusName FROM #IRVersionids ORDER BY FilingDate DESC  ---collectionStageStatusName



