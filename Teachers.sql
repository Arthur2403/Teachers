CREATE TABLE Actions (
    Id int IDENTITY(1,1) NOT NULL,
    Name nvarchar(100) NOT NULL UNIQUE,
    CONSTRAINT PK_Actions PRIMARY KEY (Id),
    CONSTRAINT CHK_Actions_Name CHECK (Name <> '')
);

CREATE TABLE Teachers (
    Id int IDENTITY(1,1) NOT NULL,
    EmploymentDate date NOT NULL,
    Name nvarchar(max) NOT NULL,
    Salary money NOT NULL,
    Surname nvarchar(max) NOT NULL,
    CONSTRAINT PK_Teachers PRIMARY KEY (Id),
    CONSTRAINT CHK_Teachers_EmploymentDate CHECK (EmploymentDate >= '1990-01-01'),
    CONSTRAINT CHK_Teachers_Name CHECK (Name <> ''),
    CONSTRAINT CHK_Teachers_Salary CHECK (Salary > 0),
    CONSTRAINT CHK_Teachers_Surname CHECK (Surname <> '')
);

CREATE TABLE TeacherManipulations (
    Id int IDENTITY(1,1) NOT NULL,
    Date date NOT NULL,
    ActionId int NOT NULL,
    TeacherId int NOT NULL,
    CONSTRAINT PK_TeacherManipulations PRIMARY KEY (Id),
    CONSTRAINT CHK_TeacherManipulations_Date CHECK (Date <= GETDATE()),
    CONSTRAINT FK_TeacherManipulations_Actions FOREIGN KEY (ActionId) REFERENCES Actions(Id),
    CONSTRAINT FK_TeacherManipulations_Teachers FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE TeacherAddedInfos (
    Id int IDENTITY(1,1) NOT NULL,
    EmploymentDate date NOT NULL,
    Name nvarchar(max) NOT NULL,
    Salary money NOT NULL,
    Surname nvarchar(max) NOT NULL,
    ManipulationId int NOT NULL,
    CONSTRAINT PK_TeacherAddedInfos PRIMARY KEY (Id),
    CONSTRAINT CHK_TeacherAddedInfos_EmploymentDate CHECK (EmploymentDate >= '1990-01-01'),
    CONSTRAINT CHK_TeacherAddedInfos_Name CHECK (Name <> ''),
    CONSTRAINT CHK_TeacherAddedInfos_Salary CHECK (Salary > 0),
    CONSTRAINT CHK_TeacherAddedInfos_Surname CHECK (Surname <> ''),
    CONSTRAINT FK_TeacherAddedInfos_Manipulation FOREIGN KEY (ManipulationId) REFERENCES TeacherManipulations(Id)
);

CREATE TABLE TeacherDeletedInfos (
    Id int IDENTITY(1,1) NOT NULL,
    EmploymentDate date NOT NULL,
    Name nvarchar(max) NOT NULL,
    Salary money NOT NULL,
    Surname nvarchar(max) NOT NULL,
    ManipulationId int NOT NULL,
    CONSTRAINT PK_TeacherDeletedInfos PRIMARY KEY (Id),
    CONSTRAINT CHK_TeacherDeletedInfos_EmploymentDate CHECK (EmploymentDate >= '1990-01-01'),
    CONSTRAINT CHK_TeacherDeletedInfos_Name CHECK (Name <> ''),
    CONSTRAINT CHK_TeacherDeletedInfos_Salary CHECK (Salary > 0),
    CONSTRAINT CHK_TeacherDeletedInfos_Surname CHECK (Surname <> ''),
    CONSTRAINT FK_TeacherDeletedInfos_Manipulation FOREIGN KEY (ManipulationId) REFERENCES TeacherManipulations(Id)
);

GO

CREATE TRIGGER trg_Teachers_SalaryIncreaseOnly
ON Teachers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON i.Id = d.Id
        WHERE i.Salary < d.Salary
    )
    BEGIN
        RAISERROR ('Salary can only be increased.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

GO

CREATE TRIGGER trg_Teachers_LogManipulations
ON Teachers
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ActionId int;
    DECLARE @ManipulationId int;

    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        SELECT @ActionId = Id FROM Actions WHERE Name = 'INSERT';
        INSERT INTO TeacherManipulations (Date, ActionId, TeacherId)
        SELECT GETDATE(), @ActionId, Id FROM inserted;

        INSERT INTO TeacherAddedInfos (EmploymentDate, Name, Salary, Surname, ManipulationId)
        SELECT i.EmploymentDate, i.Name, i.Salary, i.Surname, m.Id
        FROM inserted i
        JOIN TeacherManipulations m ON m.TeacherId = i.Id AND m.ActionId = @ActionId AND m.Date = GETDATE();
    END

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SELECT @ActionId = Id FROM Actions WHERE Name = 'UPDATE';
        INSERT INTO TeacherManipulations (Date, ActionId, TeacherId)
        SELECT GETDATE(), @ActionId, Id FROM inserted;

        INSERT INTO TeacherAddedInfos (EmploymentDate, Name, Salary, Surname, ManipulationId)
        SELECT i.EmploymentDate, i.Name, i.Salary, i.Surname, m.Id
        FROM inserted i
        JOIN TeacherManipulations m ON m.TeacherId = i.Id AND m.ActionId = @ActionId AND m.Date = GETDATE();
    END

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        SELECT @ActionId = Id FROM Actions WHERE Name = 'DELETE';
        INSERT INTO TeacherManipulations (Date, ActionId, TeacherId)
        SELECT GETDATE(), @ActionId, Id FROM deleted;

        INSERT INTO TeacherDeletedInfos (EmploymentDate, Name, Salary, Surname, ManipulationId)
        SELECT d.EmploymentDate, d.Name, d.Salary, d.Surname, m.Id
        FROM deleted d
        JOIN TeacherManipulations m ON m.TeacherId = d.Id AND m.ActionId = @ActionId AND m.Date = GETDATE();
    END
END;

GO

INSERT INTO Actions (Name) VALUES ('INSERT'), ('UPDATE'), ('DELETE');