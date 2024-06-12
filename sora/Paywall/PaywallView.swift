//
//  PaywallView.swift
//  sora
//
//  Created by Elias CHETOUANI on 28/04/2024.
//

import SwiftUI
import StoreKit
import SwiftUIX


struct PaywallView: View {
    
    @State private var appStoreIsLoading = false
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @State private var isTrialEnabled = true
    
    var productForCurrentSelection: Product? {
        purchaseManager.products.first { $0.id == (isTrialEnabled ? "weekly_free_trial" : "monthly") }
    }
    
    var body: some View {
        //      GeometryReader { geometry in
     //   ZStack {
     
            ZStack {
                backgroundImage()
                VStack {
                    headerText()
                    Spacer()
                    featuresList()
                    Spacer()
                    pricingInfo()
                    freeTrialButton()
                    purchaseButton()
                    footerLinks()
                }
                .padding(.horizontal)
                if appStoreIsLoading {
                    loadingView()
                }
            }
      //  }
        .onAppear() {
            loadProducts()
        }
        .onReceive(purchaseManager.$purchasedProductIDs, perform: handlePurchaseUpdate)
        //}
    }
    
    private func loadProducts() {
        Task {
            do {
                try await purchaseManager.loadProducts()
            } catch {
                print(error)
            }
        }
    }
    
    private func handlePurchaseUpdate(_ purchasedIDs: Set<String>) {
        appStoreIsLoading = false
        if !purchasedIDs.isEmpty {
            dismiss()
        }
    }
    
    private func purchaseSelectedProduct() {
        appStoreIsLoading = true
        let productId = isTrialEnabled ? "weekly_free_trial" : "monthly"
        
        Task {
            do {
                if let product = purchaseManager.products.first(where: { $0.id == productId }) {
                    try await purchaseManager.purchase(product)
                } else {
                    print("Product not found: \(productId)")
                }
            } catch {
                print("Purchase failed: \(error)")
            }
            appStoreIsLoading = false
        }
    }
}

extension PaywallView {
    @ViewBuilder
    private func backgroundImage() -> some View {
        //   ZStack {
        //            Rectangle()
        //                .foregroundColor(.black.opacity(0.3))
        //                .edgesIgnoringSafeArea(.all)
        //    .frame(width: geometry.size.width, height: geometry.size.height)
        Image("BackgroundPaywall")
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .ignoresSafeArea()
          
            .overlay(
                Rectangle()
                    .fill(Color.black.opacity(0.3)) // Semi-transparent overlay for debugging
            )
        //    }
        
    }
    
    @ViewBuilder
    private func headerText() -> some View {
        VStack(spacing: 3) {
            Text("Unlock Everything")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            Text("90% of our users are Pro")
                .font(.title3)
                .bold()
                .foregroundColor(.gray)
        }.padding(.top, 40)
    }
    
    @ViewBuilder
    private func loadingView() -> some View {
        ProgressView("Waiting for AppStore..")
            .font(.subheadline.bold())
            .frame(width: 210, height: 90)
            .background(Blur())  // Optional: Adding a blur effect
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 0)
            )
            .zIndex(1)
    }
    
    @ViewBuilder
    private func featuresList() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            FeatureItem(icon: "checkmark", title: "Unlimited creation")
            FeatureItem(icon: "checkmark", title: "Faster video processing")
            FeatureItem(icon: "checkmark", title: "Up to 300 characters")
        }
    }
    
    @ViewBuilder
    private func freeTrialButton() -> some View {
        ZStack {
            Blur()
                .frame(height: 60)
                .cornerRadius(20, style: .circular)
            
            HStack {
                Text(isTrialEnabled == true ? "Free Trial Enabled" : "Enable Free Trial")
                    .bold()
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                Spacer()
                
                Toggle(isOn: $isTrialEnabled) {
                    
                }
                .tintColor(.accentColor)
                .labelsHidden()
                .padding(.trailing, 20)
                
            }
            .frame(height: 70)
        }
    }
    
    
    @ViewBuilder
    private func pricingInfo() -> some View {
        VStack(spacing: 3) {
            
            if let product = productForCurrentSelection {
                Text(isTrialEnabled ? "3-Day Free Trial then \(product.displayPrice) for 1-week" : " \(product.displayPrice) for 1 month")
                    .bold()
                    .foregroundColor(.white)
            }
            Text("Cheaper than 1 Pizza 🍕")
                .font(.footnote)
                .foregroundColor(.white)
            
        }
        .padding(.bottom, 4)
    }
    
    @ViewBuilder
    private func purchaseButton() -> some View {
        Button(action: purchaseSelectedProduct) {
            Text("Continue")
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 60)
                .font(.title3.bold())
                .background(.white)
                .foregroundColor(.black)
                .cornerRadius(30)
        }
    }
    
    @ViewBuilder
    private func footerLinks() -> some View {
        HStack {
            termsLink()
            Spacer()
            restoreButton()
            Spacer()
            privacyLink()
        }
        .padding(.vertical, 50)
    }
    
    @ViewBuilder
    private func termsLink() -> some View {
        Link(destination: URL(string: "https://termify.io/terms-and-conditions/0dfJlbiS3t")!) {
            Text("Terms")
                .font(.subheadline)
                .foregroundColor(Color.gray)
                .underline()
        }
    }
    
    @ViewBuilder
    private func restoreButton() -> some View {
        Button(action: {
            appStoreIsLoading = true
            Task {
                do {
                    try await AppStore.sync()
                } catch {
                    print(error)
                }
                appStoreIsLoading = false
            }
        }) {
            Text("Restore")
                .font(.subheadline)
                .bold()
                .foregroundColor(Color.gray)
                .underline()
        }
    }
    
    @ViewBuilder
    private func privacyLink() -> some View {
        Link(destination: URL(string: "https://termify.io/privacy-policy/pqxIVH5oKW")!) {
            Text("Privacy")
                .font(.subheadline)
                .foregroundColor(.gray)
                .underline()
        }
    }
    
    struct FeatureItem: View {
        let icon: String
        let title: String
        
        var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .bold()
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)
            }
        }
    }
    
}

struct Blur: UIViewRepresentable {
    let style: UIBlurEffect.Style = .systemUltraThinMaterialDark
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}


#Preview {
    PaywallView()
        .environmentObject(PurchaseManager())
}
