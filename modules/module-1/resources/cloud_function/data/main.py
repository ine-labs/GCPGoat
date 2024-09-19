import base64
import json
import logging
import os
import traceback
import urllib
from datetime import datetime, timedelta

import bcrypt
import jwt
from crud import *
from flask import Response
from google.cloud import storage


def generateResponse(statusCode, body):
    headers = {
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Origin": "*",
    }
    return Response(
        body,
        headers=headers, status=statusCode
    )

def download_url(url):
    req = urllib.request.Request(url, headers={"User-Agent": "Magic Browser"})
    image = urllib.request.urlopen(req).read()
    return image

#upload function here
def upload_file(img_data, bucket_name, url=None):
    client = storage.Client()
    bucket = client.get_bucket(bucket_name)
    file_b64 = ""

    if url == True:
        file = download_url(img_data)
        print(file)
    else:
        file = base64.b64decode(img_data)
    try:
        destination_blob_name = "images/" + datetime.utcnow().strftime("%Y%m%d%H%M%S%f") + ".png"
        blob = bucket.blob(destination_blob_name)
        blob.upload_from_string(file)
        url = 'https://storage.googleapis.com/%(mybucket)s/%(file)s'%{'mybucket': bucket_name, 'file':destination_blob_name}
        return url
    except Exception as e:
        print(str(e))
        return "Please try with another image"

def generate_auth(userInfo):
    if userInfo is not None:
        JWT_SECRET = os.environ['JWT_SECRET']
        userInfo['exp'] = datetime.now() + timedelta(seconds=3600)
        return jwt.encode(payload=userInfo, key=JWT_SECRET, algorithm='HS256')
    else:
        return None

def auth_is_valid(req):
    JWT_SECRET = ''
    JWT_TOKEN = req.headers.get('JWT-TOKEN') or req.headers.get('jwt-token')
    if JWT_TOKEN != '':
        JWT_SECRET = os.environ['JWT_SECRET']
        try:
            decode_token = jwt.decode(
                JWT_TOKEN, JWT_SECRET, algorithms=['HS256'])
            print("Token is still valid and active")
            return True
        except jwt.ExpiredSignatureError:
            print("Token expired. Get new one")
            return False
        except jwt.InvalidTokenError as e:
            print("Invalid Token")
            return False
    else:
        print("returning false authentication")
        return False


def main(req):
    path = req.path
    path = path[1:]
    method = req.method
    try:
        data = json.loads(req.data)
    except:
        data = {}

    print(data)
    logging.info(data)
    responses = ''
    userTable = 'users'
    postsTable = 'blogs'
    
    if method == "POST" and path == "register":
        new_user = {}
        if "email" in data:
            new_user["email"] = data["email"].lower().strip()
        if "address" in data:
            new_user["address"] = data["address"]
        if "country" in data:
            new_user["country"] = data["country"]
        if "name" in data:
            new_user["name"] = data["name"]
        if "phone" in data:
            new_user["phone"] = data["phone"]
        if "secretQuestion" in data:
            new_user["secretQuestion"] = data["secretQuestion"]
        if "secretAnswer" in data:
            new_user["secretAnswer"] = data["secretAnswer"]
        if "creationDate" in data:
            new_user["creationDate"] = data["creationDate"]
        if "username" in data:
            new_user["username"] = data["username"].lower().strip()
        if "password" in data:
            new_user["password"] = data["password"].encode('utf-8').strip()

        required_info = ["email", "username", "password",
                            "country", "secretQuestion", "secretAnswer"]

        for field in required_info:
            if field not in new_user:
                return generateResponse(200, "Fields required")

        new_user['authLevel'] = '300'
        new_user['userStatus'] = 'active'

        response = list(read(userTable))
        logging.info(response)
        items = response

        condition = "email == {}".format(str(new_user["email"]))
        check_user_email = list(read(userTable, condition))

        logging.info(check_user_email)
        # if 'Item' in check_user_email:
        if len(check_user_email) != 0:
            responses = "User with email already exists. Please choose a different email address"
            return generateResponse(200, json.dumps({"body": responses}))

        new_user["id"] = str(len(items)+1)
        logging.info("id is")
        logging.info(new_user["id"])
        new_user["password"] = bcrypt.hashpw(
            new_user["password"], bcrypt.gensalt(rounds=10)).decode('utf-8')
        
        create(userTable, new_user)

        responses = "User Registered"
        return generateResponse(200, json.dumps({"body": responses}))

    elif method == "POST" and path == "login":
        user_email = data['email']
        user_password = data['password']

        condition = "email == {}".format(user_email)
        db_user = list(read(userTable, condition))

        logging.info("new user is")
        logging.info(db_user)


        if user_email != db_user[0]['email']:
            responses = "User with email "+user_email+" not found"
            return generateResponse(200, json.dumps({"body": responses}))
        if db_user[0]['userStatus'] == "banned":
            responses = "User is banned. Please contact your administrator"
            return generateResponse(200, json.dumps({"body": responses}))
        if not bcrypt.checkpw((user_password).encode('utf-8'), (db_user[0]['password']).encode('utf-8')):
            responses = "Incorrect Password!!"
            return generateResponse(200, json.dumps({"body": responses}))

        userInfo = {
            'id': db_user[0]['id'],
            'email': db_user[0]['email'],
            'name': db_user[0]['name'],
            'authLevel': db_user[0]['authLevel'],
            'address': db_user[0]['address'],
            'country': db_user[0]['country'],
            'phone': db_user[0]['phone'],
            'secretQuestion': db_user[0]['secretQuestion'],
            'secretAnswer': db_user[0]['secretAnswer'],
            'username': db_user[0]['username'],
            'admin': 'johndoe@gmail.com'
        }
        logging.info("Userinfo is")
        logging.info(userInfo)
        gen_token = generate_auth(userInfo)
        responses = {
            'user': userInfo,
            'token': (gen_token).decode('utf-8')
        }
        logging.info(responses)
        return generateResponse(200, json.dumps({"body": responses}))
    
    elif method == "POST" and path == "reset-password":    
        if 'email' not in data or 'secretQuestion' not in data or 'secretAnswer' not in data or 'password' not in data:
            responses="All fields are required"
            return generateResponse(200, json.dumps({"body": responses}))

        email=data['email'].lower().strip()
        secretQuestion=data['secretQuestion']
        secretAnswer=data['secretAnswer']
        newPassword=data['password']

        condition = "email == {}".format(str(email))
        user_data = list(read(userTable, condition))        
        
        if user_data[0]['secretQuestion'] != secretQuestion or user_data[0]['secretAnswer'] != secretAnswer:
            responses="Secret question or key doesn't match"
            return generateResponse(200, json.dumps({"body": responses}))

        encryptedPW = bcrypt.hashpw((newPassword).encode('utf-8'), bcrypt.gensalt(rounds=10))

        for item in user_data:
            if item['email'] == email:
                new_item = item
                new_item['password'] = (encryptedPW).decode('utf-8')
                value = {'password':new_item['password']} 
                update_response = update(userTable, value,item["id"])
                break

        responses = "Password changed successfully"
        return generateResponse(200, json.dumps({"body": responses}))

    #Only for Development
    elif method == "GET" and path == "dump-db-321423541325":
        postItems = list(read(postsTable))

        userItems = list(read(userTable))

        responses=userItems+postItems
        return generateResponse(200, json.dumps({"body": responses}))
    
    elif method == "POST" and path == "list-posts":
        try:
            data = json.loads(req.data)
        except:
            data = None
        if data is None:
            items = list(read(postsTable))
            for item in items:
                if item['postStatus'] != 'approved':
                    items.remove(item)
            for item in items: 
                if item['postStatus'] != 'approved':
                    items.remove(item)
            return generateResponse(200, json.dumps({"body": items}))

        authLevel=data['authLevel']
        postStatus=data['postStatus']
        email= data['email']

        items = list(read(postsTable))     

        responses=[]
        if authLevel=='0' or authLevel=='100':
            if postStatus!='all':
                for i in range(len(items)):
                    item=items[i]
                    if item['postStatus'] == postStatus:
                        responses.append(item)
            else:
                for i in range(len(items)):
                    item=items[i]
                    responses.append(item)
        else:
            if postStatus!='all':
                for i in range(len(items)):
                    item=items[i]
                    if item['postStatus'] == postStatus and item['email']==email:
                        responses.append(item)
            else:
                for i in range(len(items)):
                    item=items[i]
                    if item['email']==email:
                        responses.append(item)

        print(len(items))
        print(len(responses))
        return generateResponse(200, json.dumps({"body": responses}))

    if auth_is_valid(req):

        if method == "POST" and path == "change-password":
            id = data['id'].strip()

            if 'newPassword' not in data or 'confirmNewPassword' not in data:
                responses = 'New password & Confirm new password are mandatory'
                return generateResponse(200, json.dumps({"body": responses}))

            newPassword = data['newPassword'].strip()
            confirmNewPassword = data['confirmNewPassword'].strip()

            if (newPassword != confirmNewPassword):
                responses = 'New password & Confirm new password must match'
                return generateResponse(200, json.dumps({"body": responses}))

            db_data = list(read(userTable))

            for item in db_data:
                if item['id'] == id:
                    email=item['email']
                    break

            encryptedPW = bcrypt.hashpw((newPassword).encode('utf-8'), bcrypt.gensalt(rounds=10))

            for item in db_data:
                if item['id'] == id:
                    new_item = item
                    new_item['password'] = (encryptedPW).decode('utf-8')
                    value = {"password":new_item["password"]}
                    update_response = update(userTable, value,item["id"])
                    break
            
            responses = {
                'email': email,
                'newPassword': newPassword,
                'message': "Password changed successfully",
                'authLevel': db_data[0]['authLevel'],
                'country': db_data[0]['country'],
                'id': id,
                'phone': db_data[0]['phone'],
                'username': db_data[0]['username'],
                'userStatus': db_data[0]['userStatus']
            }
            return generateResponse(200, json.dumps({"body": responses}))

        

        elif method == "POST" and path == "ban-user":
            if 'name' not in data or 'authLevel' not in data or 'email' not in data:
                responses = "Something is missing. Please check proper authentication"
                return generateResponse(200, json.dumps({"body": responses}))

            name = data['name']
            authLevel = data['authLevel']
            email = data['email']

            if authLevel != '0':
                responses = "Requires Admin"
                return generateResponse(200, json.dumps({"body": responses}))

            condition = "email == {}".format(str(email))
            check_user = list(read(userTable, condition)) 

            if 'email' not in check_user[0]:
                responses = "User does not exists"
                return generateResponse(200, json.dumps({"body": responses}))

            if check_user[0]['userStatus'] == 'banned':
                responses = "User already banned"
                return generateResponse(200, json.dumps({"body": responses}))
            else:
                for item in check_user:
                    if item['email'] == email:
                        new_item = item
                        new_item['userStatus'] = 'banned'
                        value = {"userStatus":new_item["userStatus"]}
                        update_response = update(userTable, value,item["id"])

                        break
                responses = "User "+email+" Banned"
                return generateResponse(200, json.dumps({"body": responses}))

        elif method == "POST" and path == "unban-user":
            if 'name' not in data or 'authLevel' not in data or 'email' not in data:
                responses = "Something is missing. Please check proper authentication"
                return generateResponse(200, json.dumps({"body": responses}))

            name = data['name']
            authLevel = data['authLevel']
            email = data['email']

            if authLevel != '0':
                responses = "Requires Admin"
                return generateResponse(200, json.dumps({"body": responses}))

            condition = "email == {}".format(str(email))
            check_user = list(read(userTable, condition)) 

            if 'email' not in check_user[0]:
                responses = "User does not exists"
                return generateResponse(200, json.dumps({"body": responses}))

            if check_user[0]['userStatus'] != 'banned':
                responses = "User already Unbanned"
                return generateResponse(200, json.dumps({"body": responses}))
            else:
                for item in check_user:
                    if item['email'] == email:
                        new_item = item
                        new_item['userStatus'] = 'active'
                        value = {"userStatus":new_item["userStatus"]}
                        update_response = update(userTable, value,item["id"])
                        break
                responses = "User "+email+" Unbanned"
                return generateResponse(200, json.dumps({"body": responses}))

        elif method == "POST" and path == "xss":
                responses = data['scriptValue']
                return generateResponse(200, json.dumps({"body": responses}))
        
        elif method == "POST" and path == "save-post":
            new_post = {}
            if "postTitle" in data:
                new_post["postTitle"] = data["postTitle"]
            if "authorName" in data:
                new_post["authorName"] = data["authorName"]
            if "postingDate" in data:
                new_post["postingDate"] = data["postingDate"]
            if "email" in data:
                new_post["email"] = data["email"]
            if "postContent" in data:
                new_post["postContent"] = data["postContent"]
            if "getRequestImageData" in data:
                new_post["getRequestImageData"] = data["getRequestImageData"]

            required_info = ["postTitle", "authorName", "postingDate",
                                "email", "postContent", "getRequestImageData"]

            for field in required_info:
                if field not in new_post:
                    return generateResponse(200, "Fields required")

            new_post['postStatus'] = 'pending'
            items = list(read(postsTable))

            new_post['id'] = str(len(items)+1)
            create(postsTable, new_post)
            
            responses = "Post Added"
            return generateResponse(200, json.dumps({"body": responses}))

        elif path == "save-content":
            bucket = os.environ['BUCKET_NAME']
            if method == "POST":
                try:
                    img_data = json.loads(req.data)
                except:
                    img_data = {}
                responses = upload_file(img_data['value'], bucket)
                print(responses)
                return generateResponse(200, json.dumps({"body": responses}))

            elif method == "GET":
                try:
                    img_data = req.args.get('value')
                except:
                    img_data = ''

                # print(img_data)
                responses = upload_file(img_data, bucket, True)
                return generateResponse(200, json.dumps({"body": responses}))
            else:
                return generateResponse(200, json.dumps({"body": responses}))

        elif method == "POST" and path == "search-author":

            name = data["value"]
            authLevel = data['authLevel']
            
            if authLevel == '300':
                exec_statement="name == "+name+" and authLevel == 300,200"
            elif authLevel == '200':
                exec_statement="name == "+name+" and authLevel == 300,200,100"
            elif authLevel == '100':
                exec_statement="name == "+name+" and authLevel == 300,200,100"
            else:
                exec_statement="name == "+name

            logging.info(exec_statement)
            responses = list(read(userTable, exec_statement)) 

            if len(responses) > 0:
                for item in responses:
                    item['password'] = ''
                    item["secretAnswer"] = ""
                    item["secretQuestion"] = ""

            print("Response ", responses)
            return generateResponse(200, json.dumps({"body": responses}))

        elif method == "POST" and path == "get-users":
            logging.info(data)
            authLevel = data['authLevel']

            if authLevel == '300':
                exec_statement = "authLevel == 300,200"
            elif authLevel == '200':
                exec_statement = "authLevel == 300,200,100"
            elif authLevel == '100':
                exec_statement = "authLevel == 300,200,100"
            else:
                exec_statement = ""

            responses = list(read(userTable, exec_statement))

            if len(responses) > 0:
                for item in responses:
                    item['password'] = ''
                    item["secretAnswer"] = ""
                    item["secretQuestion"] = ""
            print("Response ", responses)
            return generateResponse(200, json.dumps({"body": responses}))

        elif method == "POST" and path == "delete-user":

            if 'authLevel' not in data or 'email' not in data:
                responses = "Something is missing. Please check proper authentication"
                return generateResponse(200, json.dumps({"body": responses}))

            authLevel = data['authLevel']
            email = data['email']

            if authLevel != '0':
                responses = "Requires Admin"
                return generateResponse(200, json.dumps({"body": responses}))

            condition = "email == {}".format(email)
            check_user = list(read(userTable, condition)) 

            if len(check_user) < 1:
                responses = "User does not exists"
                return generateResponse(200, json.dumps({"body": responses}))

            delete_response = delete(userTable, "document",check_user[0]['id'])

            responses = "User "+email+" deleted"
            return generateResponse(200, json.dumps({"body": responses}))

        elif method == "POST" and path == "change-auth":
            if 'authLevel' not in data or 'email' not in data or 'userAuthLevel' not in data:
                responses = "Something is missing. Please check proper authentication"
                return generateResponse(200, json.dumps({"body": responses}))

            authLevel = data['authLevel']
            email = data['email']
            userAuthLevel =data['userAuthLevel'].strip()

            if authLevel != "0":
                responses = "Requires Admin"
                return generateResponse(200, json.dumps({"body": responses}))
            
            if userAuthLevel == 'Reassign as Admin':
                userAuthLevel = '0'
            elif userAuthLevel == 'Reassign as Author':
                userAuthLevel = '200'
            elif userAuthLevel == 'Reassign as Editor':
                userAuthLevel = '100'
            else:
                userAuthLevel = '300'

            condition = "email == {}".format(email)
            check_user = list(read(userTable, condition)) 

            if len(check_user) < 1:
                responses = "User does not exists"
                return generateResponse(200, json.dumps({"body": responses}))
            
            for item in check_user:
                if item['email'] == email:
                    new_item = item
                    new_item['authLevel'] = userAuthLevel
                    value = {"authLevel":new_item["authLevel"]}
                    update_response = update(userTable,value,item["id"])

                    break
            responses = "User "+email+" AuthLevel Updated"
            return generateResponse(200, json.dumps({"body": responses}))

        elif method == "POST" and path == "user-details-modal":

            email = data['email']
            condition = "email == {}".format(email)
            responses = list(read(postsTable, condition)) 
            return generateResponse(200, json.dumps({"body": responses}))

        elif method == "POST" and path == "modify-post-status":

            if 'authLevel' not in data or 'postStatus' not in data or 'id' not in data:
                responses = "Something is missing. Please check proper authentication"
                return generateResponse(200, json.dumps({"body": responses}))

            authLevel = data['authLevel']
            id = data['id']
            postStatus =data['postStatus'].lower().strip()

            if not (authLevel == '0' or authLevel =='100'):
                responses = "Requires Admin or Editor"
                return generateResponse(200, json.dumps({"body": responses}))
            condition = "id == {}".format(id)
            check_post = list(read(postsTable, condition)) 

            if len(check_post)<1:
                responses = "Post does not exists"
                return generateResponse(200, json.dumps({"body": responses}))

            for item in check_post:
                if item['id'] == id:
                    new_item = item
                    new_item['postStatus'] = postStatus
                    value = {"postStatus":new_item["postStatus"]}
                    update_response = update(postsTable,value,item["id"])
                    break

            responses = "Post "+id+" status Updated"
            return generateResponse(200, json.dumps({"body": responses}))
        
        elif method == "POST" and path == "change-profile":
            new_user_data = {}
            if "email" in data:
                new_user_data["email"] = data["email"].lower().strip()
            if "address" in data:
                new_user_data["address"] = data["address"]
            if "country" in data:
                new_user_data["country"] = data["country"]
            if "name" in data:
                new_user_data["name"] = data["name"]
            if "phone" in data:
                new_user_data["phone"] = data["phone"]
            if "secretQuestion" in data:
                new_user_data["secretQuestion"] = data["secretQuestion"]
            if "secretAnswer" in data:
                new_user_data["secretAnswer"] = data["secretAnswer"]
            if "username" in data:
                new_user_data["username"] = data["username"].lower().strip()

            required_info = ["email", "address","name","phone", "username",
                                "country", "secretQuestion", "secretAnswer"]

            for field in required_info:
                if field not in new_user_data:
                    return generateResponse(200, json.dumps({"body": "All Fields required"}))

            new_user_data['userStatus'] = 'active'
            condition = "email == {}".format(new_user_data["email"])
            user = list(read(userTable, condition)) 

            olduserdata = user
            value = {
                "address" : new_user_data['address'],
                "name" : new_user_data['name'],
                "phone" : new_user_data['phone'],
                "username" : new_user_data['username'],
                "country" : new_user_data['country'],
                "secretQuestion" : new_user_data['secretQuestion'],
                "secretAnswer" : new_user_data['secretAnswer']
            }

            update_response = update(userTable,value,olduserdata[0]["id"])
            
            responses = "User "+new_user_data['email']+" Updated"
            return generateResponse(200, json.dumps({"body": responses}))

        elif method == "POST" and path == "get-dashboard":
            currentYear = str(datetime.now().year)

            posts = list(read(postsTable))
            users = list(read(userTable)) 

            total_posts=str(len(posts))
            total_users=str(len(users))

            print("Total Posts: "+total_posts)
            print("Total Users: "+total_users)
            data={}

            for post in posts:
                postingdate=post['postingDate']
                print(postingdate)
                if postingdate[:7] in data:
                    data[postingdate[:7]]=data[postingdate[:7]] + 1
                else:
                    if (postingdate[:4]==currentYear):
                        data[postingdate[:7]]=1

            for i in range(1,13):
                mm=str(i).zfill(2)
                key=currentYear+'-'+mm
                if key not in data:
                    data[key]=0

            chartLabels=list(data.keys())
            chartData=list(data.values())

            for i in range(len(chartLabels)):
                label=chartLabels[i]
                yyyy=label[:4]
                mm=label[5:7]
                lab=mm+"/01/"+yyyy
                chartLabels[i]=lab
            
            
            recent_user_names=[]
            recent_user_times=[]
            for user in users:
                createtime=datetime.strptime(user['creationDate'][:10], '%Y-%m-%d')
                recent_user_names.append(user['name'])
                recent_user_times.append(createtime)

            top_recent_users=[]
            top_recent_times=[]

            for i in range(5):
                list_index=recent_user_times.index(max(recent_user_times))
                top_recent_times.append(recent_user_times[list_index].strftime("%d %b %Y"))
                top_recent_users.append(recent_user_names[list_index])
                del recent_user_names[list_index]
                del recent_user_times[list_index]

            responses={
                "totalPosts": total_posts,
                "totalUsers": total_users,
                "chartLabel": chartLabels,
                "chartData": chartData,
                "recentUserNames": top_recent_users,
                "recentUserDates": top_recent_times
            }
            return generateResponse(200, json.dumps({"body": responses}))

        else:
            return generateResponse(200, json.dumps({"body": responses}))

    responses = "Invalid Authorization"
    return generateResponse(200, json.dumps({"body": responses}))