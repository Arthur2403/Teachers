CREATE DATABASE University;
GO

USE University;
GO

CREATE TABLE Groups (
    Id INT PRIMARY KEY IDENTITY(1,1),
    GroupName NVARCHAR(50) NOT NULL
);
GO

CREATE TABLE Students (
    Id INT PRIMARY KEY IDENTITY(1,1),
    LastName NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    Grants DECIMAL(10,2) NULL,
    GroupId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);
GO

INSERT INTO Groups (GroupName) VALUES
('30PR11'),
('31PR21'),
('32PR31');
GO

INSERT INTO Students (LastName, FirstName, BirthDate, Grants, GroupId) VALUES
('Doe', 'John', '2000-05-15', 1200.00, 1),
('Johnson', 'Emma', '1999-11-22', 1256.00, 1),
('Williams', 'James', '2001-03-10', NULL, 1),
('Brown', 'Olivia', '2000-07-18', 1100.00, 2),
('Jones', 'Liam', '1998-12-05', 1150.00, 2),
('Garcia', 'Sophia', '2002-01-30', 1000.00, 2),
('Miller', 'Noah', '1999-09-12', NULL, 3),
('Davis', 'Isabella', '2001-06-25', 1256.00, 3),
('Rodriguez', 'Lucas', '2000-04-08', 1200.00, 3),
('Martinez', 'Mia', '1999-02-14', 1100.00, 3);
GO

SELECT COUNT(*) AS TotalStudents
FROM Students;

SELECT AVG(Grants) AS AverageGrant
FROM Students
WHERE Grants IS NOT NULL;

SELECT SUM(Grants) AS TotalGrants
FROM Students
WHERE Grants IS NOT NULL;

SELECT MIN(BirthDate) AS MinBirthDate, MAX(BirthDate) AS MaxBirthDate
FROM Students;

SELECT COUNT(DISTINCT Grants) AS UniqueGrants
FROM Students
WHERE Grants IS NOT NULL;

SELECT g.GroupName, COUNT(s.Id) AS StudentCount
FROM Groups g
JOIN Students s ON g.Id = s.GroupId
GROUP BY g.GroupName;

SELECT g.GroupName, AVG(s.Grants) AS AverageGrant
FROM Groups g
JOIN Students s ON g.Id = s.GroupId
WHERE s.Grants IS NOT NULL
GROUP BY g.GroupName;

SELECT g.GroupName, MAX(s.Grants) AS MaxGrant
FROM Groups g
JOIN Students s ON g.Id = s.GroupId
WHERE s.Grants IS NOT NULL
GROUP BY g.GroupName;

SELECT g.GroupName, COUNT(s.Id) AS StudentCount
FROM Groups g
JOIN Students s ON g.Id = s.GroupId
GROUP BY g.GroupName
HAVING COUNT(s.Id) > 3;

SELECT g.GroupName, AVG(s.Grants) AS AverageGrant
FROM Groups g
JOIN Students s ON g.Id = s.GroupId
WHERE s.Grants IS NOT NULL
GROUP BY g.GroupName
HAVING AVG(s.Grants) > 1000;

SELECT s.LastName
FROM Students s
WHERE s.Grants IS NOT NULL
GROUP BY s.LastName, s.Grants
HAVING s.Grants <= 1200;

SELECT s.FirstName, s.LastName
FROM Students s
WHERE s.Grants = (SELECT MAX(Grants) FROM Students WHERE Grants IS NOT NULL);

SELECT g.GroupName
FROM Groups g
JOIN Students s ON g.Id = s.GroupId
WHERE s.Grants IS NULL;

SELECT s.FirstName, s.LastName
FROM Students s
JOIN Groups g ON s.GroupId = g.Id
WHERE g.GroupName LIKE '%11';