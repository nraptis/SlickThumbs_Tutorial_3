//
//  PriorityDataDownloader.swift
//  SlickThumbnail
//
//  Created by Nick Raptis on 9/30/22.
//

import Foundation

protocol PriorityDataDownloaderDelegate: AnyObject {
    func dataDownloadDidStart(_ thumbModel: ThumbModel)
    func dataDownloadDidSucceed(_ thumbModel: ThumbModel)
    func dataDownloadDidFail(_ thumbModel: ThumbModel)
}

class PriorityDataDownloader {
    
    weak var delegate: PriorityDataDownloaderDelegate?
    
    private let numberOfSimultaneousDownloads: Int
    init(numberOfSimultaneousDownloads: Int) {
        self.numberOfSimultaneousDownloads = numberOfSimultaneousDownloads
    }
    
    private(set) var taskList = [PriorityDataDownloaderTask]()
    private var _numberOfActiveDownloads = 0
    
    func addDownloadTask(_ thumbModel: ThumbModel) {
        guard !doesTaskExist(thumbModel) else { return }
        
        let newTask = PriorityDataDownloaderTask(self, thumbModel)
        taskList.append(newTask)
        computeNumberOfActiveDownloads()
    }
    
    func removeDownloadTask(_ thumbModel: ThumbModel) {
        guard let index = taskIndex(thumbModel) else { return }
        taskList.remove(at: index)
        computeNumberOfActiveDownloads()
    }
    
    func doesTaskExist(_ thumbModel: ThumbModel) -> Bool { taskIndex(thumbModel) != nil }
    
    private func taskIndex(_ thumbModel: ThumbModel) -> Int? {
        for (index, task) in taskList.enumerated() {
            if task.thumbModelIndex == thumbModel.index { return index }
        }
        return nil
    }
    
    private func computeNumberOfActiveDownloads() {
        _numberOfActiveDownloads = 0
        for task in taskList {
            if task.active == true {
                _numberOfActiveDownloads += 1
            }
        }
    }
    
    private func chooseTaskToStart() -> PriorityDataDownloaderTask? {
        for task in taskList {
            if task.active == false {
                return task
            }
        }
        return nil
    }
    
    func startTasksIfNecessary() {
        while _numberOfActiveDownloads < numberOfSimultaneousDownloads {
            if let task = chooseTaskToStart() {
                // start the task!
                task.start()
                computeNumberOfActiveDownloads()
                delegate?.dataDownloadDidStart(task.thumbModel)
            } else {
                // there are no tasks to start, must exit!
                return
            }
            
        }
        
    }
    
}

extension PriorityDataDownloader {
    
    func handleDownloadTaskDidSucceed(_ task: PriorityDataDownloaderTask) {
        removeDownloadTask(task.thumbModel)
        computeNumberOfActiveDownloads()
        delegate?.dataDownloadDidSucceed(task.thumbModel)
    }
    
    func handleDownloadTaskDidFail(_ task: PriorityDataDownloaderTask) {
        removeDownloadTask(task.thumbModel)
        computeNumberOfActiveDownloads()
        delegate?.dataDownloadDidFail(task.thumbModel)
    }
    
}
