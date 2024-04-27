import Foundation

final class TextLayoutDataCache {
    var cache: [Key : TextLayoutData] = [:]
    
    func data(for key: Key) -> TextLayoutData? {
        cache[key]
    }
    
    func store(_ data: TextLayoutData, for key: Key) {
        cache[key] = data
    }
    
    func removeAll() {
        cache.removeAll()
    }
}

