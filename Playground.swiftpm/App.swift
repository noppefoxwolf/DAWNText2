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
    @State var usesDAWNText: Bool = true
    
    var body: some View {
        NavigationView {
            SampleView(usesDAWNText: usesDAWNText)
                .toolbar {
                    Menu {
                        Picker("Accent Color", selection: $color) {
                            Text("Default").tag(Color.accentColor)
                            Text("Yellow").tag(Color.yellow)
                            Text("Custom").tag(Color(uiColor: .custom))
                        }.pickerStyle(.menu)
                        
                        Picker("Component", selection: $usesDAWNText) {
                            Text("DAWNText").tag(true)
                            Text("SwiftUI").tag(false)
                        }.pickerStyle(.menu)
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
                .tint(color)
        }
    }
}

struct SampleView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ViewController
    let usesDAWNText: Bool
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.usesDAWNText = usesDAWNText
    }
}

