USE CompAccInc_OLTPTeamBryan;

BULK INSERT Regions
-- Replace the path with the appropriate path
FROM 'C:\Users\ryany\OneDrive\Desktop\SP Y2S1\DENG\CA2\OLTP\DataSourceInsert\Regions\Regions.txt'
WITH
(
FIRSTROW = 2,
FIELDTERMINATOR= '\t\t',
ROWTERMINATOR = '\n'
)