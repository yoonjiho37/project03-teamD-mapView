//
//  AnnouncementDetailView.swift
//  BinGongGan_Seller
//
//  Created by 오영석 on 2023/09/06.
//
import SwiftUI
import BinGongGanCore

struct AnnouncementDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var isShowingAnnouncementOptionSheet: Bool = false
    
    var body: some View {
        ZStack {
            Color.myBackground
                .ignoresSafeArea(.all)
            
                ScrollView {
                    AnnouncementTitleCell()
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
                    
                    AnnouncemnetContentCell()
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
            .navigationTitle("공지사항")
            .navigationBarTitleDisplayMode(.inline)
        }
        .scrollContentBackground(.hidden)
        .background(Color.myBackground)
        .customBackbutton()
    }
}
struct AnnouncementDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AnnouncementDetailView()
    }
}
