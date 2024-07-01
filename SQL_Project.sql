
-- Создание базы данных
CREATE DATABASE CourseDB;

-- Использование созданной базы данных
USE CourseDB;

-- Создание таблицы Students
CREATE TABLE Students (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Age INT,
    Email NVARCHAR(100),
    Address NVARCHAR(255)
);

-- Создание таблицы StudentArchives
CREATE TABLE StudentArchives (
    ArchiveID INT PRIMARY KEY IDENTITY(1,1),
    StudentID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Age INT,
    Email NVARCHAR(100),
    Address NVARCHAR(255),
    DeletedAt DATETIME DEFAULT GETDATE()
);

-- Хранимая процедура для удаления данных из таблицы Students и записи их в таблицу StudentArchives
CREATE PROCEDURE DeleteStudent
    @StudentID INT
AS
BEGIN
    -- Перемещение удаляемых данных в таблицу архивов
    INSERT INTO StudentArchives (StudentID, FirstName, LastName, Age, Email, Address)
    SELECT StudentID, FirstName, LastName, Age, Email, Address
    FROM Students
    WHERE StudentID = @StudentID;
    
    -- Удаление данных из таблицы Students
    DELETE FROM Students
    WHERE StudentID = @StudentID;
END;

-- Создание таблицы Roles
CREATE TABLE Roles (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50)
);

-- Создание таблицы StaffMembers
CREATE TABLE StaffMembers (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    RoleID INT,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);

-- Добавление данных в таблицу Roles
INSERT INTO Roles (RoleName) VALUES ('Administrator'), ('Instructor'), ('Support');

-- Добавление данных в таблицу StaffMembers
INSERT INTO StaffMembers (FirstName, LastName, Email, RoleID) 
VALUES ('John', 'Doe', 'john.doe@example.com', 1),
       ('Jane', 'Smith', 'jane.smith@example.com', 2),
       ('Emily', 'Johnson', 'emily.johnson@example.com', 3);

-- Использование UNION и UNION ALL для объединения результатов из таблиц Students и StaffMembers
SELECT FirstName, LastName, Email FROM Students
UNION
SELECT FirstName, LastName, Email FROM StaffMembers;

SELECT FirstName, LastName, Email FROM Students
UNION ALL
SELECT FirstName, LastName, Email FROM StaffMembers;

-- Использование EXCEPT для получения данных студентов, не являющихся сотрудниками
SELECT FirstName, LastName, Email FROM Students
EXCEPT
SELECT FirstName, LastName, Email FROM StaffMembers;

-- Использование INTERSECT для получения общих данных студентов и сотрудников
SELECT FirstName, LastName, Email FROM Students
INTERSECT
SELECT FirstName, LastName, Email FROM StaffMembers;

-- Использование TRUNCATE для очистки таблицы StudentArchives
TRUNCATE TABLE StudentArchives;

-- Использование GROUP BY для группировки данных студентов по возрасту
SELECT Age, COUNT(*) AS NumberOfStudents
FROM Students
GROUP BY Age;

-- Создание триггера для автоматического перемещения удаленных данных из таблицы Students в таблицу StudentArchives
CREATE TRIGGER trgAfterDeleteStudents
ON Students
FOR DELETE
AS
BEGIN
    INSERT INTO StudentArchives (StudentID, FirstName, LastName, Age, Email, Address, DeletedAt)
    SELECT StudentID, FirstName, LastName, Age, Email, Address, GETDATE()
    FROM DELETED;
END;
