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
              
              if store.eventID?.isEmpty != nil {
                  qrCodeReaderText()
              } else {
                  creatEventButton()
              }
          }
          .navigationBarBackButtonHidden()
          .task {
              store.send(.appearLoading)
              store.send(.fetchEvent)
              store.send(.observeEvent)
              
              Task {
                  await Task.sleep(seconds: 1.7)
                      store.send(.generateQRCode)
                  
              }
          }
      }
      .onChange(of: store.eventModel) { oldValue , newValue in
          store.send(.updateEventModel(newValue))    
      }
      
      .sheet(item: $store.scope(state: \.destination?.makeEvent, action: \.destination.makeEvent)) { makeEventStore in
          MakeEventView(store: makeEventStore, completion: {
              store.send(.closeMakeEventModal)
          })
          .presentationDetents([.height(UIScreen.screenHeight * 0.65)])
          .presentationCornerRadius(20)
          .presentationDragIndicator(.hidden)
      }
    }
}

extension QrCodeView {
    
    @ViewBuilder
    fileprivate func generateQrImage() -> some View {
        VStack {
            
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.2)
            
            if ((store.eventID?.isEmpty) != nil) {
                if let qrCodeImage = store.qrCodeImage {
                    qrCodeImage
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.screenHeight * 0.3, height: UIScreen.screenHeight * 0.3)
                } else {
                    AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(true))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
            } else {
                AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(true))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
    }
    
    @ViewBuilder
    fileprivate func qrCodeReaderText() -> some View {
        if store.eventModel != [ ] {
            VStack {
                Spacer()
                    .frame(height: UIScreen.screenHeight * 0.1)
                
                Text(store.qrCodeReaderText)
                    .pretendardFont(family: .Bold, size: 20)
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    fileprivate func creatEventButton() -> some View {
        if store.eventID?.isEmpty == nil  {
            Spacer()
                .frame(height: UIScreen.screenHeight * 0.3)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.basicBlue200.opacity(0.4))
                .frame(height: 48)
                .padding(.horizontal, 20)
                .overlay {
                    Text("이벤트를 추가 해주세요")
                        .pretendardFont(family: .SemiBold, size: 20)
                        .foregroundColor(.basicWhite)
                }
                .onTapGesture {
                    store.send(.presntEventModal)
                }
            
            Spacer()
        }
    }
}

#Preview {
    QrCodeView(store: Store(initialState: QrCode.State(userID: ""), reducer: {
        QrCode()
    }), backAction: {})
}
