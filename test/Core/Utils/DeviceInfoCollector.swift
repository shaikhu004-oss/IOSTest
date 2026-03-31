import Foundation
import UIKit
import Security
import CommonCrypto
internal import CoreLocation

class DeviceInfoCollector {

    static let shared = DeviceInfoCollector()

    // Keychain configuration
    private let keychainService = "com.pathpulseai.scout.deviceid"
    private let keychainAccount = "persistent-device-uuid"

    private init() {}
    
    func getFullPayload() async -> [String: Any] {
        let deviceInfo = getDeviceInfo()
        var locationInfo: LocationInfo? = nil

        // Try to get location safely
        let status = await LocationManager.shared.requestLocationPermissionIfNeeded()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if let loc = await LocationManager.shared.requestSingleLocation() ?? LocationManager.shared.currentLocation {
                locationInfo = LocationInfo(
                    accuracy: loc.horizontalAccuracy,
                    latitude: loc.coordinate.latitude,
                    longitude: loc.coordinate.longitude,
                    timestamp: Int64(loc.timestamp.timeIntervalSince1970 * 1000)
                )
            }
        }

        let payload = FullDevicePayload(deviceInfo: deviceInfo, location: locationInfo)

        if let data = try? JSONEncoder().encode(payload),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return dict
        }

        return [:]
    }

    func getDeviceInfo() -> DeviceInfo {
        print("📱 Collecting iOS device information...")

        let keychainUUID = getKeychainUUID()
        let idfv = getIDFV()
        let screenInfo = getScreenInfo()
        let fingerprint = generateDeviceFingerprint(keychainUUID: keychainUUID, idfv: idfv, screenInfo: screenInfo)

        let deviceInfo = DeviceInfo(
            firebaseInstallationId: nil,
            androidId: nil,
            iosKeychainUuid: keychainUUID,
            iosVendorId: idfv,
            devicePlatform: "ios",
            deviceModel: UIDevice.current.model,
            osVersion: "iOS \(UIDevice.current.systemVersion)",
            appVersion: getAppVersion(),
            versionCode: getVersionCode(), // 🌟 NOW AN INT
            manufacturer: "Apple",
            brand: "Apple",
            screenWidth: Int(screenInfo.width),
            screenHeight: Int(screenInfo.height),
            screenDensity: Int(screenInfo.scale),
            deviceId: getDeviceIdentifier(),
            fingerprint: fingerprint,
            sdkInt: nil
        )

        logDeviceInfo(deviceInfo)

        return deviceInfo
    }

    private func getKeychainUUID() -> String {
        if let existingUUID = readFromKeychain() {
            return existingUUID
        }

        let newUUID = UUID().uuidString
        if saveToKeychain(newUUID) {
            return newUUID
        }
        return UUID().uuidString
    }

    private func saveToKeychain(_ uuid: String) -> Bool {
        guard let data = uuid.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    private func readFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
           let data = result as? Data,
           let uuid = String(data: data, encoding: .utf8) {
            return uuid
        }
        return nil
    }

    private func getIDFV() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }

    private func generateDeviceFingerprint(keychainUUID: String, idfv: String?, screenInfo: ScreenInfo) -> String? {
        var components: [String] = []

        components.append(keychainUUID)
        if let idfv = idfv { components.append(idfv) }

        components.append(UIDevice.current.model)
        components.append(UIDevice.current.systemVersion)
        components.append("\(Int(screenInfo.width))x\(Int(screenInfo.height))")
        components.append("\(Int(screenInfo.scale))")

        let combined = components.joined(separator: "|")
        return sha256(combined)
    }

    private func sha256(_ string: String) -> String? {
        guard let data = string.data(using: .utf8) else { return nil }

        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }

        return hash.map { String(format: "%02x", $0) }.joined()
    }

    private func getScreenInfo() -> ScreenInfo {
        let screen = UIScreen.main
        let bounds = screen.bounds
        let scale = screen.scale

        return ScreenInfo(
            width: bounds.width * scale,
            height: bounds.height * scale,
            scale: scale
        )
    }

    private func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    // 🌟 SEPARATED: Parses the build string into a strict Integer
    private func getVersionCode() -> Int {
        let buildString = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return Int(buildString) ?? 1
    }

    private func getDeviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    private func logDeviceInfo(_ info: DeviceInfo) {
        print("═════════════════════════════════════════════════════════")
        print("📱 DEVICE INFORMATION COLLECTED (iOS)")
        print("═════════════════════════════════════════════════════════")
        print("   Platform: \(info.devicePlatform)")
        print("   Model: \(info.deviceModel)")
        print("   OS: \(info.osVersion)")
        print("   App Version: \(info.appVersion)")
        print("   Version Code (Int): \(info.versionCode ?? 0)") // 🌟 Log as Int
        print("─────────────────────────────────────────────────────────")
        print("   Fingerprint: \(info.fingerprint?.prefix(32) ?? "unknown")...")
        print("═════════════════════════════════════════════════════════")
    }
}

// MARK: - Supporting Structures

private struct ScreenInfo {
    let width: CGFloat
    let height: CGFloat
    let scale: CGFloat
}

struct LocationInfo: Codable {
    let accuracy: Double
    let latitude: Double
    let longitude: Double
    let timestamp: Int64
}

struct FullDevicePayload: Codable {
    let deviceInfo: DeviceInfo
    let location: LocationInfo?

    enum CodingKeys: String, CodingKey {
        case deviceInfo = "device_info"
        case location
    }
}

struct DeviceInfo: Codable {
    let firebaseInstallationId: String?
    let androidId: String?
    let iosKeychainUuid: String?
    let iosVendorId: String?
    let devicePlatform: String
    let deviceModel: String
    let osVersion: String
    let appVersion: String
    let versionCode: Int?
    let manufacturer: String?
    let brand: String?
    let screenWidth: Int?
    let screenHeight: Int?
    let screenDensity: Int?
    let deviceId: String?
    let fingerprint: String?
    let sdkInt: Int?

    enum CodingKeys: String, CodingKey {
        case firebaseInstallationId = "firebase_installation_id"
        case androidId = "android_id"
        case iosKeychainUuid = "ios_keychain_uuid"
        case iosVendorId = "ios_vendor_id"
        case devicePlatform = "device_platform"
        case deviceModel = "device_model"
        case osVersion = "os_version"
        case appVersion = "app_version"
        case versionCode = "version_code" // 🌟 Maps properly to Int in JSON
        case manufacturer
        case brand
        case screenWidth = "screen_width"
        case screenHeight = "screen_height"
        case screenDensity = "screen_density"
        case deviceId = "device_id"
        case fingerprint = "device_fingerprint"
        case sdkInt = "sdk_int"
    }
}
