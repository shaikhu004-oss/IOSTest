//
//  LocationManager.swift
//  test
//
//  Created by Umar Momin on 31/03/26.
//

internal import Combine
import Foundation
internal import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    
    private var permissionContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Requests permission and returns the status
    func requestLocationPermissionIfNeeded() async -> CLAuthorizationStatus {
        let status = manager.authorizationStatus
        if status == .notDetermined {
            return await withCheckedContinuation { continuation in
                self.permissionContinuation = continuation
                manager.requestWhenInUseAuthorization()
            }
        }
        return status
    }
    
    /// Requests a single one-time location update
    func requestSingleLocation() async -> CLLocation? {
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            manager.requestLocation()
        }
    }
    
    // MARK: - Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        currentLocation = location
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location Error: \(error.localizedDescription)")
        locationContinuation?.resume(returning: nil)
        locationContinuation = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        permissionContinuation?.resume(returning: manager.authorizationStatus)
        permissionContinuation = nil
    }
}
