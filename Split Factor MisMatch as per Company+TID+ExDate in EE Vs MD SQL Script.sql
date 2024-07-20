--- PYTHON & SQL ETL DEVELOPER-GNANESHWAR SRAVANE

--SELECT * FROM financialdata..splitmaster_tbl (NOLOCK) WHERE companyid = 882872

SELECT DISTINCT * FROM comparisondata..split_tbl (NOLOCK) a
INNER JOIN comparisondata..tradingitemdetails_tbl (NOLOCK) b ON a.tradingitemid = b.tradingitemid
INNER JOIN comparisondata..security_tbl (NOLOCK) c ON b.securityid = c.securityid
WHERE c.companyid = 552711


--SELECT DISTINCT * FROM CumilativeSplitFactor_tbl WHERE companyId =552711
--SELECT DISTINCT * FROM Estimates.[dbo].[EstimateSplitInfo_tbl] WHERE companyId =552711

--SELECT * FROM comparisondata.[dbo].[SplitType_tbl]
--SELECT * FROM comparisondata..split_tbl WHERE splitTypeId IN (4)


SELECT DISTINCT * FROM Estimates.[dbo].[EstimateSplitInfo_tbl] WHERE companyId IN (882872,552711)

USE Estimates
IF OBJECT_ID ('TEMPDB..#SPLITFR') IS NOT NULL DROP TABLE #SPLITFR
SELECT DISTINCT stt.companyId,st.tradingItemId,st.exDate,st.rate as splitfactor,st.appliedFlag,csf.tradingItemId as Esti_tradingItemId,csf.toDate as Esti_toDate,slt.splitTypeId,
csf.cumilativeSplitFactor,slt.splitTypeName,csf.effectiveDate,esi.announcedDate,esi.exDate as Esti_exDate
INTO #SPLITFR FROM comparisondata..split_tbl st (NOLOCK)
INNER JOIN comparisondata..tradingitemdetails_tbl tid (NOLOCK) ON tid.tradingitemid=st.tradingitemid
INNER JOIN comparisondata..security_tbl stt (NOLOCK) ON stt.securityid=tid.securityid
LEFT JOIN Estimates.dbo.CumilativeSplitFactor_tbl csf (NOLOCK) ON csf.companyId=stt.companyId AND csf.tradingItemId=st.tradingitemid AND csf.toDate=st.exDate
LEFT JOIN comparisondata.[dbo].[SplitType_tbl] slt (NOLOCK) ON slt.splitTypeId=st.splitTypeId
LEFT JOIN Estimates.[dbo].[EstimateSplitInfo_tbl] esi (NOLOCK) ON esi.companyId=stt.companyId AND esi.tradingItemId=st.tradingItemId AND esi.exDate=st.exDate --AND esi.announcedDate IS NOT NULL

--RIGHT JOIN CumilativeSplitFactor_tbl csf1 (NOLOCK) ON csf1.companyId=stt.companyId AND csf1.tradingItemId=st.tradingitemid AND csf1.toDate=st.exDate
--LEFT JOIN financialdata..splitmaster_tbl sm (NOLOCK) ON sm.companyId=stt.companyId AND sm.primaryExDate=st.exDate
WHERE 
st.appliedFlag IN (1)
AND stt.companyId IN (882872,552711,882663,882672,882674,882676,882694,882701,882765,882765,882775,882780)
AND esi.announcedDate IS NOT NULL
ORDER BY stt.companyId,st.exDate DESC

SELECT * FROM #SPLITFR

SELECT *,COUNT(*) OVER(PARTITION BY companyId) AS Count_of_mismatch_of_splits_C_AND_T FROM #SPLITFR WHERE Esti_tradingItemId IS NULL AND Esti_toDate IS NULL
ORDER BY companyId,exDate DESC



IF OBJECT_ID ('TEMPDB..#SPLITFR1') IS NOT NULL DROP TABLE #SPLITFR1
SELECT DISTINCT esi.companyId,esi.tradingItemId,esi.exDate,st.rate as splitfactor,st.appliedFlag,csf.tradingItemId as Esti_tradingItemId,csf.toDate as Esti_toDate,slt.splitTypeId,
csf.cumilativeSplitFactor,slt.splitTypeName,csf.effectiveDate,esi.announcedDate,esi.exDate as Esti_exDate
INTO #SPLITFR1 FROM Estimates.[dbo].[EstimateSplitInfo_tbl] esi (NOLOCK)
INNER JOIN Estimates.dbo.CumilativeSplitFactor_tbl csf (NOLOCK) ON csf.companyId=esi.companyId AND csf.tradingItemId=esi.tradingitemid AND csf.toDate=esi.exDate
LEFT JOIN comparisondata..split_tbl st (NOLOCK) ON esi.companyId=csf.companyId AND esi.tradingItemId=st.tradingItemId AND esi.exDate=st.exDate --AND esi.announcedDate IS NOT NULL
LEFT JOIN comparisondata.[dbo].[SplitType_tbl] slt (NOLOCK) ON slt.splitTypeId=st.splitTypeId
INNER JOIN comparisondata..tradingitemdetails_tbl tid (NOLOCK) ON tid.tradingitemid=esi.tradingitemid
INNER JOIN comparisondata..security_tbl stt (NOLOCK) ON stt.securityid=tid.securityid

--RIGHT JOIN CumilativeSplitFactor_tbl csf1 (NOLOCK) ON csf1.companyId=stt.companyId AND csf1.tradingItemId=st.tradingitemid AND csf1.toDate=st.exDate
--LEFT JOIN financialdata..splitmaster_tbl sm (NOLOCK) ON sm.companyId=stt.companyId AND sm.primaryExDate=st.exDate
WHERE 
st.appliedFlag IN (1)
AND esi.companyId IN (882872,552711,882663,882672,882674,882676,882694,882701,882765,882765,882775,882780)
AND esi.announcedDate IS NOT NULL
ORDER BY esi.companyId,esi.exDate DESC

SELECT * FROM #SPLITFR1


SELECT * FROM comparisondata..split_tbl
