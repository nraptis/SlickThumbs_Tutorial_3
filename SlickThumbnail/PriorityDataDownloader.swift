//
//  PriorityDataDownloader.swift
//  SlickThumbnail
//
//  Created by Nick Raptis on 9/25/22.
//

import Foundation

protocol PriorityDataDownloaderDelegate: AnyObject {
    func dataDownloadSuccess(_ thumbModel: ThumbModel)
}

class PriorityDataDownloader {
    
    weak var delegate: PriorityDataDownloaderDelegate?
    
    private let numberOfSimultaneousDownloads: Int
    init(numberOfSimultaneousDownloads: Int) {
        self.numberOfSimultaneousDownloads = numberOfSimultaneousDownloads
    }
    
    private var taskList = [PriorityDataTask]()
    
    func addDownloadTask(_ thumbModel: ThumbModel) {
        if doesTaskExist(for: thumbModel) { return }
        let newTask = PriorityDataTask(thumbModel: thumbModel, downloader: self)
        taskList.append(newTask)
        startTasksIfNeeded()
    }
    
    func removeDownloadTask(_ thumbModel: ThumbModel) {
        if let taskIndex = index(for: thumbModel) {
            taskList.remove(at: taskIndex)
        }
    }
    
    func index(for thumbModel: ThumbModel) -> Int? {
        for taskIndex in taskList.indices {
            if taskList[taskIndex].index == thumbModel.index {
                return taskIndex
            }
        }
        return nil
    }
    
    func doesTaskExist(for thumbModel: ThumbModel) -> Bool {
        return index(for: thumbModel) != nil
    }
    
    private var numberOfActiveDownloads = 0
    private func computeNumberOfActiveDownloads() {
        numberOfActiveDownloads = 0
        for task in taskList {
            if task.active {
                numberOfActiveDownloads += 1
            }
        }
    }
    
    private func chooseTaskToStart() -> PriorityDataTask? {
        for task in taskList {
            if task.active == false {
                return task
            }
        }
        return nil
    }
    
    private func startTasksIfNeeded() {
        while numberOfActiveDownloads < numberOfSimultaneousDownloads {
            if let task = chooseTaskToStart() {
                task.start()
                computeNumberOfActiveDownloads()
            } else {
                return
            }
        }
    }
    
}

// Task responses...
extension PriorityDataDownloader {
    
    func handleTaskDidSucceed(_ task: PriorityDataTask) {
        removeDownloadTask(task.thumbModel)
        computeNumberOfActiveDownloads()
        delegate?.dataDownloadSuccess(task.thumbModel)
        startTasksIfNeeded()
    }
    
}
