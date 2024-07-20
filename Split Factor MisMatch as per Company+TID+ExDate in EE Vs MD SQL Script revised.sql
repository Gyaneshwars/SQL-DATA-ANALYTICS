
----Estimates Vs Pricing
USE Estimates
IF OBJECT_ID ('TEMPDB..#SPLITFR1') IS NOT NULL DROP TABLE #SPLITFR1
SELECT DISTINCT csf.companyId,csf.tradingItemId,csf.effectiveDate,csf.toDate,esi.factor as Esti_splitfactor,esi.announcedDate,st.announcedDate as Pricing_announcedDate,st.rate as Pricing_splitfactor,st.exDate as Pricing_exDate
INTO #SPLITFR1 FROM Estimates.dbo.CumilativeSplitFactor_tbl csf
LEFT JOIN Estimates.[dbo].[EstimateSplitInfo_tbl] esi ON esi.companyId=csf.companyId AND esi.tradingItemId=csf.tradingItemId AND esi.exDate=csf.toDate
--LEFT JOIN [EstimateTimeliness].dbo.[EstimateTimelinessDetail_tbl] etd ON etd.CompanyId=csf.companyId
LEFT JOIN comparisondata..split_tbl st ON st.tradingItemId=csf.tradingItemId AND st.exDate=csf.toDate AND st.appliedFlag=1
WHERE csf.companyId IN (882872,552711,882672,882676,882701,882765,882765,882775)


IF OBJECT_ID ('TEMPDB..#FD') IS NOT NULL DROP TABLE #FD
SELECT CompanyId,MIN(EffectiveDate) AS Min_FD INTO #FD FROM [EstimateTimeliness].dbo.[EstimateTimelinessDetail_tbl]
WHERE CompanyId IN (882872,552711,882672,882676,882701,882765,882765,882775)
GROUP BY CompanyId

IF OBJECT_ID ('TEMPDB..#Final') IS NOT NULL DROP TABLE #Final
SELECT a.*,b.Min_FD INTO #Final FROM #SPLITFR1 a
INNER JOIN #FD b ON b.CompanyId=a.companyId

--SELECT *,COUNT(*) OVER(PARTITION BY companyId) AS Count_of_mismatch_of_splits_C_AND_T FROM #Final-- WHERE Esti_tradingItemId IS NULL AND Esti_toDate IS NULL
--ORDER BY companyId,toDate DESC

------------------------------------------------

----Pricing Vs Estimates

IF OBJECT_ID ('TEMPDB..#SPLITFR') IS NOT NULL DROP TABLE #SPLITFR
SELECT DISTINCT stt.companyId,st.tradingItemId,csf.effectiveDate,st.exDate,st.rate as Pricing_splitfactor,csf.toDate as Esti_toDate,
esi.announcedDate AS Esti_announcedDate,esi.factor as Esti_splitfactor,esi.exDate as Esti_exDate
INTO #SPLITFR FROM comparisondata..split_tbl st (NOLOCK)
INNER JOIN comparisondata..tradingitemdetails_tbl tid (NOLOCK) ON tid.tradingitemid=st.tradingitemid
INNER JOIN comparisondata..security_tbl stt (NOLOCK) ON stt.securityid=tid.securityid
LEFT JOIN Estimates.dbo.CumilativeSplitFactor_tbl csf (NOLOCK) ON csf.companyId=stt.companyId AND csf.tradingItemId=st.tradingitemid AND csf.toDate=st.exDate
--LEFT JOIN comparisondata.[dbo].[SplitType_tbl] slt (NOLOCK) ON slt.splitTypeId=st.splitTypeId
LEFT JOIN Estimates.[dbo].[EstimateSplitInfo_tbl] esi (NOLOCK) ON esi.companyId=csf.companyId AND esi.tradingItemId=csf.tradingItemId AND esi.exDate=csf.toDate --AND esi.announcedDate IS NOT NULL
--RIGHT JOIN CumilativeSplitFactor_tbl csf1 (NOLOCK) ON csf1.companyId=stt.companyId AND csf1.tradingItemId=st.tradingitemid AND csf1.toDate=st.exDate
--LEFT JOIN financialdata..splitmaster_tbl sm (NOLOCK) ON sm.companyId=stt.companyId AND sm.primaryExDate=st.exDate
WHERE 
st.appliedFlag IN (1)
AND stt.companyId IN (882872,552711,882672,882676,882701,882765,882765,882775)
ORDER BY stt.companyId,st.exDate DESC

IF OBJECT_ID ('TEMPDB..#FD1') IS NOT NULL DROP TABLE #FD1
SELECT CompanyId,MIN(EffectiveDate) AS Min_FD INTO #FD1 FROM [EstimateTimeliness].dbo.[EstimateTimelinessDetail_tbl]
WHERE CompanyId IN (882872,552711,882672,882676,882701,882765,882765,882775)
GROUP BY CompanyId

IF OBJECT_ID ('TEMPDB..#Final1') IS NOT NULL DROP TABLE #Final1
SELECT a.*,b.Min_FD INTO #Final1 FROM #SPLITFR a
INNER JOIN #FD b ON b.CompanyId=a.companyId


SELECT DISTINCT *,COUNT(*) OVER(PARTITION BY companyId) AS Count_of_mismatch_of_splits_C_AND_T FROM #Final-- WHERE Esti_tradingItemId IS NULL AND Esti_toDate IS NULL
ORDER BY companyId,toDate DESC

SELECT DISTINCT *,COUNT(*) OVER(PARTITION BY companyId) AS Count_of_mismatch_of_splits_C_AND_T FROM #Final1-- WHERE Esti_tradingItemId IS NULL AND Esti_toDate IS NULL
ORDER BY companyId,exDate DESC


----Count as per companyid & todate

SELECT DISTINCT companyId,tradingItemId,toDate,announcedDate,COUNT(*) OVER(PARTITION BY companyId,tradingItemId) AS Count_of_mismatch_of_splits_C_AND_T FROM #Final-- WHERE Esti_tradingItemId IS NULL AND Esti_toDate IS NULL
ORDER BY companyId,tradingItemId,toDate DESC

SELECT DISTINCT companyId,tradingItemId,exDate,Esti_announcedDate,COUNT(*) OVER(PARTITION BY companyId,tradingItemId) AS Count_of_mismatch_of_splits_C_AND_T FROM #Final1-- WHERE Esti_tradingItemId IS NULL AND Esti_toDate IS NULL
ORDER BY companyId,tradingItemId,exDate DESC
