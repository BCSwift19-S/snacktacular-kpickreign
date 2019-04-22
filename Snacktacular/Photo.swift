//
//  Photo.swift
//  Snacktacular
//
//  Created by Kelly Pickreign on 4/22/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Photo {
    var image: UIImage
    var description: String
    var postedBy: String
    var date: Date
//    var documentID: String
    var documentUUID: String
    var dictionary: [String: Any] {
        return ["description": description, "postedBy": postedBy, "date": date]
    }
    
    init(image: UIImage, description: String, postedBy: String, date: Date, documentUUID: String) {
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        
        self.documentUUID = documentUUID
    }
    
    convenience init() {
        let postedBy = Auth.auth().currentUser?.email ?? "unknown user"
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentUUID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let postedBy = dictionary["postedBy"] as! String? ?? ""
        let date = dictionary["date"] as! Date? ?? Date()
        self.init(image: UIImage(), description: description, postedBy: postedBy, date: date, documentUUID: "")
    }
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        //convert photo image to a data type so it can be saved in fire base storage
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("ERROR could not convert")
            return completed(false)
        }
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        documentUUID = UUID().uuidString // generate unique id to use for photo images
        //create ref to upload images
        let storageRef = storage.reference().child(spot.documentID).child(self.documentUUID)
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) {
            metadata, error in
            guard error == nil else {
                print("ERROR during .putData")
                return
            }
            print("upload worked, metadata is \(metadata)")
        }
        
        uploadTask.observe(.success) { (snapshot) in
            // Create the dicitonary representing the data we want to save
            let dataToSave = self.dictionary
            // Either create or update
            let ref = db.collection("spots").document(spot.documentID).collection("photos").document(self.documentUUID)
            ref.setData(dataToSave) {(error) in
                if let error = error {
                    print("ERROR: updating document \(self.documentUUID) in spot \(spot.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("Doument updated with ref id \(ref.documentID)")
                    completed(true)
                }
            }
        }
        
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("ERROR: upload task for file \(self.documentUUID) failed in spot \(spot.documentID) error \(error)")
            }
            return completed(false)
        }
        

    }
}
