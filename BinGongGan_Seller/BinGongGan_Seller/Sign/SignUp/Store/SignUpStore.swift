//
//  SignUpStore.swift
//  BinGongGan_Seller
//
//  Created by 김민기 on 2023/09/12.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

final class SignUpStore: ObservableObject {
    let dbRef = Firestore.firestore()
    @Published var signUpData = SignUpData()
    @State var certificateNumber: String = ""
    @Published var currentStep: SignUpStep = .first
    @Published var showAlert: Bool = false
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    
    public func isValidAuthentication() -> Bool {
        guard signUpData.name.count >= 2 else {
            showToast = true
            toastMessage = "이름을 다시 입력하여 주세요."
            return false
        }
        guard signUpData.birthDate.count == 6 else {
            showToast = true
            toastMessage = "생년월일 6자리를 입력하여 주세요."
            return false
        }
        guard signUpData.phoneNumber.count == 11 else {
            showToast = true
            toastMessage = "휴대폰 번호 11자리를 입력하여 주세요."
            return false
        }
        return true
    }
    
    public func isValidEmailId() -> Bool {
        // 이메일 형식을 검사하는 정규 표현식
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: signUpData.emailId)
    }
    
    public func isValidPassword() -> Bool {
        let passwordRegex = "^[a-zA-Z0-9]+$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: signUpData.password)
    }
    
    public func isValidIdAndPassword() -> Bool {
        guard isValidEmailId() else {
            showToast = true
            toastMessage = "이메일 형식이 올바르지 않습니다."
            return false
        }
        
        guard signUpData.password.count >= 4 else {
            showToast = true
            toastMessage = "비밀번호 4자리 이상 입력하여 주세요."
            return false
        }
        
        guard isValidPassword() else {
            showToast = true
            toastMessage = "비밀번호 형식이 올바르지 않습니다."
            return false
        }
        
        guard signUpData.password == signUpData.passwordCheck else {
            showToast = true
            toastMessage = "비밀번호가 일치하지 않습니다."
            return false
        }

        return true
    }
    func isValidRegistration() -> Bool {
        guard signUpData.accountNumber.count >= 8 else {
            showToast = true
            toastMessage = "계좌 번호를 입력해주세요."
            return false
        }
        
        guard signUpData.registrationNumber.count >= 4 else {
            showToast = true
            toastMessage = "사업자 등록번호를 입력해주세요."
            return false
        }
        
        guard signUpData.registrationImage != UIImage() else {
            showToast = true
            toastMessage = "사업자 등록증을 등록하여 주세요."
            return false
        }

        return true
    }
    
    func isAllAgreed() -> Bool {
        guard signUpData.isTermOfUseAgree else {
            showToast = true
            toastMessage = "서비스 이용약관에 동의하여 주세요."
            return false
        }

        guard signUpData.isPrivacyAgree else {
            showToast = true
            toastMessage = "개인정보 이용약관에 동의하여 주세요."
            return false
        }

        guard signUpData.isLocaitonAgree else {
            showToast = true
            toastMessage = "위치 이용약관에 동의하여 주세요."
            return false
        }
        
        return true
    }
    
    @MainActor
    func postSignUp() async -> Bool {
//        print(signUpData)
//        return false
        ///*
        guard isAllAgreed() else {
            return false
        }
        do {
            let authResult = try await AuthStore.createUser(email: signUpData.emailId, password: signUpData.password)
            let seller = signUpData.changeToSellerModel(id: authResult.user.uid)
        
            try await SellerStore.saveUserData(seller: seller)
            
//            UserDefaults.standard.setValue(authResult.user.uid, forKey: "UserId")
            return true
        } catch {
            showToast = true
            if let error = error as? AuthErrorCode {
                if error.errorCode == 17007 {
                    toastMessage = "이미 회원가입 되어있습니다."
                } else {
                    toastMessage = "회원가입을 할 수 없습니다."
                }
            }
            return false
        }
        //*/

    }
}
