# TechPath Learning System Implementation Plan

## 1. System Overview

TechPath Learning System is an ASP.NET Web Forms learning platform created for the Web Applications group assignment. The system provides public course browsing, registration, Member learning activities, Administrator management functions, SQL Server connectivity, validation, authentication, authorization, and database CRUD operations.

The visible product name is **TechPath Learning System**. The internal Visual Studio project and namespace remain `Techspire_LMS` because maintaining the established project architecture reduces compatibility risk.

## 2. Project Objectives

The project objectives are to:

1. Develop an interlinked web-based learning system.
2. Demonstrate HTML5, CSS, ASP.NET Web Forms, C#, and SQL Server.
3. Provide public course browsing.
4. Support Member registration, login, enrollment, learning, progress, and quizzes.
5. Provide role-protected Administrator CRUD functions.
6. Apply client-side and server-side validation.
7. Demonstrate secure parameterized database operations.
8. Provide structured technology-learning content.
9. Display an ordered roadmap and recommended projects for every course.
10. Produce a stable assignment application that can be demonstrated and explained.

## 3. Scope

### Included

- Landing page
- Course catalogue
- Course details
- Ordered course roadmap
- Recommended projects
- One comprehensive text-based lesson per course
- Member registration
- Login and logout
- Member enrollment
- Lesson completion
- Progress tracking
- Quiz attempt and scoring
- Profile management
- Contact and feedback
- Administrator CRUD
- Role-based access
- SQL Server database

### Excluded

- Payment processing
- Social login
- Two-factor authentication
- Email verification
- Commercial deployment
- Live video streaming
- Recommendation engines
- Mobile applications
- Production-scale monitoring

## 4. Target Audience

- Students learning practical IT skills
- Beginners exploring technology subjects
- Registered learners tracking course progress
- Administrators managing educational content and users

## 5. User Roles and Permissions

### Guest

- View the landing page
- Browse published courses
- Search and filter courses
- View course details
- View roadmaps and recommended projects
- Open Contact
- Register
- Log in

### Member

- Use all public functionality
- Access My Learning
- Enroll in a course
- Open the enrolled course lesson
- Mark the lesson complete
- Track progress
- Attempt quizzes
- View quiz results
- View and edit the profile
- Log out

### Administrator

- Use authorized Admin pages
- Manage users
- Manage categories
- Manage courses
- Manage lessons
- Manage enrollments
- Manage quizzes
- Manage questions and answer options
- Review feedback
- Preview draft course content

## 6. Functional Requirements

### FR1: Landing Page

The system shall provide a TechPath landing page containing navigation, a hero section, learning areas, featured courses, and public calls to action.

### FR2: Course Catalogue

The system shall display published courses and support browsing, search, category filtering, and tag filtering where implemented.

### FR3: Course Details

The system shall display:

- Category
- Title
- Difficulty
- Duration
- Tags
- Course overview
- Ordered learning roadmap
- Recommended projects
- Enrollment state
- Text lesson
- Quiz and question count

### FR4: Registration

The system shall validate registration input, prevent duplicate emails, generate a salt and password hash, assign the Member role, and store the account.

### FR5: Login and Logout

The system shall authenticate active accounts, establish Session values, apply role-aware navigation, record failed login attempts, temporarily lock repeated failures, and clear the session during logout.

### FR6: Enrollment

A logged-in Member shall enroll in a published course. Duplicate enrollment shall be prevented.

### FR7: Text-Based Learning

Each course shall contain exactly one comprehensive text-based lesson containing:

- Introduction
- Ordered roadmap
- Core concepts
- Practical activity
- Recommended projects
- Summary

### FR8: Progress

The system shall record completed lessons in `LessonProgress` and calculate enrollment progress. With one lesson per course, completion changes progress to 100%.

### FR9: Quiz

Each course shall provide one quiz with three questions. The system shall display questions and options, accept answers, calculate a score, compare the score with the pass mark, and store a QuizAttempt.

### FR10: Contact and Feedback

The system shall validate contact input and store feedback for Administrator review.

### FR11: Administrator CRUD

The Administrator shall perform CRUD operations for assignment-relevant entities through authorized pages.

## 7. Final Course Catalogue

The final system contains seven published courses:

1. HTML5 and CSS Fundamentals
2. JavaScript Essentials
3. ASP.NET Web Forms Development
4. SQL Server Database Development
5. Python for Data Engineering
6. Introduction to Cloud Computing
7. Cybersecurity Fundamentals

The C# Programming Fundamentals course was intentionally removed from the final implementation.

## 8. Database Design

### Roles

Stores Administrator and Member role definitions.

### Users

Stores account details, salted password data, role, active status, login timestamps, failed attempts, and lockout information.

### Categories

Stores course categories.

### Tags

Stores reusable course tags.

### Courses

Stores course title, descriptions, category, difficulty, duration, publication status, creator, and timestamps.

### CourseTags

Implements the many-to-many relationship between Courses and Tags.

### Lessons

Stores one comprehensive text-based lesson for each course.

### Resources

Stores optional lesson resources.

### Enrollments

Implements the many-to-many relationship between Users and Courses and stores enrollment progress.

### LessonProgress

Stores completed lessons for an enrollment.

### Quizzes

Stores course quizzes and pass marks.

### Questions

Stores quiz questions and question types.

### QuestionOptions

Stores answer options and correct-answer status.

### QuizAttempts

Stores quiz-result snapshots.

### Feedback

Stores contact and feedback submissions.

## 9. Database Relationships

- `Roles.RoleID` to `Users.RoleID`
- `Categories.CategoryID` to `Courses.CategoryID`
- `Users.UserID` to `Courses.CreatedBy`
- `Courses.CourseID` and `Tags.TagID` through `CourseTags`
- `Courses.CourseID` to `Lessons.CourseID`
- `Lessons.LessonID` to `Resources.LessonID`
- `Users.UserID` and `Courses.CourseID` through `Enrollments`
- `Enrollments.EnrollmentID` and `Lessons.LessonID` through `LessonProgress`
- `Courses.CourseID` to `Quizzes.CourseID`
- `Quizzes.QuizID` to `Questions.QuizID`
- `Questions.QuestionID` to `QuestionOptions.QuestionID`
- `Users.UserID` and `Quizzes.QuizID` to `QuizAttempts`
- Optional `Users.UserID` to `Feedback.UserID`

## 10. Page and Navigation Structure

### Shared

- `Masterpages/Site.Master`
- Shared navigation
- Shared footer
- Guest, Member, and Admin-aware links

### Public and Account Pages

- `Pages/Default.aspx`
- `Pages/Courses.aspx`
- `Pages/CourseDetails.aspx`
- `Pages/LessonDetails.aspx`
- `Pages/Contact.aspx`
- `Account/Register.aspx`
- `Account/Login.aspx`
- `Account/Logout.aspx`
- `Account/Profile.aspx`

### Member Pages

- My Learning
- Lesson access
- Quiz access
- Progress and completion functions

### Administrator Pages

The Admin folder contains management pages for users, categories, courses, lessons, enrollments, quizzes, questions, and feedback according to the existing project structure.

## 11. CRUD Matrix

### Users

- Create: Registration and Admin user creation
- Read: Admin user list and Member profile
- Update: Admin user edit and Member profile edit
- Delete or deactivate: Administrator user-management action

### Categories

- Create: Admin category form
- Read: Admin category list and course filters
- Update: Admin category edit
- Delete: Admin category deletion with relationship handling

### Courses

- Create: Admin course form
- Read: Public catalogue, course details, and Admin list
- Update: Admin course edit
- Delete: Admin course deletion with dependency handling

### Lessons

- Create: Admin lesson form
- Read: Course Details and Lesson Details
- Update: Admin lesson edit
- Delete: Admin lesson deletion

### Enrollments

- Create: Member enrollment and Admin enrollment creation
- Read: Member My Learning and Admin enrollment list
- Update: Lesson progress and Admin enrollment editing
- Delete: Member unenrollment or Admin deletion

### Quizzes and Questions

- Create: Admin quiz, question, and option forms
- Read: Course quiz list and Member quiz page
- Update: Admin quiz, question, and option editing
- Delete: Administrator deletion with attempt restrictions

### Feedback

- Create: Contact form
- Read: Admin feedback list
- Update: Read or management status where implemented
- Delete: Admin feedback management where implemented

## 12. Authentication and Authorization

### Registration Process

1. Validate Full Name, Email, Password, and optional Phone Number.
2. Normalize the email.
3. Reject an existing email.
4. Generate a unique salt.
5. Generate a compatible password hash.
6. Insert the User with the Member role.
7. Establish the authenticated session or redirect to Login according to the current workflow.

### Login Process

1. Validate Email and Password.
2. Find the active account by normalized email.
3. Check temporary lockout.
4. Verify the password against the stored salt and hash.
5. Reset failed login values on success.
6. Store UserID, FullName, RoleID, and RoleName in Session.
7. Redirect to the appropriate application page.

### Authorization

- Guests cannot use protected Member and Admin functions.
- Members cannot access Admin functions.
- Administrators can access Admin pages.
- Server-side checks protect direct URL access.
- Ownership checks protect Member records.

## 13. Validation

The project uses:

- Required-field validation
- Email-format validation
- Password-length validation
- Password-confirmation validation
- Server-side business validation
- Duplicate-email validation
- Duplicate-enrollment validation
- Numeric and dropdown validation
- Invalid-ID handling
- Database constraints
- Clear success and error messages

## 14. Security Controls

- Salted password hashing
- Parameterized SQL
- Generic login failure messages
- Failed-login tracking
- Temporary account lockout
- Active-account checking
- Role checks
- Session clearing during logout
- HTML encoding for untrusted display values
- Local redirect protection
- Ownership validation
- Unique database constraints

## 15. Project Structure

```text
Techspire_LMS/
├── Account/
├── Admin/
├── App_Data/
├── App_Start/
├── BLL/
├── Content/
├── Data_Access_Layer/
├── Helpers/
├── Images/
├── Masterpages/
├── Media/
├── Member/
├── Models/
├── Pages/
├── Scripts/
├── Bundle.config
├── CreateAdmin.cs
├── Global.asax
├── packages.config
├── Web.config
├── Web.sitemap
└── 01_CreateDatabase.sql
```

## 16. Implementation Phases

### Phase 1: Project and Database Setup

Status: **Completed and verified**

### Phase 2: TechPath Branding and Shared UI

Status: **Completed and verified**

### Phase 3: Landing Page and Public Browsing

Status: **Completed and verified**

### Phase 4: Registration, Login, Logout, and Roles

Status: **Completed and verified**

### Phase 5: Course Catalogue and Course Details

Status: **Completed and verified**

### Phase 6: Roadmaps and Recommended Projects

Status: **Completed and verified**

### Phase 7: Enrollment, Text Lesson, and Progress

Status: **Completed and verified**

### Phase 8: Quiz and Scoring

Status: **Completed and verified**

### Phase 9: Administrator CRUD

Status: **Completed and verified**

### Phase 10: Contact and Feedback

Status: **Completed and verified**

### Phase 11: Documentation and Final Testing

Status: **Completed and verified based on the final manual-test results recorded below**

## 17. Assignment Requirement Mapping

- Interlinked webpages: Implemented through public, Account, Member, and Admin navigation.
- HTML5: Used in semantic page structures including header, nav, main, section, article, forms, and footer.
- CSS: Centralized TechPath theme in `Content/Site.css` with responsive layouts.
- Learning content: Seven technology courses with text lessons and roadmaps.
- Multimedia: Images, icons, and optional media/resource support are included in the project structure.
- Database connectivity: Implemented using ADO.NET and SQL Server.
- Insert: Registration, enrollment, feedback, and Admin create operations.
- Display: Course catalogue, lesson content, Member learning, quizzes, reports, and Admin lists.
- Update: Profiles, progress, and Admin edit operations.
- Delete: Administrator delete operations and supported Member actions.
- Registration: Implemented and tested.
- Member module: Implemented and tested.
- Administrator module: Implemented and tested.
- Validation: Client-side and server-side validation implemented.
- Navigation: Role-aware shared navigation implemented.
- File organization: Layered folders for Models, BLL, DAL, pages, content, and helpers.

## 18. Testing Checklist and Final Results

All items below were reported as manually tested successfully:

### Public

- Landing page opens
- Guest browsing works
- Course catalogue opens
- Course details open
- Roadmap displays
- Recommended projects display
- Contact form works
- Feedback is stored

### Account

- Registration works
- Member login works
- Administrator login works
- Logout works

### Member

- Enrollment works
- My Learning works
- Text lesson opens
- Mark Lesson Complete works
- Progress reaches 100%
- Quiz displays three questions
- Quiz submission and scoring work

### Administrator

- Admin authorization works
- User CRUD works
- Category CRUD works
- Course CRUD works
- Lesson CRUD works
- Enrollment CRUD works
- Quiz CRUD works
- Question CRUD works
- Feedback management works

## 19. Demonstration Accounts

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

These credentials are for local assignment demonstration only.

## 20. Final Implementation Status

- Audit date: 26 September 2026
- Build status: Working solution confirmed by the user during final implementation testing
- Database setup: Completed using `01_CreateDatabase.sql`
- Public pages: Completed and verified
- Registration: Completed and verified
- Login and logout: Completed and verified
- Member module: Completed and verified
- Admin module: Completed and verified
- User CRUD: Completed and verified
- Category CRUD: Completed and verified
- Course CRUD: Completed and verified
- Lesson CRUD: Completed and verified
- Enrollment CRUD: Completed and verified
- Quiz and Question CRUD: Completed and verified
- Feedback: Completed and verified
- Validation: Completed and verified
- Authorization: Completed and verified
- Final course count: Seven
- Lesson design: One comprehensive text-based lesson per course
- Quiz design: One quiz with three questions per course

## 21. Known Limitations

- The project is designed for academic demonstration rather than production deployment.
- The internal project name remains `Techspire_LMS` for compatibility.
- Learning delivery is primarily text-based.
- Each course contains one comprehensive lesson rather than multiple smaller lessons.
- Demonstration credentials must not be reused outside the local assignment environment.
- Advanced features such as payments, email verification, social login, and cloud deployment are outside the assignment scope.
