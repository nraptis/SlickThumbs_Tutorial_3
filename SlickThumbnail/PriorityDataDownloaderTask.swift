//
//  PriorityDataDownloaderTask.swift
//  SlickThumbnail
//
//  Created by Nick Raptis on 9/28/22.
//

import Foundation

class PriorityDataDownloaderTask {
    
    
    weak var downloader: PriorityDataDownloader?
    let thumbModel: ThumbModel
    
    private(set) var active = false
    
    init(_ downloader: PriorityDataDownloader, _ thumbModel: ThumbModel) {
        self.downloader = downloader
        self.thumbModel = thumbModel
    }
    
    var index: Int {
        return thumbModel.index
    }
    
    func start() {
        active = true
        DispatchQueue.global(qos: .background).async {
            Thread.sleep(forTimeInterval: TimeInterval.random(in: 0.25...1.0))
            DispatchQueue.main.async {
                if Int.random(in: 0...2) == 0 {
                    self.active = false
                    self.downloader?.handleTaskDidFail(self)
                } else {
                    self.active = false
                    self.downloader?.handleTaskDidSucceed(self)
                }
            }
        }
    }
    

}
