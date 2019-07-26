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
    
    var audioList: [String] = ["Andrei", "Marius", "Daniel"]
    
    override func viewDidLoad() {
        self.stopRecordingButton.isEnabled = false
        self.recordingLabel.isHidden = true
    }
    
    
    
    @IBAction func startRecording(_ sender: UIButton) {
        SVProgressHUD.show()
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
        SVProgressHUD.dismiss()
        audioRecorder.record()
        self.recordingsTableView.reloadData()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            
            let audioContentByteArray: [UInt8] = convertAudioFileToByteArray(path: recorder.url)
            
           self.audioRecord = AudioRecord(
                                id: audioId,
                                title: recorder.url.lastPathComponent,
                                content: audioContentByteArray)
            audioRecordsList.append(audioRecord)
            audioId += 1
            self.recordingsTableView.reloadData()
        } else {
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
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let audioRecord =
//    }
//
}
