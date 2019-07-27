//
//  AudioViewController.swift
//  SpeakNow
//
//  Created by Razvan Rujoiu on 24/07/2019.
//  Copyright © 2019 Rujoiu Razvan. All rights reserved.
//

import AVFoundation
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
    private var audioId = 0

    
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
    
    func postAudioRecord(id: Int, title: String, content: [UInt8]) {
        AudioRecordService.shared.postAudioRecord(id: id, title: title, content: content) { (err) in
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
            self.recordingsTableView.reloadData()
        }
    }


    
    @IBAction func startRecording(_ sender: UIButton) {
        self.recordingLabel.isHidden = false
        self.stopRecordingButton.isEnabled = true
        self.startRecordingButton.isEnabled = false
       
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
        if !flag {
          
         //  let audioContentByteArray: [UInt8] = convertAudioFileToByteArray(path: recorder.url)
            let data = NSData(contentsOf: recorder.url)
            
//            do {
//
//                let content =  String(data: data as! Data, encoding: .utf8)
//                self.audioRecord = AudioRecord(id: self.audioId, title: recorder.url.lastPathComponent, content: content!)
//                } catch {
//                    print("error when converting recording to string")
//                }

           // let stringContent = String(bytes: audioContentByteArray, encoding: .utf8)

//           self.audioRecord = AudioRecord(
//                                id: audioId,
//                                title: recorder.url.lastPathComponent,
//                                content: stringContent!)
//            postAudioRecord(id: 111,
//                            title: "Razvan",
//                            content: audioContentByteArray)
//            audioId += 1
            self.recordingsTableView.reloadData()
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
    
    func convertAudioFileToByteArray(path: URL) -> [UInt8] {
        var byteArray = [UInt8]()
        if let data = NSData(contentsOf: path) {
            byteArray = data.map {
                UInt8($0)
            }
        }
        return byteArray
    }
    
   
    
    
}

extension AudioViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioRecordsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAudio", for: indexPath)
        cell.textLabel?.text = audioRecordsList[indexPath.row].title
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audioRecord = self.audioRecordsList[indexPath.row]
        
        do {
            if let data = NSData(base64Encoded: audioRecord.content, options: .ignoreUnknownCharacters) {
                audioPlayer = try! AVAudioPlayer(data: data as Data)
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
