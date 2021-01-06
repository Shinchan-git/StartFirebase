//
//  Rules.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/21.
//

import Foundation

class Rules {
    
    enum RuleType: String {
        case majorityRule = "多数決"
        case bordaRule = "ボルダルール"
        case instantRunoffVoting = "即時決戦投票"
    }
    
    
    class func majorityRule(of personalRanks: [[Int]], for room: Room) -> [ResultRank] {
        var results: [ResultRank] = []
        for i in 0 ..< room.options.count {
            let result = ResultRank(arrayIndex: i, name: room.options[i], score: 0, rank: 0)
            results.append(result)
        }
        
        for personalRank in personalRanks {
            let indexOfTop1 = personalRank.firstIndex(of: 1)!
            results[indexOfTop1].score += 1
        }
                
        results.sort { $0.score > $1.score }
        for i in 0 ..< results.count {
            results[i].rank = i + 1
        }
        for i in 0 ..< results.count {
            if i == results.count - 1 { break }
            if results[i].score == results[i + 1].score {
                results[i + 1].rank = results[i].rank
            }
        }
        
        return results
    }
    
    class func bordaRule(of personalRanks: [[Int]], for room: Room) -> [ResultRank] {
        var results: [ResultRank] = []
        for i in 0 ..< room.options.count {
            let result = ResultRank(arrayIndex: i, name: room.options[i], score: 0, rank: 0)
            results.append(result)
        }
        
        for personalRank in personalRanks {
            for i in 0 ..< personalRank.count {
                let score = personalRank.count - personalRank[i] + 1
                results[i].score += score
            }
        }
        
        results.sort { $0.score > $1.score }
        for i in 0 ..< results.count {
            results[i].rank = i + 1
        }
        for i in 0 ..< results.count {
            if i == results.count - 1 { break }
            if results[i].score == results[i + 1].score {
                results[i + 1].rank = results[i].rank
            }
        }
        
        return results
    }
    
    
    class func instantRunoffVoting(of personalRanks: [[Int]], for room: Room) -> [ResultRank] {
        //optionが2つだけの時でも対応できるか
        
        var results: [ResultRank] = []
        var optionsDead: [ResultRank] = []
        for i in 0 ..< room.options.count {
            let result = ResultRank(arrayIndex: i, name: room.options[i], score: 0, rank: 0)
            results.append(result)
        }
        
        //for k in 0 ..< results.count - 1
        var k = 1
        
        //1
        //開票
        for personalRank in personalRanks {
            let indexOfTopOptionAlive = personalRank.firstIndex(of: 1)!
            //arrayIndexを探す
            for i in 0 ..< results.count {
                if results[i].arrayIndex == indexOfTopOptionAlive {
                    results[i].score += 1
                }
            }
        }
        
        //ランキング
        results.sort { $0.score > $1.score }
        for i in 0 ..< results.count {
            results[i].rank = i + 1
        }
        for i in 0 ..< results.count {
            if i == results.count - 1 { break }
            if results[i].score == results[i + 1].score {
                results[i + 1].rank = results[i].rank
            }
        }
        
        //過半数かチェック

        //引き算
        var optionsAlive: [ResultRank] = []
        for option in results {
            if !optionsDead.contains(option) {
                optionsAlive.append(option)
            }
        }
        
        //最下位を求める
        var numberOfDeadOptions = 1
        while results[results.count - 1].rank == results[results.count - 1 - numberOfDeadOptions].rank {
            if results.count - 1 - numberOfDeadOptions == 0 { break }
            numberOfDeadOptions += 1
        }
        for i in 0 ..< numberOfDeadOptions {
            optionsDead.append(results[results.count - 1 - i])
        }
        
        //2
        for personalRank in personalRanks {
            
            let indexOfTopOptionAlive = personalRank.firstIndex(of: 1)!
            //arrayIndexを探す
            for i in 0 ..< results.count {
                if results[i].arrayIndex == indexOfTopOptionAlive {
                    results[i].score += 1
                }
            }
            
            for i in 0 ..< personalRank.count {
                //contains
                for f in 0 ..< optionsDead.count {
                    if optionsDead[f].arrayIndex == i { continue }
                }
                results[i].score += 1
                break
            }
        }
        
//        //2
//        for personalRank in personalRanks {
//            var indexOfTopOptionAlive = personalRank.firstIndex(of: 1)!
//            for i in 0 ..< optionsDead.count {
//                if optionsDead[i].arrayIndex == indexOfTopOptionAlive {
//                    indexOfTopOptionAlive = 2
//                    //arrayIndexを探す
//                    for f in 0 ..< results.count {
//                        if results[f].arrayIndex == indexOfTopOptionAlive {
//                            results[f].score += 1
//                        }
//                    }
//                    break
//                }
//            }
//        }
//
//        //3
//        for personalRank in personalRanks {
//            var indexOfTopOptionAlive = personalRank.firstIndex(of: 1)!
//
//            for i in 0 ..< optionsDead.count {
//                if optionsDead[i].arrayIndex == indexOfTopOptionAlive {
//                    indexOfTopOptionAlive = 2
//                    break
//                }
//                if optionsDead[i].arrayIndex == indexOfTopOptionAlive {
//                    indexOfTopOptionAlive = 3
//                    break
//                }
//            }
//        }
        
        
        return results
        //結果は、第何ラウンド敗退、と表示
    }
    
}
