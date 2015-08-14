//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by cb on 4/13/15.
//  Copyright (c) 2015 InfAspire. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var recordingLabel: UILabel?
    @IBOutlet weak var stopButton: UIButton?
    @IBOutlet weak var recordButton: UIButton?

    var audioRecorder:AVAudioRecorder?
    var recordedAudio:RecordedAudio?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordAudio(sender: UIButton) {
        println("in recordAudio")
        changeState()
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        let recordingName = "recording.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        let session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)

        if let audioRecorder = audioRecorder {
            audioRecorder.delegate=self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag) {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            println("error with recording");
            if (!recordButton!.enabled) {
                changeState()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    @IBAction func stopTapped(sender: UIButton) {
        audioRecorder!.stop()
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
        changeState()
    }
    
    func changeState() {
        recordButton!.enabled = !recordButton!.enabled
        if let recordingLabel = recordingLabel {
            if (recordingLabel.text=="Recording...") {
                recordingLabel.text="Tap to Record"
            } else {
                recordingLabel.text="Recording..."
            }
        }
        stopButton!.hidden = !stopButton!.hidden
    }
}

