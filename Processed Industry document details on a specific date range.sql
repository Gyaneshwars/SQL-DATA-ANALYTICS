----SQL QUERY DEVELOPER - GNANESHWAR SRAVANE
USE Estimates
DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frDate = '2023-10-31 00:00:00.000' 
SET @toDate = '2023-11-17 23:59:59.999' 


IF OBJECT_ID('tempdb..#IndustryDocsDetails') IS NOT NULL DROP TABLE #IndustryDocsDetails
SELECT DISTINCT ISNULL(CT.collectionEntityId,ed.versionId) AS versionId,ISNULL(CT.relatedCompanyId,ed.companyId) AS companyId, cc.companyName,l.languageName AS Language,
contributor=dbo.researchcontributorname_fn(ISNULL(RD.researchcontributorid,ed.researchcontributorid)),ISNULL(RD.researchcontributorid,ed.researchcontributorid) AS researchcontributorid,
stt.subTypeId,stt.subTypeValue,CT.collectionstageId,ISNULL(RD.lastUpdatedDate,ed.effectiveDate) AS FilingDate,COUNT(dbo.dataitemname_fn(ISNULL(ednd.dataitemid,21625))) AS NoOfDataPoints,cm.IndustryID,
id.IndustryName,cst.statusDescription AS StatusoftheCompamy,RD.pagecount AS NumberOfPages
INTO #IndustryDocsDetails FROM EstimateDetail_tbl ed
RIGHT JOIN WorkflowArchive_Estimates.[dbo].[CommonTracker_vw] CT (NOLOCK) ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
INNER JOIN ComparisonData.dbo.Company_tbl CC (NOLOCK) ON cc.companyId = CT.relatedCompanyId
INNER JOIN Comparisondata.dbo.SubType_tbl stt (NOLOCK) ON stt.SubTypeId=cc.PrimarySubTypeId
INNER JOIN CompanyMaster.[dbo].[CompanyInfoMaster] cm (NOLOCK) ON cm.CIQCompanyId=CT.relatedCompanyId
INNER JOIN Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] id (NOLOCK) ON cm.IndustryID=id.IndustryId
LEFT JOIN [EstFull_vw] ednd (NOLOCK) ON ednd.estimateDetailId=ed.estimateDetailId
INNER JOIN CompanyMaster.[dbo].[CompanyStatusType_tbl] cst (NOLOCK) ON cst.companyStatusTypeId=cc.companyStatusTypeId
LEFT JOIN DataItemMaster_vw dim (NOLOCK) ON dim.dataItemID=ednd.dataItemId
INNER JOIN ComparisonData.dbo.ResearchDocument_tbl RD (NOLOCK) ON CT.collectionEntityId=RD.versionId
INNER JOIN Comparisondata.[dbo].Language_tbl l (NOLOCK) ON l.languageId=RD.languageId
WHERE CT.endDate>=@frDate AND CT.endDate<=@toDate
AND stt.subTypeId IN (3221000,3211000,7013000,7012000,9551733,7132000,7121000,7113000,7021000,7112000,7111000,7133000,3112400,6032000,6022000,9551728,6021000,6033000,9551730,3041000,4113000,4214000,4211000,4212000,9621070,4213000,7214000,6034000,7212000,7215000,7213000,2052001,1033404,2052000,2053000,2054000,9621065,2055000,7131000,1033402,6111000,6121000,6031000,9551731,9551737,9551735,9612015,9612014,9551736,9612016,7312000,9551734,9551732,9621071,9551705,4444000,5122000,4432000,3112100,4444100,4441000,4131000,5022000,4431000,3112800,4442000,4411000,5024000,5021000,1033000,5023000,3061000,4443000,4132000,4422000,9612013,8041000,3081000,9031000,8030001,3242000,4314000,9612012,4300003,8043000,4313000,4311000,9022000,3111000,9021000,3253000)
AND CT.collectionEntityId IS NOT NULL 
AND CT.collectionstageStatusId IN (4)
--AND ednd.auditTypeId NOT IN (2059)
AND CT.collectionstageId IN (2,122)
AND ed.feedFileId IS NULL
---AND dim.dataCollectionTypeID IN (54,63)
AND RD.researchcontributorid IS NOT NULL
--AND CT.collectionEntityId IN (-2107462988,-2098508296)--,-2093853890,1977116774)
GROUP BY ISNULL(CT.collectionEntityId,ed.versionId),ISNULL(CT.relatedCompanyId,ed.companyId), cc.companyName,l.languageName,dbo.researchcontributorname_fn(ISNULL(RD.researchcontributorid,ed.researchcontributorid)),
ISNULL(RD.researchcontributorid,ed.researchcontributorid),stt.subTypeId,stt.subTypeValue,CT.collectionstageId,ISNULL(RD.lastUpdatedDate,ed.effectiveDate),cm.IndustryID,id.IndustryName,cst.statusDescription,RD.pagecount

--SELECT * FROM #IndustryDocsDetails

--IF OBJECT_ID('tempdb..#IndustryDocsDetails') IS NOT NULL DROP TABLE #IndustryDocsDetails
--SELECT DISTINCT CT.collectionEntityId AS versionId,CT.relatedCompanyId AS companyId, cc.companyName,contributor=dbo.researchcontributorname_fn(RD.researchcontributorid),RD.researchcontributorid,stt.subTypeId,stt.subTypeValue,CT.collectionstageId,
--RD.lastUpdatedDate AS FilingDate,COUNT(dbo.dataitemname_fn(ISNULL(ednd.dataitemid,21625))) AS NoOfDataPoints,cm.IndustryID,id.IndustryName,cst.statusDescription AS StatusoftheCompamy INTO #IndustryDocsDetails
--FROM WorkflowArchive_Estimates.[dbo].[CommonTracker_vw] CT
--INNER JOIN ComparisonData.dbo.Company_tbl CC (NOLOCK) ON cc.companyId = CT.relatedCompanyId
--INNER JOIN Comparisondata.dbo.SubType_tbl stt (NOLOCK) ON stt.SubTypeId=cc.PrimarySubTypeId
--INNER JOIN CompanyMaster.[dbo].[CompanyInfoMaster] cm (NOLOCK) ON cm.CIQCompanyId=cc.companyId
--INNER JOIN Workflow_Estimates.[dbo].[CTAdmin_Industries_vw] id (NOLOCK) ON cm.IndustryID=id.IndustryId
--INNER JOIN CompanyMaster.[dbo].[CompanyStatusType_tbl] cst (NOLOCK) ON cst.companyStatusTypeId=cc.companyStatusTypeId
--LEFT JOIN EstimateDetail_tbl ed (NOLOCK) ON ed.versionid = CT.collectionEntityId AND ed.companyid = CT.relatedCompanyId
--INNER JOIN [EstFull_vw] ednd (NOLOCK) ON ednd.estimateDetailId=ed.estimateDetailId
--INNER JOIN DataItemMaster_vw dim (NOLOCK) ON dim.dataItemID=ednd.dataItemId
--INNER JOIN ComparisonData.dbo.ResearchDocument_tbl RD (NOLOCK) ON CT.collectionEntityId=RD.versionId
--WHERE ----collectionEntityId IN (1942080092)
--CT.endDate>=@frDate AND CT.endDate<=@toDate 
--AND CT.collectionEntityId IS NOT NULL 
--AND CT.collectionstageStatusId IN (4)
--AND ednd.auditTypeId NOT IN (2059)
--AND CT.collectionstageId IN (2,122)
--AND CT.collectionstageId NOT IN (24)
--AND dim.dataCollectionTypeID IN (54,63)
--AND ed.feedFileId IS NULL
--GROUP BY CT.collectionEntityId,CT.relatedCompanyId, cc.companyName,RD.researchcontributorid,stt.subTypeId,stt.subTypeValue,CT.collectionstageId,RD.lastUpdatedDate,cm.IndustryID,
--id.IndustryName,cst.statusDescription


IF OBJECT_ID ('TEMPDB..#IDD2') IS NOT NULL DROP TABLE #IDD2
SELECT a.* INTO #IDD2 FROM #IndustryDocsDetails a
INNER JOIN #IndustryDocsDetails b ON a.VersionId=b.VersionId AND a.CompanyId=b.CompanyId
WHERE a.collectionstageId=2 AND b.collectionstageId=122
ORDER BY a.companyid

---SELECT * FROM #IDD2

-----Periodic Query development

IF OBJECT_ID ('TEMPDB..#IDD3') IS NOT NULL DROP TABLE #IDD3
SELECT DISTINCT versionId,companyId,companyName,contributor,researchcontributorid,FilingDate,NoOfDataPoints,subTypeId,subTypeValue,IndustryID,IndustryName,NumberOfPages,Language,
CASE WHEN StatusoftheCompamy='Operating' THEN 'ACTIVE' ELSE StatusoftheCompamy END AS StatusoftheCompamy,collectionstageId INTO #IDD3
FROM #IndustryDocsDetails WHERE contributor IS NOT NULL
EXCEPT
SELECT DISTINCT versionId,companyId,companyName,contributor,researchcontributorid,FilingDate,NoOfDataPoints,subTypeId,subTypeValue,IndustryID,IndustryName,NumberOfPages,Language,
CASE WHEN StatusoftheCompamy='Operating' THEN 'ACTIVE' ELSE StatusoftheCompamy END AS StatusoftheCompamy,collectionstageId
FROM #IDD2 WHERE contributor IS NOT NULL

---SELECT * FROM #IDD3

IF OBJECT_ID ('TEMPDB..#TotalIDD3') IS NOT NULL DROP TABLE #TotalIDD3
SELECT DISTINCT a.versionId,a.companyId,a.companyName,a.contributor,a.FilingDate,a.NoOfDataPoints,a.StatusoftheCompamy,a.NumberOfPages,et.eventtypename AS EventName,a.subTypeId,a.subTypeValue,a.IndustryID,a.IndustryName,a.Language INTO #TotalIDD3 FROM #IDD3 a
--INNER JOIN ComparisonData.dbo.ResearchDocument_tbl RD (NOLOCK) ON a.researchcontributorid=RD.researchContributorId AND a.versionId=RD.versionId
LEFT JOIN  Estimates.dbo.Event_tbl e (NOLOCK) ON e.versionId=a.versionId AND e.companyId=a.companyId  ---e.researchcontributorid=a.researchcontributorid AND 
LEFT JOIN Estimates.dbo.EventType_tbl et (NOLOCK) ON  et.eventtypeid=e.eventtypeid


--SELECT DISTINCT * FROM #TotalIDD3


-----Non-Periodic Query development

IF OBJECT_ID ('TEMPDB..#TotalNPIDD3') IS NOT NULL DROP TABLE #TotalNPIDD3
SELECT DISTINCT a.*,ISNULL(dim.dataCollectionTypeID,63) AS dataCollectionTypeID INTO #TotalNPIDD3 FROM #TotalIDD3 a
LEFT JOIN EstimateDetail_tbl ed (NOLOCK) ON a.versionId=ed.versionId AND a.companyId=ed.companyId
LEFT JOIN [EstFull_vw] ednd (NOLOCK) ON ednd.estimateDetailId=ed.estimateDetailId
LEFT JOIN DataItemMaster_vw dim (NOLOCK) ON dim.dataItemID=ednd.dataItemId
---GROUP BY a.versionId,a.companyId,a.companyName,a.contributor,a.FilingDate,a.NoOfDataPoints,a.StatusoftheCompamy,a.NumberOfPages,a.EventName,a.subTypeId,a.subTypeValue,a.IndustryID,a.IndustryName,ISNULL(dim.dataCollectionTypeID,63)

----SELECT * FROM #TotalNPIDD3

IF OBJECT_ID ('TEMPDB..#TotalNPIDDFinal') IS NOT NULL DROP TABLE #TotalNPIDDFinal
SELECT DISTINCT *,(ROW_NUMBER() OVER(PARTITION BY versionId,companyId,contributor ORDER BY versionId,companyId,contributor)) AS RN 
INTO #TotalNPIDDFinal FROM #TotalNPIDD3 
ORDER BY subTypeId

----SELECT * FROM #TotalNPIDDFinal

--IF OBJECT_ID ('TEMPDB..#NPFinal') IS NOT NULL DROP TABLE #NPFinal
--SELECT DISTINCT versionId,companyId,companyName,contributor,FilingDate,NoOfDataPoints,StatusoftheCompamy,NumberOfPages,EventName,subTypeId,subTypeValue,
--IndustryID,IndustryName
--INTO #NPFinal FROM #TotalNPIDDFinal
--WHERE dataCollectionTypeID IN (63) AND RN IN (1)
--ORDER BY subTypeId


----Non Periodic Data only document details
--SELECT DISTINCT *  FROM #NPFinal

----Periodic & Non Periodic both Data document details
--SELECT DISTINCT * FROM #TotalIDD3
--EXCEPT
--SELECT DISTINCT * FROM #NPFinal

IF OBJECT_ID ('TEMPDB..#NIDDFinal') IS NOT NULL DROP TABLE #NIDDFinal
SELECT DISTINCT versionId, CASE WHEN COUNT(DISTINCT(companyId))>1 THEN 'MULTI' ELSE 'SINGLE' END AS Companytype 
INTO #NIDDFinal FROM #TotalNPIDD3 
GROUP BY versionId



SELECT DISTINCT a.versionId,a.companyId,a.companyName,a.contributor,a.FilingDate,a.NoOfDataPoints,a.StatusoftheCompamy,a.NumberOfPages,a.EventName,tn3.Companytype,a.Language,
CASE WHEN dataCollectionTypeID IN (54) AND RN IN (1) THEN 'PERIODIC' WHEN  dataCollectionTypeID IN (63) AND RN IN (1) THEN 'NON-PERIODIC' ELSE 'Nothing' END AS DataCategory,
subTypeId,subTypeValue,IndustryID,IndustryName
FROM #TotalNPIDDFinal a
INNER JOIN #NIDDFinal tn3 ON tn3.versionId=a.versionId
WHERE dataCollectionTypeID IN (54,63) AND RN IN (1)
ORDER BY a.versionId,a.subTypeId
