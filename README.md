# TechPath Learning System

## Project Overview

TechPath Learning System is a web-based learning platform developed for the Web Applications group assignment. The system allows guests to browse technology courses, registered members to enroll in courses and complete text-based lessons and quizzes, and administrators to manage the learning platform through CRUD operations.

The visible system is branded as **TechPath Learning System**. The internal Visual Studio project and namespace remain `Techspire_LMS` to preserve the stable ASP.NET Web Forms architecture.

## Assignment Purpose

The project demonstrates:

- Interlinked web pages
- HTML5 and CSS
- Responsive navigation and layouts
- SQL Server database connectivity
- Insert, display, update, and delete operations
- Member registration
- Login and logout
- Role-based authorization
- Member and administrator modules
- Client-side and server-side validation
- Text-based digital learning content
- Learning roadmaps and recommended projects
- Enrollment, lesson progress, and quizzes
- Organized project files and naming conventions

## Technology Stack

- ASP.NET Web Forms
- .NET Framework 4.8
- C#
- Microsoft SQL Server LocalDB
- ADO.NET and `System.Data.SqlClient`
- HTML5
- CSS3
- JavaScript and ASP.NET validation controls
- Visual Studio 2022

## User Roles

### Guest

A guest can:

- Open the landing page
- Browse published courses
- View course details
- View learning roadmaps
- View recommended project ideas
- Open the Contact page
- Register a Member account
- Log in

A guest cannot enroll, track lesson progress, attempt protected quizzes, or open administrator pages.

### Member

A Member can:

- Log in and log out
- Browse published courses
- Enroll in a course
- View My Learning
- Open the text-based lesson for an enrolled course
- View the course roadmap
- View practical activities and recommended projects
- Mark the lesson complete
- Track course progress
- Attempt quizzes and receive a score
- View and update the Member profile

### Administrator

An Administrator can:

- Access the Admin Panel
- Manage users
- Manage categories
- Manage courses
- Manage lessons
- Manage enrollments
- Manage quizzes
- Manage questions and answer options
- Review feedback
- Use create, read, update, and delete operations provided by the system

## Main Features

### Public Module

- TechPath landing page
- Published course catalogue
- Course search and filtering
- Course details
- Learning roadmap display
- Recommended projects display
- Contact and feedback form
- Registration and login

### Member Module

- Member authentication
- Course enrollment
- My Learning dashboard
- One comprehensive text-based lesson per course
- Lesson completion tracking
- Course progress calculation
- Quiz attempts and scoring
- Profile management

### Administrator Module

- Role-protected Admin Panel
- User management
- Category management
- Course management
- Lesson management
- Enrollment management
- Quiz and question management
- Feedback management

## Final Learning Content

The final system contains seven published technology courses:

1. HTML5 and CSS Fundamentals
2. JavaScript Essentials
3. ASP.NET Web Forms Development
4. SQL Server Database Development
5. Python for Data Engineering
6. Introduction to Cloud Computing
7. Cybersecurity Fundamentals

The C# Programming Fundamentals course was removed from the final implementation.

Each remaining course contains:

- Course overview
- Difficulty level
- Duration
- Tags
- Ordered learning roadmap
- One comprehensive text-based lesson
- Core learning concepts
- Practical activity
- Recommended projects
- Lesson completion tracking
- One quiz with three questions

## Database

### Database Name

```text
LearningPlatformDB
```

### Final SQL Setup File

```text
01_CreateDatabase.sql
```

The SQL file is the primary database setup file for the assignment.

### Main Tables

- `Roles`
- `Users`
- `Categories`
- `Tags`
- `Courses`
- `CourseTags`
- `Lessons`
- `Resources`
- `Enrollments`
- `LessonProgress`
- `Quizzes`
- `Questions`
- `QuestionOptions`
- `QuizAttempts`
- `Feedback`

### Important Relationships

- A Role has many Users.
- A Category has many Courses.
- A User can create many Courses.
- Courses and Tags have a many-to-many relationship through CourseTags.
- A Course has lessons and quizzes.
- Users and Courses have a many-to-many relationship through Enrollments.
- LessonProgress records completed lessons for an enrollment.
- A Quiz has Questions.
- A Question has QuestionOptions.
- A User can create QuizAttempts.
- Feedback may be submitted by a registered user or a guest.

## Database Setup

> Warning: if the SQL file drops and recreates `LearningPlatformDB`, existing local users, enrollments, progress, and attempts will be removed.

1. Open SQL Server Management Studio or SQL Server Object Explorer.
2. Connect to the SQL Server instance used by the project.
3. Open `01_CreateDatabase.sql`.
4. Execute the complete script.
5. Confirm that `LearningPlatformDB` is created.
6. Refresh the Databases node.
7. Verify the tables and seeded TechPath content.

## Connection String

The application connection string in `Web.config` must point to `LearningPlatformDB`.

Example for LocalDB:

```xml
<add name="LearningPlatformDB"
     connectionString="Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=LearningPlatformDB;Integrated Security=True;TrustServerCertificate=True"
     providerName="System.Data.SqlClient" />
```

Keep the actual connection-string key expected by the existing data-access layer.

## Build and Run

1. Open the solution in Visual Studio 2022.
2. Restore NuGet packages if prompted.
3. Confirm that the project targets .NET Framework 4.8.
4. Set `Pages/Default.aspx` as the Start Page.
5. Select **Build > Clean Solution**.
6. Select **Build > Rebuild Solution**.
7. Confirm that the solution builds with zero errors.
8. Press `F5` to run with debugging.

The landing page should open before Login so guests can browse the public website.

## Demonstration Accounts

These accounts are for local assignment demonstration only.

### Administrator

```text
Email: admin@techpath.local
Password: Admin@123
```

### Member

```text
Email: Niranjan@techpath.local
Password: Niranjan@123
```

Passwords are not stored as plaintext in the Users table. Registration and password utilities generate a salt and password hash. Do not use these demonstration credentials in a production deployment.

## Project Structure

```text
Techspire_LMS/
├── Account/                 Registration, Login, Logout and Profile
├── Admin/                   Administrator pages and CRUD interfaces
├── App_Data/                Application data and database files
├── App_Start/               Startup configuration
├── BLL/                     Business Logic Layer
├── Content/                 Site.css and frontend styles
├── Data_Access_Layer/       ADO.NET database operations
├── Helpers/                 Password, database and utility helpers
├── Images/                  Image assets
├── Masterpages/             Shared Site and Admin master pages
├── Media/                   Multimedia assets
├── Member/                  Member dashboard, learning and quiz pages
├── Models/                  Data models
├── Pages/                   Landing page, courses, contact and lesson pages
├── Scripts/                 Client-side scripts
├── Global.asax              Application lifecycle configuration
├── Web.config               Application and database configuration
├── Web.sitemap              Navigation sitemap
└── 01_CreateDatabase.sql    Complete database setup
```

## Security and Validation

The project includes:

- Salted password hashing
- Generic invalid-login messages
- Temporary login lockout support
- Parameterized SQL queries
- Duplicate account and enrollment prevention
- Server-side role checks
- Guest, Member, and Admin authorization
- Session-based authenticated-user information
- HTML encoding for user-facing messages
- Client-side and server-side form validation
- Ownership checks for Member data

## Confirmed Functional Tests

The following functions were manually confirmed:

- Registration
- Member login
- Administrator login
- Logout
- Guest course browsing
- Enrollment
- Text lesson access
- Learning roadmap display
- Recommended project display
- Mark Lesson Complete
- Progress reaching 100%
- Three-question quiz display
- Quiz submission and scoring
- Administrator CRUD
- Contact form submission
- Feedback storage
- User management
- Category management
- Course management
- Lesson management
- Enrollment management
- Quiz management
- Question management
- Feedback management

## Known Limitations

- The application is an academic assignment, not a production deployment.
- Each course contains one comprehensive text-based lesson.
- Course media is optional and the final learning design focuses on text content.
- Demonstration credentials are intentionally simple and must not be reused outside the local assignment environment.
- The internal project name remains `Techspire_LMS` to avoid breaking namespaces and the established Web Forms architecture.

## Final Status

The final assignment implementation includes public browsing, registration, authentication, authorization, Member learning functions, Administrator CRUD, text-based lessons, roadmaps, recommended projects, progress tracking, quizzes, feedback, and SQL Server database integration.
