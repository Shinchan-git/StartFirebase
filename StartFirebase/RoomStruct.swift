//
//  RoomStruct.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/12.
//

import Foundation

struct Room {
    
    var roomTitle: String
    var docId: String
    var explanation: String
    var options: [String]
    var rule: String
    var state: String
}

struct ResultRank: Equatable {
    
    var arrayIndex: Int
    var name: String
    var score: Int
    var rank: Int
    
    static func ==(lhs: ResultRank, rhs: ResultRank) -> Bool {
        return lhs.name == rhs.name
    }
}
