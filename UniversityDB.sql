CREATE DATABASE UniversityDB;
GO

USE UniversityDB;
GO

CREATE TABLE Faculties (
    Id INT PRIMARY KEY IDENTITY(1,1),
    FacultyName NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE Groups (
    Id INT PRIMARY KEY IDENTITY(1,1),
    GroupName NVARCHAR(50) NOT NULL,
    FacultyId INT NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
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

CREATE TABLE Subjects (
    Id INT PRIMARY KEY IDENTITY(1,1),
    SubjectName NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE Teachers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    LastName NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL
);
GO

CREATE TABLE TeachersSubjects (
    TeacherId INT NOT NULL,
    SubjectId INT NOT NULL,
    PRIMARY KEY (TeacherId, SubjectId),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id),
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id)
);
GO

CREATE TABLE Achievements (
    Id INT PRIMARY KEY IDENTITY(1,1),
    StudentId INT NOT NULL,
    SubjectId INT NOT NULL,
    Assessment INT NOT NULL,
    FOREIGN KEY (StudentId) REFERENCES Students(Id),
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id)
);
GO

INSERT INTO Faculties (FacultyName) VALUES
('Computer Science'),
('Mathematics');
GO

INSERT INTO Groups (GroupName, FacultyId) VALUES
('CS-101', 1),
('CS-102', 1),
('Math-201', 2),
('Math-202', 2);
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
('Martinez', 'Mia', '1999-02-14', 1100.00, 4),
('Hernandez', 'Ethan', '2000-08-20', 1300.00, 4),
('Lopez', 'Ava', '2001-10-10', 1150.00, 4);
GO

INSERT INTO Subjects (SubjectName) VALUES
('Database Systems'),
('Algorithms'),
('Linear Algebra'),
('Calculus'),
('Statistics');
GO

INSERT INTO Teachers (LastName, FirstName) VALUES
('Wilson', 'Michael'),
('Taylor', 'Sarah'),
('Clark', 'David');
GO

INSERT INTO TeachersSubjects (TeacherId, SubjectId) VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 2),
(3, 5);
GO

INSERT INTO Achievements (StudentId, SubjectId, Assessment) VALUES
(1, 1, 8),
(1, 2, 9),
(2, 1, 10),
(2, 2, 7),
(3, 1, 6),
(4, 2, 8),
(5, 1, 9),
(6, 2, 10),
(7, 3, 7),
(7, 4, 8),
(8, 3, 9),
(8, 4, 10),
(9, 3, 6),
(10, 4, 8),
(11, 4, 9),
(11, 5, 7),
(12, 5, 8),
(12, 3, 9),
(1, 3, 10),
(2, 4, 8);
GO

SELECT f.FacultyName, COUNT(s.Id) AS StudentCount
FROM Faculties f
LEFT JOIN Groups g ON f.Id = g.FacultyId
LEFT JOIN Students s ON g.Id = s.GroupId
GROUP BY f.FacultyName;

SELECT AVG(Assessment) AS AverageAssessment
FROM Achievements;

SELECT SUM(Grants) AS TotalGrants
FROM Students
WHERE Grants IS NOT NULL;

SELECT MIN(BirthDate) AS OldestTeacher
FROM Teachers;

SELECT MAX(BirthDate) AS YoungestStudent
FROM Students;

SELECT COUNT(DISTINCT Assessment) AS UniqueAssessments
FROM Achievements;

SELECT f.FacultyName, g.GroupName, COUNT(s.Id) AS StudentCount
FROM Faculties f
JOIN Groups g ON f.Id = g.FacultyId
LEFT JOIN Students s ON g.Id = s.GroupId
GROUP BY f.FacultyName, g.GroupName;

SELECT sub.SubjectName, AVG(a.Assessment) AS AverageAssessment
FROM Subjects sub
LEFT JOIN Achievements a ON sub.Id = a.SubjectId
GROUP BY sub.SubjectName;

SELECT g.GroupName, MAX(s.Grants) AS MaxGrant
FROM Groups g
LEFT JOIN Students s ON g.Id = s.GroupId
GROUP BY g.GroupName;

SELECT t.LastName, t.FirstName, COUNT(ts.SubjectId) AS SubjectCount
FROM Teachers t
LEFT JOIN TeachersSubjects ts ON t.Id = ts.TeacherId
GROUP BY t.Id, t.LastName, t.FirstName;

SELECT f.FacultyName, COUNT(s.Id) AS StudentCount
FROM Faculties f
JOIN Groups g ON f.Id = g.FacultyId
JOIN Students s ON g.Id = s.GroupId
GROUP BY f.FacultyName
HAVING COUNT(s.Id) > 5;

SELECT sub.SubjectName, AVG(a.Assessment) AS AverageAssessment
FROM Subjects sub
JOIN Achievements a ON sub.Id = a.SubjectId
GROUP BY sub.SubjectName
HAVING AVG(a.Assessment) > 8;

SELECT t.LastName, t.FirstName, COUNT(ts.SubjectId) AS SubjectCount
FROM Teachers t
JOIN TeachersSubjects ts ON t.Id = ts.TeacherId
GROUP BY t.Id, t.LastName, t.FirstName
HAVING COUNT(ts.SubjectId) > 1;

SELECT g.GroupName, AVG(s.Grants) AS AverageGrant
FROM Groups g
JOIN Students s ON g.Id = s.GroupId
WHERE s.Grants IS NOT NULL
GROUP BY g.GroupName
HAVING AVG(s.Grants) > 1100;


SELECT s.LastName, s.FirstName, s.Grants, f.FacultyName
FROM Students s
JOIN Groups g ON s.GroupId = g.Id
JOIN Faculties f ON g.FacultyId = f.Id
WHERE s.Grants = (
    SELECT MAX(s2.Grants)
    FROM Students s2
    JOIN Groups g2 ON s2.GroupId = g2.Id
    WHERE g2.FacultyId = f.Id
);

SELECT DISTINCT t.LastName, t.FirstName
FROM Teachers t
JOIN TeachersSubjects ts ON t.Id = ts.TeacherId
JOIN Achievements a ON ts.SubjectId = a.SubjectId
WHERE ts.SubjectId IN (
    SELECT a2.SubjectId
    FROM Achievements a2
    GROUP BY a2.SubjectId
    HAVING AVG(a2.Assessment) > 7
);

SELECT DISTINCT g.GroupName
FROM Groups g
JOIN Students s ON g.Id = s.GroupId
JOIN Achievements a ON s.Id = a.StudentId
WHERE a.Assessment = (
    SELECT MAX(a2.Assessment)
    FROM Achievements a2
    WHERE a2.SubjectId = a.SubjectId
);

SELECT s.LastName, s.FirstName
FROM Students s
WHERE NOT EXISTS (
    SELECT ts.SubjectId
    FROM TeachersSubjects ts
    WHERE ts.TeacherId = 1
    AND NOT EXISTS (
        SELECT a.SubjectId
        FROM Achievements a
        WHERE a.StudentId = s.Id
        AND a.SubjectId = ts.SubjectId
    )
);

SELECT f.FacultyName
FROM Faculties f
JOIN Groups g ON f.Id = g.FacultyId
JOIN Students s ON g.Id = s.GroupId
GROUP BY f.FacultyName
HAVING AVG(DATEDIFF(YEAR, s.BirthDate, GETDATE())) < (
    SELECT AVG(DATEDIFF(YEAR, BirthDate, GETDATE()))
    FROM Students
);

SELECT sub.SubjectName
FROM Subjects sub
JOIN Achievements a ON sub.Id = a.SubjectId
JOIN Students s ON a.StudentId = s.Id
JOIN Groups g ON s.GroupId = g.Id
JOIN Faculties f ON g.FacultyId = f.Id
WHERE f.FacultyName = 'Computer Science'
AND sub.Id NOT IN (
    SELECT a2.SubjectId
    FROM Achievements a2
    JOIN Students s2 ON a2.StudentId = s2.Id
    JOIN Groups g2 ON s2.GroupId = g2.Id
    JOIN Faculties f2 ON g2.FacultyId = f2.Id
    WHERE f2.FacultyName != 'Computer Science'
);

SELECT DISTINCT t.LastName, t.FirstName
FROM Teachers t
JOIN TeachersSubjects ts ON t.Id = ts.TeacherId
JOIN Achievements a ON ts.SubjectId = a.SubjectId
JOIN Students s ON a.StudentId = s.Id
WHERE s.Grants IS NULL;

SELECT s.LastName, s.FirstName
FROM Students s
WHERE (
    SELECT AVG(a.Assessment)
    FROM Achievements a
    WHERE a.StudentId = s.Id
) > (
    SELECT AVG(Assessment)
    FROM Achievements
);

