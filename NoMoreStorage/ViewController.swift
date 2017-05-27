//
//  ViewController.swift
//  NoMoreStorage
//
//  Created by Lukas Böhler on 01/08/16.
//  Copyright © 2016 Lukas Böhler. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var freeStorageLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var aimedFreeStorage: UITextField!
    
    var writeBullshit = false
    var removeBullshit = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        startButton.layer.cornerRadius = 3.0
        aimedFreeStorage.layer.cornerRadius = 3.0
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.hideKeyBoard))
        view.addGestureRecognizer(gesture)
    }
    
    func update() {
        // Check diskstorage.
        let freeSpaceInMBytes = deviceRemainingFreeSpaceInMBytes()
        freeStorageLabel.text = "\(freeSpaceInMBytes!)"
        
        if let aimedFreeSpace = Int(aimedFreeStorage.text!) {
            if(freeSpaceInMBytes! < aimedFreeSpace) {
                self.writeBullshit = false
            }
        }
    }
    
    @IBAction func hideKeyboard(_ sender: AnyObject) {
        sender.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideKeyBoard() {
        aimedFreeStorage.resignFirstResponder();
    }
    
    func deviceRemainingFreeSpaceInMBytes() -> Int? {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectoryPath.last!) {
            if let freeSize = systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber {
                return Int(Double(freeSize.int64Value) / 1000000.0)
            }
        }
        // something failed
        return nil
    }
    
    @IBAction func startWrittingBullshit() {
        self.writeBullshit = !self.writeBullshit
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
            let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0]
            let fileMgr = FileManager.default
            while self.writeBullshit {
                let diceRoll = Int(arc4random_uniform(10000) + 1)
                let destPath = (docsDir as NSString).appendingPathComponent("/alotof_\(diceRoll).shit")
                if let path = Bundle.main.path(forResource: "alotof", ofType:"shit") {
                    do {
                        try fileMgr.copyItem(atPath: path, toPath: destPath)
                    } catch _ {
                        
                    }
                }
            }
        }
    }
    
    @IBAction func FreeSpace(_ sender: Any) {
        self.removeBullshit = !self.removeBullshit;
        removeFile();
    }
    
    func removeFile() {
        let priority = DispatchQueue.GlobalQueuePriority.default
        DispatchQueue.global(priority: priority).async {
            let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0]
            let fileMgr = FileManager.default
            while self.removeBullshit {
                do {
                    let directoryContents = try fileMgr.contentsOfDirectory(atPath: docsDir)
                    if directoryContents.count > 0 {
                        try fileMgr.removeItem(atPath: (docsDir as NSString).appendingPathComponent("/\(directoryContents.first!)"))
                    } else {
                        self.removeBullshit = false;
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    @IBAction func removeSingleFile(_ sender: Any) {
        removeOneFile()
    }
    
    func removeOneFile() {
        let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0]
        let fileMgr = FileManager.default
        do {
            let directoryContents = try fileMgr.contentsOfDirectory(atPath: docsDir)
            if directoryContents.count > 0 {
                try fileMgr.removeItem(atPath: (docsDir as NSString).appendingPathComponent("/\(directoryContents.first!)"))
            } else {
                self.removeBullshit = false;
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension OutputStream {
    /// http://stackoverflow.com/questions/26989493/how-to-open-file-and-append-a-string-in-it-swift
    /// Write String to outputStream
    ///
    /// - parameter string:                The string to write.
    /// - parameter encoding:              The NSStringEncoding to use when writing the string. This will default to UTF8.
    /// - parameter allowLossyConversion:  Whether to permit lossy conversion when writing the string.
    ///
    /// - returns:                         Return total number of bytes written upon success. Return -1 upon failure.
    
    func write(_ string: String, encoding: String.Encoding = String.Encoding.utf8, allowLossyConversion: Bool = true) -> Int {
        if let data = string.data(using: encoding, allowLossyConversion: allowLossyConversion) {
            var bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
            var bytesRemaining = data.count
            var totalBytesWritten = 0
            
            while bytesRemaining > 0 {
                let bytesWritten = self.write(bytes, maxLength: bytesRemaining)
                if bytesWritten < 0 {
                    return -1
                }
                
                bytesRemaining -= bytesWritten
                bytes += bytesWritten
                totalBytesWritten += bytesWritten
            }
            
            return totalBytesWritten
        }
        
        return -1
    }
    
}

