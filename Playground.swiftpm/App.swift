import SwiftUI
import DAWNText2

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    
    @State var color: Color = .accentColor
    
    var body: some View {
        NavigationView {
            SampleView()
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Picker("Accent Color", selection: $color) {
                            Text("Default").tag(Color.accentColor)
                            Text("Yellow").tag(Color.yellow)
                            Text("Custom").tag(Color(uiColor: .custom))
                        }.pickerStyle(.inline)
                    }
                }
                .tint(color)
        }
    }
}

struct SampleView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

