//
//  AudioViewController.swift
//  SpeakNow
//
//  Created by Razvan Rujoiu on 24/07/2019.
//  Copyright © 2019 Rujoiu Razvan. All rights reserved.
//

import AVFoundation
import CryptoSwift
import PMAlertController
import SVProgressHUD
import UIKit

class AudioViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    
    @IBOutlet private weak var recordingLabel: UILabel!
    @IBOutlet private weak var stopRecordingButton: UIButton!
    @IBOutlet private weak var startRecordingButton: UIButton!
    @IBOutlet private weak var recordingsTableView: UITableView!
    
    private var audioRecord: AudioRecord!
    private var audioRecordsList: [AudioRecord] = []
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        
        self.stopRecordingButton.isEnabled = false
        self.recordingLabel.isHidden = true
        fetchAudioRecords()
        self.recordingsTableView.reloadData()
        
    
    }
    
    fileprivate func fetchAudioRecords() {
        AudioRecordService.shared.fetchAudioRecords { (res) in
            switch res {
            case .failure(let err):
                print("Failed to fetch audio records:", err)
            case .success(let audioRecords):
                self.audioRecordsList = audioRecords
                self.recordingsTableView.reloadData()
            }
        }
    }
    
    func postAudioRecord(title: String, content: String, date: String) {
        AudioRecordService.shared.postAudioRecord(title: title, content: content, date: date) { (err) in
            if let err = err {
                print("Failed to create post object", err)
                return
            }
            print("Finished creating post")
            self.fetchAudioRecords()
            DispatchQueue.main.async {
                self.recordingsTableView.reloadData()
            }
            
        }
    }
    
    func deleteAudioRecord(id: Int) {
        AudioRecordService.shared.deleteAudioRecord(id: id) { (err) in
            if let err = err {
                print("Failed to delete", err)
                return
            }
            print("Succesfully deleted post from server")
            self.fetchAudioRecords()
            DispatchQueue.main.async {
                self.recordingsTableView.reloadData()
            }
            
        }
    }


    
    @IBAction func startRecording(_ sender: UIButton) {
        self.recordingLabel.isHidden = false
        self.stopRecordingButton.isEnabled = true
        self.startRecordingButton.isEnabled = false
       
        
        
        UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.recordingLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        })
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String

        let currentDateTime = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy-HH-mm"
        let recordingName = formatter.string(from: currentDateTime as Date) + ".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURL(withPathComponents: pathArray)
        
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        try! session.setActive(true)

        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            var recordingTitle: String = "Default"
            showInputDialog(title: "Success",
                            subtitle: "Name the recording",
                            actionTitle: "Add",
                            cancelTitle: "Cancel",
                            inputPlaceholder: "recording name",
                            inputKeyboardType: .default,
                            cancelHandler: { (UIAlertAction) in
                                return
            }) { (input: String?) in
                recordingTitle = input!
                SVProgressHUD.show()
                do {
                    
                    let fileData = try Data.init(contentsOf: recorder.url)
                    
                    let fileStream: String = fileData.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
                    
                    let datetimeNow = Date()
                    let now:String = datetimeNow.toString(dateFormat:"yyyy-MM-dd'T'HH:mm:ss.SSS")
                    self.postAudioRecord(title: recordingTitle,
                                    content: fileStream,
                                    date: now)
                    
                } catch {
                    print("error when converting recording to string")
                }
                
                self.recordingsTableView.reloadData()
                SVProgressHUD.dismiss()
            }
           
        } else {
            stopRecordingButton.isEnabled = false
            startRecordingButton.isEnabled = true
            let alertVC = PMAlertController(title: "Error", description: "Recording was not succesful", image: UIImage(named: "icons8-error"), style: .alert)
            alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: {
                print("OK")
            }))
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        recordingLabel.isHidden = true
        startRecordingButton.isEnabled = true
        stopRecordingButton.isEnabled = false
        audioRecorder.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        
        self.recordingsTableView.reloadData()
        
    }
    

//    func aesEncrypt(text: String, key: String, iv: String) -> String? {
//        do {
//            let aes = try AES(key: key, iv: iv, padding: .pkcs7)
//            let cipherText = try aes.encrypt(text.bytes)
//            return String(bytes: cipherText, encoding: String.Encoding.utf8)!
//        } catch {}
//        return nil
//    }
//    
//    func aesDecrypt(text: String, key: String, iv: String) -> String? {
//        do {
//             let aes = try AES(key: key, iv: iv, padding: .pkcs7)
//             let cipherText = try aes.decrypt(text.bytes)
//            return String(bytes: cipherText, encoding: String.Encoding.utf8)
//        } catch {}
//        return nil
//    }

}

extension AudioViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioRecordsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAudio", for: indexPath) as! AudioRecordTableViewCell
        cell.load(audioRecord: audioRecordsList[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audioRecord = self.audioRecordsList[indexPath.row]
        
        do {
            
            if let data = NSData(base64Encoded: audioRecord.content, options: .ignoreUnknownCharacters) {
                audioPlayer = try! AVAudioPlayer(data: data as Data, fileTypeHint: AVFileType.mp3.rawValue)
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
            }
        } catch {
            print("Error at playing recording when pressing cell or the filepath was null")
            print(error.localizedDescription)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let audioRecord = self.audioRecordsList[indexPath.row]
        deleteAudioRecord(id: audioRecord.id)
    }
}

