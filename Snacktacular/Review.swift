//
//  Review.swift
//  Snacktacular
//
//  Created by Kelly Pickreign on 4/21/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewerUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["title": title, "text": text, "rating": rating, "reviewerUserID": reviewerUserID, "date": date, "documentID": documentID]
    }
    
    init(title: String, text: String, rating: Int, reviewerUserID: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewerUserID = reviewerUserID
        self.date = date
        self.documentID = documentID
    }
    
    convenience init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown User"
        self.init(title: "", text: "", rating: 0, reviewerUserID: currentUserID, date: Date(), documentID: "")
    }
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        
        // Create the dicitonary representing the data we want to save
        let dataToSave = self.dictionary
        // If we HAVE saved a record, we'll have a document ID
        if self.documentID != "" {
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) {(error) in
                if let error = error {
                    print("ERROR: updating document \(self.documentID) in spot \(spot.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("Doument updated with ref id \(ref.documentID)")
                    completed(true)
                }
            }
        } else {
            var ref: DocumentReference? = nil // Let firestore create the first document id
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave) { error in
                if let error = error {
                    print("ERROR: creating new document in spot \(spot.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("New doument created with ref id \(ref?.documentID ?? "unknown")")
                    completed(true)
                }
            }
        }
    }

    
}