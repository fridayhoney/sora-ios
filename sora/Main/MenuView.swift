//
//  MenuView.swift
//  sora
//
//  Created by Elias CHETOUANI on 27/04/2024.
//

import SwiftUI

struct MenuView: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Menu {
            Button {
                EmailHelper.shared.send(subject: "[Support VoiceAI]", body: "Hello ! How can we help you?", to: ["bananacake130@gmail.com"])
            } label: {
                Label("Contact us", systemImage: "message.fill")
            }
            Button {
                openURL(URL(string: "https://termify.io/terms-and-conditions/0dfJlbiS3t")!)
            } label: {
                Label("Terms", systemImage: "doc.text.fill")
            }
            Button {
                openURL(URL(string: "https://termify.io/privacy-policy/pqxIVH5oKW")!)
                
            } label: {
                Label("Privacy", systemImage: "hand.raised.fill")
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .resizable()
            //.sizeToFit()
                .frame(width: 25, height: 25)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    MenuView()
}
