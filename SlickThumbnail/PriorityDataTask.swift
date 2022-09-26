//
//  PriorityDataTask.swift
//  SlickThumbnail
//
//  Created by Nick Raptis on 9/25/22.
//

import Foundation

class PriorityDataTask {
    
    weak var downloader: PriorityDataDownloader?
    let thumbModel: ThumbModel
    private var isActive: Bool = false
    
    init(thumbModel: ThumbModel, downloader: PriorityDataDownloader) {
        self.thumbModel = thumbModel
        self.downloader = downloader
    }
    
    var active: Bool {
        return isActive
    }
    
    var index: Int {
        return thumbModel.index
    }
    
    func start() {
        isActive = true
        DispatchQueue.global(qos: .utility).async {
            Thread.sleep(forTimeInterval: TimeInterval.random(in: 0.25...1.0))
            DispatchQueue.main.async {
                self.isActive = false
                self.downloader?.handleTaskDidSucceed(self)
            }
        }
    }
    
}
