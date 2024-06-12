//
//  ContentView.swift
//  sora
//
//  Created by Elias CHETOUANI on 27/04/2024.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        TopBarView()
        TextFieldView()
        Spacer()
    }
}

struct TopBarView: View {
    var body: some View {
        HStack {
            Text("SORA AI")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .fontWeight(.bold)
            
            Spacer()
            MenuView()
        }
        .padding()
    }
}


struct TextFieldView: View {
    
    @State private var prompt: String = ""
    @State private var characterLimit = 300
    @FocusState var textEditorIsFocused: Bool
    
    @State private var shakePlaceholder: Bool = false
    
    private let impactHeavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $prompt)
                .font(.title)
                .fontWeight(.heavy)
                .padding(.horizontal, 10)
                .focused($textEditorIsFocused)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        KeyboardAccessoryView(prompt: $prompt, shakePlaceholder: $shakePlaceholder, characterLimit: characterLimit)
                            .background(Color(UIColor.systemBackground)) // This should make it opaque
                                             .edgesIgnoringSafeArea(.all)
                        //                            .introspect(.view, on: .iOS(.v17)) { view in
                        //                                if let targetView = view.superview?.superview?.superview?.superview {
                        //                                    targetView.backgroundColor = .black
                        //                                }
                        //                            }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        textEditorIsFocused = true
                    }
                }
                .onChange(of: prompt) { newValue in
                    if newValue.count > characterLimit {
                        impactHeavyGenerator.impactOccurred()
                        prompt = String(newValue.prefix(characterLimit))
                    }
                }
            if prompt.isEmpty {
                Text("Enter your text here..")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.gray)
                    .offset(x: shakePlaceholder ? 12 : 0)
                    .animation(shakePlaceholder ? Animation.linear(duration: 0.05).repeatCount(5, autoreverses: true) : nil, value: shakePlaceholder)
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .allowsHitTesting(false)
            }
        }
    }
}



#Preview {
    MainView()
}
