import SwiftUI

struct UIFontKey: EnvironmentKey {
    static let defaultValue: UIFont = .preferredFont(forTextStyle: .body)
}

extension EnvironmentValues {
    var uiFont: UIFont {
        get { self[UIFontKey.self] }
        set { self[UIFontKey.self] = newValue }
    }
}

extension View {
    public func font(_ font: UIFont) -> some View {
        self.environment(\.uiFont, font)
    }
}
