//
//  ViewController.swift
//  HW_GuessNumber
//
//  Created by 曹家瑋 on 2023/7/11.



import UIKit
import AVFoundation

class ViewController: UIViewController {

    /// 起始畫面
    @IBOutlet var startGameView: UIView!
    /// 遊戲失敗畫面
    @IBOutlet weak var gameOverView: UIView!
    /// 遊戲獲勝畫面
    @IBOutlet var successGuessView: UIView!


    /// 數字鍵盤 0~9 的IBOutlet Collections
    @IBOutlet var numberButtons: [UIButton]!
    /// 提示Label：目前數字範圍
    @IBOutlet weak var promptLabel: UILabel!
    /// 使用者猜測的數字
    @IBOutlet weak var guessedNumberLabel: UILabel!
    /// 使用者剩餘的猜測機會
    @IBOutlet weak var guessLeftLabel: UILabel!
    /// 倒數計時器
    @IBOutlet weak var timerLabel: UILabel!

    /// 用來保存使用者輸入的數字
    var inputNumber = ""

    /// 設置倒數計時器
    var gameTimer: Timer?

    /// ViewController 設置Game 結構體的實例（包含數字範圍、正確的數字、猜測的剩餘次數、以及倒數的時間值）
    var game = Game(lowerBound: 1, upperBound: 100, correctAnswer: Int.random(in: 1...100), guessesLeft: 8, timeLeft: 10)

    /// 設置音效播放器
    let soundplayer = AVPlayer()


    override func viewDidLoad() {
        super.viewDidLoad()

        // 初始化數字按鍵
        creatNumberKeyboard()

//        print(game) // 測試ViewController的 game 用

        // 初始化 promptLabel、guessedNumberLabel
        promptLabel.text = "Range: 1 - 100"
        guessedNumberLabel.text = "0"

        // 更新 guessLeftLabel 的内容
        updateGuessLeftLabel()

        // 控制畫面狀態（隱藏結果畫面）
        successGuessView.isHidden = true
        gameOverView.isHidden = true

    }


    /// 數字鍵盤 0~9 的IBAction Collections
    @IBAction func numberButtonPressed(_ sender: UIButton) {

        playSound(soundName: "clickSound")    // 按鈕音效

        // 取得該按鈕 titleLabel 做為numberString的值
        if let numberString = sender.titleLabel?.text {

            // 如果 inputNumber 的長度已經達到 3，則忽略新的數字（限制字串長度，同時100也可能是答案）
            if inputNumber.count < 3 {
                // 否則，添加新的數字到 inputNumber 和 guessedNumberLabel
                inputNumber += numberString
                guessedNumberLabel.text = inputNumber
                print("\(inputNumber)")
            }
            // 輸入的字串長度過長
            else  {
                print("輸入的數字已達到最大長度")
            }

        }

    }


    /// 當使用者點擊後，將數字鍵盤輸入的數字字串轉換為Int型別，並進行比較是否在猜測範圍內
    @IBAction func enterGuessNumberPressed(_ sender: UIButton) {

        // 檢查 inputNumber 是否為空，再進行轉換和解包。
        if !inputNumber.isEmpty {
            let guessNumber = Int(inputNumber)!

            // 檢查使用者輸入的數字是否在猜測的範圍內
            if game.isWithinBounds(guess: guessNumber) {

                // 比對猜測狀態結果
                switch game.makeGuess(guess: guessNumber) {
                case .correct:
                    print("猜對了！遊戲結束")            // 猜對了，更新界面並結束遊戲
                    successGuessView.isHidden = false // 顯示 successGuessView
                    gameTimer?.invalidate()           // 停止計時器
                    gameTimer = nil                   // 設置為 nil
                    playSound(soundName: "winSound")  // 猜對音效

                case .incorrect:
                    print("猜錯了，請再試一次，剩餘次數\(game.guessesLeft)")     // 猜錯了，更新猜測範圍、減少猜測次數並繼續遊戲
                    updateGuessLeftLabel()                                 // 更新 guessLeftLabel 顯示
                    playSound(soundName: "functionButton")                 // 輸入音效（在猜錯時顯示）

                case .gameOver:
                    print("遊戲失敗，你沒有猜對")              // 沒有猜對遊戲結束
                    gameOverView.isHidden = false          // 顯示 gameOverView
                    updateGuessLeftLabel()                 // 更新 guessLeftLabel 顯示（讓最後一個💣可以被更新到）
                    gameTimer?.invalidate()                // 停止計時器
                    gameTimer = nil                        // 設置為 nil
                    playSound(soundName: "explosion")      // 次數猜完音效（遊戲失敗）
                }

                // 處理完玩家的猜測後的狀態
                // 更新提示Label以及清空inputNumber
                promptLabel.text = "Range: \(game.currentRange())"
                
                // 測試（與clearNumberButtonPressed的操作邏輯有關，會影響到使用者的操作直覺）
                // 使用inputNumber = "" 則當數字被送出比較時，接著按下清除鈕則可以立刻顯示0。
                // 移除inputNumber = "" 則當數字被送出比較時，inputNumber還遺留當前字串，必須點擊清除鈕逐字串清空。
                inputNumber = ""
                
                // 重設倒數計時器
                game.timeLeft = 10
            }
            // 如果輸入超過的範圍
            else {
                print("你輸入的數字超出了當前的猜測範圍")
            }

        }
        // 如果沒有輸入任何數字（沒有值）而按下enterGuessNumberPressed時。(沒有反應）
        else {
            print("沒有輸入任何的值，因此無反應。")
        }

    }


    /// 清除字串的位數長度
    @IBAction func clearNumberButtonPressed(_ sender: UIButton) {

        playSound(soundName: "clearButtonSound")    // 按鈕音效

        // 如果inputNumber不為空，則清理最後一個位數
        if !inputNumber.isEmpty {
            inputNumber.removeLast()
            guessedNumberLabel.text = inputNumber

            // 當 guessedNumberLabel 都被清空時，則給予“0”
            if guessedNumberLabel.text == "" {
                guessedNumberLabel.text = "0"
            }
        }
        // 用於處理當 enterGuessNumberPressed 執行後，這時候 inputNumber為""，要讓使用者可以更方便處理數字的清理。（測試）
        else if inputNumber == "" {
            guessedNumberLabel.text = "0"
        }

    }


    /// 開始遊戲
    @IBAction func startGameButtonPressed(_ sender: UIButton) {
        startGame()                         // 開始遊戲
        startGameView.isHidden = true       // 點擊Button後隱藏
        playSound(soundName: "beepbeep")    // 開始遊戲音效
    }


    /// 重新開始
    @IBAction func restartGameButtonPressed(_ sender: UIButton) {
        startGame()                    // 開始遊戲
        updateGuessLeftLabel()         // 更新使用者次數
        promptLabel.text = "Range: \(game.currentRange())"        // 重置 promptLabel
        guessedNumberLabel.text = "0"                             // 重置 guessedNumberLabel
        inputNumber = ""                                          // 重置 inputNumber（清理上一場inputNumber，但還沒送出比較的數字）
        gameOverView.isHidden = true                              // 隱藏 gameOverView
        successGuessView.isHidden = true                          // 隱藏 successGuessView
        playSound(soundName: "beepbeep")                          // 按鈕音效
    }


    /// 數字鍵盤的生成
    func creatNumberKeyboard() {
        // 設置鍵盤上的數字顯示（對應 Outlet Collections 拉動時的順序）
        for (indx, button) in numberButtons.enumerated() {
            button.setTitle(String(indx), for: .normal)                     // 設置鍵盤上的數字
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)     // 設置字體屬性大小
            button.backgroundColor = .white                                 // 設置背景色（白色）

            button.layer.cornerRadius = button.frame.width / 2              // 按鈕的圓角（圓形）
            button.layer.borderWidth = 3.0                                  // 按鈕邊線的寬度
            button.layer.borderColor = UIColor.black.cgColor                // 邊線的顏色
            button.clipsToBounds = true                                     // 確保按鈕內容在圓形的邊界內顯示
        }
    }


    ///  更新 guessLeftLabel 顯示💣的部分（猜錯則顯示💥）
    func updateGuessLeftLabel() {
        let bombCount = game.guessesLeft                                     // 剩餘的機會顯示為 💣（猜測機會）
        let explosionCount = 8 - bombCount                                   // 猜測失敗產生💥

        let bombString = String(repeating: "💣", count: bombCount)           // 產生炸彈及次數
        let explosionString = String(repeating: "💥", count: explosionCount) // 已經失去的機會顯示為 💥（猜測失敗）
        guessLeftLabel.text = explosionString + bombString
    }


    /// 初始化遊戲並開始計時器（在開始遊戲、重新開始使用）
    func startGame() {
        /// 設置Game 結構體的實例（包含數字範圍、正確的數字、猜測的剩餘次數、以及時間倒數）
        /// 這個game變數在點擊開始Button、重新開始Button 時將遊戲初始化，並在遊戲進行中根據玩家的猜測和時間倒數進行更新。
        game = Game(lowerBound: 1, upperBound: 100, correctAnswer: Int.random(in: 1...100), guessesLeft: 8, timeLeft: 10)

        // 確保之前（上一個遊戲）的計時器已被清空
        gameTimer?.invalidate()
        gameTimer = nil

        /// 啟動計時器
        startTimer()

        print(game)    // 測試用
    }


    /// 啟動計時器
    func startTimer() {
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    /// 當計時器每次觸發時調用（同時控制另一個gameOver的狀態）
    @objc func updateTimer() {
        if game.timeLeft > 0 {
            game.decrementTime()                    // 減少一秒的時間
            timerLabel.text = "\(game.timeLeft)"    // 更新 timerLabel（timeLeft為10秒）
            print("剩下的時間：\(game.timeLeft)秒")
        } else {
            print("時間耗盡，遊戲結束")
            gameTimer?.invalidate()                 // 停止計時器
            gameTimer = nil                         // 設置為 nil（清空）
            gameOverView.isHidden = false           // 顯示 gameOverView
            playSound(soundName: "explosion")       // 遊戲失敗音效
        }
    }


    /// 播放音效
    ///  - Parameter soundName: 音效檔案名稱
    func playSound(soundName: String) {
        let soundUrl = Bundle.main.url(forResource: soundName, withExtension: "mp3")!
        let playerItem = AVPlayerItem(url: soundUrl)
        soundplayer.replaceCurrentItem(with: playerItem)
        soundplayer.play()
    }

}





// 第二版（未整理function）
//import UIKit
//import AVFoundation
//
//class ViewController: UIViewController {
//
//    /// 起始畫面
//    @IBOutlet var startGameView: UIView!
//    /// 遊戲失敗畫面
//    @IBOutlet weak var gameOverView: UIView!
//    /// 遊戲獲勝畫面
//    @IBOutlet var successGuessView: UIView!
//
//
//    /// 數字鍵盤 0~9 的IBOutlet Collections
//    @IBOutlet var numberButtons: [UIButton]!
//    /// 提示Label：目前數字範圍
//    @IBOutlet weak var promptLabel: UILabel!
//    /// 使用者猜測的數字
//    @IBOutlet weak var guessedNumberLabel: UILabel!
//    /// 使用者剩餘的猜測機會
//    @IBOutlet weak var guessLeftLabel: UILabel!
//    /// 倒數計時器
//    @IBOutlet weak var timerLabel: UILabel!
//
//    /// 用來保存使用者輸入的數字
//    var inputNumber = ""
//
//    /// 設置倒數計時器
//    var gameTimer: Timer?
//
//    /// 設置音效播放器
//    let soundplayer = AVPlayer()
//
//
//    /// 設置Game 結構體的實例（包含數字範圍、正確的數字、猜測的剩餘次數、以及時間倒數
//    var game = Game(lowerBound: 1, upperBound: 100, correctAnswer: Int.random(in: 1...100), guessesLeft: 8, timeLeft: 10)
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        /// 設置鍵盤上的數字顯示（對應 Outlet Collections 拉動時的順序）
//        for (indx, button) in numberButtons.enumerated() {
//            button.setTitle(String(indx), for: .normal)                     // 設置鍵盤上的數字
//            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)     // 設置字體屬性大小
//            button.backgroundColor = .white                                 // 設置背景色（白色）
//
//            button.layer.cornerRadius = button.frame.width / 2              // 按鈕的圓角（圓形）
//            button.layer.borderWidth = 3.0                                  // 按鈕邊線的寬度
//            button.layer.borderColor = UIColor.black.cgColor                // 邊線的顏色
//            button.clipsToBounds = true                                     // 確保按鈕內容在圓形的邊界內顯示
//        }
//
////        print(game) // 測試用
//
//        // 初始化 promptLabel、guessedNumberLabel
//        promptLabel.text = "Range: 1 - 100"
//        guessedNumberLabel.text = "0"
//
//        // 更新 guessLeftLabel 的内容
//        updateGuessLeftLabel()
//
//        // 控制畫面狀態（隱藏結果畫面）
//        successGuessView.isHidden = true
//        gameOverView.isHidden = true
//
//    }
//
//
//    /// 數字鍵盤 0~9 的IBAction Collections
//    @IBAction func numberButtonPressed(_ sender: UIButton) {
//
//        clickNumberButtonSound()    // 按鈕音效
//
//        // 取得該按鈕 titleLabel 做為numberString的值
//        if let numberString = sender.titleLabel?.text {
//
//            // 如果 inputNumber 的長度已經達到 3，則忽略新的數字（限制字串長度，同時100也可能是答案）
//            if inputNumber.count < 3 {
//                // 否則，添加新的數字到 inputNumber 和 guessedNumberLabel
//                inputNumber += numberString
//                guessedNumberLabel.text = inputNumber
//                print("\(inputNumber)")
//            }
//            // 輸入的字串長度過長
//            else  {
//                print("輸入的數字已達到最大長度")
//            }
//
//        }
//
//    }
//
//
//    /// 當使用者點擊後，送出數字鍵盤輸入的數字到guessedNumberLabel上
//    @IBAction func enterGuessNumberPressed(_ sender: UIButton) {
//
//        // 檢查 inputNumber 是否為空，再進行轉換和解包。
//        if !inputNumber.isEmpty {
//            let guessNumber = Int(inputNumber)!
//
//            // 檢查使用者輸入的數字是否在猜測的範圍內
//            if game.isWithinBounds(guess: guessNumber) {
//
//                // 比對猜測狀態結果
//                switch game.makeGuess(guess: guessNumber) {
//                case .correct:
//                    print("猜對了！遊戲結束")            // 猜對了，更新界面並結束遊戲
//                    successGuessView.isHidden = false // 顯示 successGuessView
//                    gameTimer?.invalidate()           // 停止計時器
//                    gameTimer = nil                   // 設置為 nil
//                    successSound()                    // 猜對音效
//
//                case .incorrect:
//                    print("猜錯了，請再試一次，剩餘次數\(game.guessesLeft)")     // 猜錯了，更新猜測範圍、減少猜測次數並繼續遊戲
//                    updateGuessLeftLabel()                                 // 更新 guessLeftLabel 顯示
//                    functionButtonSound()                                  // 輸入音效（在猜錯時顯示）
//
//                case .gameover:
//                    print("遊戲失敗，你沒有猜對")       // 沒有猜對遊戲結束
//                    gameOverView.isHidden = false   // 顯示 gameOverView
//                    updateGuessLeftLabel()          // 更新 guessLeftLabel 顯示（讓最後一個💣可以被更新到）
//                    gameTimer?.invalidate()         // 停止計時器
//                    gameTimer = nil                 // 設置為 nil
//                    gameOverSound()                 // 次數猜完音效（遊戲失敗）
//
//                }
//
//                // 更新提示Label以及清空inputNumber
//                promptLabel.text = "Range: \(game.currentRange())"
//                // 測試（與clearNumberButtonPressed的操作邏輯有關，會影響到使用者的操作直覺）
//                inputNumber = ""
//                // 重設倒數計時器
//                game.timeLeft = 10
//
//            }
//            // 如果輸入超過的範圍
//            else {
//                print("你輸入的數字超出了當前的猜測範圍")
//            }
//
//        }
//
//        // 如果沒有輸入任何數字（沒有值）而按下enterGuessNumberPressed時。(沒有反應）
//        else {
//            print("沒有輸入任何的值，因此無反應。")
//        }
//
//    }
//
//
//    /// 清除字串的位數長度
//    @IBAction func clearNumberButtonPressed(_ sender: UIButton) {
//
//        clearButtonSound()  // 按鈕音效
//
//        // 如果inputNumber不為空，則清理最後一個位數
//        if !inputNumber.isEmpty {
//            inputNumber.removeLast()
//            guessedNumberLabel.text = inputNumber
//
//            // 當 guessedNumberLabel 都被清空時，則給予“0”
//            if guessedNumberLabel.text == "" {
//                guessedNumberLabel.text = "0"
//            }
//        }
//        // 用於處理當 enterGuessNumberPressed 執行後，這時候 inputNumber為""，要讓使用者可以更方便處理數字的清理。（測試）
//        else if inputNumber == "" {
//            guessedNumberLabel.text = "0"
//        }
//
//    }
//
//
//    /// 開始遊戲
//    @IBAction func startGameButtonPressed(_ sender: UIButton) {
//        startGame()                    // 開始遊戲
//        startGameView.isHidden = true  // 點擊Button後隱藏
//        startGameButtonSound()         // 開始遊戲音效
//    }
//
//
//    /// 重新開始
//    @IBAction func restartGameButtonPressed(_ sender: UIButton) {
//        startGame()                    // 開始遊戲
//        updateGuessLeftLabel()         // 更新使用者次數
//        promptLabel.text = "Range: \(game.currentRange())"        // 重置 promptLabel
//        guessedNumberLabel.text = "0"                             // 重置 guessedNumberLabel
//        inputNumber = ""                                          // 重置 inputNumber（清理上一場inputNumber，但還沒送出比較的數字）
//        gameOverView.isHidden = true                              // 隱藏 gameOverView
//        successGuessView.isHidden = true                          // 隱藏 successGuessView
//        startGameButtonSound()                                    // 按鈕音效
//    }
//
//
//    ///  更新 guessLeftLabel 顯示💣的部分（猜錯則顯示💥）
//    func updateGuessLeftLabel() {
//        let bombCount = game.guessesLeft                                     // 剩餘的機會顯示為 💣（猜測機會）
//        let explosionCount = 8 - bombCount                                   // 猜測失敗產生💥
//
//        let bombString = String(repeating: "💣", count: bombCount)           // 產生炸彈及次數
//        let explosionString = String(repeating: "💥", count: explosionCount) // 已經失去的機會顯示為 💥（猜測失敗）
//        guessLeftLabel.text = explosionString + bombString
//
//        // 檢查是否所有猜測次數已用完
//        if bombCount == 0 {
//            gameOverSound()     // 遊戲失敗音效
//        }
//
//    }
//
//
//    /// 初始化遊戲並開始計時器（在開始遊戲、重新開始使用）
//    func startGame() {
//        /// 設置Game 結構體的實例（包含數字範圍、正確的數字、猜測的剩餘次數、以及時間倒數）
//        game = Game(lowerBound: 1, upperBound: 100, correctAnswer: Int.random(in: 1...100), guessesLeft: 8, timeLeft: 10)
//
//        // 確保之前（上一個遊戲）的計時器已被清空
//        gameTimer?.invalidate()
//        gameTimer = nil
//
//        /// 啟動計時器
//        startTimer()
//
//        print(game)          // 測試用
//    }
//
//
//    /// 啟動計時器
//    func startTimer() {
//        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
//    }
//
//    /// 當計時器每次觸發時調用
//    @objc func updateTimer() {
//        if game.timeLeft > 0 {
//            game.decrementTime()                     // 減少一秒的時間
//            timerLabel.text = "\(game.timeLeft)"   // 更新 timerLabel
//            print("剩下的時間：\(game.timeLeft)秒")    // 更新展示剩餘時間
//        } else {
//            print("時間耗盡，遊戲結束")
//            gameTimer?.invalidate()                 // 停止計時器
//            gameTimer = nil                         // 設置為 nil
//            gameOverView.isHidden = false           // 顯示gameOverView
//            gameOverSound()                         // 遊戲失敗音效
//        }
//    }
//
//
//    /// startGameButton音效（用於開始遊戲、再玩一次）
//    func startGameButtonSound() {
//        let soundUrl = Bundle.main.url(forResource: "beepbeep", withExtension: "mp3")!
//        let playerItem = AVPlayerItem(url: soundUrl)
//        soundplayer.replaceCurrentItem(with: playerItem)
//        soundplayer.play()
//    }
//
//    /// 點擊數字的音效
//    func clickNumberButtonSound() {
//        let soundUrl = Bundle.main.url(forResource: "clickSound", withExtension: "mp3")!
//        let playerItem = AVPlayerItem(url: soundUrl)
//        soundplayer.replaceCurrentItem(with: playerItem)
//        soundplayer.play()
//    }
//
//
//    /// 點擊enterGuessNumberPressed按鈕的音效（猜錯 .incorrect 才會顯示該音效）
//    func functionButtonSound() {
//        let soundUrl = Bundle.main.url(forResource: "functionButton", withExtension: "mp3")!
//        let playerItem = AVPlayerItem(url: soundUrl)
//        soundplayer.replaceCurrentItem(with: playerItem)
//        soundplayer.play()
//    }
//
//    /// 點擊clearButton的音效
//    func clearButtonSound() {
//        let soundUrl = Bundle.main.url(forResource: "clearButtonSound", withExtension: "mp3")!
//        let playerItem = AVPlayerItem(url: soundUrl)
//        soundplayer.replaceCurrentItem(with: playerItem)
//        soundplayer.play()
//    }
//
//    /// GameOver的音效（用於當猜測次數用完、時間倒數結束）
//    func gameOverSound() {
//        let soundUrl = Bundle.main.url(forResource: "explosion", withExtension: "mp3")!
//        let playerItem = AVPlayerItem(url: soundUrl)
//        soundplayer.replaceCurrentItem(with: playerItem)
//        soundplayer.play()
//    }
//
//    /// correct 猜中的音效
//    func successSound() {
//        let soundUrl = Bundle.main.url(forResource: "winSound", withExtension: "mp3")!
//        let playerItem = AVPlayerItem(url: soundUrl)
//        soundplayer.replaceCurrentItem(with: playerItem)
//        soundplayer.play()
//    }
//
//}




/*----------------------------------------------------------------------------*/



/// 初始版（已完成初步功能）
//import UIKit
//
//class ViewController: UIViewController {
//
//    /// 數字鍵盤 0~9 的IBOutlet Collections
//    @IBOutlet var numberButtons: [UIButton]!
//    /// 提示Label：目前數字範圍
//    @IBOutlet weak var promptLabel: UILabel!
//
//    /// 使用者猜測的數字
//    @IBOutlet weak var guessedNumberLabel: UILabel!
//
//
//    /// 用來保存使用者輸入的數字
//    var inputNumber = ""
//
//    /// 設置Game 結構體的實例
//    var game = Game(lowerBound: 1, upperBound: 100, correctAnswer: Int.random(in: 1...100), guessesLeft: 8, timeLeft: 10)
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        /// 設置鍵盤上的數字顯示（對應 Outlet Collections 拉動時的順序）
//        for (indx, button) in numberButtons.enumerated() {
//            button.setTitle(String(indx), for: .normal)                     // 設置鍵盤上的數字
//            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)     // 設置字體屬性大小
//            button.backgroundColor = .white                                 // 設置背景色（白色）
//
//            button.layer.cornerRadius = button.frame.width / 2              // 按鈕的圓角（圓形）
//            button.layer.borderWidth = 3.0                                  // 按鈕邊線的寬度
//            button.layer.borderColor = UIColor.black.cgColor                // 邊線的顏色
//            button.clipsToBounds = true                                     // 確保按鈕內容在圓形的邊界內顯示
//        }
//
//        print(game)
//
//        // 初始化 promptLabel、guessedNumberLabel
//        promptLabel.text = "目前範圍介於 1 ~ 100"
//        guessedNumberLabel.text = "0"
//    }
//
//
//    /// 數字鍵盤 0~9 的IBAction Collections
//    @IBAction func numberButtonPressed(_ sender: UIButton) {
//        // 取得該按鈕 titleLabel 做為numberString的值
//        if let numberString = sender.titleLabel?.text {
//
//            // 如果 inputNumber 的長度已經達到 3，則忽略新的數字（限制字串長度，同時100也可能是答案）
//            if inputNumber.count < 3 {
//                // 否則，添加新的數字到 inputNumber 和 guessedNumberLabel
//                inputNumber += numberString
//                guessedNumberLabel.text = inputNumber
//                print("\(inputNumber)")
//            } else  {
//                print("輸入的數字已達到最大長度")
//            }
//
//        }
//
//    }
//
//
//    /// 當使用者點擊後，送出數字鍵盤輸入的數字到guessedNumberLabel上
//    @IBAction func enterGuessNumberPressed(_ sender: UIButton) {
//
//        // 檢查 inputNumber 是否為空，再進行轉換和解包。
//        if !inputNumber.isEmpty {
//            let guessNumber = Int(inputNumber)!
//
//            // 檢查使用者輸入的數字是否在猜測的範圍內
//            if game.isWithinBounds(guess: guessNumber) {
//
//                // 比對猜測狀態結果
//                switch game.makeGuess(guess: guessNumber) {
//                case .correct:
//                    // 猜對了，更新界面並結束遊戲
//                    print("猜對了！遊戲結束")
//                case .incorrect:
//                    // 猜錯了，更新界面並繼續遊戲
//                    print("猜錯了，請再試一次")
//                case .gameover:
//                    print("遊戲結束，你沒有猜對")
//                }
//
//                // 更新提示Label以及清空inputNumber
//                promptLabel.text = "目前範圍介於 \(game.currentRange())"
//                inputNumber = ""
//            }
//            // 如果輸入超過的範圍
//            else {
////                inputNumber = ""
//                print("你輸入的數字超出了當前的猜測範圍")
//            }
//
//        }
//        // 如果沒有輸入任何數字（沒有值）而按下enterGuessNumberPressed時。(沒有反應）
//        else {
//            // 顯示一條錯誤訊息或者進行其他的錯誤處理
//            print("沒有輸入任何的值，因此無反應。")
//        }
//
//    }
//
//    /// 清除字串的位數
//    @IBAction func clearNumberButtonPressed(_ sender: UIButton) {
//
//        // 如果inputNumber不為空，則清理最後一個位數
//        if !inputNumber.isEmpty {
//            inputNumber.removeLast()
//            guessedNumberLabel.text = inputNumber
//
//            // 當 guessedNumberLabel 都被清空時，則給予“0”
//            if guessedNumberLabel.text == "" {
//                guessedNumberLabel.text = "0"
//            }
//        }
//    }
//
//}
