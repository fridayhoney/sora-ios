//
//  LoadingView.swift
//  sora
//
//  Created by Elias CHETOUANI on 07/05/2024.
//

import SwiftUI
import LottieUI

struct LoadingView: View {
    
    let text: String
    
    @EnvironmentObject var network: NetworkManager

    @State private var showResultView = false
    @State private var videoURL: URL? = nil
    
    var body: some View {
        if showResultView {
          //  ResultView(voice: voice, audioURL: network.audioURL!)
        }
        else {
            VStack(spacing: 8) {
                LottieView("welcome")
                    .loopMode(.loop)
                    .frame(maxWidth: .infinity, maxHeight: 250)

                    Text("Video in preparation..")
                        .font(.title).bold()
           
                Text("Usually takes 45 seconds ⏳").bold()
                Spacer()
            }
       
            .padding()
            .padding(.top, 40)
            .onAppear {
              //  network.getAudio(voiceId: voice.id, text: text, languageCode: "en")
            }
//            .onReceive(network.$audioURL, perform: { audioURL in
//                if let _ = audioURL, audioURL != nil {
//                   // isProcessComplete = true
//                    showResultView = true
//                }
//            })

            .interactiveDismissDisabled()
        }
         
        
    }
}

#Preview {
    LoadingView(text: "This is a test")
        .environmentObject(NetworkManager())
     
}
