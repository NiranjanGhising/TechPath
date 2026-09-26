<%@ Page Title="Course Details" Language="C#" AutoEventWireup="true"
    MasterPageFile="~/Masterpages/Site.Master"
    CodeBehind="CourseDetails.aspx.cs"
    Inherits="Techspire_LMS.Pages.CourseDetails" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .course-header {
            margin-bottom: 1.5rem;
        }

        .course-description {
            max-width: 850px;
            font-size: 1rem;
            line-height: 1.7;
        }

        .course-section {
            margin: 1.5rem 0;
        }

        .roadmap-panel {
            border-left: 5px solid var(--accent);
        }

        .roadmap-panel h2,
        .projects-panel h2 {
            margin-top: 0;
            color: var(--brand-dark);
        }

        .roadmap-panel ol {
            margin: 1rem 0 0;
            padding: 0;
            list-style: none;
            counter-reset: roadmap-step;
        }

        .roadmap-panel ol li {
            position: relative;
            margin-bottom: 0.85rem;
            padding: 0.9rem 1rem 0.9rem 3.6rem;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            background: #f8fffd;
            counter-increment: roadmap-step;
        }

        .roadmap-panel ol li::before {
            content: counter(roadmap-step);
            position: absolute;
            left: 0.9rem;
            top: 50%;
            width: 1.9rem;
            height: 1.9rem;
            display: flex;
            align-items: center;
            justify-content: center;
            transform: translateY(-50%);
            border-radius: 50%;
            background: var(--brand);
            color: #fff;
            font-size: 0.82rem;
            font-weight: 700;
        }

        .projects-panel {
            border-left: 5px solid var(--brand);
        }

        .projects-panel ul {
            margin-bottom: 0;
            padding-left: 1.25rem;
        }

        .projects-panel li {
            margin-bottom: 0.55rem;
        }

        .learning-item {
            margin-bottom: 0.75rem;
            padding: 0.9rem 1rem;
            border: 1px solid var(--border);
            border-radius: var(--radius);
            background: #fff;
        }

        .learning-item a {
            font-weight: 600;
        }

        .enrolment-panel {
            max-width: 520px;
        }

        .progress-row {
            margin: 0;
        }
    </style>
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="MainContent" runat="server">
    <asp:PlaceHolder ID="phNotFound" runat="server" Visible="false">
        <div class="alert alert-error">This course could not be found.</div>
    </asp:PlaceHolder>

    <asp:PlaceHolder ID="phCourse" runat="server">
        <asp:Literal ID="litMessage" runat="server" />

        <header class="course-header">
            <span class="badge"><asp:Literal ID="litCategory" runat="server" /></span>
            <h1 class="page-title"><asp:Literal ID="litTitle" runat="server" /></h1>
            <p class="page-subtitle"><asp:Literal ID="litMeta" runat="server" /></p>

            <div class="tag-list">
                <asp:Repeater ID="rptTags" runat="server">
                    <ItemTemplate>
                        <a class="tag" href='<%# ResolveUrl("~/Pages/Courses.aspx?tag=" + Eval("TagID")) %>'>
                            <%# Eval("TagName") %>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </header>

        <section class="course-section" aria-labelledby="overview-heading">
            <h2 id="overview-heading">Course Overview</h2>
            <p class="course-description">
                <asp:Literal ID="litDescription" runat="server" />
            </p>
        </section>

        <asp:PlaceHolder ID="phRoadmap" runat="server" Visible="false">
            <section class="admin-panel roadmap-panel course-section" aria-labelledby="roadmap-heading">
                <h2 id="roadmap-heading">Learning Roadmap</h2>
                <p class="page-subtitle">
                    Follow these topics in order, from the foundation to the practical application.
                </p>
                <asp:Literal ID="litRoadmap" runat="server" />
            </section>
        </asp:PlaceHolder>

        <asp:PlaceHolder ID="phProjects" runat="server" Visible="false">
            <section class="admin-panel projects-panel course-section" aria-labelledby="projects-heading">
                <h2 id="projects-heading">Recommended Projects</h2>
                <p class="page-subtitle">
                    Use these project ideas to apply the knowledge from this course.
                </p>
                <asp:Literal ID="litProjects" runat="server" />
            </section>
        </asp:PlaceHolder>

        <section class="admin-panel enrolment-panel course-section" aria-labelledby="enrolment-heading">
            <h2 id="enrolment-heading">Enrollment</h2>

            <asp:PlaceHolder ID="phGuestPrompt" runat="server" Visible="false">
                <p>You must be logged in to enroll and track course progress.</p>
                <a class="btn" href="~/Account/Login.aspx" runat="server">Log In to Enroll</a>
            </asp:PlaceHolder>

            <asp:PlaceHolder ID="phEnrolAction" runat="server" Visible="false">
                <asp:Button ID="btnEnrol" runat="server"
                    Text="Enroll in This Course"
                    CssClass="btn"
                    OnClick="btnEnrol_Click" />
            </asp:PlaceHolder>

            <asp:PlaceHolder ID="phEnrolled" runat="server" Visible="false">
                <p class="progress-row">
                    <strong>You are enrolled.</strong>
                    Progress: <asp:Literal ID="litProgress" runat="server" />%
                </p>
            </asp:PlaceHolder>
        </section>

        <section class="course-section" aria-labelledby="lesson-heading">
            <h2 id="lesson-heading">Text-Based Lesson</h2>
            <p class="page-subtitle">
                Open the complete learning guide to study the roadmap topics in detail.
            </p>

            <asp:Repeater ID="rptLessons" runat="server">
                <ItemTemplate>
                    <article class="learning-item">
                        <a href='<%# ResolveUrl("~/Pages/LessonDetails.aspx?id=" + Eval("LessonID")) %>'>
                            <%# IsLessonDone(Eval("LessonID")) ? "✓ " : "" %><%# Eval("Title") %>
                        </a>
                        <span class="card-meta">
                            <%# Eval("DurationMinutes") != null ? " · " + Eval("DurationMinutes") + " min" : "" %>
                        </span>
                    </article>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Literal ID="litNoLessons" runat="server" Visible="false">
                <p>No lesson is available for this course yet.</p>
            </asp:Literal>
        </section>

        <section class="course-section" aria-labelledby="quiz-heading">
            <h2 id="quiz-heading">Course Quiz</h2>
            <p class="page-subtitle">
                Attempt the quiz after studying the lesson and completing the practical activity.
            </p>

            <asp:Repeater ID="rptQuizzes" runat="server">
                <ItemTemplate>
                    <article class="learning-item">
                        <a href='<%# ResolveUrl("~/Member/Quiz.aspx?id=" + Eval("QuizID")) %>'>
                            <%# Eval("Title") %>
                        </a>
                        <span class="card-meta">
                            (<%# Eval("QuestionCount") %> questions, pass mark <%# Eval("PassMark") %>%)
                        </span>
                    </article>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Literal ID="litNoQuizzes" runat="server" Visible="false">
                <p>No quiz is available for this course yet.</p>
            </asp:Literal>
        </section>
    </asp:PlaceHolder>
</asp:Content>
