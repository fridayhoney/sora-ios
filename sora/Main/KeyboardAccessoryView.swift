//
//  KeyboardAccessoryView.swift
//  sora
//
//  Created by Elias CHETOUANI on 27/04/2024.
//

import SwiftUI
import StoreKit

struct KeyboardAccessoryView: View {
    @Binding var prompt: String
    @Binding var shakePlaceholder: Bool

    let characterLimit: Int
    
    @State private var isRate5 = false
    @State private var showPaywallView = false
    @State private var showRatingView = false
    @State private var showLoadingView = false
    
  //  @EnvironmentObject var network: Network
   // @EnvironmentObject var purchaseManager: PurchaseManager
    
    // ok mais faut tu comprennes que faut tu gères ca de ton coté, moi je peux pas
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    
   
    @AppStorage("GenerationCount") private var generationCount: Int = 0
    @AppStorage("hasShownRatingView") private var hasShownRatingView: Bool = false
  
    
   // @EnvironmentObject private var configuration: RemoteConfigManager
    
    private let maxGenerations = 2
    private let sentences = [
        "I told my wife she should embrace her mistakes. She gave me a hug.",
        "Why don't scientists trust atoms? Because they make up everything!",
        "I'm reading a book on anti-gravity. It's impossible to put down."
    ]
    
    var body: some View {
        VStack {
            HStack {
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(prompt.count)/\(characterLimit)")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundStyle(prompt.count == characterLimit ? .red : .gray)
                    
//                    if !purchaseManager.hasUnlockedPro {
//                        Text("\(maxGenerations-generationCount) left generations")
//                            .font(.subheadline, weight: .heavy)
//                            .foregroundColor(maxGenerations - generationCount <= 0 ? .red : .gray)
//                    }
                }
                Spacer()
                HStack(spacing: 15) {
                    Button("🎲") {
                        impactGenerator.impactOccurred()
                        prompt = sentences.randomElement() ?? ""
                        
                    }
                    .font(.title3)
                    .padding(.vertical)
                    .padding(.horizontal, 6)
                    .frame(height: 40)
                    .background(.white)
                    .cornerRadius(18)
                   // .shadow(color: .white.opacity(0.6), radius: 14, x: 0, y: 0)
                    
                    Button(LocalizedStringKey("Generate")) {
                        // Show RatingView
//                        if generationCount >= maxGenerations && !purchaseManager.hasUnlockedPro &&
//                            !hasShownRatingView && !configuration.inReview {
//                            showRatingView = true
//                            hasShownRatingView = true
//                        }
//                        
//                        // Show Paywall
//                        else if generationCount >= maxGenerations && !purchaseManager.hasUnlockedPro {
//                            showPaywallView = true
//                            print("No generations remaining")
//                        }
//                        // Shake Placeholder if empty
//                        else if prompt.isEmpty {
//                            notificationFeedbackGenerator.notificationOccurred(.error)
//                            shakePlaceholder = true
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//                                shakePlaceholder = false
//                            }
//                        } else {
//                            generationCount += 1
//                            impactGenerator.impactOccurred()
//                            showLoadingView = true
//                        }
                    }
                    // .font(.callout, weight: .heavy)
//                    .font(.headline, weight: .bold)
//                    // .bold()
//                    .foregroundColor(.white)
//                    .padding(.vertical)
//                    .padding(.horizontal, 8)
//                    .frame(height: 40)
//                    .background(Color.accentColor)
//                    .cornerRadius(18)
                }
                .padding(.horizontal, -4)
                //.padding(.bottom, 20)
            }
        }
        .padding(.bottom, 30)
        .background(.black)
        .sheet(isPresented: $showPaywallView) {
      //      PaywallView()
        }
        .sheet(isPresented: $showLoadingView) {
        //    LoadingView(voice: selectedVoice!, text: prompt, mediaType: .audio)
        }
        .sheet(isPresented: $showRatingView) {
//            RateView(hasRate5: $isRate5)
//                .presentationDetents([.medium])
//                .presentationCornerRadius(30)
//                .presentationBackground(.thinMaterial)
                
        }
        .onChange(of: isRate5) { newValue in
            if newValue {
                // Perform actions when isRate5 becomes true
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    generationCount -= 1
                }
            }
        }
    }
}


