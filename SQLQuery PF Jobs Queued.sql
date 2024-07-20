--PYTHON,SQL,AZURE DATA FACTORY AND POWER BI ETL DEVELOPER --> GNANESHWAR SRAVANE
USE Pathfinder
DECLARE @frDate DATETIME, @toDate DATETIME 
--SET @frDate = '2019-11-01 06:00:00.000' -- Give From Date here 
--SET @toDate = '2019-11-10 23:59:00.000'-- Give To Date here
IF OBJECT_ID ('TEMPDB..#Pathfinder') IS NOT NULL DROP TABLE #Pathfinder
SELECT DISTINCT P.KEYPERSON,P.SPGMIEIN, P.LOGINNAME,IPS.KEYPROCESSSTREAM,IPS.STREAMNAME , IPI.PROCESSINSTANCEAPPIANID ,TASKINSTANCEBEGUN=TI.TASKINSTANCEBEGUN + '5:30',
TASKINSTANCECOMPLETED=TI.TASKINSTANCECOMPLETED + '5:30',TI.TASKINSTANCEEFFORT,TI.EXPECTEDTASKEFFORT,IPI.PROCESSWORKUNITS,TI.SNLANALYSTTASKENTRY,
PN.INTERNALNOTES,PDV.FIELDIDENTIFIER,PDV.PROCESSFIELDVALUE,ipi.ProcessInstanceDescription INTO #Pathfinder FROM PROCESSINSTANCE IPI
INNER JOIN PROCESSSTREAM IPS (NOLOCK) ON IPI.KEYPROCESSSTREAM = IPS.KEYPROCESSSTREAM AND IPS.UPDOPERATION < 2
INNER JOIN DBO.PROCESSSTREAMGROUP PG (NOLOCK) ON PG.KEYPROCESSSTREAM=IPS.KEYPROCESSSTREAM
JOIN TASKINSTANCE TI (NOLOCK) ON IPI.KEYPROCESSINSTANCE = TI.KEYPROCESSINSTANCE AND  TI.UPDOPERATION < 2
JOIN DBO.PROCESSDATAVALUE PDV (NOLOCK) ON PDV.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE
LEFT JOIN DBO.PROCESSNOTES PN (NOLOCK) ON PN.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE
LEFT JOIN InternalUseOnly.DBO.EMPLOYEE P (NOLOCK) ON TI.KEYPERSON = P.KEYPERSON
WHERE IPI.UPDOPERATION < 2
AND IPS.KEYPROCESSSTREAM IN (46486,52344,52345,52346,56853,56854,56855,56856)
AND TASKINSTANCECOMPLETED BETWEEN GETDATE()-360 AND GETDATE()  



IF OBJECT_ID ('TEMPDB..#queued') IS NOT NULL DROP TABLE #queued
SELECT DISTINCT P.KEYPERSON,P.SPGMIEIN, P.LOGINNAME,IPS.KEYPROCESSSTREAM,IPS.STREAMNAME , IPI.PROCESSINSTANCEAPPIANID ,IPI.PROCESSWORKUNITS,
PN.INTERNALNOTES,PDV.FIELDIDENTIFIER,PDV.PROCESSFIELDVALUE,ipi.ProcessInstanceDescription INTO #queued  FROM PROCESSINSTANCE IPI
INNER JOIN PROCESSSTREAM IPS (NOLOCK) ON IPI.KEYPROCESSSTREAM = IPS.KEYPROCESSSTREAM AND IPS.UPDOPERATION < 2
--INNER JOIN DBO.PROCESSSTREAMGROUP PG (NOLOCK) ON PG.KEYPROCESSSTREAM=IPS.KEYPROCESSSTREAM
--JOIN TASKINSTANCE TI (NOLOCK) ON IPI.KEYPROCESSINSTANCE = TI.KEYPROCESSINSTANCE 
JOIN DBO.PROCESSDATAVALUE PDV (NOLOCK) ON PDV.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE
LEFT JOIN DBO.PROCESSNOTES PN (NOLOCK) ON PN.KEYPROCESSINSTANCE=IPI.KEYPROCESSINSTANCE
LEFT JOIN InternalUseOnly.DBO.EMPLOYEE P (NOLOCK) ON IPS.KeyProcessOwner = P.KEYPERSON
WHERE IPI.UPDOPERATION < 2 
AND IPI.ProcessInstanceCompleted IS NULL
AND IPS.KEYPROCESSSTREAM IN (46486,52344,52345,52346,56853,56854,56855,56856)


IF OBJECT_ID ('TEMPDB..#queued2') IS NOT NULL DROP TABLE #queued2
SELECT DISTINCT * INTO #queued2 FROM (SELECT KEYPERSON, LOGINNAME,KEYPROCESSSTREAM,STREAMNAME,PROCESSINSTANCEAPPIANID ,
FIELDIDENTIFIER,ProcessInstanceDescription,CAST(PROCESSFIELDVALUE AS VARCHAR(MAX)) PROCESSFIELDVALUE FROM #queued)
AS pathSOURCE
PIVOT
( MAX (PROCESSFIELDVALUE) FOR FIELDIDENTIFIER IN ([emailSubject],[emailBody],[Comment],[Source]))
AS pathPIVOT

IF OBJECT_ID ('TEMPDB..#queued3') IS NOT NULL DROP TABLE #queued3
SELECT DISTINCT a.ProcessInstanceAppianID,pfj.ProcessInstanceTargetDate AS goaldate,a.StreamName,emailSubject,a.ProcessInstanceDescription AS additionalinformation, 
Comment, 'Type'='queud' INTO #queued3 FROM #queued2 a
LEFT JOIN PFJobs PFJ (NOLOCK) ON PFJ.KeyProcessStream = a.KeyProcessStream AND PFJ.ProcessInstanceAppianID = a.ProcessInstanceAppianID
ORDER BY pfj.ProcessInstanceTargetDate DESC

---SELECT * FROM #queued3

IF OBJECT_ID ('TEMPDB..#queued4') IS NOT NULL DROP TABLE #queued4
SELECT
    emailSubject,
	goaldate,
	StreamName,
	ProcessInstanceAppianID,
    CASE
        WHEN emailSubject LIKE 'Translated Version Available For : VID#%' THEN
            CASE 
                WHEN CHARINDEX(' of CID#', emailSubject) > CHARINDEX(':', emailSubject) THEN
                    SUBSTRING(emailSubject, CHARINDEX(':', emailSubject) + 6, CHARINDEX(' of CID#', emailSubject) - CHARINDEX(':', emailSubject) - 6)
                ELSE 'Unknown'
            END
        WHEN emailSubject LIKE 'Got Error Out By Estimates Translation Service Version ID#%</br>%' THEN
            CASE
                WHEN CHARINDEX('-', emailSubject) < CHARINDEX(' CID', emailSubject) THEN
                    SUBSTRING(emailSubject, CHARINDEX('-', emailSubject) + 1, CHARINDEX(' CID', emailSubject) - CHARINDEX('-', emailSubject) - 1)
                ELSE 'Unknown'
            END
        WHEN emailSubject LIKE 'VID %CID%' THEN
            CASE
                WHEN CHARINDEX(' CID', emailSubject) > CHARINDEX('VID ', emailSubject) THEN
                    SUBSTRING(emailSubject, CHARINDEX('VID ', emailSubject) + 4, CHARINDEX(' CID', emailSubject) - CHARINDEX('VID ', emailSubject) - 4)
                ELSE 'Unknown'
            END
        WHEN emailSubject LIKE 'Translation required for%' THEN
            CASE
                WHEN CHARINDEX('_', emailSubject, CHARINDEX('for_', emailSubject) + 4) > CHARINDEX('for_', emailSubject) THEN
                    SUBSTRING(emailSubject, CHARINDEX('for_', emailSubject) + 4, CHARINDEX('_', emailSubject, CHARINDEX('for_', emailSubject) + 4) - CHARINDEX('for_', emailSubject) - 4)
                ELSE 'Unknown'
            END
        ELSE 'Unknown'
    END AS VID,
    
    CASE
        WHEN emailSubject LIKE '% of CID# %' THEN
            SUBSTRING(emailSubject, CHARINDEX(' of CID# ', emailSubject) + 9, 1000)
        WHEN emailSubject LIKE '%CID %' AND emailSubject NOT LIKE '%CID#%' AND emailSubject NOT LIKE '%</br>%' THEN
            SUBSTRING(emailSubject, CHARINDEX('CID ', emailSubject) + 4, 1000)
        WHEN emailSubject LIKE '%CID# %' THEN
            SUBSTRING(emailSubject, CHARINDEX('CID# ', emailSubject) + 5, 1000)
		WHEN emailSubject LIKE '% of CID# </br>%' THEN
			SUBSTRING(emailSubject, CHARINDEX('</br>', emailSubject) + 5, LEN(emailSubject) - CHARINDEX('</br>', emailSubject) - 4)
        WHEN emailSubject LIKE '%</br>%CID%' THEN
            CASE
                WHEN CHARINDEX('CID', emailSubject, CHARINDEX('</br>', emailSubject)) + 4 < LEN(emailSubject) THEN
                    SUBSTRING(emailSubject, CHARINDEX('CID', emailSubject, CHARINDEX('</br>', emailSubject)) + 4, 1000)
                ELSE 'Unknown'
            END
        WHEN emailSubject LIKE 'Translation required for%' THEN
            CASE
                WHEN CHARINDEX('_', emailSubject, CHARINDEX('for_', emailSubject) + 4) < CHARINDEX('_Korean', emailSubject) THEN
                    SUBSTRING(emailSubject, CHARINDEX('_', emailSubject, CHARINDEX('for_', emailSubject) + 4) + 1, CHARINDEX('_Korean', emailSubject) - CHARINDEX('_', emailSubject, CHARINDEX('for_', emailSubject) + 4) - 1)
                ELSE 'Unknown'
            END
        ELSE 'Unknown'
    END AS CID
INTO #queued4
FROM
    #queued3


SELECT A.*,B.VID AS VERSIONID,B.CID AS COMPANYID FROM #queued3 A
LEFT JOIN #queued4 B ON A.ProcessInstanceAppianID=B.ProcessInstanceAppianID AND A.goaldate=B.goaldate
AND A.StreamName=B.StreamName AND A.emailSubject=B.emailSubject


