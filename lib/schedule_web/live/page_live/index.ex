defmodule ScheduleWeb.PageLive.Index do
  use ScheduleWeb, :live_view

  import Jason.Sigil

  @table :ratings_table
  @url "https://iowacodecamp.com/data/json/"
  @headers [{"Content-Type", "application/json"}]

  @impl true
  def mount(_params, session, socket) do
    session_id = session["session_uuid"] || Ecto.UUID.generate()
    # sessions = json_sessions() |> transform()
    sessions = get_sessions() |> Map.get("data") |> transform()
    ratings = Schedule.Cache.get(@table, session_id, fn -> [] end)

    {:ok, assign(socket, ratings: ratings, sessions: sessions, session_id: session_id)}
  end

  @impl true
  def handle_event("rate", %{"id" => id, "star" => star}, socket) do
    ratings = Schedule.Cache.get(@table, socket.assigns.session_id, fn -> [] end)
    ratings = Enum.reject(ratings, &(&1.id == id))
    new_ratings = ratings ++ [%{id: id, rating: String.to_integer(star)}]
    Schedule.Cache.put(@table, socket.assigns.session_id, new_ratings)

    {:noreply, assign(socket, ratings: new_ratings)}
  end

  @impl true
  def handle_event("refresh", _, socket) do
    Process.sleep(1000)

    new_sessions = json_sessions() |> transform()

    socket =
      socket
      |> assign(sessions: new_sessions)
      |> push_event("refreshed", %{})

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div :if={Enum.count(@sessions) > 0}>
      <.pull_refresh>
        <h2>Iowa Code Camp</h2>
        <%= for session <- @sessions do %>
          <.conference_session session={session} ratings={@ratings} />
        <% end %>
      </.pull_refresh>
    </div>
    """
  end

  def json_sessions() do
    Finch.build(:get, @url, @headers)
    |> Finch.request(Schedule.Finch)
    |> case do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        Jason.decode(body)
        |> case do
          {:ok, %{"d" => %{"success" => true, "data" => data}}} ->
            data

          _ ->
            []
        end

      _ ->
        []
    end
  end

  def transform(data) do
    data
    |> Schedule.Util.deep_atomize()
    |> Enum.with_index()
    |> Enum.map(fn {s, i} -> Map.put(s, :id, "session#{i}") end)
  end

  def get_sessions() do
    ~J"""
      {
        "data": [
           {
               "session": "Sponsor Area",
               "time": "8:00 AM - 5:30 PM",
               "desc": "Visit with our sponsors to learn about their services and opportunities.",
               "room": "Atrium",
               "speaker": {
                   "web": "http://www.iowacodecamp.com",
                   "location": "Des Moines, IA",
                   "name": "Iowa Code Camp",
                   "bio": "Iowa Code Camp!",
                   "img": "icc_logo_400.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Opening Session",
               "time": "8:30 AM - 8:45 AM",
               "desc": "Welcome and announcements",
               "room": "Room 106 (Robert Half)",
               "speaker": {
                   "web": "http://www.iowacodecamp.com",
                   "location": "Des Moines, IA",
                   "name": "Iowa Code Camp",
                   "bio": "Iowa Code Camp!",
                   "img": "icc_logo_400.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "The Trials And Tribulations Of Being A Fully Remote Developer",
               "time": "9:00 AM - 10:15 AM",
               "desc": "Imagine working from home full-time. Your job choices are not limited geographically. You have a nice quiet workspace in your comfortable home with limited distractions. Lunch break in your easy chair. What's a dress code? You don't have to go outside in the morning during a frigid Iowa winter. Sounds perfect.\n\nNow imagine this actually happening to you and nothing goes to plan. How do you stay motivated? How do you deal with communication breakdowns? The feelings of isolation? Of feeling like a second rate employee of the company?\n\nIn this presentation, Mike will review the tips and techniques he has learned over the past several years while being a full-time remote developer. This session is geared both towards developers and managers of remote development teams.",
               "room": "Room 106 (Robert Half)",
               "speaker": {
                   "web": "http://colemike.com/",
                   "location": "Cedar Falls, IA",
                   "name": "Mike Cole",
                   "bio": "Mike Cole is a developer currently focusing on .NET working remotely from Cedar Falls for Clear Measure in Austin, TX. He's been around the proverbial block in the IT profession and has a wide array of experience in many fields. He is incredibly lazy and is always looking for easier and more streamlined ways to solve everyday problems. His passions in life include his family, sarcastic memes, the outdoors, and always having the last word.",
                   "img": "MikeCole.png",
                   "imgLarge": null
               }
           },
           {
               "session": " \"So, who's gonna tell 'em?\"",
               "time": "9:00 AM - 10:15 AM",
               "desc": "The talk about \"the talk\" that nobody wants to talk about.\n\nThe growing emphasis on \"Individuals and Interactions\" yields tremendous rewards, but not without risk. Teams who work together more increasingly find themselves in situations where they NEED to have sensitive and high risk conversations, but don't always know how to approach it. Everyone knows about some of the biggest challenges that face a team. They are also aware of the many ways the corrective conversation that can go awry.\n\nThese conversations are often indefinitely delayed. Opportunities for growth are missed and resentment grows. Learn how to be the agent of change your team needs with techniques and practices to help you master the crucial conversations.",
               "room": "Room 107 (QCI)",
               "speaker": {
                   "web": "delta3consulting.com",
                   "location": "Altoona, IA",
                   "name": "Dustin Thostenson",
                   "bio": "Dustin Thostenson is an independent consultant, leading Delta3Consulting. He has been a developer, mentor, trainer and agile coach for almost 2 decades. His passion lies in helping people grow and teams deliver. To keep it interesting he helps lead the Iowa .NET User Group and volunteers in Central Iowa. To keep it real he spends time with his wife and 4 kids. To keep it random he tweets @dustinson\n",
                   "img": "ThostensonProfileSmyl_BWsq_-_Dustin_Thostenson.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Mastering Github",
               "time": "9:00 AM - 10:15 AM",
               "desc": "GitHub is often used as a basic Git host, but its platform has so much more to offer. From simple and powerful issues and pull requests, to advanced features for power users and integrators, it\u2019s a tool worth knowing well in its own right. This session will review everything you need to know to master collaboration with GitHub, from best practices for GitHub Issues and how it represents basic Git concepts, to hidden features and the tools enabling its developer ecosystem.",
               "room": "Room 108 (Scooter Software)",
               "speaker": {
                   "web": null,
                   "location": "Cedar Rapids, IA",
                   "name": "Keith Dahlby",
                   "bio": "Keith Dahlby is a father, web developer, Git enthusiast, language geek and five-time C# MVP from Cedar Rapids, Iowa. His open source efforts include posh-git, a Git environment for PowerShell; and up-for-grabs.net, a site featuring open source projects looking to mentor new contributors. He's also a core contributor to LibGit2Sharp, used by GitHub for Windows and Git for Visual Studio. Keith studied Computer Engineering and Human-Computer Interaction at Iowa State University, and has spoken at developer events around the world. His talks have been described as \"terrific!\", \"very interactive!\", and \"the best I've seen all hour!\".",
                   "img": "KeithDahlby.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "So you want (someone else) to learn to code",
               "time": "9:00 AM - 10:15 AM",
               "desc": "\n My first programming classes in college were so bad that I withdrew from school and worked for a couple of years before regaining a love for programming.\n \n Since then I've had a number of opportunities to mentor youth wanting to learn programming, teach a class for homeschoolers, give presentations at high schools, and mentor new hires fairly fresh to professional programming. Two years ago I made a radical shift in my professional career and once again had the opportunity to be reminded of what is is like to go back to the beginning and learn afresh.\n \n Discussion items:\n \n - Inspiring love of programming\n - Experiences of what has worked and not\n - Tools, learning materials, teaching \n- Mentoring others",
               "room": "Room 109",
               "speaker": {
                   "web": null,
                   "location": "Windsor Heights, IA",
                   "name": "Caleb Salt",
                   "bio": "I got a degree in Political Science from Iowa State and then spent 6 1/2 years writing code in a proprietary mainframe scripting language. Two years ago I decided to change my career, picked up an entirely new tech stack, and have been loving it.",
                   "img": "CalebSalt_-_Caleb_Salt.png",
                   "imgLarge": null
               }
           },
           {
               "session": "Why do they not understand and what to do about it",
               "time": "9:00 AM - 10:15 AM",
               "desc": "Discuss what it means to be an Architect and how to work through technical decisions in the context of building out Workiva's microservice architecture. I hope to share my personal experience and have a candid conversation about the challenges of working in technical management and share techniques for helping groups work through conflict to the point it is resolved.",
               "room": "Room 112",
               "speaker": {
                   "web": "http://savorywatt.com",
                   "location": "Ankeny, Iowa",
                   "name": "Ross Hendrickson",
                   "bio": "Ross Hendrickson is a Software Architect at Workiva in Ames Iowa. A lifelong hacker he has worked on diverse subjects such as machine learning, natural language processing, and distributed calculation engines. He loves working on large distributed problems and helping make systems that fail but still end up giving correct results.",
                   "img": "myself_-_Ross_Hendrickson.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Beginner's Guide to Refactoring Code",
               "time": "9:00 AM - 10:15 AM",
               "desc": "Imagine that you have just started working on a large established legacy code base with little test support. Documentation doesn't exist and the development culture has been of a \u00e2\u20ac\u02dcgit er done' mentality, so there are reams of bugs, unused code, copy pasta, and so on. When you are tasked to make enhancements to this code, it seems like anything you do will likely cause it to break.\n\nIn this session we will take a codebase of questionable quality and walk through a series of refactorings. I will lay out a consistent approach that you can apply to such code, and we will cover the common refactorings that are available in Eclipse, Intellij, and Visual Studio. If you bring your laptop along, I will be using Eclipse and code I find on Github, so you should be able to follow the presentation as we go through it.\n",
               "room": "Room 113",
               "speaker": {
                   "web": null,
                   "location": "Des Moines, IA",
                   "name": "Daniel Juliano",
                   "bio": "I'm a Tech Lead for Telligen in West Des Moines. Am currently trawling the depths of legacy C# and VB.Net Winforms applications, and have spent my career trawling the waters of Javascript, Java, Groovy, PHP, Perl, and so forth and have served in Project Manager, Business Analyst, Data Analyst, and Quality Assurance roles. \n",
                   "img": "headshot_-_Daniel_Juliano.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Building a Distributed Message Log from Scratch",
               "time": "9:00 AM - 10:15 AM",
               "desc": "Apache Kafka has shown that the log is a powerful abstraction for data-intensive applications. It can play a key role in managing data and distributing it across the enterprise efficiently. Vital to any data plane is not just performance, but availability and scalability. In this session, we examine what a distributed log is, how it works, and how it can achieve these goals. Specifically, we'll discuss lessons learned while building NATS Streaming, a reliable messaging layer built on NATS that provides similar semantics. We'll cover core components like leader election, data replication, log persistence, and message delivery. Come learn about distributed systems!",
               "room": "Room 114",
               "speaker": {
                   "web": "http://bravenewgeek.com",
                   "location": "Ames, IA",
                   "name": "Tyler Treat",
                   "bio": "Tyler Treat is a Senior Software Engineer at Apcera working on NATS, an open-source, high-performance messaging system for cloud-native applications. Previously, Tyler was a Product Development Manager with Workiva's Infrastructure and Reliability team. He is interested in distributed systems, messaging infrastructure, and resilience engineering. Tyler is also a frequent open-source contributor and avid blogger at bravenewgeek.com.",
                   "img": "headshot-400_-_Tyler_Treat.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Successful remote working",
               "time": "9:00 AM - 10:15 AM",
               "desc": "Working remotely can sound great. You have to create the right environment and work effectively with your teammates. Don't think it is just working in your PJs every day. We will discuss how to work remotely and create best practices to ensure things work out for you and your teammates.",
               "room": "Room 115",
               "speaker": {
                   "web": "http://myitcareercoach.com/",
                   "location": "West Des Moines, IA",
                   "name": "Tom Henricksen",
                   "bio": "Tom Henricksen is a technology professional with over 15 years of technical experience. He has worked as a developer, Team Lead, Scrum Master, and a Manager. Tom currently works for Zirous in West Des Moines, Iowa an Oracle Platinum partner.",
                   "img": "TomHenricksenBW_-_Tom_Henricksen.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Break",
               "time": "10:15 AM - 10:30 AM",
               "desc": "Break and refreshments",
               "room": "Atrium",
               "speaker": {
                   "web": "http://www.iowacodecamp.com",
                   "location": "Des Moines, IA",
                   "name": "Iowa Code Camp",
                   "bio": "Iowa Code Camp!",
                   "img": "icc_logo_400.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Basics of the Mobile Market: From Prototyping and Design to Delivery",
               "time": "10:30 AM - 11:45 AM",
               "desc": "Companies like Google and Apple have made it really easy for any developer to create an app. The tools are great, the community support is amazing, and the tutorials are endless. This leads to a lot of amazing apps, but it also means the mobile market is crowded. There are a ton of apps out there and they do almost everything you can think of. How can you design and make something that will get noticed, and once you do, how can you maintain that momentum and build a product or a brand that is truly unique?\n\nI will cover the basics of getting started with your idea, including the importance of UI/UX as a base for your app and the tools for developing an Android app. Then I will go into the release process and how to convert views to installs and retain those users for the life of your app.",
               "room": "Room 106 (Robert Half)",
               "speaker": {
                   "web": "luke.klinker.xyz",
                   "location": "Ankeny, Iowa",
                   "name": "Luke Klinker",
                   "bio": "\nI am an Ankeny native and graduated from the University of Iowa in May of 2016. During our freshman year at Iowa, my twin brother, Jake, and I started making Android apps and releasing them to the Play Store. We never looked back. Turns out, people liked what we were making! Over the past five years, we built out Klinker Apps, continued to put out more quality apps, bring in new customers, and expand into web services to back our Android apps. We have some of the highest rated and most downloaded apps in the Play Store, across a variety of categories. Right now, I work full time for my own company. I continue to support and bring new features to my current apps, along with doing some consulting for companies around the metro and the San Fransisco bay area.\n\nI am passionate about giving back to the Android community, through open source contributions and blogging. My wife and I just had a baby girl in the middle of this year, so most of my free time is spent with her, but when I am not working and hanging out with them, I love all things in the water. I swam on the University of Iowa team - while I was there - and I played water polo.\n",
                   "img": "headshot_-_Luke_Klinker.jpeg",
                   "imgLarge": null
               }
           },
           {
               "session": "Logging is not for Humans",
               "time": "10:30 AM - 11:45 AM",
               "desc": "Stop logging for the humans, log for computers. When debugging issues or looking for anomalies, finding context and metadata in human readable logs is never easy. In this talk, I will show how logging for computers from your applications and servers will make your life easier and get you quicker to finding the things you are looking for.",
               "room": "Room 107 (QCI)",
               "speaker": {
                   "web": null,
                   "location": "Des Moines, IA",
                   "name": "Spencer Herzberg",
                   "bio": "Spencer Herzberg is a local independent consultant. He loves to automate and test everything. When not deploying continuously, he is either enjoying his growing family, playing with his 3D printer, or building furniture in his garage.",
                   "img": "icc_logo_400.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Reinforcement Learning: Welcome to the party!",
               "time": "10:30 AM - 11:45 AM",
               "desc": "In this session I will talk through reinforcement learning. I will start with a solution to an OpenAI gym by using DQN (Deep Q Network) with Keras and Tensorflow.",
               "room": "Room 108 (Scooter Software)",
               "speaker": {
                   "web": "http://blog.eckronsoftware.com/",
                   "location": "Urbandale, IA",
                   "name": "Evan Hennis",
                   "bio": "I write software and attend grad school at Georgia Tech and write poor bios.",
                   "img": "profile_-_Evan_Hennis.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Couch to Code",
               "time": "10:30 AM - 11:45 AM",
               "desc": "Learn about code boot camp experience from two recent graduates of the first graduating Delta V class. Find out what we learned and our experience putting our lives on hold for 20 weeks.",
               "room": "Room 109",
               "speaker": {
                   "web": "n/a",
                   "location": "Cedar Rapids, IA",
                   "name": "Jason Logan and Benjamin Beeksma",
                   "bio": "A couple of students from the Delta V code school - hosted by NewboCo in Cedar Rapids, IA. Jason was a soldier, factory worker, and GoDaddy employee before joining Delta V to pursue a passion in technology. Benjamin discovered his love for code while working with SQL as part of a development team, and left that position to take the Delta V code school course and learn to be more than just a back end guy, full-stack baby.",
                   "img": "BenMe_-_Jason_Logan.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "The Signposts on Your Agile Journey",
               "time": "10:30 AM - 11:45 AM",
               "desc": "When I first saw the infamous Deloitte Agile Landscape diagram, I wondered how did agile get so complicated. The second thought was a question: 'how can I inspect those techniques and practices and choose the right ones for my team?'.\r\n\r\nIn this session, I\u2019ll talk about how empirical data (which I\u2019m calling agile numbers) can serve as signposts on our journey to reach the goal of delivering customer value faster with maximum reliability and minimum issues. I\u2019ll show how agile numbers can help us determine if a practice is worth the investment and whether it will improve our team\u2019s performance. I will also share examples of agile numbers that can assist you in your agile journey. Those numbers are pulled from different sources like scientific studies, research from Google, and the 2017 State of DevOps Report.",
               "room": "Room 112",
               "speaker": {
                   "web": "https://blogs.sourceallies.com/author/asaed/",
                   "location": "Urbandale, IA",
                   "name": "Akrem Saed",
                   "bio": "Akrem would describe himself as a \"technologist\" interested in the different facets of software delivery. Those facets include writing code, automating infrastructure, continuous integration, continuous delivery, agile practices, and figuring out what makes high-performing teams come into existence from a collection of individuals. Like many developers, he got his first taste of professional programming with PHP and Java and the latter still has a special place in his heart even after branching into C#, Scala, Groovy and Python. His latest adventures are in AWS-land wearing the DevOps hat. Akrem currently plies his trade with Source Allies, Inc out of Urbandale, IA which is dedicated to helping its partners grow and become more productive through creative and open technology solutions.\n",
                   "img": "20161028_221815_400x400_-_Akrem_Saed.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "ASP.NET Core 2 Fundamentals",
               "time": "10:30 AM - 11:45 AM",
               "desc": "In this talk we'll go over the fundamentals of ASP.NET Core 2 and what you need to know to get started and be productive. We'll discuss the latest changes and improvements made in ASP.NET Core 2 over the 1.x versions including the brand new Razor Pages.",
               "room": "Room 113",
               "speaker": {
                   "web": "scottsauber.com",
                   "location": "Ankeny, Iowa",
                   "name": "Scott Sauber",
                   "bio": "I'm the Lead Developer at Iowa Bankers Association. I'm primarily a web developer using ASP.NET, JavaScript, HTML5, and fighting my way through CSS. I'm constantly learning and trying new things. I blog (primarily on ASP.NET Core) at scottsauber.com.",
                   "img": "Me400x400_-_Scott_Sauber.png",
                   "imgLarge": null
               }
           },
           {
               "session": "Docker is Helping NFM Better Serve our Customers",
               "time": "10:30 AM - 11:45 AM",
               "desc": "I am planning on presenting the several\u00c2\u00a0flavors of Docker\u00c2\u00a0we are using at NFM including:\n1. Developers\u00c2\u00a0running Docker for Windows on VMware virtual machines running Windows Server 2016\u00c2\u00a0highlighting how we use Docker Compose to support local instances of our Microservices during development.\n2. Utilizing\u00c2\u00a0Docker running on Ubuntu and Centos Linux virtual machine\u00c2\u00a0in our CI/CD pipeline to support our integration testing and how this solution is integrated\u00c2\u00a0with Microsoft Team Foundation Server\n3. Running a private Docker Registry to\u00c2\u00a0manage\u00c2\u00a0our build Artifacts in or CI/CD pipeline and getting the Registry tied into Microsoft Team Foundation Server\nManaging our docker containers\u00c2\u00a0within our DC/OS clusters which is\u00c2\u00a0our chosen\u00c2\u00a0\u00c2\u00a0Orchestration solution\u00c2\u00a0for our environments\n\nI am planning on hitting on some of the technical hurdles we had to overcome to get Docker up\u00c2\u00a0and running in each of these scenarios.\u00c2\u00a0There\u00c2\u00a0were different issues and expertise we had to gain in order to implement each different flavor of Docker.\nMy hope is that by sharing some of the\u00c2\u00a0successes and failures we had\u00c2\u00a0along the way, others\u00c2\u00a0will be able to\u00c2\u00a0streamline their\u00c2\u00a0efforts of utilizing\u00c2\u00a0Docker. If there are are additonal topics of intertest to you, please let me know and I may be able to incorporate them into my presentation",
               "room": "Room 114",
               "speaker": {
                   "web": "http://www.nfm.com",
                   "location": "Omaha, NE",
                   "name": "Michael Nichols",
                   "bio": "Experienced Senior Software Architect leading the adoption of a micro service architecture at NFM leveraging Docker to improve the speed of software development while improving overall quality and stability",
                   "img": "linked_-_Michael_Nichols.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Lightening Talks",
               "time": "10:30 AM - 11:45 AM",
               "desc": "5-10 minute talks supplied by you! Come prepared or be spontaneous!",
               "room": "Room 115",
               "speaker": {
                   "web": "http://www.iowacodecamp.com",
                   "location": "Des Moines, IA",
                   "name": "Iowa Code Camp",
                   "bio": "Iowa Code Camp!",
                   "img": "icc_logo_400.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Lunch",
               "time": "11:45 AM - 12:45 PM",
               "desc": "Lunch",
               "room": "Atrium",
               "speaker": {
                   "web": "http://www.iowacodecamp.com",
                   "location": "Des Moines, IA",
                   "name": "Iowa Code Camp",
                   "bio": "Iowa Code Camp!",
                   "img": "icc_logo_400.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Introduction to the R Language and Ecosystem",
               "time": "12:45 PM - 2:00 PM",
               "desc": "This session will introduce you to R, a popular language and software environment for data analysis and visualization. We will cover some of the basics of the R language, but we will focus on examples of the kinds of things that R excels at, like data manipulation, statistical computing, and data visualization.\n\nWe'll also introduce the R ecosystem, including R packages and RStudio. We'll see examples of how you can easily create documents containing code and graphics using tools like R Markdown, or create and publish interactive data-driven web applications using Shiny.\n\nNo prior knowledge of R is required. The emphasis will be on breadth rather than depth. You'll come away with a basic understanding of what R is all about and suggestions for how to learn more.\n",
               "room": "Room 107 (QCI)",
               "speaker": {
                   "web": "www.bigcreek.com",
                   "location": "Polk City, IA",
                   "name": "David W. Body",
                   "bio": "David W. Body is an experienced software developer who is interested in data science, machine learning, and related areas. He is available for freelance consulting and contract work.",
                   "img": "davidbody_400x400_-_David_Body.png",
                   "imgLarge": null
               }
           },
           {
               "session": "Building your own AI (in a tube): DIY Alexa, Cortana, and Google Home",
               "time": "12:45 PM - 2:00 PM",
               "desc": "Amazon Echo devices are affordable and are now in every home. Every windows machine comes with Cortana and Cortana even lives in entertainment systems. Would you like to build your own Cortana, Alexa, or Google home from scratch? We have built a device for under $100.00. We will show you how to design a 3D printable case. We will discuss our hardware selection for the brain of our very own Ai. We will show what we used for microphone and audio. Finally, we will show the code under the covers on selecting the Ai of choice and bringing the tube to life.",
               "room": "Room 108 (Scooter Software)",
               "speaker": {
                   "web": "http://www.minmaung.com",
                   "location": "Chicago, IL",
                   "name": "Min Maung & Lwin Maung",
                   "bio": "Name a new technology that Min isn't interested in. Min has developed on all mobile platforms from latest Windows 8 to Windows Mobile 6.5. Of course that also means that he has had countless smartphones and tablets. Min is often honing his skills by aggressively competing in hackathons dating back to his days at Dominican University. Being technologically agnostic, he does not stop tinkering with mobile platforms like Android, he creates his own personal microcontrollers for robotics projects. When he's not coding, he's building robots. When he's not adding more robots to his robot army, you will see him speaking at conferences such as That Conference and CodeMash. Monday through Friday, you'll find him at Polaris Solutions, cranking out .Net code and writing apps in ASP.Net, KendoUI, Knockout.js, Node.js, and other web solutions.\n\nLwin Maung is a Microsoft Windows Development MVP and Senior Technical Architect for Concurrency. Lwin is an expert on mechatronics with over a decade of consulting experience. He has consulted for small startups, fortune 500 companies as well as NGOs world wide. Lwin's mobile applications have been featured on technology sites such as engadget, gizmodo, and pocket now. He has also designed and created programmable microcontrollers as well as microcontroller controlled robots from the ground up to use in teaching children(and teens) simple programming. In his free time, Lwin teaches and mentors highschool and university students who are building applications and developing hardware prototypes. Lwin was also involved in creation of various certification exams for Microsoft. Lwin is highly active in the development community and helps run Chicago Code Camp. You can find him speaking various technical conferences and code camps.",
                   "img": "me_-_Min_M.jpeg",
                   "imgLarge": null
               }
           },
           {
               "session": "Tech Survival 101",
               "time": "12:45 PM - 2:00 PM",
               "desc": "Surviving and thriving in a technology career can be quite difficult. First you need to focus on your technical chops. Then you have to figure out how to work with your team members and manage your boss. We will cover the steps it takes to make a tech career successful.",
               "room": "Room 109",
               "speaker": {
                   "web": null,
                   "location": "West Des Moines, IA",
                   "name": "Tom Henricksen & Greg Jensen",
                   "bio": "See Tom's separate profile for his details. Greg is the VP of Engineering at CDS Global, leading the transition to next generation enterprise systems and new digital experience delivery. Greg has previously held senior technical and executive positions for companies such as AT&T, Best Buy, Dish Network, Lockheed Martin, and Verizon and led multiple startups as a VP of Engineering or CTO. He has led the delivery of over a billion dollars in enterprise programs and projects for leadership companies around the globe. With 30 plus years in the high tech industry ranging from startups to Fortune 500, and across industry verticals such as finance, media & entertainment, telecom, retail, defense and national intelligence agencies, Greg brings a very broad base of experience and industry success. Greg holds a BS degree in Computer Science from Park University and an MS degree in Software Engineering from the University of Minnesota where he also served as an adjunct faculty member at the Software Engineering Center teaching a graduate course on big data strategies and data science. Greg and his wife Patty currently live in downtown Des Moines.",
                   "img": "gjensen_pic.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "When is the feature done done?",
               "time": "12:45 PM - 2:00 PM",
               "desc": "How does a development team ensure that the feature they are working is done? Development teams throughout time have tackled this task. Organizational dynamics makes this task different per team. \n\nSome common techniques emerge though to ensure that a feature gets done as quickly and accurately as possible. I will be facilitating an open discussion on how the above question is answered while also giving insights from my time on development teams. Topics discussed will include Git, CICD, Client Interaction, etc...\n\nBe prepared to participate.",
               "room": "Room 112",
               "speaker": {
                   "web": null,
                   "location": "Cedar Rapids, IA",
                   "name": "Matt Winger",
                   "bio": "I am a Senior Software Developer with Geonetric. I work in the .net and the web space. I love talking with other developers to share ideas and learning about new techniques and technologies.",
                   "img": "0032_Matt-Winger_-_Matthew_Winger.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Learn React in Isolation",
               "time": "12:45 PM - 2:00 PM",
               "desc": "The React ecosystem can be overwhelming to learn all at once, but React by itself can be much more manageable. In this talk, we will explore ways to learn React and JSX in an isolated way so that learning is not distracted by other tools like Babel, Webpack, Redux, or even how to load data from the back-end.",
               "room": "Room 113",
               "speaker": {
                   "web": "https://matt.travi.org",
                   "location": "Des Moines, IA",
                   "name": "Matt Travi",
                   "bio": "Matt is a full-stack JavaScript engineer and lead at Gain Compliance, specializing in front-end solutions, continuous-deployment, and hypermedia APIs.",
                   "img": "fullRes_-_Matt_Travi.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "API Design from the consumer's persepective",
               "time": "12:45 PM - 2:00 PM",
               "desc": "This session is to explain and show examples of how to design your APIs to make consuming them as easy and intuitive to the consumer as possible while also providing the functionality of a solid API.",
               "room": "Room 114",
               "speaker": {
                   "web": null,
                   "location": "Des Moines, IA",
                   "name": "Bobby Dineen",
                   "bio": "Developer who is passionate about doing things \"right\".",
                   "img": "icc_logo_400.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Are you ready for production and the barbarian horde? Scaling, Scalability Techniques and Best Pract",
               "time": "12:45 PM - 2:00 PM",
               "desc": "Talk on how and why to scale. Go over the 12-Factor app principles and discuss personal experience in utilizing these patterns to scale large systems at Workiva. Overview of scale evaluations and techniques to understand how well your system scales.",
               "room": "Room 115",
               "speaker": {
                   "web": "http://savorywatt.com",
                   "location": "Ankeny, Iowa",
                   "name": "Ross Hendrickson",
                   "bio": "Ross Hendrickson is a Software Architect at Workiva in Ames Iowa. A lifelong hacker he has worked on diverse subjects such as machine learning, natural language processing, and distributed calculation engines. He loves working on large distributed problems and helping make systems that fail but still end up giving correct results.",
                   "img": "myself_-_Ross_Hendrickson.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Break",
               "time": "2:00 PM - 2:15 PM",
               "desc": "Break and refreshments",
               "room": "Atrium",
               "speaker": {
                   "web": "http://www.iowacodecamp.com",
                   "location": "Des Moines, IA",
                   "name": "Iowa Code Camp",
                   "bio": "Iowa Code Camp!",
                   "img": "icc_logo_400.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Kotlin: The New Standard for Android",
               "time": "2:15 PM - 3:30 PM",
               "desc": "Earlier this year, Google announced that Jetbrain's Kotlin (https://kotlinlang.org/) programming language was becoming a first class citizen for Android development. Being a much more modern programming language, Kotlin support marks a turning point for Android development, similar to the introduction of Swift for iOS development.\n\nThis talk will cover the basics of the language and what makes it unique from Java, then I will get into setting up and using Kotlin in your Android projects as well as converting existing code to the new language. \n\nThis is an introductory talk on both the basics of Kotlin, as well as Android development and setting up an app.",
               "room": "Room 106 (Robert Half)",
               "speaker": {
                   "web": "luke.klinker.xyz",
                   "location": "Ankeny, Iowa",
                   "name": "Luke Klinker",
                   "bio": "\nI am an Ankeny native and graduated from the University of Iowa in May of 2016. During our freshman year at Iowa, my twin brother, Jake, and I started making Android apps and releasing them to the Play Store. We never looked back. Turns out, people liked what we were making! Over the past five years, we built out Klinker Apps, continued to put out more quality apps, bring in new customers, and expand into web services to back our Android apps. We have some of the highest rated and most downloaded apps in the Play Store, across a variety of categories. Right now, I work full time for my own company. I continue to support and bring new features to my current apps, along with doing some consulting for companies around the metro and the San Fransisco bay area.\n\nI am passionate about giving back to the Android community, through open source contributions and blogging. My wife and I just had a baby girl in the middle of this year, so most of my free time is spent with her, but when I am not working and hanging out with them, I love all things in the water. I swam on the University of Iowa team - while I was there - and I played water polo.\n",
                   "img": "headshot_-_Luke_Klinker.jpeg",
                   "imgLarge": null
               }
           },
           {
               "session": "Making the most of MOOCs (Massive Open Online Courses)",
               "time": "2:15 PM - 3:30 PM",
               "desc": "Learn more about how to select and make the most of opportunities to continue your own education. The speaker will share what he has learned through his participation in courses offered by Coursera, Udacity, Duolingo, and other vendors. The presentation will include tips for effective study and a review of the tremendous increase in the quality and quantity of online courses during the last five years.",
               "room": "Room 107 (QCI)",
               "speaker": {
                   "web": "www.countingfromzero.com",
                   "location": "Mount Vernon, Iowa",
                   "name": "Leon Tabak",
                   "bio": "Leon Tabak is a professor of computer science at Cornell College in Mount Vernon, Iowa. He is an active volunteer in the Cedar Rapids Section of the Institute of Electrical and Electronics Engineers (IEEE) and has contributed to the College Board's Advanced Placement in Computer Science program in several roles. He is a regular moderator for KCRG-TV's \"Ethical Perspectives on the News,\" where he has led discussions of how technological innovations---including the development of new ways of teaching and learning---are changing society.",
                   "img": "leontabak-oct2015-400x400_-_Leon_Tabak.png",
                   "imgLarge": null
               }
           },
           {
               "session": "A DSL for Your API",
               "time": "2:15 PM - 3:30 PM",
               "desc": "Have you ever wanted to allow your users to be able to write scripts to execute actions within your application? Have you ever wondered how applications that do this accomplish it? Have you ever been sitting around with too much time on your hands and needed something interesting to think about? If so, then this talk is for you. During this talk we'll look at an app with a simple, easy to Grok API, and build up our own scripting language using the ANTLR4 Parser/Lexer generator, with which to drive it. All this, faster than you can say \"The Dragon Book\".",
               "room": "Room 108 (Scooter Software)",
               "speaker": {
                   "web": "https://www.linkedin.com/in/gregsohl/",
                   "location": "Cedar Rapids, IA",
                   "name": "Greg Sohl",
                   "bio": "Greg is the director of software development and a software architect with StoneRiver in Cedar Rapids. He's spent the last 35 years building commercially sold software in the financial industry. Greg is also the Speaker Liason & MC for CRineta and President of Iowa Code Camp.",
                   "img": "GregSohl_-_Greg_Sohl.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Debate Me",
               "time": "2:15 PM - 3:30 PM",
               "desc": "For about 15 years I have been developing software and in that time have settled on certain opinions and preferences based on my experiences. Confirmation bias and the bubble that I am in reinforce those opinions and preferences. \n\nIn this talk audience participation is required. I will be presenting a list of my personal opinions and preferences and, for each one, will open up the floor for friendly debate. My hope is that I can learn something and at the same time impart some useful information to all who attend.",
               "room": "Room 109",
               "speaker": {
                   "web": "mattjmorrison.com",
                   "location": "Grimes, IA",
                   "name": "Matthew Morrison",
                   "bio": "I am a software developer and enthusiast. I began learning web technologies in the late 90s and in the 2000s began my career as a professional developer by writing COBOL on an IBM mainframe. Since then I have worked in many different technologies, primarily focused in the realm of web development.",
                   "img": "matt_-_Matthew_Morrison.jpeg",
                   "imgLarge": null
               }
           },
           {
               "session": "An Advocates Guide: You Just Got Hired. Now What?",
               "time": "2:15 PM - 3:30 PM",
               "desc": "Great! You landed a new job and are now on a team of developers. Who is bringing you up to speed? What are you doing in your down time? What questions do you ask? This talk aims to demystify those questions, decrease imposter syndrome and give less experienced developers a fair chance at becoming leaders. Juniors to tech leads will find this talk valuable.",
               "room": "Room 112",
               "speaker": {
                   "web": null,
                   "location": "Davenport, IA",
                   "name": "Michael Liendo",
                   "bio": "Previously a professional model, Michael now considers himself a professional problem solver. Working as a Developer Advocate, my job is to expedite the learning process of new fronted developers. When not coding, or creating docs, you can typically find me wrestling my three kids or casually throwing a boomerang.",
                   "img": "icc_logo_400.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Form Inputs: The UX Issue You Didn't Know You Had",
               "time": "2:15 PM - 3:30 PM",
               "desc": "The lowly form input: it's been a part of HTML for as long as HTML has had a formal specification, but before HTML5, developers were hamstrung by its limited types and attributes. As the use of smartphones and their onscreen keyboards has flourished, however, inputs have taken on a new and incredibly important role - but they're also riddled with browser and device inconsistencies. Learn how input types and patterns can give your users a better onscreen keyboard experience, and how to abuse these features to meet the needs of today (if you must).",
               "room": "Room 113",
               "speaker": {
                   "web": "aaronladage.com",
                   "location": "Overland Park, KS",
                   "name": "Aaron Ladage",
                   "bio": "Aaron Ladage is a Senior UI engineer at DEG in Kansas City. He's spoken about front-end development at a number of prominent tech conferences, including SXSW Interactive, Future of Web Design NYC and HTML5DevConf San Francisco. He's also the creator of inputtypes.com, a popular form input testing utility. Outside of work and freelance, Aaron is a clich\u00c3\u00a9 Kansas City BBQ snob and brews some really bad beer.",
                   "img": "ladage_aaron_-_Aaron_Ladage.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Introduction to Blockchain",
               "time": "2:15 PM - 3:30 PM",
               "desc": "If you want to know what Blockchain is, how it relates to crypto-currencies like Bitcoin and why people compare it to early days of the Internet then this session is for you. I will give an overview and practical ways to get started based on my own experience and share other resources if you want to dive deeper.",
               "room": "Room 114",
               "speaker": {
                   "web": "eugen.burianov.com",
                   "location": "Des Moines, IA",
                   "name": "Eugen Burianov",
                   "bio": "I am a full time software engineer in a large financial company, Toastmasters club member and enthusiastic speaker.",
                   "img": "Eugen-400x400_-_Eugen_Burianov.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Open Space Discussion",
               "time": "2:15 PM - 3:30 PM",
               "desc": "Join us for open discussion based on topics you suggest.",
               "room": "Room 115",
               "speaker": {
                   "web": "http://www.iowacodecamp.com",
                   "location": "Des Moines, IA",
                   "name": "Iowa Code Camp",
                   "bio": "Iowa Code Camp!",
                   "img": "icc_logo_400.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Break",
               "time": "3:30 PM - 3:45 PM",
               "desc": "Break and refreshments",
               "room": "Atrium",
               "speaker": {
                   "web": "http://www.iowacodecamp.com",
                   "location": "Des Moines, IA",
                   "name": "Iowa Code Camp",
                   "bio": "Iowa Code Camp!",
                   "img": "icc_logo_400.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Introduction to AWS Step Functions",
               "time": "3:45 PM - 5:00 PM",
               "desc": "Learn how powerful AWS Step Functions can be to influence your next project. Leveraging several internal tools at Amazon, Steps provides a simple interface for creating very complex state machines, letting you focus on the code and less on its supporting infrastructure.",
               "room": "Room 106 (Robert Half)",
               "speaker": {
                   "web": null,
                   "location": "Ames, Iowa",
                   "name": "Eric Larssen",
                   "bio": "Eric is a Site Reliability Engineer at Workiva in Ames. Working primarily to integrate AWS hosted products with internal products that support the infrastructure at Workiva.",
                   "img": "Eric-Larssen-3_-_Eric_Larssen.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Fast UX and Usability Testing for Agile Teams",
               "time": "3:45 PM - 5:00 PM",
               "desc": "One of the benefits of agile development practices is responding quickly to feedback. We tend to focus on how to develop software in a way that gives us those capabilities, but it's time to start talking about how to actually get a useful feedback loop tied into the process. This will be a highly pragmatic discussion with real examples and demonstrations of how to create scripts, find participants, conduct measurable research and present findings.",
               "room": "Room 107 (QCI)",
               "speaker": {
                   "web": "https://www.tekrs.com/",
                   "location": "Ankeny, IA",
                   "name": "Matthew Nuzum",
                   "bio": "Matt loves to make software easier to use.",
                   "img": "icc_logo_400.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Data Visualization with ggplot2",
               "time": "3:45 PM - 5:00 PM",
               "desc": "This session will introduce you to data visualization using ggplot2, an elegant and versatile plotting system for R. ggplot2 is based on a \"grammar of graphics\" for describing and building plots.\n\nData is mapped to aesthetic attributes (color, shape, size, etc) of geometric objects (points, lines, bars, etc). Statistical transformations may be applied and the plot can be drawn on a specific coordinate system. A plot can be repeated for subsets of the data using facetting. Sophisticated graphics can be built up in layers, combining multiple data sets if desired. Themes can be used to control things like font size and background color.\n\nMuch of the power of ggplot2 comes from the fact that it is based on coherent set of principles. Although this means there is a bit of a learning curve, ggplot2 is not going to get you 90% of the way to your desired graphic and leave you frustrated that there is no way to achieve what you really want.\n\nBasic knowledge of R will be assumed but not absolutely required. You'll come away with a basic understanding of how to create data visualizations using ggplot2.\n",
               "room": "Room 108 (Scooter Software)",
               "speaker": {
                   "web": "www.bigcreek.com",
                   "location": "Polk City, IA",
                   "name": "David W. Body",
                   "bio": "David W. Body is an experienced software developer who is interested in data science, machine learning, and related areas. He is available for freelance consulting and contract work.",
                   "img": "davidbody_400x400_-_David_Body.png",
                   "imgLarge": null
               }
           },
           {
               "session": "WPF (and WinForms) isn't dead (Workshop)",
               "time": "3:45 PM - 5:00 PM",
               "desc": "Let's look at two workplace scenarios. You have created amazing business applications (or) you start a new line of business application by creating a new project in Visual Studio. 90% of the time, it will default to WinForms or WPF. Why move your line of business apps and re-write them as universal apps? This is not necessary. We will show you how to bring your app to Windows App Store and add all the new bells and whistles. We will teach your app new tricks. Your app is not dead. You do not need to move over from your old code. Bring your existing apps that you want to see in the App Store and we will roll up our sleeves and have your app shine as new Universal Apps by using the Desktop Bridge. Takeaways: 1. Ability to add UWP features to existing WPF or WinForms applications 2. Understanding Windows Store Deployment process 3. Window Store Listing",
               "room": "Room 109",
               "speaker": {
                   "web": "http://www.minmaung.com",
                   "location": "Chicago, IL",
                   "name": "Min Maung & Lwin Maung",
                   "bio": "Name a new technology that Min isn't interested in. Min has developed on all mobile platforms from latest Windows 8 to Windows Mobile 6.5. Of course that also means that he has had countless smartphones and tablets. Min is often honing his skills by aggressively competing in hackathons dating back to his days at Dominican University. Being technologically agnostic, he does not stop tinkering with mobile platforms like Android, he creates his own personal microcontrollers for robotics projects. When he's not coding, he's building robots. When he's not adding more robots to his robot army, you will see him speaking at conferences such as That Conference and CodeMash. Monday through Friday, you'll find him at Polaris Solutions, cranking out .Net code and writing apps in ASP.Net, KendoUI, Knockout.js, Node.js, and other web solutions.\n\nLwin Maung is a Microsoft Windows Development MVP and Senior Technical Architect for Concurrency. Lwin is an expert on mechatronics with over a decade of consulting experience. He has consulted for small startups, fortune 500 companies as well as NGOs world wide. Lwin's mobile applications have been featured on technology sites such as engadget, gizmodo, and pocket now. He has also designed and created programmable microcontrollers as well as microcontroller controlled robots from the ground up to use in teaching children(and teens) simple programming. In his free time, Lwin teaches and mentors highschool and university students who are building applications and developing hardware prototypes. Lwin was also involved in creation of various certification exams for Microsoft. Lwin is highly active in the development community and helps run Chicago Code Camp. You can find him speaking various technical conferences and code camps.",
                   "img": "me_-_Min_M.jpeg",
                   "imgLarge": null
               }
           },
           {
               "session": "Your brain is broken and you suck at making decisions",
               "time": "3:45 PM - 5:00 PM",
               "desc": "The human brain is really good at lots of things, but living and making decisions in our modern world typically isn't one of them. Learn about some of the ways our brain works less than optimally in decision making scenarios and how to stack the deck in favor of not totally messing things up. \r\n\r\nAfter exploring some of these concepts (they're features, not bugs, am I right?) we'll talk about why thinking in increments and iterations, and using empirical decision making can help us be more awesome.",
               "room": "Room 112",
               "speaker": {
                   "web": null,
                   "location": null,
                   "name": "Nate Adams",
                   "bio": "Nate has worked professionally in the IT industry for nearly 20 years developing software and mentoring and leading teams in a wide range of environments from small companies with dozens of employees to large global enterprises with over 20,000 employees. Nate currently brings this experience with him to NewBoCo in Cedar Rapids as he helps with their mission to make the Iowa Corridor an awesome place to work in tech. \r\n\r\nAs a software developer, Nate has written code and developed architecture for all aspects of systems from the UI through the middleware and to the back-end. Nate has also given many talks for user groups in the midwest on a broad range of technology topics. \r\n\r\nAs an agile enthusiast and coach, Nate has developed and coached agile teams using a broad array of methodologies. Nate has taught the Intro to Agile course at the University of Iowa Tippie College of Business as well as an agile certificate through Kirkwood Community College.",
                   "img": "NateAdams.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Building Large, Yet Maintainable, ASP.NET Applications",
               "time": "3:45 PM - 5:00 PM",
               "desc": "As an application adds more and more features, if you're not careful, it can quickly spiral into becoming the application no one on the team enjoys working on. This talk is structured as a series of lightning talks on various topics to help you improve the maintainability of your ASP.NET applications. We'll discuss libraries and best practices to help with folder structure, validation, ORM's, unit testing, code flow, DevOps, and more. By the end, you should be able to take at least one thing away that you can start implementing immediately when you get back to the office.",
               "room": "Room 113",
               "speaker": {
                   "web": "scottsauber.com",
                   "location": "Ankeny, Iowa",
                   "name": "Scott Sauber",
                   "bio": "I'm the Lead Developer at Iowa Bankers Association. I'm primarily a web developer using ASP.NET, JavaScript, HTML5, and fighting my way through CSS. I'm constantly learning and trying new things. I blog (primarily on ASP.NET Core) at scottsauber.com.",
                   "img": "Me400x400_-_Scott_Sauber.png",
                   "imgLarge": null
               }
           },
           {
               "session": "\"We'll do it live!\": Monitoring and Debugging in Production",
               "time": "3:45 PM - 5:00 PM",
               "desc": "That big \"P\" word: Production. That new piece of shiny code you just wrote with a hundred percent test coverage goes ka-put once it's deployed once deployed there. What broken, and why? Sometimes the errors are a little more subtle, lying and growing there until you reach the right conditions. Either way, when users experience problems, it's not good. \n\nMaybe we need to check our assumptions a bit and figure out how to lower the risk if things go sideways. We'll go over my experience in a highly regulated industry to apply the OODA loop, continuous delivery, ownership, and observability to embrace failure to lower risk of production incidents.",
               "room": "Room 114",
               "speaker": {
                   "web": null,
                   "location": "West Des Moines, IA",
                   "name": "Luke Amdor",
                   "bio": "Luke Amdor is a Principal Staff Engineer at Banno / Jack Henry and Associates where he leads the Infrastructure team. Banno began as a startup many years ago entering the financial technology services space. Three and a half years ago, this small Iowa start-up was acquired by Jack Henry and Associates, a S&P 400 publicly traded company with over 5,000 employees. Banno has continued to grow and thrive to be a remote-first business unit over almost 150 associates.\n\nHe's a person of many hats: having been an agile developer for 10+ years, he now focuses more on the infrastructure side of the world and figuring out how to empower development teams to deliver their best. He's currently interested in the Kubernetes ecosystem and cloud native technologies.",
                   "img": "14__NCB8600_T8_LowRes_-_Luke_Amdor.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "High Performance Websites Revisited",
               "time": "3:45 PM - 5:00 PM",
               "desc": "10 Years ago Steve Souders of Yahoo published the book High Performance Websites that described in depth how browser engines request assets and render html, and how to tune your pages for speed. Around the time the book was released, Yahoo also released YSlow, a tool which leveraged the highlights from the book to give a web page a grade for rendering speed and to help with tuning.\n\nDo the principles from 2007 still apply today? For this session a younger, hipper colleague of mine (Ben Kallaus, another developer at Telligen) will debate me as we cover the tuning recommendations made by the book and discuss whether they are still relevant. We will also spend part of this session reviewing developer tools built into Chrome and will describe how we use them as part of everyday development.",
               "room": "Room 115",
               "speaker": {
                   "web": null,
                   "location": "Des Moines, IA",
                   "name": "Daniel Juliano",
                   "bio": "I'm a Tech Lead for Telligen in West Des Moines. Am currently trawling the depths of legacy C# and VB.Net Winforms applications, and have spent my career trawling the waters of Javascript, Java, Groovy, PHP, Perl, and so forth and have served in Project Manager, Business Analyst, Data Analyst, and Quality Assurance roles. \n",
                   "img": "headshot_-_Daniel_Juliano.jpg",
                   "imgLarge": null
               }
           },
           {
               "session": "Closing Session",
               "time": "5:00 PM - 5:30 PM",
               "desc": "Wrap it up and go out with a bang.",
               "room": "Room 106 (Robert Half)",
               "speaker": {
                   "web": "http://www.iowacodecamp.com",
                   "location": "Des Moines, IA",
                   "name": "Iowa Code Camp",
                   "bio": "Iowa Code Camp!",
                   "img": "icc_logo_400.jpg",
                   "imgLarge": null
               }
           }
        ]
      }
    """
  end
end
