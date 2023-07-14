//
//  Game.swift
//  HW_GuessNumber
//
//  Created by 曹家瑋 on 2023/7/11.
//

import Foundation

// 改進版（針對數字範圍做修改：顯示範圍及猜測範圍）
/// Game 用於控制數字的範圍以及正確的數字
struct Game {
    var lowerBound: Int         // 最小範圍
    var upperBound: Int         // 最大範圍
    var correctAnswer: Int      // 正確的答案
    var guessesLeft: Int        // 剩餘猜測次數（每次猜測都會減少）
    var timeLeft: Int           // 倒數計時（每次猜測後會重置）

    /// 使用一個陣列來儲存已經猜過的數字
    var guessedNumbers: [Int] = []


    /// makeGuess 進行猜測並返回結果（GuessResult），猜錯會減少剩餘次數。
    ///  - Parameters:
    ///   - guess: 使用者猜測的數字
    ///  - Returns: 猜測結果（正確、錯誤或遊戲結束）
    mutating func makeGuess(guess: Int) -> GuessResult {

        // 如果使用者猜的數字等於生成的數字
        if guess == correctAnswer {
            // 猜對，遊戲結束
            return .correct

        } else {
            // 猜錯，減少剩餘猜測次數
            guessesLeft -= 1

            // 檢查是否遊戲結束
            if guessesLeft == 0 {
                // 當 guessesLeft 歸0 則遊戲失敗
                return .gameOver

            } else if guess < correctAnswer {
                // 猜小了，更新最小範圍，將猜測的數字添加到已猜過的數字陣列（guessedNumbers）中
                lowerBound = guess
                guessedNumbers.append(guess)
            } else {
                // 猜大了，更新最大範圍，將猜測的數字添加到已猜過的數字陣列（guessedNumbers）中
                upperBound = guess
                guessedNumbers.append(guess)
            }

            // 返回猜測數字不正確
            return .incorrect
        }
    }

    ///  減少剩餘時間（倒數計時器使用）
    /// 每次呼叫時，將 timeLeft 減 1，表示減少一秒的剩餘時間。
    mutating func decrementTime() {
        timeLeft -= 1
    }
    
    
    /// isWithinBounds 檢查數字是否在當前猜測範圍內，且尚未猜過（從而避免重複猜測同一個數字。）
    /// - Parameters:
    ///   - guess: 使用者猜測的數字
    /// - Returns: 是否在範圍內且尚未猜過
    func isWithinBounds(guess: Int) -> Bool {
        return guess >= lowerBound && guess <= upperBound && !guessedNumbers.contains(guess)
    }

    /// currentRange取得當前的猜測範圍
    func currentRange() -> String {
        return "\(lowerBound) - \(upperBound)"
    }

}

/*
 isWithinBounds的解說：
 
 guess >= lowerBound: 這個條件檢查使用者猜測的數字是否大於或等於最小範圍。如果數字小於最小範圍，則返回 false。
 guess <= upperBound: 這個條件檢查使用者猜測的數字是否小於或等於最大範圍。如果數字大於最大範圍，則返回 false。
 
 !guessedNumbers.contains(guess): 這個條件檢查使用者猜測的數字是否已經存在於已經猜過的數字陣列中。
 如果數字已經猜過，則返回 false。! 運算符表示取反，所以 !guessedNumbers.contains(guess) 表示當數字不存在於已經猜過的數字陣列時返回 true。
 
 因此，當所有條件都滿足時，即數字在範圍內且尚未猜過，整個表達式返回 true，否則返回 false。

 這樣就可以確保使用者輸入的數字在當前猜測範圍內且尚未猜過，以避免重複猜測同一個數字。
 */


/* 在 初始版（顯示範圍會進位）由於
lowerBound = guess + 1
upperBound = guess - 1
的關係，因此我猜測完之後，會幫我的範圍改變。

假設目前正確數字是19。
我現在猜17，剛好是lowerBound，則範圍會顯示18。
我猜20，剛好是upperBound，則範圍會顯示19。
範圍會變成18-19。由於這時候18以及19還是可以猜測，因此數字範圍的上限再繼續猜到最小範圍值會變成19~19（這會使使用者混淆）

但是我希望範圍的顯示是17-20，近一步猜測的最小範圍是18-20，當然18以及20已經被排出在能夠猜測的數字了，那麼剩下可選的數字是19。
因此我改用修改版（使用一個陣列來儲存已經猜過的數字，並且用isWithinBounds的條件檢查範圍。）
 */



// 初始版（顯示範圍會進位，也可使用，但可能讓使用者產生混淆。）
/// Game 用來展示數字的範圍以及正確的數字
//struct Game {
//    var lowerBound: Int         // 最低範圍
//    var upperBound: Int         // 最高範圍
//    var correctAnswer: Int      // 生成的正確數字
//    var guessesLeft: Int        // 剩餘次數（每次猜都會扣除）
//    var timeLeft: Int           // 倒數計時（每次猜完就會重置）
//
//    /// makeGuess（參數：使用者猜測的數字） 猜測的結果會返回到 GuessResult
//    mutating func makeGuess(guess: Int) -> GuessResult {
//
//        // 如果使用者猜的數字等於生成的數字
//        if guess == correctAnswer {
//            //  正確遊戲結束
//            return .correct
//
//        } else {
//            // 猜測才會扣除剩餘次數
//            guessesLeft -= 1
//
//            // 當 guessesLeft 或是 時間歸0 則遊戲結束
//            if guessesLeft == 0 || timeLeft == 0 {
//                return .gameOver
//
//            } else if guess < correctAnswer {
//                // 如果猜測數字小於正確數字，將最低範圍上限更新為 guess + 1
//                lowerBound = guess + 1
//
//            } else {
//                // 如果猜測數字大於正確數字，將最高範圍下限更新為 guess - 1
//                upperBound = guess - 1
//            }
//            // 返回不正確
//            return .incorrect
//        }
//    }
//
//    ///  將時間減少一秒
//    mutating func decrementTime() {
//        timeLeft -= 1
//    }
//
//    /// 檢查使用者輸入的數字是否在當前猜測數字範圍內
//    func isWithinBounds(guess: Int) -> Bool {
//        return guess >= lowerBound && guess <= upperBound
//    }
//
//    /// 用來取得當前的範圍
//    func currentRange() -> String {
//        return "\(lowerBound) - \(upperBound)"
//    }
//}
