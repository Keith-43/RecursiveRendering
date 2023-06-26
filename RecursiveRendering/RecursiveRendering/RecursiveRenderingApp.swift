//  RecursiveRenderingApp.swift
//  RecursiveRendering
//
//  recursive: involving the repeated application of a procedure to successive results
//
//  Created by Keith Bromley on 6/24/23.

import SwiftUI

@main
struct RecursiveRenderingApp: App {
    var body: some Scene {
        WindowGroup {
            MyView()
                .environmentObject(DataGenerator.generator)
        }
    }
}



class DataGenerator: ObservableObject {
    static let generator = DataGenerator() // This singleton instantiates the DataGenerator class and runs it's init().
    @Published var myVariable: Double = 0.0
    
    init() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.myVariable = Double.random(in: 0.0 ... 1.0)
        }
    }
}



@MainActor
struct MyView: View {
    @EnvironmentObject var generator: DataGenerator  // Observe the instance of DataGenerator.
    
    static let mySize = CGSize(width: 1_000, height: 1_000)

    static var myImage = Image(size: mySize, opaque: true) { gc in
        gc.fill(Path(CGRect(origin: .zero, size: mySize)), with: .color(.white))
    }

    var body: some View {

        let canvas = Canvas { context, size in
            context.draw(MyView.myImage, in: CGRect(origin: .zero, size: MyView.mySize))

            var path = Path()
            path.move(   to: CGPoint( x: 0.0,        y: generator.myVariable * size.height ) )
            path.addLine(to: CGPoint( x: size.width, y: generator.myVariable * size.height ) )
            context.stroke( path, with: .color( Color.black ), lineWidth: 1.0  )

        }.frame(width: MyView.mySize.width, height: MyView.mySize.height)

        let renderer = ImageRenderer(content: canvas)
        
        #if os(macOS)
            Image(nsImage: renderer.nsImage!)                           // The struct Image is a view that displays an image.
                .resizable()
                .aspectRatio(contentMode: .fill)
            ExecuteCode {
                MyView.myImage = Image(nsImage: renderer.nsImage!)      // Update myImage with the added line.
            }
        #endif

        #if os(iOS)
            Image(uiImage: renderer.uiImage!)                           // The struct Image is a view that displays an image.
                .resizable()
                .aspectRatio(contentMode: .fill)
            ExecuteCode {
                MyView.myImage = Image(uiImage: renderer.uiImage!)      // Update myImage with the added line.
            }
        #endif

    }
}



// Use this struct to insert non-View code into a View.  (Use with caution.):
// https://stackoverflow.com/questions/63090325/how-to-execute-non-view-code-inside-a-swiftui-view
struct ExecuteCode : View {
    init( _ codeToExec: () -> () ) {
        codeToExec()
    }
    
    var body: some View {
        EmptyView()
    }
}
