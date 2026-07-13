-- Databricks notebook source
select * from `brightlearn`.`bright_tv`.`bright_tv_dataset` limit 100;
select distinct gender from `brightlearn`.`bright_tv`.`bright_tv_dataset`;
select distinct race from `brightlearn`.`bright_tv`.`bright_tv_dataset`;
select distinct Province from `brightlearn`.`bright_tv`.`bright_tv_dataset`;
Select MIN(Age) AS Youngest, MAX(Age) AS Oldest, ROUND(AVG(Age),2) AS Average_Age from `brightlearn`.`bright_tv`.`bright_tv_dataset`;
SELECT UserID, COUNT(*) AS duplicate_count FROM `brightlearn`.`bright_tv`.`bright_tv_dataset` GROUP BY UserID HAVING COUNT(*) > 1;
SELECT COUNT(*) from `brightlearn`.`bright_tv`.`bright_tv_dataset`;
SELECT COUNT(DISTINCT UserID) from `brightlearn`.`bright_tv`.`bright_tv_dataset`;
SELECT MIN(RecordDate2), MAX(RecordDate2) from `brightlearn`.`bright_tv`.`viewership`;
SELECT COUNT(*) from `brightlearn`.`bright_tv`.`viewership` WHERE UserID0 IS NULL AND userid4 IS NULL;
SELECT DISTINCT Channel2 FROM `brightlearn`.`bright_tv`.`viewership`;
SELECT COUNT(*) FROM brightlearn.bright_tv.bright_tv_dataset WHERE Age IS NULL;
SELECT COUNT(*) FROM brightlearn.bright_tv.bright_tv_dataset WHERE Gender IS NULL;
SELECT UserID0, RecordDate2, COUNT(*) AS duplicate_count FROM `brightlearn`.`bright_tv`.`viewership` GROUP BY UserID0, RecordDate2
HAVING COUNT(*) > 1;
SELECT COUNT(*) AS missing_channels FROM `brightlearn`.`bright_tv`.`viewership`
WHERE Channel2 IS NULL;



CREATE OR REPLACE TEMP VIEW user_profiles AS

SELECT

UserID,

CASE
    WHEN Province IS NULL THEN 'Uncategorized'
    WHEN Province IN ('','None','other') THEN 'Uncategorized'
    ELSE Province
END AS Region,

Age,

CASE
    WHEN Age = 0 THEN 'Infants'
    WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
    WHEN Age BETWEEN 13 AND 19 THEN 'Teenager'
    WHEN Age BETWEEN 20 AND 35 THEN 'Youth'
    WHEN Age BETWEEN 36 AND 50 THEN 'Adult'
    WHEN Age BETWEEN 51 AND 65 THEN 'Elder'
    ELSE 'Pensioner'
END AS Age_Group,

CASE
    WHEN Email IS NOT NULL
         AND Email <> ''
         AND Email <> 'None'
    THEN 1
    ELSE 0
END AS Email_Flag,

CASE
    WHEN `Social Media Handle` IS NOT NULL
         AND `Social Media Handle` <> ''
         AND `Social Media Handle` <> 'None'
    THEN 1
    ELSE 0
END AS SocialMedia_Flag,

CASE
    WHEN Race IN ('','None','other') THEN 'Unknown'
    ELSE Race
END AS Race,

CASE
    WHEN Gender IN ('','None') THEN 'Unknown'
    ELSE Gender
END AS Gender

FROM `brightlearn`.`bright_tv`.`bright_tv_dataset`;



CREATE OR REPLACE TEMP VIEW viewership AS

SELECT

COALESCE(UserID0, userid4) AS UserID,

date_format(RecordDate2,'yyyyMM') AS Month_ID,

to_date(RecordDate2) AS Watch_Date,

dayname(RecordDate2) AS Day_Name,

CASE
    WHEN dayname(RecordDate2) IN ('Sat','Sun')
    THEN 'Weekend'
    ELSE 'Weekday'
END AS Day_Type,

monthname(RecordDate2) AS Month_Name,

CASE

WHEN Channel2 IN ('SawSee','Sawsee')
THEN 'SawSee'

WHEN Channel2 IN
(
'SuperSport Live Events',
'Supersport Live Events',
'Live on SuperSport',
'DStv Events 1'
)
THEN 'Live Events'

ELSE Channel2

END AS TV_Channel,

date_format(RecordDate2,'HH:mm:ss') AS Watch_Time,

CASE

WHEN date_format(RecordDate2,'HH:mm:ss')
BETWEEN '00:00:00' AND '05:59:59'
THEN 'Midnight'

WHEN date_format(RecordDate2,'HH:mm:ss')
BETWEEN '06:00:00' AND '11:59:59'
THEN 'Morning'

WHEN date_format(RecordDate2,'HH:mm:ss')
BETWEEN '12:00:00' AND '16:59:59'
THEN 'Afternoon'

ELSE 'Evening'

END AS Time_Of_Day,

`Duration 2` AS Duration,

hour(RecordDate2) AS Hour_Of_Day

FROM `brightlearn`.`bright_tv`.`viewership`;


SELECT

COALESCE(v.UserID, u.UserID) AS Subscriber_ID,

v.Month_ID,

v.Watch_Date,

v.Day_Name,

v.Day_Type,

v.Month_Name,

v.TV_Channel,

v.Watch_Time,

v.Time_Of_Day,

v.Hour_Of_Day,

v.Duration,

u.Region,

u.Age_Group,

u.Email_Flag,

u.SocialMedia_Flag,

u.Race,

u.Gender

FROM viewership v

LEFT JOIN user_profiles u

ON v.UserID = u.UserID;
