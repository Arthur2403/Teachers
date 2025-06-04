CREATE DATABASE Academy;
GO

USE Academy;
GO

CREATE TABLE Curators (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL CHECK (Name != ''),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname != '')
);
GO

CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name != ''),
    FacultyId INT NOT NULL
);
GO

CREATE TABLE Faculties (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Financing MONEY NOT NULL DEFAULT 0 CHECK (Financing >= 0),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name != '')
);
GO

CREATE TABLE Groups (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(10) NOT NULL UNIQUE CHECK (Name != ''),
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL
);
GO

CREATE TABLE GroupsCurators (
    Id INT PRIMARY KEY IDENTITY(1,1),
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL,
    FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);
GO

CREATE TABLE GroupsLectures (
    Id INT PRIMARY KEY IDENTITY(1,1),
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);
GO

CREATE TABLE Lectures (
    Id INT PRIMARY KEY IDENTITY(1,1),
    LectureRoom NVARCHAR(MAX) NOT NULL CHECK (LectureRoom != ''),
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);
GO

CREATE TABLE Subjects (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name != '')
);
GO

CREATE TABLE Teachers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(MAX) NOT NULL CHECK (Name != ''),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname != ''),
    Position NVARCHAR(50) NOT NULL DEFAULT 'Assistant' CHECK (Position IN ('Professor', 'Assistant', 'Senior Lecturer'))
);
GO

INSERT INTO Curators (Name, Surname)
VALUES ('Ivan', 'Petrov'),
       ('Maria', 'Ivanova');
GO

INSERT INTO Departments (Financing, Name, FacultyId)
VALUES (20000, 'Computer Science', 1),
       (30000, 'Mathematics', 2),
       (5000, 'Software Development', 1),
       (15000, 'Physics', 2);
GO

INSERT INTO Faculties (Financing, Name)
VALUES (10000, 'Engineering'),
       (12000, 'Natural Sciences'),
       (8000, 'Computer Science');
GO

INSERT INTO Groups (Name, Year, DepartmentId)
VALUES ('GroupA', 2, 1),
       ('GroupB', 1, 2),
       ('GroupC', 5, 1),
       ('GroupD', 5, 2),
       ('GroupE', 3, 1),
       ('P107', 3, 1);
GO

INSERT INTO GroupsCurators (CuratorId, GroupId)
VALUES (1, 1),
       (2, 2);
GO

INSERT INTO GroupsLectures (GroupId, LectureId)
VALUES ((SELECT Id FROM Groups WHERE Name = 'GroupA'), (SELECT Id FROM Lectures WHERE LectureRoom = 'B103' AND SubjectId = (SELECT Id FROM Subjects WHERE Name = 'Database Theory') AND TeacherId = (SELECT Id FROM Teachers WHERE Surname = 'Doe'))),
       ((SELECT Id FROM Groups WHERE Name = 'GroupB'), (SELECT Id FROM Lectures WHERE LectureRoom = 'A201' AND SubjectId = (SELECT Id FROM Subjects WHERE Name = 'Programming') AND TeacherId = (SELECT Id FROM Teachers WHERE Surname = 'Smith'))),
       ((SELECT Id FROM Groups WHERE Name = 'GroupA'), (SELECT Id FROM Lectures WHERE LectureRoom = 'B103' AND SubjectId = (SELECT Id FROM Subjects WHERE Name = 'Mathematics') AND TeacherId = (SELECT Id FROM Teachers WHERE Surname = 'Brown')));
GO

INSERT INTO Lectures (LectureRoom, SubjectId, TeacherId)
VALUES ('B103', (SELECT Id FROM Subjects WHERE Name = 'Database Theory'), (SELECT Id FROM Teachers WHERE Surname = 'Doe')),
       ('A201', (SELECT Id FROM Subjects WHERE Name = 'Programming'), (SELECT Id FROM Teachers WHERE Surname = 'Smith')),
       ('B103', (SELECT Id FROM Subjects WHERE Name = 'Mathematics'), (SELECT Id FROM Teachers WHERE Surname = 'Brown'));
GO

INSERT INTO Subjects (Name)
VALUES ('Database Theory'),
       ('Programming'),
       ('Mathematics');
GO

INSERT INTO Teachers (Name, Salary, Surname, Position)
VALUES ('John', 3000, 'Doe', 'Professor'),
       ('Anna', 600, 'Smith', 'Assistant'),
       ('Michael', 1200, 'Brown', 'Professor'),
       ('Sarah', 500, 'Johnson', 'Assistant'),
       ('David', 800, 'Wilson', 'Senior Lecturer'),
       ('Samantha', 1000, 'Adams', 'Assistant');
GO

SELECT t.Surname AS TeacherSurname, g.Name AS GroupName
FROM Teachers t
CROSS JOIN Groups g;
GO

SELECT f.Name
FROM Faculties f
WHERE f.Financing < (SELECT SUM(d.Financing) 
                     FROM Departments d 
                     WHERE d.FacultyId = f.Id);
GO

SELECT c.Surname AS CuratorSurname, g.Name AS GroupName
FROM Curators c
JOIN GroupsCurators gc ON c.Id = gc.CuratorId
JOIN Groups g ON gc.GroupId = g.Id;
GO

SELECT DISTINCT t.Surname
FROM Teachers t
JOIN Lectures l ON t.Id = l.TeacherId
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
WHERE g.Name = 'P107';
GO

SELECT DISTINCT t.Surname, f.Name AS FacultyName
FROM Teachers t
JOIN Lectures l ON t.Id = l.TeacherId
JOIN Subjects s ON l.SubjectId = s.Id
JOIN Groups g ON EXISTS (SELECT 1 FROM GroupsLectures gl WHERE gl.LectureId = l.Id AND gl.GroupId = g.Id)
JOIN Departments d ON g.DepartmentId = d.Id
JOIN Faculties f ON d.FacultyId = f.Id;
GO

SELECT d.Name AS DepartmentName, g.Name AS GroupName
FROM Departments d
JOIN Groups g ON d.Id = g.DepartmentId;
GO

SELECT s.Name
FROM Subjects s
JOIN Lectures l ON s.Id = l.SubjectId
JOIN Teachers t ON l.TeacherId = t.Id
WHERE t.Surname = 'Adams';
GO

SELECT DISTINCT d.Name AS DepartmentName
FROM Departments d
JOIN Groups g ON d.Id = g.DepartmentId
JOIN GroupsLectures gl ON g.Id = gl.GroupId
JOIN Lectures l ON gl.LectureId = l.Id
JOIN Subjects s ON l.SubjectId = s.Id
WHERE s.Name = 'Database Theory';
GO

SELECT g.Name
FROM Groups g
JOIN Departments d ON g.DepartmentId = d.Id
JOIN Faculties f ON d.FacultyId = f.Id
WHERE f.Name = 'Computer Science';
GO

SELECT g.Name AS GroupName, f.Name AS FacultyName
FROM Groups g
JOIN Departments d ON g.DepartmentId = d.Id
JOIN Faculties f ON d.FacultyId = f.Id
WHERE g.Year = 5;
GO

SELECT t.Surname, s.Name AS SubjectName, g.Name AS GroupName
FROM Teachers t
JOIN Lectures l ON t.Id = l.TeacherId
JOIN Subjects s ON l.SubjectId = s.Id
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
WHERE l.LectureRoom = 'B103';
GO