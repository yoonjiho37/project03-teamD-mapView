//
//  MyInfoVIew.swift
//  BinGongGan_Seller
//
//  Created by 윤경환 on 2023/09/05.
//

import SwiftUI
import BinGongGanCore

struct MyInfo: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var phoneNumber: String
    var accountNumber: String
    var companyNumber: String
}
class MyStore: ObservableObject {
    @Published var myStore: MyInfo = MyInfo(name: "윤경환", phoneNumber: "010-1234", accountNumber: "123456-02-123456", companyNumber: "111-11-12345")
}


struct MyInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var alertMessage = ""
    @State private var isShowAlert: Bool = false
    @State private var logOutToggle: Bool = false
    
    @StateObject var info: MyStore = MyStore()
    var body: some View {
        NavigationStack {
            Form {
                    VStack(alignment: .leading) {
                        Text("이름")
                            .font(.body1Regular)
                        Text(info.myStore.name)
                            .font(.body1Bold)
                            .foregroundColor(.myDarkGray)
                    }
                
                Group {
                    VStack(alignment: .leading) {
                        Text("연락처")
                            .font(.body1Regular)
                        Text(info.myStore.phoneNumber)
                            .font(.body1Bold)
                            .foregroundColor(.myDarkGray)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("계좌번호")
                        .font(.body1Regular)
                    Text(info.myStore.accountNumber)
                        .font(.body1Bold)
                        .foregroundColor(.myDarkGray)
                }
                
                VStack(alignment: .leading) {
                    Text("사업자 등록번호")
                        .font(.body1Regular)
                    Text(info.myStore.companyNumber)
                        .font(.body1Bold)
                        .foregroundColor(.myDarkGray)
                }
                
                Section {
                    Button {
                        isShowAlert.toggle()
                        alertMessage = "로그아웃 하시겠습니까?"
                    } label: {
                        Text("로그아웃")
                            .foregroundColor(.myDarkGray)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        isShowAlert.toggle()
                        alertMessage = "정말 탈퇴 하시겠습니까?"
                    } label: {
                        Text("회원 탈퇴")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("내 정보")
        .navigationBarBackButtonHidden(true)
        .scrollContentBackground(.hidden)
        .background(Color.myBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement:.navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.myPrimary)
                    
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    MyInfoEditView(myInfo: info)
                } label: {
                    Text("편집")
                }
                
            }
        }
        .alert(isPresented:$isShowAlert) {
            Alert(title: Text(""), message: Text(alertMessage), primaryButton: .default(Text("확인"), action: {
                if alertMessage == "로그아웃 하시겠습니까?" {
                    logOutToggle.toggle()
                } else if alertMessage == "정말 탈퇴 하시겠습니까?" {
                    
                }
            }),
                  secondaryButton: .cancel(Text("취소")))
        }
        
        .navigationDestination(isPresented: $logOutToggle) {
            HomeView() // 로그인뷰로 이동
                .navigationBarBackButtonHidden()
        }
    }
}

struct MyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MyInfoView()
        }
    }
}
