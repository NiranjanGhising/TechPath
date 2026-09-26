using System;
using System.Collections.Generic;
using System.Web.UI;
using Techspire_LMS.BLL;
using Techspire_LMS.Models;

namespace Techspire_LMS.Pages
{
    public partial class CourseDetails : Page
    {
        private int CourseId
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) ? id : 0;
            }
        }

        private Enrollment _currentEnrollment;
        private List<int> _completedLessonIds = new List<int>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCourse();
            }
        }

        private void LoadCourse()
        {
            CourseBLL courseBll = new CourseBLL();

            Course course = AuthBLL.IsAdmin
                ? courseBll.GetById(CourseId)
                : courseBll.GetPublishedById(CourseId);

            if (course == null)
            {
                phNotFound.Visible = true;
                phCourse.Visible = false;
                return;
            }

            phNotFound.Visible = false;
            phCourse.Visible = true;

            litCategory.Text = Server.HtmlEncode(course.CategoryName);
            litTitle.Text = Server.HtmlEncode(course.Title);
            litMeta.Text = Server.HtmlEncode(
                course.DifficultyLevel + " · " + course.DurationDisplay);
            litDescription.Text = Server.HtmlEncode(
                course.FullDescription ?? course.ShortDescription);

            if (!course.IsPublished)
            {
                litMessage.Text =
                    "<div class=\"alert alert-error\">" +
                    "This course is a draft. Only administrators can see it." +
                    "</div>";
            }

            rptTags.DataSource = new TagBLL().GetByCourse(course.CourseID);
            rptTags.DataBind();

            BindEnrolmentState(course.CourseID);

            List<Lesson> lessons =
                new LessonBLL().GetByCourse(course.CourseID);

            BindLearningContent(lessons);

            rptLessons.DataSource = lessons;
            rptLessons.DataBind();
            litNoLessons.Visible = lessons.Count == 0;

            List<Quiz> quizzes =
                new QuizBLL().GetByCourse(course.CourseID);

            rptQuizzes.DataSource = quizzes;
            rptQuizzes.DataBind();
            litNoQuizzes.Visible = quizzes.Count == 0;
        }

        private void BindLearningContent(List<Lesson> lessons)
        {
            phRoadmap.Visible = false;
            phProjects.Visible = false;
            litRoadmap.Text = string.Empty;
            litProjects.Text = string.Empty;

            if (lessons == null || lessons.Count == 0)
            {
                return;
            }

            string contentHtml = lessons[0].ContentHtml;

            if (string.IsNullOrWhiteSpace(contentHtml))
            {
                return;
            }

            string roadmapHtml = ExtractListAfterHeading(
                contentHtml,
                "Learning Roadmap",
                "ol");

            if (!string.IsNullOrWhiteSpace(roadmapHtml))
            {
                litRoadmap.Text = roadmapHtml;
                phRoadmap.Visible = true;
            }

            string projectsHtml = ExtractListAfterHeading(
                contentHtml,
                "Recommended Projects",
                "ul");

            if (!string.IsNullOrWhiteSpace(projectsHtml))
            {
                litProjects.Text = projectsHtml;
                phProjects.Visible = true;
            }
        }

        private string ExtractListAfterHeading(
            string contentHtml,
            string headingText,
            string listTag)
        {
            string heading = "<h3>" + headingText + "</h3>";
            string listStart = "<" + listTag + ">";
            string listEnd = "</" + listTag + ">";

            int headingIndex = contentHtml.IndexOf(
                heading,
                StringComparison.OrdinalIgnoreCase);

            if (headingIndex < 0)
            {
                return string.Empty;
            }

            int listStartIndex = contentHtml.IndexOf(
                listStart,
                headingIndex,
                StringComparison.OrdinalIgnoreCase);

            if (listStartIndex < 0)
            {
                return string.Empty;
            }

            int listEndIndex = contentHtml.IndexOf(
                listEnd,
                listStartIndex,
                StringComparison.OrdinalIgnoreCase);

            if (listEndIndex < 0)
            {
                return string.Empty;
            }

            int htmlLength =
                listEndIndex + listEnd.Length - listStartIndex;

            return contentHtml.Substring(listStartIndex, htmlLength);
        }

        private void BindEnrolmentState(int courseId)
        {
            _completedLessonIds = new List<int>();

            if (!AuthBLL.IsLoggedIn)
            {
                phGuestPrompt.Visible = true;
                phEnrolAction.Visible = false;
                phEnrolled.Visible = false;
                return;
            }

            EnrollmentBLL enrollmentBll = new EnrollmentBLL();

            _currentEnrollment = enrollmentBll.GetEnrollment(
                AuthBLL.CurrentUserId,
                courseId);

            if (_currentEnrollment != null)
            {
                phEnrolled.Visible = true;
                phEnrolAction.Visible = false;
                phGuestPrompt.Visible = false;

                litProgress.Text =
                    _currentEnrollment.ProgressPercent.ToString("0");

                _completedLessonIds =
                    enrollmentBll.GetCompletedLessonIds(
                        _currentEnrollment.EnrollmentID);
            }
            else
            {
                phEnrolAction.Visible = true;
                phEnrolled.Visible = false;
                phGuestPrompt.Visible = false;
            }
        }

        protected bool IsLessonDone(object lessonId)
        {
            if (lessonId == null || lessonId == DBNull.Value)
            {
                return false;
            }

            int parsedLessonId;

            if (!int.TryParse(lessonId.ToString(), out parsedLessonId))
            {
                return false;
            }

            return _completedLessonIds.Contains(parsedLessonId);
        }

        protected void btnEnrol_Click(object sender, EventArgs e)
        {
            try
            {
                new EnrollmentBLL().Enroll(
                    AuthBLL.CurrentUserId,
                    CourseId);

                litMessage.Text =
                    "<div class=\"alert alert-success\">" +
                    "You are now enrolled in this course." +
                    "</div>";
            }
            catch (ValidationException vex)
            {
                litMessage.Text =
                    "<div class=\"alert alert-error\">" +
                    Server.HtmlEncode(vex.Message) +
                    "</div>";
            }

            LoadCourse();
        }
    }
}
