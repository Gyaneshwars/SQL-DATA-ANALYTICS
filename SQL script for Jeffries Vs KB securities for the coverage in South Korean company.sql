--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DATA ANALYTICS DEVELOPER --> GNANESHWAR SRAVANE
Use Estimates

IF OBJECT_ID('TempDb..#Dup') IS NOT NULL DROP TABLE #Dup 
SELECT DISTINCT ED.researchContributorId,CASE ED.researchContributorId  
WHEN 90 THEN 731  --- Jefferies and KB securities
END as DUP_cont INTO #Dup
FROM EstimateDetail_tbl ED
WHERE ED.researchContributorId IN (90)

IF OBJECT_ID('TempDb..#Dup2') IS NOT NULL DROP TABLE #Dup2
SELECT A.*,RC.contributorShortName,RC2.contributorShortName AS DUP_con_NAme INTO #Dup2
FROM #Dup A
INNER JOIN ComparisonData.dbo.ResearchContributor_tbl RC (NOLOCK) ON RC.researchContributorId = A.researchContributorId
INNER JOIN ComparisonData.dbo.ResearchContributor_tbl RC2 (NOLOCK) ON RC2.researchContributorId = A.DUP_cont

--SELECT * FROM #Dup2

IF OBJECT_ID('TempDb..#prasad') IS NOT NULL DROP TABLE #prasad 
SELECT DISTINCT DUP.*,ed.companyId,ED.versionId,Ed.feedFileId,ED.effectiveDate,ED2.versionId AS DUP_VID,ED2.feedFileId AS DUP_FeedID, ED2.effectiveDate AS DUP_Date, DIM.dataItemName,ed.estimatePeriodId
,EDND.dataItemValue,EDND2.dataItemValue AS DUP_dataItemValue
INTO #prasad
FROM  EstimateDetail_tbl ED
INNER JOIN EstimatePeriod_tbl EP (NOLOCK) ON EP.estimatePeriodId = ED.estimatePeriodId AND EP.actualizedDate IS NULL
INNER JOIN EstimateDetail_tbl ED2 (NOLOCK) ON ED.companyId= ED2.companyId AND ED.estimatePeriodId = ED2.estimatePeriodId
INNER JOIN #Dup2 DUP (NOLOCK) ON ED2.researchContributorId = Dup.DUP_cont
INNER JOIN Estimates.dbo.EstFull_vw EDND (NOLOCK) ON EDND.estimateDetailId = ED.estimateDetailId AND EDND.toDate >= '2079-06-06 00:00:00.000'
INNER JOIN Estimates.dbo.EstFull_vw EDND2 (NOLOCK) ON EDND2.estimateDetailId = ED2.estimateDetailId AND EDND2.toDate >= '2079-06-06 00:00:00.000' and EDND.dataItemId= EDND2.dataItemId
INNER JOIN DataItemMaster_vw DIM (NOLOCK) ON DIM.dataItemID = EDND.dataItemId
--INNER JOIN Estimates.dbo.DS_DocumentsReadyForEDCA_vw EE ON ISNULL(EE.versionId,EE.feedFileId ) = ISNULL(ED.versionId,ED.feedFileId) AND EE.companyId = ED.companyId
--INNER JOIN Estimates.dbo.DS_DocumentsReadyForEDCA_vw EE2 ON ISNULL(EE2.versionId,EE2.feedFileId ) = ISNULL(ED2.versionId,ED2.feedFileId) AND EE2.companyId = ED2.companyId
WHERE ed.researchContributorId = DUP.researchContributorId 


IF OBJECT_ID('TempDb..#TEXT') IS NOT NULL DROP TABLE #TEXT
SELECT DISTINCT DUP.*,ed.companyId,ED.versionId,ED.feedFileId,ED.effectiveDate,ED2.versionId AS DUP_VID,ED2.feedFileId AS DUP_FeedID,ED2.effectiveDate AS DUP_Date, DIM.dataItemName,ed.estimatePeriodId
,EDND.dataItemValue,EDND2.dataItemValue AS DUP_dataItemValue
INTO #TEXT
FROM  EstimateDetail_tbl ED
INNER JOIN EstimateDetail_tbl ED2 (NOLOCK) ON ED.companyId= ED2.companyId 
INNER JOIN #Dup2 DUP (NOLOCK) ON ED2.researchContributorId = DUP.DUP_cont
INNER JOIN Estimates.dbo.EstFull_vw EDND (NOLOCK) ON EDND.estimateDetailId = ED.estimateDetailId AND EDND.toDate >= '2079-06-06 00:00:00.000'
INNER JOIN Estimates.dbo.EstFull_vw EDND2 (NOLOCK) ON EDND2.estimateDetailId = ED2.estimateDetailId AND EDND2.toDate >= '2079-06-06 00:00:00.000' and EDND.dataItemId= EDND2.dataItemId
--INNER JOIN Estimates.dbo.DS_DocumentsReadyForEDCA_vw EE ON ISNULL(EE.versionId,EE.feedFileId ) = ISNULL(ED.versionId,ED.feedFileId) AND EE.companyId = ED.companyId
--INNER JOIN Estimates.dbo.DS_DocumentsReadyForEDCA_vw EE2 ON ISNULL(EE2.versionId,EE2.feedFileId ) = ISNULL(ED2.versionId,ED2.feedFileId) AND EE2.companyId = ED2.co
INNER JOIN DataItemMaster_vw DIM (NOLOCK) ON DIM.dataItemID = EDND.dataItemId
WHERE ed.researchContributorId = Dup.researchContributorId

IF OBJECT_ID('TempDb..#FINAL') IS NOT NULL DROP TABLE #FINAL
SELECT * INTO #FINAL FROM #prasad INSERT INTO #FINAL  SELECT * FROM #TEXT

IF OBJECT_ID('TempDb..#FINAL1') IS NOT NULL DROP TABLE #FINAL1
SELECT DISTINCT ED.*,ABS(DATEDIFF(DAY,ED.effectiveDate,ED.DUP_Date)) AS FD_Diff,--CNN.companyId,CNN.companyNotes,
CASE IP.periodTypeId WHEN 1 THEN 'FY: ' + CAST(IP.fiscalYear AS VARCHAR) WHEN 2 THEN 'Q' + CAST(IP.fiscalQuarter AS VARCHAR) + ': ' + CAST(IP.fiscalYear AS VARCHAR) WHEN 10 THEN 'S' + CASE iP.fiscalQuarter 
WHEN 2 THEN '1' + ': ' + CAST(iP.fiscalYear AS VARCHAR) WHEN 4 THEN '2' + ': ' + CAST(iP.fiscalYear AS VARCHAR) ELSE 'NA' END ELSE 'NA' END AS PEO,cs.country
INTO #FINAL1 FROM #FINAL ED
INNER JOIN EstimatePeriod_tbl IP (NOLOCK) ON ed.estimateperiodid = IP.estimateperiodid	
LEFT JOIN CompanyMaster.[dbo].[CompanySearch_vw] cs (NOLOCK) ON cs.companyId=ED.companyId
----INNER JOIN Estimates.dbo.DS_DocumentsReadyForEDCA_vw EE ON ISNULL(EE.versionId,EE.feedFileId ) = ISNULL(ED.versionId,ED.feedFileId) AND EE.companyId = ED.companyId
----INNER JOIN Estimates.dbo.DS_DocumentsReadyForEDCA_vw EE2 ON EE2.versionId = ED.DUP_VID AND EE2.companyId = ED.companyId
----LEFT JOIN companymaster..companyinfomaster CM (NOLOCK) ON ED.companyid = cm.CompanyId
WHERE cs.Country IN ('South Korea')


SELECT DISTINCT F1.* FROM #FINAL1 F1 
WHERE F1.FD_Diff<=30
ORDER BY F1.effectiveDate




