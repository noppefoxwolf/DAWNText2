import SwiftUI

extension EnvironmentValues {
    @Entry
    var uiFont: UIFont = UIFontMetrics.default.scaledFont(for: .preferredFont(forTextStyle: .body))
}

extension View {
    public func font(_ font: UIFont) -> some View {
        self.environment(\.uiFont, font)
    }
}
