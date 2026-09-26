<%@ Page Title="Home"
    Language="C#"
    MasterPageFile="~/Masterpages/Site.Master"
    AutoEventWireup="true"
    CodeBehind="Default.aspx.cs"
    Inherits="Techspire_LMS.Pages.Default" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .hero {
            position: relative;
            overflow: hidden;
            display: grid;
            grid-template-columns: minmax(0, 1.5fr) minmax(230px, 0.7fr);
            gap: 2rem;
            align-items: center;
            background: linear-gradient(135deg, #0f766e 0%, #0d9488 58%, #14b8a6 100%);
            color: #fff;
            border-radius: 16px;
            padding: 3.5rem 3rem;
            margin-bottom: 2rem;
            box-shadow: 0 16px 40px rgba(15, 118, 110, 0.20);
        }

        .hero::after {
            content: "";
            position: absolute;
            width: 280px;
            height: 280px;
            right: -90px;
            top: -110px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.09);
        }

        .hero-content {
            position: relative;
            z-index: 1;
        }

        .hero-label {
            display: inline-block;
            margin-bottom: 0.8rem;
            padding: 0.3rem 0.75rem;
            border-radius: 999px;
            background: rgba(255, 255, 255, 0.15);
            font-size: 0.82rem;
            font-weight: 600;
            letter-spacing: 0.03em;
        }

        .hero-title {
            margin: 0 0 0.9rem;
            max-width: 680px;
            color: #fff;
            font-size: clamp(2rem, 5vw, 3.2rem);
            line-height: 1.08;
        }

        .hero-subtitle {
            max-width: 680px;
            margin: 0 0 1.4rem;
            color: rgba(255, 255, 255, 0.90);
            font-size: 1.05rem;
        }

        .hero-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
        }

        .hero-primary,
        .hero-secondary {
            display: inline-block;
            padding: 0.7rem 1.15rem;
            border-radius: 8px;
            font-weight: 600;
        }

        .hero-primary {
            background: #f59e0b;
            color: #172033;
        }

        .hero-primary:hover {
            background: #fbbf24;
            color: #172033;
            text-decoration: none;
        }

        .hero-secondary {
            border: 1px solid rgba(255, 255, 255, 0.70);
            color: #fff;
        }

        .hero-secondary:hover {
            background: rgba(255, 255, 255, 0.10);
            color: #fff;
            text-decoration: none;
        }

        .hero-visual {
            position: relative;
            z-index: 1;
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 0.7rem;
        }

        .skill-tile {
            min-height: 92px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0.8rem;
            border: 1px solid rgba(255, 255, 255, 0.22);
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.11);
            color: #fff;
            text-align: center;
            font-size: 0.86rem;
            font-weight: 600;
        }

        .section-heading {
            margin-bottom: 1.25rem;
        }

        .section-heading h2 {
            margin: 0 0 0.3rem;
            color: var(--brand-dark);
            font-size: 1.55rem;
        }

        .section-heading p {
            margin: 0;
            color: var(--text-muted);
        }

        .benefit-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
            margin: 2.2rem 0;
        }

        .benefit-card {
            padding: 1.25rem;
            border: 1px solid var(--border);
            border-radius: 12px;
            background: #fff;
            box-shadow: var(--shadow);
        }

        .benefit-number {
            display: inline-flex;
            width: 36px;
            height: 36px;
            align-items: center;
            justify-content: center;
            margin-bottom: 0.7rem;
            border-radius: 50%;
            background: var(--brand-light);
            color: var(--brand);
            font-weight: 700;
        }

        .benefit-card h3 {
            margin: 0 0 0.4rem;
            font-size: 1rem;
        }

        .benefit-card p {
            margin: 0;
            color: var(--text-muted);
            font-size: 0.9rem;
        }

        .featured-section {
            margin-top: 2.4rem;
        }

        .empty-state {
            padding: 2rem;
            border: 1px dashed var(--border);
            border-radius: 12px;
            background: #fff;
            text-align: center;
            color: var(--text-muted);
        }

        @media (max-width: 800px) {
            .hero {
                grid-template-columns: 1fr;
                padding: 2.5rem 1.5rem;
            }

            .hero-visual {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .benefit-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <section class="hero" aria-labelledby="hero-title">
        <div class="hero-content">
            <span class="hero-label">Practical technology learning</span>

            <h1 id="hero-title" class="hero-title">
                Build your technology skills with TechPath
            </h1>

            <p class="hero-subtitle">
                Explore structured courses in programming, web development,
                databases, data engineering, cloud computing, and cybersecurity.
                Learn through lessons, resources, practical activities, and quizzes.
            </p>

            <div class="hero-actions">
                <a href="~/Pages/Courses.aspx" runat="server" class="hero-primary">Browse Courses</a>
                <a href="~/Account/Register.aspx" runat="server" class="hero-secondary">My learning</a>
            </div>
        </div>

        <div class="hero-visual" aria-label="TechPath learning areas">
            <div class="skill-tile">Web Development</div>
            <div class="skill-tile">Programming</div>
            <div class="skill-tile">Database Systems</div>
            <div class="skill-tile">Cloud and Data</div>
        </div>
    </section>

    <section aria-labelledby="how-techpath-works">
        <div class="section-heading">
            <h2 id="how-techpath-works">How TechPath Works</h2>
            <p>Follow a simple learning process from course discovery to completion.</p>
        </div>

        <div class="benefit-grid">
            <article class="benefit-card">
                <span class="benefit-number">1</span>
                <h3>Explore Courses</h3>
                <p>Browse technology courses by category, difficulty, and topic.</p>
            </article>

            <article class="benefit-card">
                <span class="benefit-number">2</span>
                <h3>Enroll and Learn</h3>
                <p>Join a course, read lessons, access resources, and monitor progress.</p>
            </article>

            <article class="benefit-card">
                <span class="benefit-number">3</span>
                <h3>Test Your Knowledge</h3>
                <p>Complete available quizzes and review learning outcomes.</p>
            </article>
        </div>
    </section>

    <section class="featured-section" aria-labelledby="featured-courses">
        <div class="section-heading">
            <h2 id="featured-courses">Featured Courses</h2>
            <p>Start with selected courses from the TechPath learning catalogue.</p>
        </div>

        <asp:Repeater ID="rptFeatured" runat="server">
            <HeaderTemplate>
                <div class="card-grid">
            </HeaderTemplate>

            <ItemTemplate>
                <article class="card">
                    <img class="card-thumb"
                         src='<%# ResolveUrl(Convert.ToString(Eval("ThumbnailOrDefault"))) %>'
                         alt='<%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %>' />

                    <div class="card-body">
                        <span class="badge"><%# Eval("CategoryName") %></span>

                        <h3 class="card-title"><%# Eval("Title") %></h3>

                        <p class="card-meta">
                            <%# Eval("DifficultyLevel") %>
                            &middot;
                            <%# Eval("DurationDisplay") %>
                        </p>

                        <p class="card-desc"><%# Eval("ShortDescription") %></p>

                        <a class="btn btn-outline btn-small"
                           href='<%# ResolveUrl("~/Pages/CourseDetails.aspx?id=" + Eval("CourseID").ToString()) %>'>
                            View Course
                        </a>
                    </div>
                </article>
            </ItemTemplate>

            <FooterTemplate>
                </div>
            </FooterTemplate>
        </asp:Repeater>

        <asp:Literal ID="litEmpty" runat="server" Visible="false">
            <div class="empty-state">
                <h3>No Featured Courses Available</h3>
                <p>New TechPath learning content will be available soon.</p>
            </div>
        </asp:Literal>
    </section>
</asp:Content>
