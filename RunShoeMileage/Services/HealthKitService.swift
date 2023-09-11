//  HealthKitService.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/8/23.
//  
//

import Foundation
import HealthKit

class HealthKitService: ObservableObject {
    let isHealthDataAvailable: Bool
    @Published var authorizationStatus: HKAuthorizationStatus
    private let healthStore: HKHealthStore
    private let runQuantityType: HKQuantityType
    
    enum ServiceError: Error {
        case healthDataIsNotAvailable
        case healthDataSharingDenied
        case otherHealthError
        case unknownError
    }
    

    init() {
        isHealthDataAvailable = HKHealthStore.isHealthDataAvailable()
        healthStore = HKHealthStore()
        runQuantityType = HKQuantityType(.distanceWalkingRunning)
        authorizationStatus = healthStore.authorizationStatus(for: runQuantityType)
    }
    
    func requestAccessToHealthKitForShoeCycle() async throws {
        if authorizationStatus != .sharingAuthorized {
            do {
                try await healthStore.requestAuthorization(toShare: [runQuantityType], read: [runQuantityType])
                await MainActor.run {
                    authorizationStatus = healthStore.authorizationStatus(for: runQuantityType)
                }
                
            }
            catch(let error as HKError ) {
                print(error)
                if error.code == .errorAuthorizationDenied {
                    throw ServiceError.healthDataSharingDenied
                }
                else {
                    throw ServiceError.otherHealthError
                }
            }
            catch {
                throw ServiceError.unknownError
            }
        }
        else {
            await MainActor.run {
                authorizationStatus = healthStore.authorizationStatus(for: runQuantityType)
            }
            
        }
    }
}
