final class KeyFactory: Sendable {
    func make(for size: TextLayoutSize) -> Key {
        Key(value: size.width)
    }
}

