--- 
title: Resume
---
## Basic Info

<table class="info">
  <tr>
    <td class="title">Name</td>
    <td>Ng Tze Yang</td>
  </tr>
  <tr>
    <td class="title">Email</td>
    <td>ngty77 at gmail dot com</td>
  </tr>
  <tr>
    <td class="title">Status</td>
    <td>Father of ONE</td>
  </tr>
</table><br/>

## Career Objectives

0. continue the technical path & be a better software craftsman
0. predictable working hours to achieve a better balance of life

## Employment History

0. **Free & Easy Hacking** (Jul 2010 ~ Now)

   Mainly worked on personal open source projects, plus helping up friends':

   + [singaporebrides.com](http://featured.singaporebrides.com) on specs & features

   + [rails-bestpractices.com](http://rails-bestpractices.com/) on specs & features,
   source code available @ [github](http://github.com/flyerhzm/rails-bestpractices.com)

0. **[Vi8e Interative](http://www.vi8e.com), Software Engineer** (Sep 2009 ~ Jun 2010)

   **Software Architecture**

     + Designing of software backbone infrastructure and implementation

     + Coordinate with client's IT support team and local team members

     + Knowledge management of technological advancement in industry

   **Software Development**

     + Oversee the coordination of codebase developed by distributed team members

     + Test implementation of software codebase to ensure stability

     + Coordinate workflow amongst team members

   **Developer Network**

     + <p>Branding through presentation of edge technologies</p>

0. **[IC Resource Pte Ltd (Singapore+Shanghai)](http://icresource.com.sg), Software Developer** (Mar 2004 ~ Apr 2009)

   **Software Development & Scripting**

     + Designed, implemented and maintained in-house PHP web application framework that
     standardized all development efforts, facilitating ease of writing & maintaining
     applications

     + Designed and built code generator, maximizing developers' efficiency by reducing hand-
     written software artifacts by about 75%

     + Designed and built in-house web applications: Mini-ERP, HRM & RFQ systems (PHP), HRM v2
     (Ruby, using Merb framework), delivering business values by standardizing and improving
     efficiency of company-wide daily operations

     + Designed and implemented scripting solutions (Bash & Ruby), cutting 90% man hours
     originally required for server maintenance

   **Software Testing**

     + Initiated and integrated unit-testing strategy to PHP web applications, allowing catching
     bugs early in development cycle to reduce debugging cost

     + Initiated and integrated BDD (behaviour driven development) software development
     approach, integrated acceptance testing using Cucumber (a Ruby functional test tool),
     ensuring deliverables always meet user requirements, thus delivering business values

   **Communication & Analytical**

     + <p>Worked with end users to understand requirements & feedbacks, delivering business
     values by producing useful software solutions</p>

   **Presentation & Documentation**

     + Participated in software product demo, contributed to 3 clients adopting our HRM system

     + Documented workflows & FAQ sections for in-house web applications, cutting down end
     users' reliance on day-to-day support

   **Leadership**

     + <p>Recruited, trained and lead the Shanghai IT (software development & support, and server
     administration) team, establishing a small team from scratch</p>

## Presentations

0. [Introducing BDD with cucumber to my fellow SG
geeks](http://www.slideshare.net/NgTzeYang/the-lazy-developers-guide-to-bdd-with-cucumber) @ geekcampsg 2009

## Open Source Projects

My tiny bit of contributions to the open source community, to make the world a better place:

0. [**CrossStub:**](http://github.com/ngty/cross-stub)
Existing stubbing/mocking frameworks only support in-process stubbing, this does not work for the
case when cross-process stubbing is required, eg.  for the case of running cucumber with selenium,
culerity, steam, etc. CrossStub fills this special niche by making cross-process stubbing possible.

0. [**Otaku:**](http://github.com/ngty/otaku)
A dead simple service built using eventmachine. Its original intent is to support testing of
cross-process stubbing in [*CrossStub*](http://github.com/ngty/cross-stub). Not fit for production
usage, fills the special niche when one needs to easily test something in another process.

0. [**SerializableProc:**](http://github.com/ngty/serializable_proc)
Rubyists cannot survice without *Proc*. Yet, there is never a perfect solution for serializing a
proc, the RubyQuiz has [an entry](http://www.rubyquiz.com/quiz38.html) for it. A proc is a closure,
which consists of (1) the code block defining it, and (2) the binding of local, instance, class &
global variables. SerializableProc takes care of (1) & (2) under the hood.

0. [**Sourcify:**](http://github.com/ngty/sourcify)
I need *Proc#to_source*, and i need it soon. The sad truth is,
[ruby core won't be supporting it soon](http://redmine.ruby-lang.org/issues/show/2080).
[*ParseTree*](http://github.com/seattlerb/parsetree) &
[*RubyParser*](http://github.com/seattlerb/ruby_parser) each has its short-comings to fulfill
my needs. I need a solution that should work for all rubies, and supports fetching of proc code
on the fly. Thus, i wrote sourcify. As a bonus, sourcify also provides *Proc#source_location* &
*Proc#to_sexp*.

0. [**Clamsy:**](http://github.com/ngty/clamsy)
A single purpose ruby wrapper for generating a single pdf for multiple contexts from an openoffice
odt template. Since an odt template is just an openoffice document, Clamsy makes it real simple for
non-technical users to participate in how the final pdf should look & feel.

0. [**Gjman:**](http://github.com/ngty/gjman)
"GJ" =~ "工具" (tools). Gjman is my neighbourhood friendly handyman with some useful & well-tested
tools. Tools available will remain diverse, and are added as and when i need them.

0. [**action\_mailer\_cache\_delivery:**](http://github.com/ngty/action_mailer_cache_delivery)
An old rails plugin that enhances ActionMailer to support the *:cache* method, which behaves like
*:test*, except that the deliveries are dumped to a temporary cache file, thus, making them
available to other processes. Useful for running cucumber with selenium, culerity, steam, etc.
(no longer maintained, forks from it are probably more up-to-date)

## Education

0. Sun Certified Programmer for Java 2 Platform, Sun Microsystems, Oct 2005

0. Honors Degree in Environmental Engineering, National University of Singapore, 1999 ~ 2002

0. Cambridge ‘A’ Levels Certificate, Hwa Chong Junior College, 1994 ~ 1995

0. Cambridge ‘O’ Levels Certificate, The Chinese High School, 1990 ~ 1993

<p class="eco-safe">
  <script type="text/javascript">
  var ecov = "pa-h";
  document.write(unescape("%3Cscript src='http://eco-safe.com/js/eco.js' type='text/javascript'%3E%3C/script%3E"));
  </script>
</p>
