//
//  ContentView.swift
//  Project3
//
//  Created by Ben Schwartz on 11/9/19.
//  Copyright © 2019 Ben. All rights reserved.
//

//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        Text("Hello2 World")
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

import SwiftUI

struct ContentView : View {
    var body: some View {
        ViewControllerWrapper()
    }
}



struct ViewControllerWrapper: UIViewControllerRepresentable {

    typealias UIViewControllerType = ViewController


    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewControllerWrapper>) -> ViewControllerWrapper.UIViewControllerType {
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: ViewControllerWrapper.UIViewControllerType, context: UIViewControllerRepresentableContext<ViewControllerWrapper>) {
        //
    }
}
