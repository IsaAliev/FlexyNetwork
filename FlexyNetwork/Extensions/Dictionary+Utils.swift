import Foundation

extension Dictionary {
    subscript(keyPath keyPath: String) -> Any? {
        get {
            guard let keyPath = Dictionary.keyPathKeys(forKeyPath: keyPath)
                else { return nil }
            return getValue(forKeyPath: keyPath)
        }
        set {
            guard let keyPath = Dictionary.keyPathKeys(forKeyPath: keyPath),
                let newValue = newValue else { return }
            self.setValue(newValue, forKeyPath: keyPath)
        }
    }
    
    static private func keyPathKeys(forKeyPath: String) -> [Key]? {
        let keys = forKeyPath.split(separator: ".").map({ String($0) })
            .reversed().compactMap({ $0 as? Key })
        return keys.isEmpty ? nil : keys
    }
    
    private func getValue(forKeyPath keyPath: [Key]) -> Any? {
        var value: Any?
        
        if self[keyPath.last!] != nil {
            value = self[keyPath.last!]
        } else {
            guard let regex = try? NSRegularExpression(pattern: ".*\\[\\d+\\]$"),
                let keyStr = keyPath.last as? String,
                let _ = regex.firstMatch(in: keyStr, options: [], range: NSMakeRange(0, keyStr.count)),
                let digitRegex = try? NSRegularExpression(pattern: "\\[\\d+\\]$"),
                let digitMatch = digitRegex.firstMatch(in: keyStr, options: [], range: NSMakeRange(0, keyStr.count)),
                let index = Int((((keyStr as NSString)
                    .substring(with: digitMatch.range) as NSString)
                    .substring(to: digitMatch.range.length - 1) as NSString)
                    .substring(from: 1))
                else {
                    return nil
            }
            
            let escapedKey = (keyStr as NSString).substring(to: digitMatch.range.location)
            
            guard let stringKeyedDict = self as? Dictionary<String, Any>,
                let array = stringKeyedDict[escapedKey] as? [Any],
                array.count > index else {
                    return nil
            }
            
            value = array[index]
        }
        
        return keyPath.count == 1 ? value : (value as? [Key: Any])
            .flatMap { $0.getValue(forKeyPath: Array(keyPath.dropLast())) }
    }
    
    private mutating func setValue(_ value: Any, forKeyPath keyPath: [Key]) {
        guard self[keyPath.last!] != nil else {
            return
        }
        
        if keyPath.count == 1 {
            self[keyPath.last!] = value as? Value
        } else if var subDict = self[keyPath.last!] as? [Key: Any] {
            subDict.setValue(value, forKeyPath: Array(keyPath.dropLast()))
            self[keyPath.last!] = subDict as? Value
        }
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
