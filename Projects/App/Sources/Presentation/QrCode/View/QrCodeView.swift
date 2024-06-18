//
//  QrCodeView.swift
//  DDDAttendance
//
//  Created by 서원지 on 6/11/24.
//

import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI
import CoreImage.CIFilterBuiltins

struct QrCodeView: View {
    @Bindable var store: StoreOf<QrCode>
    var backAction: () -> Void
    
    init(
        store: StoreOf<QrCode>,
        backAction: @escaping () -> Void
    ) {
        self.store = store
        self.backAction = backAction
    }
    
  public  var body: some View {
      ZStack {
          Color.basicBlack
              .edgesIgnoringSafeArea(.all)
          
          VStack {
              Spacer()
                  .frame(height: 20)
              
              NavigationBackButton(buttonAction: backAction)
              
              generateQrImage()
              
              if store.loadingQRImage {
                  qrCodeReaderText()
                  
              } else {
                  Spacer()
              }
          }
          .navigationBarBackButtonHidden()
          .task {
              store.send(.appearLoading)
              Task {
                  await Task.sleep(seconds: 1.7)
                              store.send(.generateQRCode)
                  
                  await Task.sleep(seconds: 0.2)
                             store.qrCodeReaderText = "QRCode를 찍어주셔야 출석이 가능 합니다!"
              }
          }
      }
    }
}

extension QrCodeView {
    
    @ViewBuilder
    fileprivate func generateQrImage() -> some View {
        VStack {
            
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.2)
            
            if let qrCodeImage = store.qrCodeImage {
                qrCodeImage
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.screenHeight * 0.3, height: UIScreen.screenHeight * 0.3)
            } else {
                
                AnimatedImage(name: "DDDLoding.gif", isAnimating: $store.loadingQRImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    
            }
        }
    }
    
    @ViewBuilder
    fileprivate func qrCodeReaderText() -> some View {
        VStack {
            Spacer()
                .frame(height: 40)
            
            Text(store.qrCodeReaderText)
                .pretendardFont(family: .Bold, size: 20)
            
            Spacer()
        }
    }
}

#Preview {
    QrCodeView(store: Store(initialState: QrCode.State(userID: ""), reducer: {
        QrCode()
    }), backAction: {})
}
