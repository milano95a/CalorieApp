//
//  FirebaseManager.swift
//  CalorieApp
//
//  Created by Workspace on 25/04/22.
//

import Foundation
import Firebase

final class FirebaseManager {
    
    static let shared = FirebaseManager()
    
    private var storage: Storage!
    private var entriesRef: CollectionReference!
    private var usersRef: CollectionReference!
    private var auth: Auth!
    
    func saveEntry(_ image: Data?, _ entry: Entry, _ completion: @escaping (_ error: Error?) -> Void) {
        
        isUserExist(entry.userId) { [weak self] (exist, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                completion(error)
            } else {
                if exist {
                    let entryID = !entry.id.isEmpty ? entry.id : UUID.init().uuidString
                    let docRef = strongSelf.entriesRef.document(entryID)

                    var dataToSave: [String: Any] = [
                        ENTRY_ID: entryID,
                        USER_ID: entry.userId,
                        ENTRY_NAME: entry.name,
                        ENTRY_CALORIE: entry.calorie,
                        ENTRY_IMAGE: entry.imageURL,
                        ENTRY_DATE: entry.date.millisecondsSince1970
                    ]
                    
                    if let image = image {
                        strongSelf.uploadImage(image) { (urlString, error) in
                            if let error = error {
                                print("Ooops, something went wrong. \(error.localizedDescription)")
                                completion(error)
                            } else {
                                dataToSave[ENTRY_IMAGE] = urlString
                                docRef.setData(dataToSave) { (error) in
                                    if let error = error {
                                        print("Ooops, something went wrong. \(error.localizedDescription)")
                                        completion(error)
                                    } else {
                                        print("Data saved!")
                                        completion(nil)
                                    }
                                }
                            }
                        }
                    } else {
                        docRef.setData(dataToSave) { (error) in
                            if let error = error {
                                print("Ooops, something went wrong. \(error.localizedDescription)")
                                completion(error)
                            } else {
                                print("Data saved!")
                                completion(nil)
                            }
                        }
                    }
                } else {
                    completion(FirebaseError.userNotFound)
                }
            }
        }
        

    }
    
    func getAllEntries(_ completion: @escaping (_ entries: [Entry], _ error: Error?) -> Void) {
        entriesRef.getDocuments { [weak self] (querySnapshot, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Ooops, something went wrong. \(error.localizedDescription)")
                completion([], error)
            } else {
                print("Loaded all entries from Firebase")
                completion(strongSelf.processEntryData(querySnapshot), nil)
            }
        }
    }
    
    func getEntriesByUserId(_ userId: String, _ completion: @escaping (_ entries: [Entry], _ error: Error?) -> Void) {
        CollectionReference.whereField(USER_ID, isEqualTo: userId).getDocuments { [weak self] (querySnapshot, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Something went wrong. \(error.localizedDescription)")
                completion([], error)
            } else {
                print("Loaded entries from Firebase")
                completion(strongSelf.processEntryData(querySnapshot), nil)
            }
        }
    }
    
    func deleteEntryById(_ entryId: String, _ completion: @escaping (_ error: Error?) -> Void ) {
        entriesRef.document(entryId).delete { error in
            if let error = error {
                print("Ooops, something went wrong. \(error.localizedDescription)")
                completion(error)
            } else {
                print("Entry has been deleted")
                completion(nil)
            }
        }
    }
    
    func isUserExist(_ userId: String, completion: @escaping(_ exist: Bool,  _ error: Error?) -> Void) {
        usersRef.getDocuments { [weak self] (querySnapshot, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Ooops, something went wrong. \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("Loaded all entries from Firebase")
                completion(strongSelf.processUserData(querySnapshot).contains(userId), nil)
            }
        }
    }
    
    func createUser(_ email: String, _ password: String, completion: @escaping (_ error: Error?) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let strongSelf = self else { return }
            if let error = error {
                print("Ooops, something went wrong. \(error.localizedDescription)")
                completion(error)
            } else {
                print("Successfully created new user")
                let docId = UUID.init().uuidString
                let docRef = strongSelf.usersRef.document(docId)

                let dataToSave: [String: Any] = [
                    USER_ID: email,
                ]
                
                docRef.setData(dataToSave) { (error) in
                    if let error = error {
                        print("Ooops, something went wrong. \(error.localizedDescription)")
                        completion(error)
                    } else {
                        print("Data saved!")
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func signIn(_ email: String, _ password: String, completion: @escaping (_ error: Error?) -> Void) {
        auth.signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Ooops, something went wrong. \(error.localizedDescription)")
                completion(error)
            } else {
                print("Successfully sign in")
                completion(nil)
            }
        }
    }

    private func processEntryData(_ querySnapshot: QuerySnapshot?) -> [Entry] {
        var newEntries = [Entry]()
        guard let querySnapshot = querySnapshot else {
            return newEntries
        }

        for document in querySnapshot.documents {
            let data = document.data()
            let id = data[ENTRY_ID] as? String ?? ""
            let name = data[ENTRY_NAME] as? String ?? ""
            let calorie = data[ENTRY_CALORIE] as? Int ?? 0
            let imageURL = data[ENTRY_IMAGE] as? String ?? ""
            let dateInMill = data[ENTRY_DATE] as? Int64 ?? 0
            let date = Date(milliseconds: dateInMill)
            let userId = data[ENTRY_USER_ID] as? String ?? ""
            let entry = Entry(id: id, name: name, calorie: calorie, imageURL: imageURL, date: date, userId: userId)
            newEntries.append(entry)
        }
        newEntries.sort{ $0.date > $1.date }
        return newEntries
    }
    
    private func processUserData(_ querySnapshot: QuerySnapshot?) -> [String] {
        var users = [String]()
        guard let querySnapshot = querySnapshot else {
            return users
        }

        for document in querySnapshot.documents {
            let data = document.data()
            let user = data[USER_ID] as? String ?? ""
            users.append(user)
        }
        return users
    }
    
    private init() {
        storage = Storage.storage()
        entriesRef = Firestore.firestore().collection(ENTRIES)
        usersRef = Firestore.firestore().collection(USERS)
        auth = Firebase.Auth.auth()
    }
    
    private func uploadImage(_ image: Data, completion: @escaping (_ urlString: String?, _ error: Error?) -> Void) {
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        let randomId = UUID.init().uuidString
        let uploadRef = storage.reference(withPath: "images/\(randomId).jpg")
        
        uploadRef.putData(image, metadata: uploadMetadata) { (downloadMetadata, error) in
            if let error = error {
                print("Ooops, something went wrong. \(error.localizedDescription)")
                completion(nil, error)
            } else {
                print("Image uploaded")
                uploadRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Ooops, something went wrong. \(error.localizedDescription)")
                        completion(nil, error)
                    } else {
                        if let url = url {
                            print("URL retreived")
                            completion(url.absoluteString, nil)
                        }
                    }
                }
            }
        }
    }

}

