# Defending Server-Side Request Forgery Attacks (SSRF) using Cloud Armor.

Server-Side Request Forgery (SSRF) is a type of cyber attack in which an attacker tricks a server into requesting a different server or resource on behalf of the attacker. This can be used to gain unauthorized access to internal systems, steal sensitive information, or launch other attacks.

The attack is typically carried out by injecting a malicious URL or another request into a vulnerable application, which then sends the request to the targeted server or resource. The attacker can use this technique to bypass firewalls and other security measures that are in place to protect internal systems and resources.

Google Cloud Armor helps you protect your Google Cloud deployments from multiple types of threats, including distributed denial-of-service (DDoS) attacks and application attacks like cross-site scripting (XSS) and SQL injection (SQLi). Google Cloud Armor features some automatic protections and some that you need to configure manually. This document provides a high-level overview of these features, several of which are only available for global external HTTP(S) load balancers and global external HTTP(S) load balancer (classic)s.

### Solutions:

**Step 1:** Navigate to the registration page where the User can create a new account.

![](images/defending-against-web-application/1.png)

**Step 2:** Fill in the details and click the "Register" button.

![](images/defending-against-web-application/2.png)

**Step 3:** Now log in using the new credentials.

![](images/defending-against-web-application/3.png)

**Step 4:** Click on the Newpost tab from the navigation tab.

![](images/defending-against-web-application/4.png)

**Step 5:** Enter the headline and the given payload in the URL of the image.

```
file:///etc:/passwd
```

![](images/defending-against-web-application/5.png)

**Step 6:** Right-click on the screen and you will find inspect elements, click on that and open the "Network" tab. After that, click on the "Upload" button.

![](images/defending-against-web-application/6.png)

At the bottom, you will get a notification that "URL File uploaded successfully".

**Step 7:** See one file is named "save-content" whose value is the provided URL and status is 200, this will be our main file where we can check if our application is not secured against SSRF.

Because of this reason, we will see the response page.

![](images/defending-against-web-application/7.png)

**Step 8:** We can see a URL that is pointing towards a storage bucket where our png (output) is residing, so will open this URL in a new tab.

![](images/defending-against-web-application/8.png)

**Step 9:** All the /etc/passwd data is dumped in the response. This means that the SSRF is successful.

![](images/defending-against-web-application/9.png)

**Step 10:** To make our application more secure we can use Google cloud armor and as it can be applied on the load balancer and also need some front end to make our request redirect and check first we will create a **load balancer**.

For that go for **Load balancing** can search it.

![](images/defending-against-web-application/10.png)

**Step 11:** Click on Load Balancer.

![](images/defending-against-web-application/11.png)

**Step 12:** And select Http(S) Load balancing because this is what we will protect our layer 7.

Click on Start Configuration.

![](images/defending-against-web-application/12.png)

**Step 13:** We can continue with the default setting as it is recommended plus we are just getting our traffic from the internet and want to create a global HTTP **Load Balancer**

![](images/defending-against-web-application/13.png)

**Step 14:** After giving a name to your frontend-ip (we will create an HTTP with open port 80) and click on "Done".

![](images/defending-against-web-application/14.png)

And we will move to the backend configuration by clicking on it.

![](images/defending-against-web-application/15.png)

**Step 15:** At Backend Configuration, we will select backend services or backend buckets.

![](images/defending-against-web-application/16.png)

**Step 16:** Click on "Create a Backend Services".

![](images/defending-against-web-application/17.png)

**Step 17:** At this point there we will first give a name to our backend services and then give "Serverless network endpoint group" as our backend type.

![](images/defending-against-web-application/18.png)

**Step 18:** After selecting the serverless network endpoint group we have to select a group or create one, as of now we don't have one so let's create one.

By clicking on "Create serverless network endpoint group"

![](images/defending-against-web-application/19.png)

**Step 19:** Here we have to

* Give name (what you like),

* region as us-west1 (Here we have our backend cloud function)),

* Select cloud function,

* Select backend-function because this is the brains of the website,

* Click on Create.

![](images/defending-against-web-application/20.png)

This will create our serverless network endpoint group which then is used in backend services to make our load balancer possible.

**Step 20:** After the completion of the serverless group click on done and uncheck the enable cloud cdn because we don't need this for our website and it put extra cost too.

![](images/defending-against-web-application/21.png)

Click on Create.

![](images/defending-against-web-application/22.png)

**Step 21:** Now our backend service is created so click on ok (if the service is selected as in the image or select it and click on ok to move next)

![](images/defending-against-web-application/23.png)

**Step 22:** Now move to Routing rules which are used to define how incoming traffic is distributed to all the instances within the backend pool.

![](images/defending-against-web-application/24.png)

**Step 23:** There we will put the mode as a simple host and path rule and just have the default one in place.

Give a name to the load balancer.

Click on Create (Can go to Review and finalize too to make sure everything is fine and as expected)

![](images/defending-against-web-application/25.png)

**Step 24:** It can take some moments to create a load balancer.

![](images/defending-against-web-application/26.png)

When created you can see the protocol as HTTP and in backends, it will have one network endpoint group (that we created in the above steps)

![](images/defending-against-web-application/27.png)

**Step 25:** After the successful completion click on the name of the load balancer it will open the detail page of that load balancer.

![](images/defending-against-web-application/28.png)

**Step 26:** There we can see a frontend endpoint with HTTP protocol, As we can't just use this IP in our main production application we have to redirect this http to https to be usable in our main application.

The main problem is to do that we can use a new domain and link that IP and make it secure.

Another thing we can do is redirect it with the cloud function and use the HTTPS function link as our new backend function which our application users can access at the place of the current backend link then we can secure the load balancer which ultimately secures our application (against web application attacks).

![](images/defending-against-web-application/29.png)

**Step 27:** As our plan, we will go and create a Cloud function to make our HTTP front-end HTTPS

Search for the Cloud function in the GCP and select it.
![](images/defending-against-web-application/30.png)

**Step 28:** Click on Create Function.

![](images/defending-against-web-application/31.png)

**Step 29:** We will create a 2nd gen function and give it a name in our case it is redirection will create on the same region as other (us-west1). And for the trigger will click on **"Allow unauthenticated invocation"**.

Click on next

![](images/defending-against-web-application/32.png)

**Step 30:** Then select
* For runtime select python 3.9
* And put endpoint as main (because this will be our main invocation point for this function)
* Put the code there as provided below and **Update the frontend_path with your load balancer IP address**
* Then will move to requirements.txt and then can deploy the cloud function.

###### main.py
```
import functions_framework
import requests
import json
from flask import Response, make_response, Flask, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

@functions_framework.http
def main(req):
    path = req.path
    path = path[1:]

    method = req.method
    frontend_path = <<<your load balancer ip>>>

    JWT_TOKEN = req.headers.get('JWT_TOKEN') or req.headers.get('jwt_token')
    headers = {
        "JWT_TOKEN": JWT_TOKEN
    }

    try:
        data = json.loads(req.data)
    except:
        data = {}

    url = frontend_path+path
    print("url")
    print(url)

    try:
        args = req.args.get('value')
    except:
        args = None

    if args:
        url = url+"?value="+args

    if method == 'OPTIONS':
        resp = make_response()
        resp.headers['Access-Control-Allow-Origin'] = '*'
        resp.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
        resp.headers['Access-Control-Allow-Headers'] = 'Content-Type, JWT_TOKEN, jwt_token'
        return resp

    elif method == 'GET':
        response = requests.get(url, headers=headers)
        resp = make_response(response.text)
        resp.headers['Access-Control-Allow-Origin'] = '*'
        resp.headers['Access-Control-Allow-Headers'] = 'Content-Type, JWT_TOKEN, jwt_token'
        return resp

    else:
        if data:
            response = requests.post(url, data=json.dumps(data), headers=headers)
        else:
            response = requests.post(url, data={}, headers=headers)
        resp = make_response(response.text)
        resp.headers['Access-Control-Allow-Origin'] = '*'
        resp.headers['Access-Control-Allow-Headers'] = 'Content-Type, JWT_TOKEN, jwt_token'
        return resp

```

![](images/defending-against-web-application/33.png)

**Step 31:** And complete the requirements.txt file, so the function can run smoothly.

###### requirements.txt

```
functions-framework==3.*
requests==2.28.2
flask==2.2.2
flask-cors==3.0.10
```

After that can deploy the cloud function.

![](images/defending-against-web-application/34.png)

**Step 32**: It can take some moments to deploy the cloud function.

![](images/defending-against-web-application/35.png)

**Step 33**: When successfully deployed you can copy this URL as we will replace this URL with the old URL which is used in the production application.

![](images/defending-against-web-application/36.png)

**Step 34** So the question arises where we are going to change to see what we can do it just inspect our gcp page where we have done ssrf there we can see a script file named "main.adc6b28e.js" and there we can see the filename and the indirectly full path is there and the host is in storage bucket so it means we have to make a change at that place.

![](images/defending-against-web-application/useable_in_between_01.png)

**Step 35:** For the same, we will search for the buckets and select them as shown in the below image.

![](images/defending-against-web-application/37.png)

**Step 36:** As we have seen the above image file path was "prod-blogapp-random-no./webfiles/build/static/js/main (file)"

So will follow that path as google storage buckets select prod-blagapp-* folder.

![](images/defending-against-web-application/38.png)

Then we will select "webfiles" folder.

![](images/defending-against-web-application/39.png)

After that, we will select the "build" folder.

![](images/defending-against-web-application/40.png)

After build Select "static" folder

![](images/defending-against-web-application/41.png)

And then select the js folder to get the main file.

![](images/defending-against-web-application/42.png)

**Step 37:** At this place, we can see our main.adc6b28.js file we want to edit this file now but this file is not downloadable directly so we will use a terminal for this, first click on the file name to get more details.

![](images/defending-against-web-application/43.png)

**Step 38:** There we got the public URL for the file before copying that pasting the redirection (cloud function) function invocation URL somewhere. and copy the public URL to download this code.

![](images/defending-against-web-application/44.png)

**Step 39:** Then we will use wget to fetch and download the content on the public URL.

```
wget public-url-of-the-main-file.bucket
```

![](images/defending-against-web-application/45.png)

**Step 40:** You can open the file with your favorite text editor.

![](images/defending-against-web-application/46.png)

**Step 41:** There we will update the baseURL but we have to find the one which is using the old URL ending with backend-function

![](images/defending-against-web-application/47.png)

**Step 42:** When you got the baseURL similar to the given images then change the URL with the copied/stored redirection function invocation URL.

![](images/defending-against-web-application/48.png)

**Step 43:** Now save the file and can see how would it look when you change the URL.

![](images/defending-against-web-application/49.png)

**Note:** Make sure to save the file with the same name as before so we can upload the file and overwrite the content.

**Step 44:** So at the same path we will upload the file we recently changed.

![](images/defending-against-web-application/50.png)

**Note:** You can see the file name is the same one that we are going to upload.

**Step 45:** Select the file which we want to upload.

![](images/defending-against-web-application/51.png)

**Step 46:** Then a pop-up will appear there we will select overwrite object.

![](images/defending-against-web-application/52.png)

**Step 47:** After that click on **"Continue Uploading"** the file

![](images/defending-against-web-application/53.png)

#### Note: It could take time (up to 1-2 hr.) to refresh and use the new baseURL.

**Step 48:** After that, we check if our URL is working right or not

Open the same URL that we were using at the start you will see everything working as expected.

![](images/defending-against-web-application/54_1.png)

**Step 49:** And to confirm if our new backend is in use we can go to the inspect element with a right click or with "Ctrl+Shift+I" we can see a domain with redirection and if we click on it we can get more details (as shown in the right panel)


![](images/defending-against-web-application/55_1.png)

Can confirm it with the function URL too.

![](images/defending-against-web-application/56.png)

**Step 50:** So if the website is visible we can now apply our rules with cloud armor. So we first search for Cloud armor in the GCP search section.

![](images/defending-against-web-application/57.png)

**Step 51:** Now we will create a policy in cloud armor.

![](images/defending-against-web-application/58.png)

**Step 52:** On first we have to give a name for the security policy and then make the default rule action deny (which is to make everyone access the target (which is in our case load balancer) or not ). and click on the next step.

![](images/defending-against-web-application/59.png)

**Step 53:** After the creation of configure file we will add rules.

Click on add rule.

![](images/defending-against-web-application/60.png)

**Step 54:** Click on advanced mode for specifying a custom query.

and paste the below query by which we deny any kind of query which is accessing the file

```
request.query.matches('(?i:file)')
```

![](images/defending-against-web-application/61.png)

**Step 55:** As said we will deny the action which matches the query (which matches if a request is for accessing the file) with response code 403 forbidden and with the highest priority (0). And click on done.

![](images/defending-against-web-application/62.png)

**Step 56:** After applying the rules we will add a target (our load balancer)

Click on "ADD TARGET".

![](images/defending-against-web-application/63.png)

**Step 57:** There we can see our created backend which is connected to our load balancer. Select it and then click on the next step.

![](images/defending-against-web-application/64.png)

**Step 58:** In the advanced configuration we will enable adaptive protection and then create a policy.

### Adaptive Protection

Adaptive Protection helps you protect your applications and services from L7 distributed denial-of-service (DDoS) attacks by analyzing patterns of traffic to your backend services, detecting and alerting on suspected attacks, and generating suggested WAF rules to mitigate such attacks. These rules can be tuned to meet your needs. Adaptive Protection can be enabled on a per-security policy basis, but it requires an active Managed Protection subscription in the project.

![](images/defending-against-web-application/65.png)

**Step 59:** It will take some moments to deploy the cloud armor.

![](images/defending-against-web-application/66.png)

After the successful completion of the security policy, you can see that there are two rules and one target as expected.

![](images/defending-against-web-application/67.png)

**Step 60:** Now again go to the login page and enter the same user email and password we had created (it will check that yes our new redirection base url is working as expected).

![](images/defending-against-web-application/68.png)

**Step 61:** Click on the Newpost tab from the navigation tab.

![](images/defending-against-web-application/69.png)

**Step 62:** Enter the headline and the given payload in the URL of the image.

```
file:///etc:/passwd
```

![](images/defending-against-web-application/70.png)

**Step 63:** In the inspect element we can see the request has been main and the status is 200 but the domain is our redirection one. The 200 here means the request has been done but again our cloud armor will prevent this attack and make a response so let's see the same by clicking on the domain we will see more details in the right panel.

![](images/defending-against-web-application/71.png)

**Step 64:** Now we can see a request priority as highest which we had set up in the security policy that handles this type of request at 0 (highest) priority.

![](images/defending-against-web-application/72.png)

**Step 65:** Click on the response section to see, if can we get the same storage URL and get the root passwd as got before.  

![](images/defending-against-web-application/73.png)

**Step 66:** In response, we get 403 Forbidden which means our cloud armor is working as expected as protecting our website from SSRF attacks.

![](images/defending-against-web-application/74.png)


#### WE have successfully defended our application against Server-Side Request Forgery (SSRF) Attacks with Cloud armor.
