//
//  Extension+Keychain.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/20/24.
//
import Foundation
import KeychainAccess

import Service
import LogMacro

extension Keychain {
    //MARK: -  키체인에 배열에 값 추가 하기
     func saveDocumentIDToKeychain(documentID: String) throws {
        do {
            var documentIDs: [String] = []
            if let data = try Keychain().getData("deleteEventIDs"),
               let existingIDs = try? JSONDecoder().decode([String].self, from: data) {
                documentIDs = existingIDs
            }
            
            documentIDs.append(documentID)
            
            let data = try JSONEncoder().encode(documentIDs)
            try Keychain().set(data, key: "deleteEventIDs")
            
            Log.debug("Document ID saved to Keychain: \(documentID)")
        } catch {
            Log.error("Error saving document ID to Keychain: \(error)")
            throw CustomError.unknownError("Error saving document ID to Keychain: \(error.localizedDescription)")
        }
    }
    
    
    //MARK: -  키체인에 배열에 값 삭제 하기
     func removeDocumentIDFromKeychain(documentID: String) throws {
        do {
            // Retrieve the existing array from Keychain
            var documentIDs: [String] = []
            if let data = try Keychain().getData("deleteEventIDs"),
               let existingIDs = try? JSONDecoder().decode([String].self, from: data) {
                documentIDs = existingIDs
            }
            
            // Remove the document ID
            documentIDs.removeAll { $0 == documentID }
            
            // Save the updated array back to the Keychain
            let data = try JSONEncoder().encode(documentIDs)
            try Keychain().set(data, key: "deleteEventIDs")
            
            Log.debug("Document ID removed from Keychain: \(documentID)")
        } catch {
            Log.error("Error removing document ID from Keychain: \(error)")
            throw CustomError.unknownError("Error removing document ID from Keychain: \(error.localizedDescription)")
        }
    }
}
