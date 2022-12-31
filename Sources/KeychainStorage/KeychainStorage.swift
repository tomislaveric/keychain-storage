import Foundation

public protocol KeychainStorage {
    func save<Object: Encodable>(name: String, object: Object) throws
    func read<Object: Decodable>(name: String) throws -> Object?
}

public struct KeychainStorageImpl: KeychainStorage {
    
    public init() {}

    public func read<Object: Decodable>(name: String) throws -> Object? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: name,
            kSecReturnAttributes: true,
            kSecReturnData: true,
        ] as CFDictionary
       
        var ref: AnyObject?
        SecItemCopyMatching(query, &ref)
        guard let dictionary = ref as? NSDictionary else { return nil }
        guard let result = dictionary[kSecValueData] as? Data else { return nil }
        return try JSONDecoder().decode(Object.self, from: result)
    }
    
    public func save<Object: Encodable>(name: String, object: Object) throws {
 
        let objectData = try JSONEncoder().encode(object)
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: name,
            kSecValueData: objectData
        ] as CFDictionary
        Task {
            SecItemAdd(query as CFDictionary, nil)
        }
    }
}

enum KeychainError: Error {
    case unhandledError(status: OSStatus)
}

