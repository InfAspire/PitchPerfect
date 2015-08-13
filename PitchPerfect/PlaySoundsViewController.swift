//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by cb on 4/29/15.
//  Copyright (c) 2015 InfAspire. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    typealias dispatch_cancelable_closure = (cancel : Bool) -> Void
    var retVal:dispatch_cancelable_closure?
    
    var audioPlayer:AVAudioPlayer?
    var receivedAudio:RecordedAudio?
    var audioEngine:AVAudioEngine?
    var audioFile:AVAudioFile?
    var audioFilePlayer:AVAudioPlayerNode?
    var audioAsset:AVURLAsset?
    var audioDurationSeconds:Float64 = 0.0
    
    @IBOutlet weak var stopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio!.filePathUrl, fileTypeHint: "wav", error: nil)
        
        if let audioPlayer = audioPlayer {
            audioPlayer.enableRate = true
            audioPlayer.delegate = self
        }
        
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio!.filePathUrl, error: nil)
        
        audioAsset = AVURLAsset(URL: receivedAudio!.filePathUrl, options: nil)
        let audioDuration = audioAsset!.duration;
        audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func playSlow(sender: UIButton) {
        if let sound = audioPlayer {
            sound.rate = 0.5
            play()
        }
    }
    
    @IBAction func playFast(sender: UIButton) {
        if let sound = audioPlayer {
            sound.rate = 1.5
            play()
        }
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction func playDarthVaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    func playAudioWithVariablePitch(pitch: Float){
        stop()
        
        let audioPlayerNode = AVAudioPlayerNode()
        
        if let audioEngine = audioEngine {
            audioEngine.attachNode(audioPlayerNode)
            
            let changePitchEffect = AVAudioUnitTimePitch()
            changePitchEffect.pitch = pitch
            
            audioEngine.attachNode(changePitchEffect)
            audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
            audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
            audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil )
            audioEngine.startAndReturnError(nil)
        }
        
        stopButton.hidden=false
        audioPlayerNode.play()
        
        retVal = delay(audioDurationSeconds) {
            self.stop()
        }
    }
    
    @IBAction func stopPlayback(sender: UIButton) {
        stop();
    }
    
    func stop() {
        cancel_delay(retVal)
        if let audioPlayer = audioPlayer {
            audioPlayer.stop()
            audioPlayer.currentTime=0.0
        }
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
        stopButton.hidden=true
    }

    func play() {
        stop();
        
        if let audioPlayer = audioPlayer {
            audioPlayer.play()
            stopButton.hidden=false
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        stopButton.hidden=true
    }
    
    // delay function used to properly hide the stop playback button for the variable pitch items
    // needed a cancelable one to handle the situations where users click on a button while playback is occurring
    // code taken from http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift
    
    func delay(time:NSTimeInterval, closure:()->Void) ->  dispatch_cancelable_closure? {
        
        func dispatch_later(clsr:()->Void) {
            dispatch_after(
                dispatch_time(
                    DISPATCH_TIME_NOW,
                    Int64(time * Double(NSEC_PER_SEC))
                ),
                dispatch_get_main_queue(), clsr)
        }
        
        var closure:dispatch_block_t? = closure
        var cancelableClosure:dispatch_cancelable_closure?
        
        let delayedClosure:dispatch_cancelable_closure = { cancel in
            if closure != nil {
                if (cancel == false) {
                    dispatch_async(dispatch_get_main_queue(), closure!);
                }
            }
            closure = nil
            cancelableClosure = nil
        }
        
        cancelableClosure = delayedClosure
        
        dispatch_later {
            if let delayedClosure = cancelableClosure {
                delayedClosure(cancel: false)
            }
        }
        
        return cancelableClosure;
    }
    
    func cancel_delay(closure:dispatch_cancelable_closure?) {
        
        if closure != nil {
            closure!(cancel: true)
        }
    }

}
