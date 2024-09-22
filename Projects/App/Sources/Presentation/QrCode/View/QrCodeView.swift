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

import DesignSystem

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
                  .frame(height: 16)
              
              NavigationBackButton(buttonAction: backAction)
              
              if store.loadingQRImage == true {
                  TooltipShape(tooltipText: store.qrCodeReaderText)
                      .offset(y: UIScreen.screenHeight * 0.2)
              } else {
                  TooltipShape(tooltipText: store.qrCodeReaderText)
                      .offset(y: UIScreen.screenHeight * 0.2)
              }
              
              Spacer()
                  .frame(height: 24)
              
              generateQrImage()
                  
              creatEventButton()
              
              Spacer()
          }
          .navigationBarBackButtonHidden()
          .task {
              store.send(.view(.appearLoading))
              store.send(.async(.fetchEvent))
              store.send(.async(.observeEvent))
              
              Task {
                  await Task.sleep(seconds: 1.7)
                  store.send(.async(.generateQRCode))
                  
              }
          }
      }
      .onChange(of: store.eventModel) { oldValue , newValue in
          store.send(.async(.updateEventModel(newValue)))
      }
      
      .sheet(item: $store.scope(state: \.destination?.makeEvent, action: \.destination.makeEvent)) { makeEventStore in
          MakeEventView(store: makeEventStore, completion: {
              store.send(.view(.closeMakeEventModal))
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
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(width: 200, height: 200)
                } else {
                    AnimatedImage(name: "DDDLoding.gif", isAnimating: .constant(true))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray800.opacity(0.4))
                    .frame(width:  200, height: 200)
                    .overlay {
                        VStack {
                            Spacer()
                            Image(asset: .qrCode)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 96, height: 96)
                            Spacer()
                        }
                        
                    }
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
            
            VStack {
                Spacer()
                    .frame(height: UIScreen.screenHeight * 0.25)
                
                Text("일정 등록하기")
                    .pretendardFont(family: .SemiBold, size: 16)
                    .foregroundColor(Color.gray300)
                    .underline(true, color: Color.gray300)
                    .onTapGesture {
                        store.send(.navigation(.presentSchedule))
                    }
                
                
                Spacer()
                    .frame(height: 10)
            }
        }
    }
}

#Preview {
    QrCodeView(store: Store(initialState: QrCode.State(userID: ""), reducer: {
        QrCode()
    }), backAction: {})
}
