//
//  Firestore+Combine.swift
//  
//
//  Created by nori on 2021/02/09.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

extension DocumentReference {

    public func getDocument(source: FirestoreSource = .default) -> AnyPublisher<DocumentSnapshot?, Error> {
        Future<DocumentSnapshot?, Error> { [weak self] promise in
            self?.getDocument(source: source) { (documentSnapshot, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(documentSnapshot))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func addSnapshotListener(includeMetadataChanges: Bool = false) -> AnyPublisher<DocumentSnapshot?, Error> {
        Future<DocumentSnapshot?, Error> { [weak self] promise in
            self?.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { (documentSnapshot, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(documentSnapshot))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func get<Document: Decodable>(source: FirestoreSource = .default) -> AnyPublisher<Document?, Error> {
        self.getDocument(source: source)
            .tryMap({ try $0?.data(as: Document.self)  })
            .eraseToAnyPublisher()
    }

    public func addDocumentListener<Document: Decodable>(includeMetadataChanges: Bool = false) -> AnyPublisher<Document?, Error> {
        self.addSnapshotListener()
            .tryMap({ try $0?.data(as: Document.self)  })
            .eraseToAnyPublisher()
    }
}

extension Query {

    public func getDocument(source: FirestoreSource = .default) -> AnyPublisher<QuerySnapshot?, Error> {
        Future<QuerySnapshot?, Error> { [weak self] promise in
            self?.getDocuments(source: source, completion: { (querySnapshot, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(querySnapshot))
                }
            })
        }.eraseToAnyPublisher()
    }

    public func addSnapshotListener(includeMetadataChanges: Bool = false) -> AnyPublisher<QuerySnapshot?, Error> {
        Future<QuerySnapshot?, Error> { [weak self] promise in
            self?.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { (querySnapshot, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(querySnapshot))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func get<Document: Decodable>(source: FirestoreSource = .default) -> AnyPublisher<[Document]?, Error> {
        self.getDocument(source: source)
            .tryMap { try $0?.documents.compactMap({ try $0.data(as: Document.self) }) }
            .eraseToAnyPublisher()
    }

    public func addDocumentsListener<Document: Decodable>(includeMetadataChanges: Bool = false) -> AnyPublisher<[Document]?, Error> {
        self.addSnapshotListener(includeMetadataChanges: includeMetadataChanges)
            .tryMap { try $0?.documents.compactMap({ try $0.data(as: Document.self) }) }
            .eraseToAnyPublisher()
    }
}
