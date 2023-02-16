import os

from google.cloud import firestore


def create(firestore_collection, value, document = None, merge_values = True): 
  try:
    client = firestore.Client()
    if document == None:
      client.collection(firestore_collection).add(value)  
      print("Created new document")
    else: 
      # if merge got false then value document data will be overwrited 
      client.collection(firestore_collection).document(document).set(value, merge=merge_values)
    return True
  except Exception as e:
    print("Something went wrong {}").format(e)
    return False

def read(firestore_collection, condition = ""): 
  try:
    client = firestore.Client()
    result = []
    if condition != "":
      docs=[]
      print(condition)
      condition = condition.split(" ")
      if len(condition) > 3 and "and" in condition[3].lower():
        if len(condition) == 7 :
          parts = condition[6].split(",")
          for part in parts:
            docs = client.collection(firestore_collection).where(condition[0],condition[1],condition[2]).where(condition[4],condition[5],part).stream()
            for doc in docs:
                print(doc.id, doc.to_dict())
                result.append(doc.to_dict())
            return result
        else:
          print("string is not valid")
      else: 
        if len(condition) == 3 :
          docs = client.collection(firestore_collection).where(condition[0],condition[1],condition[2]).stream()
        else:
          print("string is not valid")    
    else: 
      docs = client.collection(firestore_collection).stream()
    for doc in docs:
      print(doc.id, doc.to_dict())
      result.append(doc.to_dict())
    return result
  except Exception as e:
    print("Something went wrong,{}").format(e)
    return -1

def update(firestore_collection, value, ids, full_overrite = False):
  # pass overrite true if you want to overrite whole document in a collection
  try:
    client = firestore.Client()
    if full_overrite == False:
      docs = client.collection(firestore_collection).where(u'id', u'==', ids).stream()
      for doc in docs:
        client.collection(firestore_collection).document(doc.id).update(value)
      print("updated the value")
    else:
      create(firestore_collection, value, ids, False)
    return True
  except Exception as e:
    print("Something went wrong,{}").format(e)
    return False

def delete(firestore_collection, type_to_delete, ids= None ,document = None, value = None, document_contaion_sub_collection = False):
  try:
    client = firestore.Client()
    kind = type_to_delete.lower() 
    if kind == "field":
      if value != None:
        if ids == None:
          client.collection(firestore_collection).document(document).update({value: firestore.DELETE_FIELD})
        else :
          docs = client.collection(firestore_collection).where(u'id', u'==', ids).stream()
          for doc in docs:
            client.collection(firestore_collection).document(doc.id).update({value: firestore.DELETE_FIELD})
      else:
        print("Provide value")
      print("Deleted the feild")
    elif kind == "document" and document_contaion_sub_collection == False:
      # the delete the document
      if ids == None:
        client.collection(firestore_collection).document(document).delete()
      else :
        docs = client.collection(firestore_collection).where(u'id', u'==', ids).stream()
        for doc in docs:
          client.collection(firestore_collection).document(doc.id).delete()
      print("Deleted the Document") 
    else: 
      print("Wrong type")
    return True
  except Exception as e:
    print("Something went wrong,{}").format(e)
    return False

  print("Are you sure?? ok then Deleting values")