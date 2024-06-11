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
              
              Spacer()
          }
          .navigationBarBackButtonHidden()
          .onAppear {
              store.send(.appearLoading)
              
              DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                  store.send(.generateQRCode)
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
}

#Preview {
    QrCodeView(store: Store(initialState: QrCode.State(userID: ""), reducer: {
        QrCode()
    }), backAction: {})
}
