//
//  Rules.swift
//  StartFirebase
//
//  Created by Owner on 2020/12/21.
//

import Foundation

class Rules {
    
    enum RuleType {
        case majorityRule
        case bordaRule
        case condorcetRule
//        case instantRunoffVoting
        
        var ruleName: String {
            switch self {
            case .majorityRule:
                return "majorityRule"
            case .bordaRule:
                return "bordaRule"
            case .condorcetRule:
                return "condorcetRule"
            }
        }
        
        var displayedName: String {
            switch self {
            case .majorityRule:
                return "多数決"
            case .bordaRule:
                return "ボルダルール"
            case .condorcetRule:
                return "コンドルセ・ヤングの最尤法"
            }
        }
        
        var description: String {
            switch self {
            case .majorityRule:
                return "通常の多数決です。"
            case .bordaRule:
                return "選択肢が３つ以上の時に使えます。例えば３択の時、１番良いと思う候補に３点、２番目に２点、３番目に１点を加算します。勝者は満場一致に最も近いものになります。"
            case .condorcetRule:
                return "選択肢が３つ以上の時に使えます。総当たり戦を元に確率の計算を行います。勝者は他の候補との一騎打ちで必ず勝利します。"
            }
        }
    }
    
    class func convertRuleNameToDisplayName(ruleName: String) -> String {
        switch ruleName {
        case Rules.RuleType.majorityRule.ruleName:
            return Rules.RuleType.majorityRule.displayedName
        case Rules.RuleType.bordaRule.ruleName:
            return Rules.RuleType.bordaRule.displayedName
        case Rules.RuleType.condorcetRule.ruleName:
            return Rules.RuleType.condorcetRule.displayedName
        default:
            return ""
        }
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
    
    
    class func condorcetRule(of personalRanks: [[Int]], for room: Room) -> [[ResultRank]] {
        
        func nArrayindex(i: Int, j: Int, numOfOptions: Int) -> Int {
            if (i < j) {
                return (numOfOptions - 1)*i + j - 1
            } else {
                return (numOfOptions - 1)*i + (j + 1) - 1
            }
        }
        
        func factorial(num: Int) -> Int {
            if num == 0 { return 1 }
            return num*factorial(num: num - 1)
        }
        
        var results: [ResultRank] = []
        let numOfOptions = room.options.count
        
        //set results zero
        for i in 0 ..< numOfOptions {
            let result = ResultRank(arrayIndex: i, name: room.options[i], score: 0, rank: 0)
            results.append(result)
        }
        
        //set nArray zero
        var nArray: [Int] = []
        let nArrayLength = 2*numOfOptions*(numOfOptions - 1)/2
        for _ in 0 ..< nArrayLength {
            nArray.append(0)
        }
        
        //calculate nArray
        for f in 0 ..< personalRanks.count {
            let personalRank = personalRanks[f]
            
            for i in 0 ..< numOfOptions {
                for g in 0 ..< numOfOptions {
                    let j = g + i + 1
                    if j > numOfOptions - 1 { break }
                    //count votes
                    if personalRank[i] < personalRank[j] {
                        let nArrayIndexOfIJ = nArrayindex(i: i, j: j, numOfOptions: numOfOptions)
                        nArray[nArrayIndexOfIJ] += 1
                    } else {
                        let nArrayIndexOfJI = nArrayindex(i: j, j: i, numOfOptions: numOfOptions)
                        nArray[nArrayIndexOfJI] += 1
                    }
                }
            }
        }
        print("nArray: \(nArray)")
        
        //calculate pArrayElements
        var pArrayElements: [[Int]] = []
        let originalParrayLength: Int = Int(pow(Double(numOfOptions), Double(numOfOptions)))
        for i in 0 ..< originalParrayLength {
            //set element zero
            var element: [Int] = []
            for _ in 0 ..< numOfOptions {
                element.append(0)
            }
            //calculate elements including redundancy
            var num: Int = Int(String(i, radix: numOfOptions))!
            for j in 0 ..< numOfOptions {
                element[numOfOptions - 1 - j] = num%10
                num = num/10
            }
            //find redundancy
            let nonRedundantElement: [Int] = Array(Set(element))
            if nonRedundantElement.count == numOfOptions {
                pArrayElements.append(element)
            }
        }
        print("pArrayElements: \(pArrayElements)")
        
        //set pArray zero
        var pArray: [Int] = []
        let pArrayLength = factorial(num: numOfOptions)
        for _ in 0 ..< pArrayLength {
            pArray.append(0)
        }
        
        //calculate pArray
        for k in 0 ..< pArrayLength {
            let pElement: [Int] = pArrayElements[k]
            var nElements: [Int] = []
            for i in 0 ..< numOfOptions {
                for g in 0 ..< numOfOptions {
                    let j = g + i + 1
                    if (j > numOfOptions - 1) { break }
                    let nIndex = nArrayindex(i: pElement[i], j: pElement[j], numOfOptions: numOfOptions)
                    nElements.append(nArray[nIndex])
                }
            }
            for i in 0 ..< nElements.count {
                pArray[k] += nElements[i]
            }
        }
        print("pArray: \(pArray)")

        //find the biggest
        var maxIndexes: [Int] = [0]
        for i in 0 ..< pArray.count - 1 {
            let maxIndexFirst = maxIndexes[0]
            if pArray[maxIndexFirst] < pArray[i + 1] {
                maxIndexes = []
                maxIndexes.append(i + 1)
            } else if pArray[maxIndexFirst] == pArray[i + 1] {
                maxIndexes.append(i + 1)
            }
        }
        var maxPElements: [[Int]] = []
        for i in 0 ..< maxIndexes.count {
            maxPElements.append(pArrayElements[maxIndexes[i]])
        }
        
        //refine results
        var arrayOfResults: [[ResultRank]] = []
        for maxPElement in maxPElements {
            for i in 0 ..< numOfOptions {
                results[i].rank = maxPElement[i] + 1
            }
            results.sort { $0.rank < $1.rank }
            arrayOfResults.append(results)
        }
        print("arrayOfResults[0]: \(arrayOfResults[0])")
        
        return arrayOfResults
    }
    
    
    //
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
    }
    
}
