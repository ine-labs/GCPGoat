# GCPGoat : A Damn Vulnerable GCP Infrastructure

<p align="center">
  <img src="https://user-images.githubusercontent.com/42687376/204150661-3d576909-e271-4a3a-8996-37939f977315.jpg">
</p>

Compromising an organization's cloud infrastructure is like sitting on a gold mine for attackers. And sometimes, a simple misconfiguration or a vulnerability in web applications, is all an attacker needs to compromise the entire infrastructure. Since the cloud is relatively new, many developers are not fully aware of the threatscape and they end up deploying a vulnerable cloud infrastructure.

GCPGoat is a vulnerable by design infrastructure on GCP featuring the latest released OWASP Top 10 web application security risks (2021) and other misconfiguration based on services such as IAM, Storage Bucket, Cloud Functions and Compute Engine. GCPGoat mimics real-world infrastructure but with added vulnerabilities. It features multiple escalation paths and is focused on a black-box approach.

GCPGoat uses IaC (Terraform) to deploy the vulnerable cloud infrastructure on the user's GCP account. This gives the user complete control over code, infrastructure, and environment. Using GCPGoat, the user can learn/practice:
- Cloud Pentesting/Red-teaming
- Auditing IaC
- Secure Coding
- Detection and mitigation

The project will be divided into modules and each module will be a separate web application, powered by varied tech stacks and development practices. It will leverage IaC through terraform to ease the deployment process.

[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fine-labs%2FGCPGoat&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)

### Presented at

* [BlackHat ASIA 2023](https://www.blackhat.com/asia-23/arsenal/schedule/index.html#gcpgoat--a-damn-vulnerable-gcp-infrastructure-31312)

### Developed with :heart: by [INE](https://ine.com/) 

[<img src="https://user-images.githubusercontent.com/25884689/184508144-f0196d79-5843-4ea6-ad39-0c14cd0da54c.png" alt="drawing" width="200"/>](https://discord.gg/TG7bpETgbg)

## Built With

* Google Cloud Platform (GCP)
* React
* Python 3
* Terraform

## Vulnerabilities

The project is scheduled to encompass all significant vulnerabilities including the OWASP TOP 10 2021, and popular cloud misconfigurations.
Currently, the project  contains the following vulnerabilities/misconfigurations.

* XSS
* Insecure Direct Object reference
* Server Side Request Forgery on Cloud Function
* Sensitive Data Exposure and Password Reset
* Storage Bucket Misconfigurations
* IAM Privilege Escalations


# Getting Started

### Prerequisites
* A GCP Account with Administrative Privileges

### Installation

Manually installing GCPGoat would require you to follow these steps:

(Note: This requires a Linux Machine, with the /bin/bash shell available)

**Step 1.** Clone the repo
```sh
git clone https://github.com/ine-labs/GCPGoat
```

**Step 2.** Configure the GCP User Account Credentials using gcloud CLI
```sh
gcloud auth application-default login
```
**Step 3.** Insert the Billing Account name in main.tf file

```hcl
data "google_billing_account" "acct" {
  display_name = "<Your Billing Account Name>"
}
```

**Step 4.** In the same working directory use terraform to deploy GCPGoat.

```sh
terraform init
terraform apply --auto-approve
```

# Modules

## Module 1

The first module features a serverless blog application utilizing Cloud Functions, Cloud Storage Buckets, Compute Engine and Firestore. It consists of various web application vulnerabilities and facilitates exploitation of misconfigured GCP resources.

Escalation Path:

<p align="center">
  <img src="https://user-images.githubusercontent.com/42687376/204155231-6e80bd8c-cb86-469e-a59b-acbec0dc8a25.png">
</p>

**Recommended Browser:** Google Chrome

# Pricing
The resources created with the deployment of GCPGoat will not incur any charges if the GCP account is under the free tier/trial period. However, upon exhaustion/ineligibility of the free tier/trial, the following charges will apply for the US-East region:

Module 1: $0.03/hour

# Contributors

Nishant Sharma, Director, Lab Platform, INE <nsharma@ine.com>

Jeswin Mathai, Chief Architect, Lab Platform, INE  <jmathai@ine.com>

Sherin Stephen, Software Engineer (Cloud), INE <sstephen@ine.com>

Divya Nain, Software Engineer (Cloud), INE  <dnain@ine.com>

Rishappreet Singh Moon, Software Engineer (Cloud), INE <rmoon@ine.com> 

Litesh Ghute, Software Engineer (Cloud), INE <lghute@ine.com> 

Sanjeev Mahunta, Software Engineer (Cloud), INE <smahunta@ine.com>

# Solutions

The offensive manuals are available in the [attack-manuals](attack-manuals/) directory, and the defensive manuals are available in the [defence-manuals](defence-manuals/) directory. 

# Screenshots

Module 1:


<p align="center">
  <img src="https://user-images.githubusercontent.com/42687376/204152524-48253d8e-d1ce-48ca-b60b-6a12d97aa210.png">
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/42687376/204152571-c99b4632-61b3-4131-85ec-58cc128cb7cd.png">
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/42687376/204152587-a8f9595f-7fa6-41a1-af0f-5fb4eb44da4d.png">
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/42687376/204152593-187e7640-94b5-4be0-b1f2-c3bb2ac954ca.png">
</p>

## Contribution Guidelines

* Contributions in the form of code improvements, module updates, feature improvements, and any general suggestions are welcome. 
* Improvements to the functionalities of the current modules are also welcome. 
* The source code for each module can be found in ``modules/module-<Number>/src`` this can be used to modify the existing application code.

# License

This program is free software: you can redistribute it and/or modify it under the terms of the MIT License.

You should have received a copy of the MIT License along with this program. If not, see https://opensource.org/licenses/MIT.

# Sister Projects

- [AWSGoat](https://github.com/ine-labs/AWSGoat)
- [AzureGoat](https://github.com/ine-labs/AzureGoat)
- [PA Toolkit (Pentester Academy Wireshark Toolkit)](https://github.com/pentesteracademy/patoolkit)
- [ReconPal: Leveraging NLP for Infosec](https://github.com/pentesteracademy/reconpal) 
- [VoIPShark: Open Source VoIP Analysis Platform](https://github.com/pentesteracademy/voipshark)
- [BLEMystique](https://github.com/pentesteracademy/blemystique)
