//
//  MyPageMainView.swift
//  BinGongGan_User
//
//  Created by 방유빈 on 2023/09/05.
//

import SwiftUI
import BinGongGanCore

struct MyPageMainView: View {
    @EnvironmentObject var signInStore: SignInStore
    
    @State var isShowingSetting: Bool = false
    @State var isShowingLogoutAlert: Bool = false
    
    var body: some View {
        Form {
            Section("내 정보") {
                NavigationLink {
                    MyInformationDetailView()
                } label: {
                    HStack {
                        Circle()
                            .frame(width: min(80, UIScreen.main.bounds.width * 0.3), height: min(80, UIScreen.main.bounds.height * 0.3))
                            .foregroundColor(.myPrimary)
                            .padding(.trailing)
                        VStack(alignment: .leading) {
                            Text("손윤호")
                            Text("test@test.com")
                                .tint(.gray)
                                .font(.caption)
                        }
                    }
                }
            } //Section - 내정보
            
            Section("예약/리뷰") {
                NavigationLink("예약 내역") {
                    MyReservationListView()
                }
                
                NavigationLink("내 리뷰") {
                    MyReviewListView()
                }
            }//Section - 예약 리뷰
            
            Section("고객센터") {
                NavigationLink("1 : 1 문의하기") {
                    EnquiryView()
                }
                
                NavigationLink("자주 묻는 질문 FAQ") {
                    FAQView()
                }
            } //Section - 고객센터
            
            Section("기타") {
                NavigationLink("공지사항") {
                    AnnouncementView()
                }
                
                NavigationLink("빈공간 정보") {
                    AppInformationList()
                }
            } // Section - 기타
            Section("로그아웃") {
                Button {
                    isShowingLogoutAlert.toggle()
                } label: {
                    Text("로그 아웃")
                        .foregroundColor(.red)
                }
            }
        } //Form
        .navigationTitle("My 빈공간")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingSetting.toggle()
                }label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(.myPrimary)
                }
            }
        }
        .navigationDestination(isPresented: $isShowingSetting) {
            SettingListView()
        }
        .alert("로그아웃", isPresented: $isShowingLogoutAlert) {
            Button("취소", role: .cancel) {}
            Button("로그아웃", role: .destructive) {
                //TODO: 로그아웃
                signInStore.logout()
            }
        } message: {
            Text("로그아웃을 합니다.")
        }
    }
}

struct MyPageMainView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageMainView()
    }
}


