//
//  ResultView.swift
//  sora
//
//  Created by Elias CHETOUANI on 07/05/2024.
//

import SwiftUI
import VideoPlayer
import Photos
import AVFoundation
import FirebaseAnalytics


struct ResultView: View {
    
    let videoURL: URL
    @State private var videoAspectRatio: CGFloat = 1.78
    
    @State private var play: Bool = true
    @EnvironmentObject var network: NetworkManager
    
    @State private var showingLoader = false
    @State private var showSuccessSavedAlert = false
    @State private var showBadQualityAlert = false
    
    var body: some View {
        Text("Your video")
            .font(.title3, weight: .bold)
        VStack(alignment: .center) {
            VideoPlayer(url: videoURL, play: $play)
                .autoReplay(true)
                .aspectRatio(videoAspectRatio, contentMode: .fit)
                .cornerRadius(16)
                .padding()
            
            Button(action: {
                self.saveVideo()
                Analytics.logEvent("save_video", parameters: [
                    "url": videoURL])
            }) {
                
                HStack {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundColor(.black) // Icon color
                    Text("Save to Camera roll")
                        .font(.title3, weight: .bold)
                        .foregroundColor(.black)
                }
                .frame(width: 300, height: 50)
                .font(.title3, weight: .medium)
                .background(.white)
                .foregroundColor(.black)
                .cornerRadius(30)
                .padding(.top, 30)
            }
            .overlay(
                showingLoader ? ProgressView().scaleEffect(1.5) : nil
            )
            .alert(isPresented: $showSuccessSavedAlert) {
                Alert(
                    title: Text("Your video has been saved to the photo library 🎉"),
                    //  message: "",
                    dismissButton: .default(Text("OK"))
                )
            }
            //   ShareButtonsView()
            Spacer()
            Button(action: {
                self.showBadQualityAlert = true
                Analytics.logEvent("bad_quality_video", parameters: [
                    "url": videoURL])
            }) {
                Text("Bad quality ?")
            }
        }
        .alert(isPresented: $showBadQualityAlert) {
            Alert(
                title: Text("Ouups, Sometimes the quality might be altered"),
                message: Text("Please retry again, if the problem persist, contact us."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            configureAudioSession()
            fetchVideoProperties(url: videoURL)
            //     network.video = nil
        }
        .onDisappear {
            VideoPlayer.cleanAllCache()
        }
    }
    
    private func fetchVideoProperties(url: URL) {
        let asset = AVAsset(url: url)
        let videoTrack = asset.tracks(withMediaType: .video).first
        if let track = videoTrack {
            let size = track.naturalSize.applying(track.preferredTransform)
            let aspectRatio = abs(size.width / size.height)
            DispatchQueue.main.async {
                videoAspectRatio = aspectRatio
            }
        }
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set AVAudioSession category: \(error)")
        }
    }
    
    private func saveVideo() {
        showingLoader = true
        
        network.downloadVideo(from: videoURL) { savedURL, error in
            DispatchQueue.main.async {
                self.showingLoader = false
                
                if let error = error {
                    print("Error downloading video: \(error)")
                } else if let savedURL = savedURL {
                    print("Video downloaded to: \(savedURL)")
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: savedURL)
                    }) { success, error in
                        if let error = error {
                            print("Error saving video to the photo library: \(error.localizedDescription)")
                        } else if success {
                            print("Video saved successfully to the photo library.")
                            self.showSuccessSavedAlert = true
                            do {
                                try FileManager.default.removeItem(at: savedURL)
                                print("Saved video file deleted successfully.")
                            } catch {
                                print("Error deleting saved video file: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}

//struct ShareButtonsView: View {
//
//    struct ButtonConfig {
//        var color: Color
//        var icon: String
//        var action: () -> Void
//    }
//
//     var buttons: [ButtonConfig] = [
//        ButtonConfig(color: .white, icon: "square.and.arrow.down", action: downloadAction),
//        ButtonConfig(color: .green, icon: "2.circle", action: shareAction),
//        ButtonConfig(color: .blue, icon: "3.circle", action: customAction)
//    ]
//
//    func downloadAction() {
//        print("Download action triggered")
//    }
//
//    func shareAction() {
//        print("Share action triggered")
//    }
//
//    func customAction() {
//        print("Custom action triggered")
//    }
//
//
//    var body: some View {
//        HStack {
//            ForEach(buttons.indices, id: \.self) { index in
//                Button(action: buttons[index].action) {
//                    Circle()
//                        .foregroundColor(buttons[index].color)
//                        .frame(width: 70, height: 60)
//                        .overlay(Image(systemName: buttons[index].icon).foregroundColor(.black))
//                }
//            }
//        }.padding()
//    }
//}

#Preview {
    ResultView(videoURL: URL(string: "https://www.pexels.com/download/video/17687289/?fps=29.97&h=426&w=240")!)
        .environmentObject(NetworkManager())
    
}
