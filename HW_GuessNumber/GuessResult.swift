//
//  GuessResult.swift
//  HW_GuessNumber
//
//  Created by 曹家瑋 on 2023/7/11.
//

import Foundation

/// 遊戲結果
enum GuessResult {
    /// 猜對（獲勝，遊戲結束）
    case correct
    /// 猜錯（會縮小範圍、扣除猜測次數guessesLeft）
    case incorrect
    /// 遊戲失敗（當所有猜測次數用完）（倒數計時導致遊戲失敗判定，則是另外由updateTimer主導）
    case gameOver
}
