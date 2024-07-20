--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DATA ANALYTICS DEVELOPER --> GNANESHWAR SRAVANE
USE Estimates

DECLARE @frDate AS DATETIME, @toDate AS DATETIME
SET @frdate='2024-06-01 00:00:00.000'
SET @todate='2024-06-30 23:59:59.999'

SELECT DISTINCT CP.feedfileid,CP.versionid,CP.CompanyId,CP.parentflag,CP.tradingitemId,CP.researchcontributorId,
CP.AccountingStandardID,C.ChecklogicID,C.Checkdescription,DM.dataitemname,EEDV.Value,
CASE WHEN FI.periodTypeId = 1 THEN 'FY ' + CAST(FI.fiscalYear AS VARCHAR)
WHEN FI.periodTypeId = 2 AND FI.fiscalquarter = 1 THEN 'Q1 ' + CAST(FI.fiscalYear AS VARCHAR)
WHEN FI.periodTypeId = 2 AND FI.fiscalquarter = 2 THEN 'Q2 ' + CAST(FI.fiscalYear AS VARCHAR)
WHEN FI.periodTypeId = 2 AND FI.fiscalquarter = 3 THEN 'Q3 ' + CAST(FI.fiscalYear AS VARCHAR)
WHEN FI.periodTypeId = 2 AND FI.fiscalquarter = 4 THEN 'Q4 ' + CAST(FI.fiscalYear AS VARCHAR)
WHEN FI.periodTypeId > 2 THEN 'OTHER ' + CAST(FI.fiscalYear AS VARCHAR) END AS PEO,
FI.periodEndDate,ERT.Errorresolutiondescription,CB.starttime,CB.endtime,E.errordatetime-- CEtoCS.collectionstageid
FROM CheckParameters_tbl CP (NOLOCK)
INNER JOIN CheckBatch_tbl CB (NOLOCK) ON CP.checkBatchId = CB.checkBatchId
--LEFT JOIN WorkflowArchive_Estimates.dbo.collectionentitytoprocess_tbl CEtoP (NOLOCK) ON cp.versionid = CEtoP.collectionentityid --and CEtoP.collectionProcessId = 64 --Estimates/Actuals/Guidance
--LEFT JOIN WorkflowArchive_Estimates.dbo.collectionentitytocollectionstage_tbl CEtoCS (NOLOCK) ON CEtoP.collectionentitytoprocessid = CEtoCS.collectionentitytoprocessid and CEtoCS.collectionStageId = 24 --2-Production --  24- master correction                    
LEFT JOIN Error_tbl E (NOLOCK) ON E.checkBatchId = CB.checkBatchId --   and E.raisedInCollectionEntityToCollectionStageId = CEtoCS.collectionEntityToCollectionStageId --Restricting to poduction CECS
LEFT JOIN Check_tbl C (NOLOCK) ON E.checkId = C.checkId
LEFT JOIN ErrorToEstimateDataValue_tbl EEDV (NOLOCK) ON EEDV.errorId = E.errorId
LEFT JOIN Estimatedetail_Tbl ED (NOLOCK) ON EEDV.estimatedetailID = ED.estimatedetailID --AND  ---CP.feedFileId = ED.feedFileId AND CP.companyId=ED.companyId
LEFT JOIN estimatePeriod_tbl FI (NOLOCK) ON FI.estimatePeriodId = ED.estimatePeriodId
LEFT JOIN ErrorToResolution_tbl ER (NOLOCK) ON ER.errorId = E.errorId 
LEFT JOIN ErrorResolutionType_tbl ERT (NOLOCK) ON ER.errorResolutionTypeId = ERT.errorResolutionTypeId
LEFT JOIN dataitemmaster_vw DM (NOLOCK) ON DM.dataitemID = EEDV.dataitemID
WHERE CB.starttime > @frdate
AND CB.endtime < @todate
AND CP.feedFileId IS NOT NULL
AND CP.versionId IS NULL
AND CP.feedFileId >0
AND EEDV.dataitemID IS NOT NULL