//
//  MyPageModel.swift
//  SlickThumbnail
//
//  Created by Nick Raptis on 9/23/22.
//

import Foundation

enum ServiceError: Error {
    case any
}

class MyPageModel {
    
    private let allEmojis = "🚙🤗🦊🪗🪕🎻🐻‍❄️🚘🚕🏈⚾️🙊🙉🌲😄😁😆🚖🏎🚚🛻🎾🏐🥏🏓🥁😋🛩🚁🦓🦍🦧😌😛😎🥸🤩🦬🐃🦙🐐☹️😣😖😭🦣🦏🐪⛴🚢🚂🚝🚅😟😕🙁😤🎺🐎🐖🐏🐑🐶🐱🐭🍀🍁🍄🌾☁️🌦🌧⛈😅😂🤣🥲☺️🚛🚐🚓🥺😢🦎🦖🦕🥰😘😗😙🛸🚲☔️🐻🐼🐘🦛😍😚😠😡🤯💦🌊☂️🚤🛥🛳🚆🦇🐢🐍🐅🐆🛫🛬🏍🛶⛵️😳🥶😥🚗😓🐨🐯🦅🦉🐫🦒🙃😉🥳😏🐓🐁❄️💨💧🐰🦁🐮🥌🏂😔🏀⚽️🎼🎤🎹🪘🐥🐣🐂🐄🐵🙈🤭🤫🥀🌨🌫🦮🐈🦤😯😧✈️🚊🚔😝😜🤪🤨🐀🐒🦆🧐🤓🕊🦝🦨🦡😫😩🚉😴🤮🌺🌸😬🙄🥱🚀🚇🛺😞🤥😷🦌🐕🌴🌿☘️☀️🌤⛅️🌥😀😃🐩🦢🥅⛷🎳🚑🚒🚜🌷🌹🌼😇🙂🤧🦘🦩🦫🦦😊🤒🤠🐹🐷🐸🐲🌩🌪🦙🐐🦥🐿🦔💐🌻⛳️"
    
    private var thumbModelList = [ThumbModel?]()
    private var thumbDownloadStatusList = [ThumbDownloadStatus]()
    
    func thumbModel(at index: Int) -> ThumbModel? {
        if index >= 0 && index < thumbModelList.count {
            return thumbModelList[index]
        }
        return nil
    }
    
    func clear() {
        thumbModelList.removeAll()
    }
    
    var totalExpectedCount: Int {
        return 118
    }
    
    private func simulateRangeFetchComplete(at index: Int, withCount count: Int) {
        let newCapacity = index + count
        
        if newCapacity <= 0 { return }
        guard count > 0 else { return }
        guard index < allEmojis.count else { return }
        if count > 8192 { return }
        
        let emojisArray = Array(allEmojis)
        
        while thumbModelList.count < newCapacity {
            thumbModelList.append(nil)
        }
        while thumbDownloadStatusList.count < newCapacity {
            thumbDownloadStatusList.append(ThumbDownloadStatus(downloadDidSucceed: false, downloadDidFail: false))
        }
        
        var index = index
        while index < newCapacity {
            if index >= 0 && index < emojisArray.count, thumbModelList[index] == nil {
                let newModel = ThumbModel(index: index, image: String(emojisArray[index]))
                thumbModelList[index] = newModel
            }
            index += 1
        }
    }
    
    func fetch(at index: Int, withCount count: Int, completion: @escaping ( Result<Void, ServiceError> ) -> Void) {
        DispatchQueue.global(qos: .background).async {
            Thread.sleep(forTimeInterval: TimeInterval.random(in: 0.25...2.5))
            DispatchQueue.main.async {
                self.simulateRangeFetchComplete(at: index, withCount: count)
                completion(.success( () ))
            }
        }
    }
    
    func notifyDataDownloadSuccess(_ thumbModel: ThumbModel) {
        if thumbModel.index >= 0 && thumbModel.index < thumbDownloadStatusList.count {
            print("Download of [\(thumbModel.image)] => Success!")
            thumbDownloadStatusList[thumbModel.index].downloadDidSucceed = true
            thumbDownloadStatusList[thumbModel.index].downloadDidFail = false
        }
    }

    func notifyDataDownloadFailure(_ thumbModel: ThumbModel) {
        if thumbModel.index >= 0 && thumbModel.index < thumbDownloadStatusList.count {
            print("Download of [\(thumbModel.image)] => Failed!")
            thumbDownloadStatusList[thumbModel.index].downloadDidSucceed = false
            thumbDownloadStatusList[thumbModel.index].downloadDidFail = true
        }
    }

    func notifyDataDownloadDidStart(_ thumbModel: ThumbModel) {
        if thumbModel.index >= 0 && thumbModel.index < thumbDownloadStatusList.count {
            print("Download of [\(thumbModel.image)] => Started!")
            thumbDownloadStatusList[thumbModel.index].downloadDidSucceed = false
            thumbDownloadStatusList[thumbModel.index].downloadDidFail = false
        }
    }
    
    func isThumbDownloading(_ index: Int) -> Bool {
        if index >= 0 && index < thumbDownloadStatusList.count {
            if thumbDownloadStatusList[index].downloadDidSucceed { return false }
            if thumbDownloadStatusList[index].downloadDidFail { return false }
            return true
        }
        return false
    }

    func didThumbFailToDownload(_ index: Int) -> Bool {
        if index >= 0 && index < thumbDownloadStatusList.count {
            if thumbDownloadStatusList[index].downloadDidFail { return true }
        }
        return false
    }

    func didThumbSucceedToDownload(_ index: Int) -> Bool {
        if index >= 0 && index < thumbDownloadStatusList.count {
            if thumbDownloadStatusList[index].downloadDidSucceed { return true }
        }
        return false
    }
    
}
