//
//  RecordedAudio.swift
//  PitchPerfect
//
//  Created by cb on 8/12/15.
//  Copyright (c) 2015 InfAspire. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject{
    var filePathUrl: NSURL?
    var title: String?

    init(filePathUrl: NSURL, title:String) {
        self.filePathUrl = filePathUrl;
        self.title = title;
    }    
}
