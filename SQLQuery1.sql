USE Academy;
GO

CREATE TABLE Groups (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name != ''),
    Rating INT NOT NULL CHECK (Rating BETWEEN 0 AND 5),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5)
);
GO

CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name != '')
);
GO

CREATE TABLE Faculties (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name != '')
);
GO

CREATE TABLE Teachers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    EmploymentDate DATE NOT NULL CHECK (EmploymentDate >= '1990-01-01'),
    Name NVARCHAR(MAX) NOT NULL CHECK (Name != ''),
    Premium MONEY NOT NULL DEFAULT 0 CHECK (Premium >= 0),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname != '')
);
GO

ALTER TABLE Teachers
ADD Position NVARCHAR(50) NOT NULL DEFAULT 'Assistant' CHECK (Position IN ('Professor', 'Assistant', 'Senior Lecturer'));
GO

ALTER TABLE Faculties
ADD Dean NVARCHAR(100) NOT NULL DEFAULT 'Unknown' CHECK (Dean != '');
GO

INSERT INTO Groups (Name, Rating, Year)
VALUES ('GroupA', 4, 2),
       ('GroupB', 3, 1),
       ('GroupC', 3, 5),
       ('GroupD', 2, 5),
       ('GroupE', 4, 3);
GO

INSERT INTO Departments (Financing, Name)
VALUES (20000, 'Computer Science'),
       (30000, 'Mathematics'),
       (5000, 'Software Development'),
       (15000, 'Physics');
GO

INSERT INTO Faculties (Name, Dean)
VALUES ('Engineering', 'Dr. Smith'),
       ('Natural Sciences', 'Dr. Jones'),
       ('Computer Science', 'Dr. Taylor');
GO

INSERT INTO Teachers (EmploymentDate, Name, Premium, Salary, Surname, Position)
VALUES ('1995-03-10', 'John', 500, 3000, 'Doe', 'Professor'),
       ('2005-07-20', 'Anna', 150, 600, 'Smith', 'Assistant'),
       ('1998-11-15', 'Michael', 700, 1200, 'Brown', 'Professor'),
       ('2010-04-22', 'Sarah', 200, 500, 'Johnson', 'Assistant'),
       ('2015-06-18', 'David', 300, 800, 'Wilson', 'Senior Lecturer');
GO

SELECT Name, Financing, Id
FROM Departments;
GO

SELECT Name AS [Group Name], Rating AS [Group Rating]
FROM Groups;
GO

SELECT Surname, 
       CASE WHEN Premium = 0 THEN 0 ELSE (Salary / Premium * 100) END AS [Salary to Premium (%)],
       (Salary / (Salary + Premium) * 100) AS [Salary to Total (%)]
FROM Teachers;
GO

SELECT 'The dean of faculty ' + Name + ' is ' + Dean + '.' AS FacultyDean
FROM Faculties;
GO

SELECT Surname
FROM Teachers
WHERE Position = 'Professor' AND Salary > 1050;
GO

SELECT Name
FROM Departments
WHERE Financing < 11000 OR Financing > 25000;
GO

SELECT Name
FROM Faculties
WHERE Name != 'Computer Science';
GO

SELECT Surname, Position
FROM Teachers
WHERE Position != 'Professor';
GO

SELECT Surname, Position, Salary, Premium
FROM Teachers
WHERE Position = 'Assistant' AND Premium BETWEEN 160 AND 550;
GO

SELECT Surname, Salary
FROM Teachers
WHERE Position = 'Assistant';
GO

SELECT Surname, Position
FROM Teachers
WHERE EmploymentDate < '2000-01-01';
GO

SELECT Name AS [Name of Department]
FROM Departments
WHERE Name < 'Software Development'
ORDER BY Name;
GO

SELECT Surname
FROM Teachers
WHERE Position = 'Assistant' AND (Salary + Premium) <= 1200;
GO

SELECT Name
FROM Groups
WHERE Year = 5 AND Rating BETWEEN 2 AND 4;
GO

SELECT Surname
FROM Teachers
WHERE Position = 'Assistant' AND (Salary < 550 OR Premium < 200);
GO

INSERT INTO Teachers (EmploymentDate, Name, Premium, Salary, Surname, Position)
VALUES ('2023-01-10', 'Emma', 400, 900, 'Davis', 'Assistant');
GO

UPDATE Groups
SET Rating = 5
WHERE Name = 'GroupA';
GO

DELETE FROM Faculties
WHERE Name = 'Natural Sciences';
GO