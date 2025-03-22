-- Step 0: Drop Database and Tables if They Exist
DROP DATABASE IF EXISTS NetflixOriginalsDB;
CREATE DATABASE NetflixOriginalsDB;
USE NetflixOriginalsDB;

-- Step 2: Create Tables
DROP TABLE IF EXISTS Netflix_Originals_Cleaned;
CREATE TABLE Netflix_Originals_Cleaned (
    Title VARCHAR(255),
    GenreID VARCHAR(10),
    Runtime INT,
    IMDBScore FLOAT,
    Language VARCHAR(50),
    Premiere_Date DATE
);

DROP TABLE IF EXISTS Genre_Details;
CREATE TABLE Genre_Details (
    GenreID VARCHAR(10),
    Genre VARCHAR(50)
);

-- Step 3: Import Datasets
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Netflix_Originals_Cleaned.csv'
INTO TABLE Netflix_Originals_Cleaned
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Genre_Details.csv'
INTO TABLE Genre_Details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Step 4: Verify Data
SELECT * FROM Netflix_Originals_Cleaned LIMIT 10;
SELECT * FROM Genre_Details LIMIT 10;

-- Step 5: Analysis Queries

-- 1. Average IMDb Scores by Genre
SELECT g.Genre, AVG(n.IMDBScore) AS AvgIMDBScore
FROM Netflix_Originals_Cleaned n
JOIN Genre_Details g ON n.GenreID = g.GenreID
GROUP BY g.Genre
ORDER BY AvgIMDBScore DESC;

-- 2. Genres with Average IMDb Score > 7.5
SELECT g.Genre, AVG(n.IMDBScore) AS AvgIMDBScore
FROM Netflix_Originals_Cleaned n
JOIN Genre_Details g ON n.GenreID = g.GenreID
GROUP BY g.Genre
HAVING AvgIMDBScore > 7.5
ORDER BY AvgIMDBScore DESC;

-- 3. Titles by IMDb Score (Descending Order)
SELECT Title, IMDBScore
FROM Netflix_Originals_Cleaned
ORDER BY IMDBScore DESC;

-- 4. Top 10 Longest Netflix Originals by Runtime
SELECT Title, Runtime
FROM Netflix_Originals_Cleaned
ORDER BY Runtime DESC
LIMIT 10;

-- 5. Titles with Genres
SELECT n.Title, g.Genre
FROM Netflix_Originals_Cleaned n
JOIN Genre_Details g ON n.GenreID = g.GenreID;

-- 6. Rank Titles by IMDb Score Within Each Genre
SELECT n.Title, g.Genre, n.IMDBScore,
       RANK() OVER (PARTITION BY g.Genre ORDER BY n.IMDBScore DESC) AS RankInGenre
FROM Netflix_Originals_Cleaned n
JOIN Genre_Details g ON n.GenreID = g.GenreID;

-- 7. Titles with IMDb Scores Above Average
SELECT Title, IMDBScore
FROM Netflix_Originals_Cleaned
WHERE IMDBScore > (SELECT AVG(IMDBScore) FROM Netflix_Originals_Cleaned)
ORDER BY IMDBScore DESC;

-- 8. Number of Originals per Genre
SELECT g.Genre, COUNT(n.Title) AS NumberOfOriginals
FROM Netflix_Originals_Cleaned n
JOIN Genre_Details g ON n.GenreID = g.GenreID
GROUP BY g.Genre
ORDER BY NumberOfOriginals DESC;

-- 9. Genres with More Than 5 Originals Scoring Above 8
SELECT g.Genre, COUNT(n.Title) AS NumberOfOriginals
FROM Netflix_Originals_Cleaned n
JOIN Genre_Details g ON n.GenreID = g.GenreID
WHERE n.IMDBScore > 8
GROUP BY g.Genre
HAVING NumberOfOriginals > 5
ORDER BY NumberOfOriginals DESC;

-- 10. Top 3 Genres by Average IMDb Score
WITH GenreAvgScores AS (
    SELECT g.Genre, AVG(n.IMDBScore) AS AvgIMDBScore, COUNT(n.Title) AS NumberOfOriginals
    FROM Netflix_Originals_Cleaned n
    JOIN Genre_Details g ON n.GenreID = g.GenreID
    GROUP BY g.Genre
)
SELECT Genre, AvgIMDBScore, NumberOfOriginals
FROM GenreAvgScores
ORDER BY AvgIMDBScore DESC
LIMIT 3;

