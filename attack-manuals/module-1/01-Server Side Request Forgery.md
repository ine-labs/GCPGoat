# Objectives

We will try to perform an SSRF attack and try to fetch the source code file from the cloud function. Then dumping the database to overtake the admin account of the blog app.

# Solution

**Step 1:** Open the web application and register a new user. Then put in the login credentials on the login page and interact with the web app.

![](https://user-images.githubusercontent.com/54552051/204803419-8f935043-5622-4191-88a1-73bfe9cec415.png)

![](https://user-images.githubusercontent.com/54552051/204803427-c3e08c6b-b875-42d8-8d32-cbc6e3e86cf6.png)

**Step 2:** From the side navigation menu select the Newpost section.

![](https://user-images.githubusercontent.com/54552051/204803431-12e96022-7659-4652-9645-4837241ef490.png)

Enter any demo headline for the post like, "SSRF test". Also, fill in the Author's Name.

In the "Enter URL of image" field, write down the below-mentioned payload.

Payload:

```
file:///etc/passwd
```

**Step 3:** First, right-click on the screen and you will find inspect elements, click on that and open the "Network" tab. After that, click on the "Upload" button.

![](https://user-images.githubusercontent.com/54552051/204803434-f7fcacc0-98af-4da9-8502-ad480c797d02.png)

At the bottom, you will get a notification that "URL File uploaded successfully". 

**Step 4:** Open the response and copy the URL and open it in a new tab. This will either show the contents in the browser itself or download the file.

![](https://user-images.githubusercontent.com/54552051/204803439-64c53c62-59b5-42f9-b32d-30c621891f3f.png)

![](https://user-images.githubusercontent.com/54552051/205139292-978765fd-ef04-4860-8aba-22c306999f7f.png)

All the /etc/passwd data is dumped in the response. This means that the SSRF is successful.

**Step 5:** Dump the cloud function environment data using the payload for the URL as:

```
file:///proc/self/environ
```

This file will give us all the information related to the cloud function environment.

![](https://user-images.githubusercontent.com/54552051/204803443-15d60b12-b428-4924-935a-8f6a135253f6.png)

After you see that the URL file uploaded successfully. Copy the response URL and open it in a new tab.

![](https://user-images.githubusercontent.com/54552051/204803449-5d1bbe7d-0a93-4191-ba70-baca779657bc.png)

This will download the file in your system.

Use the **cat** command to get the file contents.

![](https://user-images.githubusercontent.com/54552051/204803453-ecdf02d7-33c9-4712-879c-c2130e62eaad.png)

You can get a bunch of information from here, GCP project name, and some JWT_SECRET set into the environment of the function. Also, you can see that the function is using python runtime.

**Step 6:** Dump the source code of the function using the payload for the URL as:

```
file:///workspace/main.py
```

For GCP cloud functions with python run time, source code files exists in **workspace** directory.

![](https://user-images.githubusercontent.com/54552051/204803454-d7389ed7-eacb-4417-9c68-3321da836427.png)

After you see that the URL file uploaded successfully. Copy the response URL and open it in a new tab.

![](https://user-images.githubusercontent.com/54552051/204803457-bbec3767-698d-4926-956c-47997e9f319c.png)

The whole source code is now dumped into the response file. This is the source code for the same function which was being called for uploading the image URL.

In the code, you will find a development endpoint for the function.

![](https://user-images.githubusercontent.com/54552051/205139539-715f5768-8cd9-448f-85d7-2696a8c7e5f7.png)

This seems to be dumping out all the data from the database.

**Step 7:** Get the function URL from the request header of any request you made for uploading the URL file.

![](https://user-images.githubusercontent.com/54552051/205139527-23a9bc7a-bc5c-4b28-8ebf-5ae5a2f918fe.png)

Hit the development endpoint with the below URL:

```
<FunctionURL>/dump-db-321423541325
```

![](https://user-images.githubusercontent.com/54552051/204803467-89a70091-006b-4f21-8776-4e4862b5f8b3.png)

The whole database is dumped into the browser.

You can check that the secret answer is stored in plain text form which can be used for resetting the password. Get the email and secret question/answer of an account that has auth level as **0**.

![](https://user-images.githubusercontent.com/54552051/204803472-992b8bd6-ca23-4e2c-951a-19e4c2cb8678.png)

**Step 8:** Go back to the login page and click on **forgot password**.

![](https://user-images.githubusercontent.com/54552051/204803475-a4b86350-657c-4601-b226-ab04be3e2ed3.png)

Enter the details of the account you noted down from the previous step. Set a new password and click on **Reset**.

![](https://user-images.githubusercontent.com/54552051/204803477-d46fb01a-fa07-438e-b5ef-7c8c4066266a.png)

You will see the message **password changed successfully** in the lower left corner of the page.

**Step 9:**Go back to the login page and use the email with the new password to log in.

![](https://user-images.githubusercontent.com/54552051/204803480-33ce7eea-1ce3-489e-b305-40701d9e00c4.png)

You will be successfully logged in with the compromised account.

![](https://user-images.githubusercontent.com/54552051/204803483-a48bceae-69f3-45d7-b24e-f83a039ab3b9.png)

You can navigate to the **User** section to confirm that the compromised user is an **admin** for this blog application.

![](https://user-images.githubusercontent.com/54552051/204803485-60af1708-3aa1-4380-b2a0-f23dfd5ea243.png)