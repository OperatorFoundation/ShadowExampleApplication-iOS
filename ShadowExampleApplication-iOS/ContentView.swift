//
//  ContentView.swift
//  ShadowExampleApplication-iOS
//
//  Created by Mafalda on 11/19/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        HStack {
            VStack {
                Text("ChaCha")
                    .padding()
                Button("Connect") {
                    ShadowController.sharedInstance.testShadowChaCha()
                }
            }
            
            VStack {
                Text("AES 128")
                    .padding()
                Button("Connect") {
                    ShadowController.sharedInstance.testShadowAES128()
                }
            }
            
            VStack {
                Text("AES 256")
                    .padding()
                Button("Connect") {
                    ShadowController.sharedInstance.testShadowAES256()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
