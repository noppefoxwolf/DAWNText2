import SwiftUI
import DAWNText2

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView2()
        }
    }
}

struct ContentView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

struct ContentView2: View {
    var body: some View {
        DAWNText2.Label(attributedString: AttributedString(makeAttributedText()))
    }
}

