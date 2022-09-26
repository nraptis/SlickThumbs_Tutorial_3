//
//  MyPageView.swift
//  SlickThumbnail
//
//  Created by Nick Raptis on 9/23/22.
//

import SwiftUI

struct MyPageView: View {
    @ObservedObject var viewModel: MyPageViewModel
    var body: some View {
        GeometryReader { containerGeometry in
            list(containerGeometry)
                .refreshable {
                    await viewModel.refresh()
                }
        }
    }
    
    private func grid(_ containerGeometry: GeometryProxy, _ scrollContentGeometry: GeometryProxy) -> some View {
        let layout = viewModel.layout
        layout.registerScrollContent(scrollContentGeometry)
        let allVisibleCellModels = layout.getAllVisibleCellModels()
        return ThumbGrid(list: allVisibleCellModels, layout: layout) { cellModel in
            ThumbView(thumbModel: viewModel.thumbModel(at: cellModel.index),
                      width: layout.getWidth(cellModel.index),
                      height: layout.getHeight(cellModel.index),
                      didDownloadSucceed: viewModel.didThumbSucceedToDownload(at: cellModel.index),
                      didDownloadFail: false)
        }
    }
    
    private func list(_ containerGeometry: GeometryProxy) -> some View {
        let layout = viewModel.layout
        if layout.registerContainer(containerGeometry, viewModel.numberOfThumbCells()) {
            DispatchQueue.main.async {
                self.viewModel.objectWillChange.send()
            }
        }
        return List {
            GeometryReader { scrollContentGeometry in
                grid(containerGeometry, scrollContentGeometry)
            }
            .frame(width: layout.width,
                   height: layout.height)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
    
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView(viewModel: MyPageViewModel.mock())
    }
}
