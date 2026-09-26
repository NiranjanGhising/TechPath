/* ============================================================================
   TechPath Learning System - Complete Database Setup

   ONE-FILE SETUP:
   1. Drops and recreates LearningPlatformDB.
   2. Creates the complete schema.
   3. Includes login lockout fields in Users.
   4. Includes LessonProgress tracking.
   5. Seeds 6 categories, 6 tags, 8 courses, exactly 1 text lesson per course,
      8 quizzes, roadmaps, practical activities, and recommended projects.

   WARNING:
   - Running this file deletes and recreates LearningPlatformDB.
   - Use for a fresh assignment setup, not to preserve an existing database.
   - The seeded admin uses a placeholder hash. Create/promote an admin through
     the existing application/CreateAdmin workflow before relying on admin login.

   Target: SQL Server Express/LocalDB 2019 or later
   ============================================================================ */

/* ============================================================================
   Base Template — Generic Learning Platform Database
   Works as-is for: programming learning system, cybersecurity learning
   platform, or any similar "browse -> enrol -> learn -> quiz" system.
   Only the seed data at the bottom is domain-specific — replace it with
   your own categories/tags/courses.

   Target : SQL Server Express 2019/2022, run via SSMS
   Usage  : Open in SSMS, press F5. Safe to re-run - it drops and recreates.
   ========================================================================= */

USE master;
GO

IF DB_ID('LearningPlatformDB') IS NOT NULL
BEGIN
    ALTER DATABASE LearningPlatformDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LearningPlatformDB;
END
GO

CREATE DATABASE LearningPlatformDB;
GO

USE LearningPlatformDB;
GO

/* ============================================================================
   1. ROLES
   ========================================================================= */
CREATE TABLE Roles (
    RoleID      INT IDENTITY(1,1) NOT NULL,
    RoleName    NVARCHAR(30)  NOT NULL,
    Description NVARCHAR(200) NULL,
    CONSTRAINT PK_Roles PRIMARY KEY (RoleID),
    CONSTRAINT UQ_Roles_RoleName UNIQUE (RoleName)
);
GO

/* ============================================================================
   2. USERS
   ========================================================================= */
CREATE TABLE Users (
    UserID       INT IDENTITY(1,1) NOT NULL,
    FullName     NVARCHAR(100) NOT NULL,
    Email        NVARCHAR(150) NOT NULL,
    PasswordHash CHAR(64)      NOT NULL,   -- SHA-256 hex, always 64 chars
    PasswordSalt CHAR(32)      NOT NULL,   -- 16 random bytes as hex
    RoleID       INT           NOT NULL,
    PhoneNumber  NVARCHAR(20)  NULL,
    IsActive     BIT           NOT NULL DEFAULT 1,
    CreatedAt    DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    LastLoginAt         DATETIME2(0)  NULL,
    FailedLoginAttempts INT           NOT NULL DEFAULT 0,
    LockoutEndUtc       DATETIME2(0)  NULL,
    CONSTRAINT PK_Users PRIMARY KEY (UserID),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
GO
CREATE INDEX IX_Users_RoleID ON Users(RoleID);
GO

/* ============================================================================
   3. CATEGORIES  (generic topic grouping — the data, not the schema, is domain-specific)
   ========================================================================= */
CREATE TABLE Categories (
    CategoryID   INT IDENTITY(1,1) NOT NULL,
    CategoryName NVARCHAR(60)  NOT NULL,
    Description  NVARCHAR(250) NULL,
    IsActive     BIT           NOT NULL DEFAULT 1,
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID),
    CONSTRAINT UQ_Categories_Name UNIQUE (CategoryName)
);
GO

/* ============================================================================
   4. TAGS  (free-form M:N labelling — the extensibility hook for any domain)
   ========================================================================= */
CREATE TABLE Tags (
    TagID   INT IDENTITY(1,1) NOT NULL,
    TagName NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Tags PRIMARY KEY (TagID),
    CONSTRAINT UQ_Tags_Name UNIQUE (TagName)
);
GO

/* ============================================================================
   5. COURSES
   ========================================================================= */
CREATE TABLE Courses (
    CourseID          INT IDENTITY(1,1) NOT NULL,
    Title             NVARCHAR(200)  NOT NULL,
    ShortDescription  NVARCHAR(300)  NULL,
    FullDescription   NVARCHAR(MAX)  NULL,
    CategoryID        INT            NOT NULL,
    ThumbnailPath     NVARCHAR(260)  NULL,
    DifficultyLevel   NVARCHAR(20)   NOT NULL DEFAULT 'Beginner',
    DurationMinutes   INT            NULL,
    IsPublished       BIT            NOT NULL DEFAULT 0,
    CreatedBy         INT            NOT NULL,
    CreatedAt         DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt         DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Courses PRIMARY KEY (CourseID),
    CONSTRAINT FK_Courses_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT FK_Courses_Users FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    CONSTRAINT CK_Courses_Difficulty CHECK (DifficultyLevel IN ('Beginner','Intermediate','Advanced'))
);
GO
CREATE INDEX IX_Courses_CategoryID ON Courses(CategoryID);
CREATE INDEX IX_Courses_CreatedBy ON Courses(CreatedBy);
CREATE INDEX IX_Courses_IsPublished ON Courses(IsPublished);
GO

/* ============================================================================
   6. COURSETAGS  (junction table for Courses <-> Tags, M:N)
   ========================================================================= */
CREATE TABLE CourseTags (
    CourseID INT NOT NULL,
    TagID    INT NOT NULL,
    CONSTRAINT PK_CourseTags PRIMARY KEY (CourseID, TagID),
    CONSTRAINT FK_CourseTags_Courses FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE,
    CONSTRAINT FK_CourseTags_Tags FOREIGN KEY (TagID) REFERENCES Tags(TagID) ON DELETE CASCADE
);
GO

/* ============================================================================
   7. LESSONS
   ========================================================================= */
CREATE TABLE Lessons (
    LessonID        INT IDENTITY(1,1) NOT NULL,
    CourseID        INT           NOT NULL,
    Title           NVARCHAR(200) NOT NULL,
    ContentHtml     NVARCHAR(MAX) NULL,
    VideoUrl        NVARCHAR(500) NULL,
    SortOrder       INT           NOT NULL DEFAULT 1,
    DurationMinutes INT           NULL,
    CONSTRAINT PK_Lessons PRIMARY KEY (LessonID),
    CONSTRAINT FK_Lessons_Courses FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE
);
GO
CREATE INDEX IX_Lessons_CourseID ON Lessons(CourseID);
GO

/* ============================================================================
   8. RESOURCES  (generic downloadable attachment per lesson — code file, PCAP,
      slide deck, cheat sheet... same table, different ResourceType)
   ========================================================================= */
CREATE TABLE Resources (
    ResourceID   INT IDENTITY(1,1) NOT NULL,
    LessonID     INT           NOT NULL,
    Title        NVARCHAR(150) NOT NULL,
    FilePath     NVARCHAR(260) NOT NULL,
    ResourceType NVARCHAR(30)  NOT NULL DEFAULT 'Document',
    UploadedAt   DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Resources PRIMARY KEY (ResourceID),
    CONSTRAINT FK_Resources_Lessons FOREIGN KEY (LessonID) REFERENCES Lessons(LessonID) ON DELETE CASCADE
);
GO
CREATE INDEX IX_Resources_LessonID ON Resources(LessonID);
GO

/* ============================================================================
   9. ENROLLMENTS  (junction table for Users <-> Courses, M:N, with attributes
      belonging to the relationship itself)
   ========================================================================= */
CREATE TABLE Enrollments (
    EnrollmentID    INT IDENTITY(1,1) NOT NULL,
    UserID          INT           NOT NULL,
    CourseID        INT           NOT NULL,
    EnrolledAt      DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    ProgressPercent DECIMAL(5,2)  NOT NULL DEFAULT 0,
    CompletedAt     DATETIME2(0)  NULL,
    CONSTRAINT PK_Enrollments PRIMARY KEY (EnrollmentID),
    CONSTRAINT FK_Enrollments_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Enrollments_Courses FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    CONSTRAINT UQ_Enrollments_UserCourse UNIQUE (UserID, CourseID)
);
GO
CREATE INDEX IX_Enrollments_CourseID ON Enrollments(CourseID);
GO

/* ============================================================================
   10. LESSON PROGRESS
   One completion record per lesson per enrollment.
   ========================================================================= */
CREATE TABLE LessonProgress (
    LessonProgressID INT IDENTITY(1,1) NOT NULL,
    EnrollmentID     INT          NOT NULL,
    LessonID         INT          NOT NULL,
    CompletedAt      DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_LessonProgress PRIMARY KEY (LessonProgressID),
    CONSTRAINT FK_LessonProgress_Enrollments FOREIGN KEY (EnrollmentID)
        REFERENCES Enrollments(EnrollmentID) ON DELETE CASCADE,
    CONSTRAINT FK_LessonProgress_Lessons FOREIGN KEY (LessonID)
        REFERENCES Lessons(LessonID) ON DELETE CASCADE,
    CONSTRAINT UQ_LessonProgress_EnrollmentLesson UNIQUE (EnrollmentID, LessonID)
);
GO
CREATE INDEX IX_LessonProgress_EnrollmentID ON LessonProgress(EnrollmentID);
GO

/* ============================================================================
   11. QUIZZES
   ========================================================================= */
CREATE TABLE Quizzes (
    QuizID   INT IDENTITY(1,1) NOT NULL,
    CourseID INT           NOT NULL,
    Title    NVARCHAR(150) NOT NULL,
    PassMark INT           NOT NULL DEFAULT 50,
    IsActive BIT           NOT NULL DEFAULT 1,
    CONSTRAINT PK_Quizzes PRIMARY KEY (QuizID),
    CONSTRAINT FK_Quizzes_Courses FOREIGN KEY (CourseID) REFERENCES Courses(CourseID) ON DELETE CASCADE
);
GO
CREATE INDEX IX_Quizzes_CourseID ON Quizzes(CourseID);
GO

/* ============================================================================
   12. QUESTIONS  (fully normalised — no fixed OptionA..D, see QuestionOptions)
   ========================================================================= */
CREATE TABLE Questions (
    QuestionID   INT IDENTITY(1,1) NOT NULL,
    QuizID       INT           NOT NULL,
    QuestionText NVARCHAR(500) NOT NULL,
    QuestionType NVARCHAR(20)  NOT NULL DEFAULT 'SingleChoice',
    Marks        INT           NOT NULL DEFAULT 1,
    CONSTRAINT PK_Questions PRIMARY KEY (QuestionID),
    CONSTRAINT FK_Questions_Quizzes FOREIGN KEY (QuizID) REFERENCES Quizzes(QuizID) ON DELETE CASCADE,
    CONSTRAINT CK_Questions_Type CHECK (QuestionType IN ('SingleChoice','MultipleChoice','TrueFalse'))
);
GO
CREATE INDEX IX_Questions_QuizID ON Questions(QuizID);
GO

/* ============================================================================
   13. QUESTIONOPTIONS  (any number of options, any number marked correct)
   ========================================================================= */
CREATE TABLE QuestionOptions (
    OptionID   INT IDENTITY(1,1) NOT NULL,
    QuestionID INT           NOT NULL,
    OptionText NVARCHAR(250) NOT NULL,
    IsCorrect  BIT           NOT NULL DEFAULT 0,
    SortOrder  INT           NOT NULL DEFAULT 1,
    CONSTRAINT PK_QuestionOptions PRIMARY KEY (OptionID),
    CONSTRAINT FK_QuestionOptions_Questions FOREIGN KEY (QuestionID) REFERENCES Questions(QuestionID) ON DELETE CASCADE
);
GO
CREATE INDEX IX_QuestionOptions_QuestionID ON QuestionOptions(QuestionID);
GO

/* ============================================================================
   14. QUIZATTEMPTS
   ========================================================================= */
CREATE TABLE QuizAttempts (
    AttemptID   INT IDENTITY(1,1) NOT NULL,
    UserID      INT          NOT NULL,
    QuizID      INT          NOT NULL,
    Score       INT          NOT NULL,
    TotalMarks  INT          NOT NULL,  -- snapshot at attempt time
    IsPassed    BIT          NOT NULL,  -- computed against PassMark at attempt time
    AttemptedAt DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_QuizAttempts PRIMARY KEY (AttemptID),
    CONSTRAINT FK_QuizAttempts_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_QuizAttempts_Quizzes FOREIGN KEY (QuizID) REFERENCES Quizzes(QuizID)
);
GO
CREATE INDEX IX_QuizAttempts_UserID ON QuizAttempts(UserID);
CREATE INDEX IX_QuizAttempts_QuizID ON QuizAttempts(QuizID);
GO

/* ============================================================================
   15. FEEDBACK
   ========================================================================= */
CREATE TABLE Feedback (
    FeedbackID  INT IDENTITY(1,1) NOT NULL,
    UserID      INT           NULL,   -- NULL when a guest submits
    Name        NVARCHAR(100) NOT NULL,
    Email       NVARCHAR(150) NOT NULL,
    Subject     NVARCHAR(150) NOT NULL,
    Message     NVARCHAR(MAX) NOT NULL,
    IsRead      BIT           NOT NULL DEFAULT 0,
    SubmittedAt DATETIME2(0)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Feedback PRIMARY KEY (FeedbackID),
    CONSTRAINT FK_Feedback_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO


/* ============================================================================
   REQUIRED AUTHORIZATION SEED
   ============================================================================ */
INSERT INTO Roles (RoleName, Description) VALUES
    ('Admin',  'Manages categories, courses, users and reviews feedback'),
    ('Member', 'Registered learner: enrols, studies and takes quizzes');
GO

/* Placeholder administrator required as the creator of seeded courses.
   Replace through the project CreateAdmin workflow to obtain a valid password. */
INSERT INTO Users
    (FullName, Email, PasswordHash, PasswordSalt, RoleID, IsActive,
     FailedLoginAttempts, LockoutEndUtc)
VALUES
    ('Platform Admin', 'admin@example.com',
     REPLICATE('0', 64), REPLICATE('0', 32),
     (SELECT RoleID FROM Roles WHERE RoleName = 'Admin'),
     1, 0, NULL);
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @AdminUserID INT;

    SELECT TOP (1) @AdminUserID = u.UserID
    FROM dbo.Users AS u
    INNER JOIN dbo.Roles AS r ON r.RoleID = u.RoleID
    WHERE r.RoleName = 'Admin'
      AND u.IsActive = 1
    ORDER BY u.UserID;

    IF @AdminUserID IS NULL
        THROW 50001, 'No active Admin account exists. Create or promote an Admin account before running this script.', 1;

    /* Remove only course-dependent learning data. Users and roles are preserved. */
    DELETE FROM dbo.QuizAttempts;
    DELETE FROM dbo.QuestionOptions;
    DELETE FROM dbo.Questions;
    DELETE FROM dbo.Quizzes;
    DELETE FROM dbo.Resources;
    DELETE FROM dbo.Enrollments;
    DELETE FROM dbo.Lessons;
    DELETE FROM dbo.CourseTags;
    DELETE FROM dbo.Courses;
    DELETE FROM dbo.Tags;
    DELETE FROM dbo.Categories;

    /* Reset demonstration identities for clean and predictable IDs. */
    DBCC CHECKIDENT ('dbo.QuizAttempts', RESEED, 0) WITH NO_INFOMSGS;
    DBCC CHECKIDENT ('dbo.QuestionOptions', RESEED, 0) WITH NO_INFOMSGS;
    DBCC CHECKIDENT ('dbo.Questions', RESEED, 0) WITH NO_INFOMSGS;
    DBCC CHECKIDENT ('dbo.Quizzes', RESEED, 0) WITH NO_INFOMSGS;
    DBCC CHECKIDENT ('dbo.Resources', RESEED, 0) WITH NO_INFOMSGS;
    DBCC CHECKIDENT ('dbo.Enrollments', RESEED, 0) WITH NO_INFOMSGS;
    DBCC CHECKIDENT ('dbo.Lessons', RESEED, 0) WITH NO_INFOMSGS;
    DBCC CHECKIDENT ('dbo.Courses', RESEED, 0) WITH NO_INFOMSGS;
    DBCC CHECKIDENT ('dbo.Tags', RESEED, 0) WITH NO_INFOMSGS;
    DBCC CHECKIDENT ('dbo.Categories', RESEED, 0) WITH NO_INFOMSGS;

    /* ------------------------------------------------------------------------
       Categories
       ------------------------------------------------------------------------ */
    INSERT INTO dbo.Categories (CategoryName, Description, IsActive)
    VALUES
    ('Programming Fundamentals', 'Core programming concepts, problem solving, and object-oriented development.', 1),
    ('Web Development', 'Client-side and server-side technologies for building web applications.', 1),
    ('Database Systems', 'Relational database design, SQL querying, integrity, and administration.', 1),
    ('Data Engineering', 'Data cleaning, transformation, pipelines, and reliable data preparation.', 1),
    ('Cloud Computing', 'Cloud concepts, service models, scalability, and shared responsibility.', 1),
    ('Cybersecurity', 'Security fundamentals, common threats, access control, and safe practices.', 1);

    /* ------------------------------------------------------------------------
       Tags
       ------------------------------------------------------------------------ */
    INSERT INTO dbo.Tags (TagName)
    VALUES
    ('Beginner-Friendly'),
    ('Hands-On'),
    ('Self-Paced'),
    ('Web'),
    ('Database'),
    ('Career Skills');

    /* ------------------------------------------------------------------------
       Courses
       ThumbnailPath remains NULL so the application's default thumbnail is used.
       ------------------------------------------------------------------------ */
    INSERT INTO dbo.Courses
    (
        Title,
        ShortDescription,
        FullDescription,
        CategoryID,
        ThumbnailPath,
        DifficultyLevel,
        DurationMinutes,
        IsPublished,
        CreatedBy
    )
    VALUES
    (
        'C# Programming Fundamentals',
        'Learn variables, conditions, loops, methods, classes, and essential object-oriented concepts in C#.',
        'A text-based introduction to C# programming. The course roadmap covers program structure, variables, decisions, loops, methods, classes, exception handling, and a practical console project.',
        (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = 'Programming Fundamentals'),
        NULL, 'Beginner', 120, 1, @AdminUserID
    ),
    (
        'HTML5 and CSS Fundamentals',
        'Create structured, accessible web pages and style them with responsive CSS.',
        'A text-based web design course covering semantic HTML5, forms, CSS selectors, the box model, Flexbox, Grid, responsive design, and a portfolio-page project.',
        (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = 'Web Development'),
        NULL, 'Beginner', 120, 1, @AdminUserID
    ),
    (
        'JavaScript Essentials',
        'Add interaction to web pages using variables, functions, events, validation, and the DOM.',
        'A text-based JavaScript course covering syntax, arrays, functions, conditions, events, DOM manipulation, validation, and an interactive quiz project.',
        (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = 'Web Development'),
        NULL, 'Beginner', 135, 1, @AdminUserID
    ),
    (
        'ASP.NET Web Forms Development',
        'Build database-connected web applications using ASP.NET Web Forms, C#, and SQL Server.',
        'A text-based ASP.NET Web Forms course covering project structure, server controls, master pages, validation, database connectivity, authentication, authorization, and CRUD operations.',
        (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = 'Web Development'),
        NULL, 'Intermediate', 180, 1, @AdminUserID
    ),
    (
        'SQL Server Database Development',
        'Design relational databases and perform secure CRUD operations with T-SQL.',
        'A text-based SQL Server course covering tables, keys, relationships, normalization, constraints, joins, aggregate queries, indexes, and parameterized CRUD operations.',
        (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = 'Database Systems'),
        NULL, 'Intermediate', 150, 1, @AdminUserID
    ),
    (
        'Python for Data Engineering',
        'Use Python to validate, clean, transform, and prepare structured data.',
        'A text-based data engineering course covering CSV extraction, validation, cleaning, transformation, modular pipelines, logging, and a small ETL project.',
        (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = 'Data Engineering'),
        NULL, 'Intermediate', 150, 1, @AdminUserID
    ),
    (
        'Introduction to Cloud Computing',
        'Understand cloud service models, deployment options, scalability, and shared responsibility.',
        'A text-based cloud fundamentals course covering IaaS, PaaS, SaaS, deployment models, elasticity, availability, security responsibility, and simple architecture planning.',
        (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = 'Cloud Computing'),
        NULL, 'Beginner', 90, 1, @AdminUserID
    ),
    (
        'Cybersecurity Fundamentals',
        'Learn common threats, authentication principles, access control, and safe computing practices.',
        'A text-based cybersecurity course covering phishing, malware, password safety, access control, software updates, backups, and basic incident response.',
        (SELECT CategoryID FROM dbo.Categories WHERE CategoryName = 'Cybersecurity'),
        NULL, 'Beginner', 105, 1, @AdminUserID
    );

    /* ------------------------------------------------------------------------
       Course tags
       ------------------------------------------------------------------------ */
    INSERT INTO dbo.CourseTags (CourseID, TagID)
    SELECT c.CourseID, t.TagID
    FROM dbo.Courses AS c
    CROSS JOIN dbo.Tags AS t
    WHERE
        (t.TagName = 'Self-Paced')
        OR (t.TagName = 'Beginner-Friendly' AND c.DifficultyLevel = 'Beginner')
        OR (t.TagName = 'Hands-On' AND c.Title IN
            ('C# Programming Fundamentals',
             'HTML5 and CSS Fundamentals',
             'JavaScript Essentials',
             'ASP.NET Web Forms Development',
             'SQL Server Database Development',
             'Python for Data Engineering'))
        OR (t.TagName = 'Web' AND c.Title IN
            ('HTML5 and CSS Fundamentals',
             'JavaScript Essentials',
             'ASP.NET Web Forms Development'))
        OR (t.TagName = 'Database' AND c.Title = 'SQL Server Database Development')
        OR (t.TagName = 'Career Skills' AND c.Title IN
            ('ASP.NET Web Forms Development',
             'SQL Server Database Development',
             'Python for Data Engineering',
             'Introduction to Cloud Computing',
             'Cybersecurity Fundamentals'));

    /* ------------------------------------------------------------------------
       Exactly ONE text-based lesson per course.
       Roadmap and recommended projects are embedded in ContentHtml so the
       existing lesson page can display them without a schema change.
       ------------------------------------------------------------------------ */
    INSERT INTO dbo.Lessons
    (
        CourseID,
        Title,
        ContentHtml,
        VideoUrl,
        SortOrder,
        DurationMinutes
    )
    SELECT
        CourseID,
        'Complete C# Learning Guide',
        '<h2>C# Programming Fundamentals</h2>
         <p>This text lesson introduces the essential concepts required to begin programming with C#.</p>
         <h3>Learning Roadmap</h3>
         <ol>
           <li>Understand the structure of a C# program.</li>
           <li>Use variables, constants, and common data types.</li>
           <li>Apply conditions and loops.</li>
           <li>Create reusable methods.</li>
           <li>Understand classes, objects, and properties.</li>
           <li>Handle common errors with exceptions.</li>
           <li>Build and test a small console application.</li>
         </ol>
         <h3>Core Concepts</h3>
         <p>C# is a strongly typed language. Variables must use compatible data types. Conditions control decisions, loops repeat tasks, and methods organise reusable behaviour. Classes model real entities by combining data and behaviour.</p>
         <h3>Practical Activity</h3>
         <p>Create a console application that accepts marks for three subjects, calculates the average, and displays a grade using conditional statements.</p>
         <h3>Recommended Projects</h3>
         <ul>
           <li>Student Grade Calculator</li>
           <li>Console-Based Quiz Application</li>
           <li>Simple Student Record Manager</li>
         </ul>
         <h3>Summary</h3>
         <p>After this lesson, learners should be able to write a structured C# program using variables, control flow, methods, and basic classes.</p>',
        NULL, 1, 120
    FROM dbo.Courses WHERE Title = 'C# Programming Fundamentals'

    UNION ALL

    SELECT
        CourseID,
        'Complete HTML5 and CSS Learning Guide',
        '<h2>HTML5 and CSS Fundamentals</h2>
         <p>This text lesson explains how to structure and style accessible, responsive web pages.</p>
         <h3>Learning Roadmap</h3>
         <ol>
           <li>Learn the basic HTML document structure.</li>
           <li>Use semantic HTML5 elements.</li>
           <li>Create links, lists, tables, media, and forms.</li>
           <li>Apply CSS selectors and reusable classes.</li>
           <li>Understand the box model.</li>
           <li>Use Flexbox and Grid.</li>
           <li>Create responsive layouts with media queries.</li>
         </ol>
         <h3>Core Concepts</h3>
         <p>HTML defines page structure and meaning, while CSS controls appearance and layout. Semantic elements such as header, nav, main, section, article, and footer improve clarity and accessibility.</p>
         <h3>Practical Activity</h3>
         <p>Create a responsive profile page containing a header, navigation, skills section, project cards, contact form, and footer.</p>
         <h3>Recommended Projects</h3>
         <ul>
           <li>Personal Portfolio Website</li>
           <li>Responsive Product Landing Page</li>
           <li>College Event Information Website</li>
         </ul>
         <h3>Summary</h3>
         <p>After this lesson, learners should be able to create semantic and responsive web pages using HTML5 and CSS.</p>',
        NULL, 1, 120
    FROM dbo.Courses WHERE Title = 'HTML5 and CSS Fundamentals'

    UNION ALL

    SELECT
        CourseID,
        'Complete JavaScript Learning Guide',
        '<h2>JavaScript Essentials</h2>
         <p>This text lesson introduces browser programming and interactive web-page behaviour.</p>
         <h3>Learning Roadmap</h3>
         <ol>
           <li>Understand values, variables, and operators.</li>
           <li>Use conditions and loops.</li>
           <li>Create and call functions.</li>
           <li>Store data in arrays and objects.</li>
           <li>Respond to browser events.</li>
           <li>Select and update DOM elements.</li>
           <li>Validate form input.</li>
         </ol>
         <h3>Core Concepts</h3>
         <p>JavaScript runs in the browser and allows a page to react to users. Functions organise behaviour, arrays hold collections, events capture actions, and DOM methods update page content.</p>
         <h3>Practical Activity</h3>
         <p>Create a form that checks required fields, validates an email address, and displays clear messages without reloading the page.</p>
         <h3>Recommended Projects</h3>
         <ul>
           <li>Interactive Quiz Application</li>
           <li>Task List with Local Storage</li>
           <li>Form Validation Demonstration</li>
         </ul>
         <h3>Summary</h3>
         <p>After this lesson, learners should be able to add events, validation, and content updates to a web page.</p>',
        NULL, 1, 135
    FROM dbo.Courses WHERE Title = 'JavaScript Essentials'

    UNION ALL

    SELECT
        CourseID,
        'Complete ASP.NET Web Forms Learning Guide',
        '<h2>ASP.NET Web Forms Development</h2>
         <p>This text lesson explains how to build a database-connected Web Forms application with C# and SQL Server.</p>
         <h3>Learning Roadmap</h3>
         <ol>
           <li>Understand solution and project structure.</li>
           <li>Create ASPX pages and code-behind classes.</li>
           <li>Use server controls, postbacks, and IsPostBack.</li>
           <li>Create master pages and navigation.</li>
           <li>Apply client-side and server-side validation.</li>
           <li>Connect to SQL Server with parameterized queries.</li>
           <li>Implement registration, login, and logout.</li>
           <li>Apply Member and Admin authorization.</li>
           <li>Implement complete CRUD operations.</li>
           <li>Test and debug the application.</li>
         </ol>
         <h3>Core Concepts</h3>
         <p>Web Forms uses ASPX markup, server controls, code-behind, postbacks, ViewState, master pages, validation controls, and event-driven programming. Database operations should use parameterized SQL and proper disposal of connections and commands.</p>
         <h3>Practical Activity</h3>
         <p>Create a category-management module containing list, add, edit, delete, validation, and clear success or error messages.</p>
         <h3>Recommended Projects</h3>
         <ul>
           <li>Student Registration System</li>
           <li>Course Management System with CRUD</li>
           <li>Web-Based Learning System with Member and Admin Modules</li>
         </ul>
         <h3>Summary</h3>
         <p>After this lesson, learners should understand the complete development flow for a secure database-connected Web Forms application.</p>',
        NULL, 1, 180
    FROM dbo.Courses WHERE Title = 'ASP.NET Web Forms Development'

    UNION ALL

    SELECT
        CourseID,
        'Complete SQL Server Learning Guide',
        '<h2>SQL Server Database Development</h2>
         <p>This text lesson covers relational database design and secure data operations.</p>
         <h3>Learning Roadmap</h3>
         <ol>
           <li>Identify entities, attributes, and relationships.</li>
           <li>Create tables with suitable data types.</li>
           <li>Use primary and foreign keys.</li>
           <li>Apply constraints and normalization.</li>
           <li>Write SELECT queries and joins.</li>
           <li>Use aggregate functions and grouping.</li>
           <li>Implement INSERT, UPDATE, and DELETE.</li>
           <li>Use indexes and parameterized queries.</li>
         </ol>
         <h3>Core Concepts</h3>
         <p>A relational database stores related data in structured tables. Keys protect identity and relationships, constraints protect quality, and parameterized queries protect operations from SQL injection.</p>
         <h3>Practical Activity</h3>
         <p>Design a database for students, courses, and enrollments, then write CRUD queries and a join that displays each student with enrolled courses.</p>
         <h3>Recommended Projects</h3>
         <ul>
           <li>Library Management Database</li>
           <li>Course Enrollment Database</li>
           <li>Inventory and Sales Database</li>
         </ul>
         <h3>Summary</h3>
         <p>After this lesson, learners should be able to design a normalized database and create secure CRUD queries.</p>',
        NULL, 1, 150
    FROM dbo.Courses WHERE Title = 'SQL Server Database Development'

    UNION ALL

    SELECT
        CourseID,
        'Complete Python Data Engineering Guide',
        '<h2>Python for Data Engineering</h2>
         <p>This text lesson introduces practical techniques for preparing data through a small ETL pipeline.</p>
         <h3>Learning Roadmap</h3>
         <ol>
           <li>Read CSV and structured files.</li>
           <li>Inspect columns, types, and missing values.</li>
           <li>Clean and standardize values.</li>
           <li>Validate required fields and business rules.</li>
           <li>Transform data into useful outputs.</li>
           <li>Separate extract, transform, and load functions.</li>
           <li>Log pipeline results and errors.</li>
         </ol>
         <h3>Core Concepts</h3>
         <p>Data engineering pipelines extract data from a source, transform it into a reliable structure, and load it into a destination. Modular functions make pipelines easier to test and maintain.</p>
         <h3>Practical Activity</h3>
         <p>Read a CSV file, remove duplicates, handle missing values, standardize text fields, and export a cleaned file.</p>
         <h3>Recommended Projects</h3>
         <ul>
           <li>CSV Data Cleaning Pipeline</li>
           <li>Netflix Data ETL Pipeline</li>
           <li>Bank Marketing Data Preparation Workflow</li>
         </ul>
         <h3>Summary</h3>
         <p>After this lesson, learners should understand how to build a small and reusable Python ETL workflow.</p>',
        NULL, 1, 150
    FROM dbo.Courses WHERE Title = 'Python for Data Engineering'

    UNION ALL

    SELECT
        CourseID,
        'Complete Cloud Computing Learning Guide',
        '<h2>Introduction to Cloud Computing</h2>
         <p>This text lesson explains cloud service models, deployment choices, scalability, and security responsibility.</p>
         <h3>Learning Roadmap</h3>
         <ol>
           <li>Understand the purpose of cloud computing.</li>
           <li>Compare IaaS, PaaS, and SaaS.</li>
           <li>Compare public, private, and hybrid cloud.</li>
           <li>Understand regions and availability zones.</li>
           <li>Learn elasticity and scalability.</li>
           <li>Understand shared security responsibility.</li>
           <li>Plan a basic cloud architecture.</li>
         </ol>
         <h3>Core Concepts</h3>
         <p>Cloud computing provides technology resources on demand. Service models define how much the provider manages, while deployment models define where services run and who can access them.</p>
         <h3>Practical Activity</h3>
         <p>Design a simple cloud architecture for a college learning website and identify the application, database, storage, backup, and security components.</p>
         <h3>Recommended Projects</h3>
         <ul>
           <li>Cloud Architecture Diagram for a Learning Platform</li>
           <li>Static Portfolio Website Deployment Plan</li>
           <li>Cloud Cost Comparison Worksheet</li>
         </ul>
         <h3>Summary</h3>
         <p>After this lesson, learners should be able to describe cloud service models and plan a basic scalable system.</p>',
        NULL, 1, 90
    FROM dbo.Courses WHERE Title = 'Introduction to Cloud Computing'

    UNION ALL

    SELECT
        CourseID,
        'Complete Cybersecurity Learning Guide',
        '<h2>Cybersecurity Fundamentals</h2>
         <p>This text lesson introduces common threats and practical defensive controls for users and systems.</p>
         <h3>Learning Roadmap</h3>
         <ol>
           <li>Understand confidentiality, integrity, and availability.</li>
           <li>Recognize phishing and social engineering.</li>
           <li>Understand malware and unsafe downloads.</li>
           <li>Create strong and unique passwords.</li>
           <li>Apply authentication and least privilege.</li>
           <li>Use updates, backups, and secure browsing.</li>
           <li>Report and respond to incidents.</li>
         </ol>
         <h3>Core Concepts</h3>
         <p>Cybersecurity protects information and systems from unauthorized access, disruption, and damage. Effective protection combines user awareness, technical controls, access management, updates, and recovery planning.</p>
         <h3>Practical Activity</h3>
         <p>Review a fictional phishing email, identify warning signs, and create a checklist for safe email handling.</p>
         <h3>Recommended Projects</h3>
         <ul>
           <li>Phishing Awareness Checklist</li>
           <li>Password Strength Evaluation Tool</li>
           <li>Small Business Security Policy</li>
         </ul>
         <h3>Summary</h3>
         <p>After this lesson, learners should be able to recognize common risks and recommend basic security controls.</p>',
        NULL, 1, 105
    FROM dbo.Courses WHERE Title = 'Cybersecurity Fundamentals';

    /* ------------------------------------------------------------------------
       One short quiz per course, three questions each.
       ------------------------------------------------------------------------ */
    INSERT INTO dbo.Quizzes (CourseID, Title, PassMark, IsActive)
    SELECT CourseID, Title + ' Quiz', 60, 1
    FROM dbo.Courses;

    INSERT INTO dbo.Questions (QuizID, QuestionText, QuestionType, Marks)
    SELECT q.QuizID, x.QuestionText, x.QuestionType, 1
    FROM dbo.Quizzes AS q
    INNER JOIN dbo.Courses AS c ON c.CourseID = q.CourseID
    CROSS APPLY
    (
        SELECT QuestionText, QuestionType
        FROM
        (
            VALUES
            ('Which item is included in the learning roadmap for this course?', 'SingleChoice'),
            ('Recommended projects are intended to apply course knowledge.', 'TrueFalse'),
            ('What should a learner do after reading the core concepts?', 'SingleChoice')
        ) AS Questions(QuestionText, QuestionType)
    ) AS x;

    INSERT INTO dbo.QuestionOptions (QuestionID, OptionText, IsCorrect, SortOrder)
    SELECT q.QuestionID, v.OptionText, v.IsCorrect, v.SortOrder
    FROM dbo.Questions AS q
    CROSS APPLY
    (
        SELECT OptionText, IsCorrect, SortOrder
        FROM
        (
            VALUES
            ('Follow the roadmap and complete the practical activity', CAST(1 AS BIT), 1),
            ('Ignore the lesson content', CAST(0 AS BIT), 2),
            ('Skip directly to unrelated material', CAST(0 AS BIT), 3),
            ('Delete the course', CAST(0 AS BIT), 4)
        ) AS Options(OptionText, IsCorrect, SortOrder)
        WHERE q.QuestionType = 'SingleChoice'
          AND q.QuestionText = 'Which item is included in the learning roadmap for this course?'

        UNION ALL

        SELECT OptionText, IsCorrect, SortOrder
        FROM
        (
            VALUES
            ('True', CAST(1 AS BIT), 1),
            ('False', CAST(0 AS BIT), 2)
        ) AS Options(OptionText, IsCorrect, SortOrder)
        WHERE q.QuestionType = 'TrueFalse'

        UNION ALL

        SELECT OptionText, IsCorrect, SortOrder
        FROM
        (
            VALUES
            ('Complete the practical activity and attempt a recommended project', CAST(1 AS BIT), 1),
            ('Avoid all practice', CAST(0 AS BIT), 2),
            ('Use another learner account', CAST(0 AS BIT), 3),
            ('Remove the learning roadmap', CAST(0 AS BIT), 4)
        ) AS Options(OptionText, IsCorrect, SortOrder)
        WHERE q.QuestionType = 'SingleChoice'
          AND q.QuestionText = 'What should a learner do after reading the core concepts?'
    ) AS v;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO

/* ============================================================================
   Verification
   Expected counts:
   Categories = 6
   Tags = 6
   Courses = 8
   Lessons = 8
   Quizzes = 8
   Questions = 24
   QuestionOptions = 80
   ============================================================================ */

SELECT COUNT(*) AS CategoryCount FROM dbo.Categories;
SELECT COUNT(*) AS TagCount FROM dbo.Tags;
SELECT COUNT(*) AS CourseCount FROM dbo.Courses;
SELECT COUNT(*) AS LessonCount FROM dbo.Lessons;
SELECT COUNT(*) AS QuizCount FROM dbo.Quizzes;
SELECT COUNT(*) AS QuestionCount FROM dbo.Questions;
SELECT COUNT(*) AS QuestionOptionCount FROM dbo.QuestionOptions;

SELECT
    c.CourseID,
    c.Title,
    cat.CategoryName,
    c.DifficultyLevel,
    c.DurationMinutes,
    c.IsPublished,
    l.LessonID,
    l.Title AS LessonTitle,
    q.QuizID,
    q.Title AS QuizTitle
FROM dbo.Courses AS c
INNER JOIN dbo.Categories AS cat ON cat.CategoryID = c.CategoryID
LEFT JOIN dbo.Lessons AS l ON l.CourseID = c.CourseID
LEFT JOIN dbo.Quizzes AS q ON q.CourseID = c.CourseID
ORDER BY c.CourseID;
GO
