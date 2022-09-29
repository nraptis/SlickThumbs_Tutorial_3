//
//  PriorityDataDownloader.swift
//  SlickThumbnail
//
//  Created by Nick Raptis on 9/28/22.
//

import Foundation

protocol PriorityDataDownloaderDelegate: AnyObject {
    func dataDownloadDidStart(_ thumbModel: ThumbModel)
    func dataDownloadSuccess(_ thumbModel: ThumbModel)
    func dataDownloadFailure(_ thumbModel: ThumbModel)
}

class PriorityDataDownloader {
    
    private let numberOfSimultaneousDownloads: Int
    init(numberOfSimultaneousDownloads: Int) {
        self.numberOfSimultaneousDownloads = numberOfSimultaneousDownloads
    }
    
    weak var delegate: PriorityDataDownloaderDelegate?
    private(set) var taskList = [PriorityDataDownloaderTask]()
    private var _numberOfActiveDownloads = 0
    
    func addDownloadTask(_ thumbModel: ThumbModel) {
        if doesTaskExist(thumbModel) == false {
            let newTask = PriorityDataDownloaderTask(self, thumbModel)
            taskList.append(newTask)
        }
    }
    
    func removeDownloadTask(_ thumbModel: ThumbModel) {
        if let index = taskIndex(thumbModel) {
            taskList.remove(at: index)
        }
    }
    
    private func doesTaskExist(_ thumbModel: ThumbModel) -> Bool {
        return taskIndex(thumbModel) != nil
    }

    private func taskIndex(_ thumbModel: ThumbModel) -> Int? {
        for index in taskList.indices {
            if taskList[index].index == thumbModel.index {
                return index
            }
        }
        return nil
    }
    
    private func chooseTaskToStart() -> PriorityDataDownloaderTask? {
        for task in taskList {
            if task.active == false {
                return task
            }
        }
        return nil
    }
    
    func startTasksIfNeeded() {
        while _numberOfActiveDownloads < numberOfSimultaneousDownloads {
            if let task = chooseTaskToStart() {
                task.start()
                computeNumberOfActiveDownloads()
                delegate?.dataDownloadDidStart(task.thumbModel)
            } else {
                return
            }
        }
    }
    
    private func computeNumberOfActiveDownloads() {
        _numberOfActiveDownloads = 0
        for task in taskList {
            if task.active {
                _numberOfActiveDownloads += 1
            }
        }
    }
}

extension PriorityDataDownloader {
    func handleTaskDidSucceed(_ task: PriorityDataDownloaderTask) {
        removeDownloadTask(task.thumbModel)
        computeNumberOfActiveDownloads()
        delegate?.dataDownloadSuccess(task.thumbModel)
    }

    func handleTaskDidFail(_ task: PriorityDataDownloaderTask) {
        removeDownloadTask(task.thumbModel)
        computeNumberOfActiveDownloads()
        delegate?.dataDownloadFailure(task.thumbModel)
    }
}
