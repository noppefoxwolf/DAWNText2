final class SizeCache {
    struct Key: Hashable {
        let width: Int
    }
    struct Value: Hashable {
        let width: Int
        let height: Int
    }
    
    var cache: [Key : Value] = [:]
    
    func store(_ value: Value, key: Key) {
        cache[key] = value
    }
    
    func value(for key: Key) -> Value? {
        cache[key]
    }
    
    func removeAll() {
        cache.removeAll()
    }
}
