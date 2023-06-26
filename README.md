# RecursiveRendering
This is a SwiftUI app (for macOS and iOS) to explore the implementation of recursive rendering.

Recursive rendering is desirable when rendering a very large array of data, and only a small portion of it needs to be updated during each View update.  I have implemented a "minimal reproducible example" app that works (although it has two problems).

The DataGenerator class (with protocol ObservableObject) updates a variable called myVariable every tenth of a second, and publishes it to all Views.  This app contains only one View called myView which observes the instance of DataGenerator, and hence gets redrawn every time myVariable changes.  myView declares a static variable called myImage using SwiftUI's Image() command.  I then create a Canvas and initialize it by drawing the current myImage into it. I then add a horizontal line (with vertical height determined by myVariable).  I then use the ImageRenderer() command to turn the Canvas into a bitmap image data called renderer, and I render this renderer using SwiftUI's Image() command.

The final statement updates the original myImage with the renderer bitmap image data to form the recursive loop.

MyView.myImage = Image(nsImage: renderer .nsImage!) 

Unfortunately, this is non-View code and Xcode complains if I try to put it in my MyView struct.  So I have had to resort the the ExecuteCode struct trick suggested in stackoverflow.com/questions/63090325/how-to-execute-non-view-code-inside-a-swiftui-view .

The RecursiveRendering code is the complete Swift app.  But it has two problems:

1.) The image rendered onscreen get progressively fuzzy with each iteration.  The new horizontal lines are sharp and distinct when they first appear, but you can watch them become more fuzzy as they drift into the background with each iteration.  This could possibly be caused by my updating myImage using the Image representation of the NSImage/UIImage, which is a view representation and thus using the “screen sized image” rather than updating with the full-resolution of the underlying NSImage/UIImaGE.  I'm not sure that this is the cause of my fuzziness problem, but I don't know what to do about it.

2.) The app has a memory leak.  As the app continues to run (and the window gets progressively filled with horizontal lines), the RAM usage indicator goes continuosly upward until the app freezes when it runs out of system memory.  I am speculating that the "renderer" bitmap is not being properly disposed of after it has been used to update myImage.  I want to make sure that this memory leak is not due to poor programming on my part, before I bother Apple with a bug report.

I would appreciate any suggestions on how to implement recursive rendering simply and efficiently.  I am not married to SwiftUI, so, if there is a simpler approach, I would be happy to use it.
