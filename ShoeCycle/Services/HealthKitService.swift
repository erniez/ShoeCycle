//  HealthKitService.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/8/23.
//  
//

import Foundation
import HealthKit


/// HealthKit Service to store runs and handle authorization.
class HealthKitService: ObservableObject, ThrowingService {
    let isHealthDataAvailable: Bool
    @Published var authorizationStatus: HKAuthorizationStatus
    private let healthStore: HKHealthStore
    private let runQuantityType: HKQuantityType
    
    enum DomainError: Error, Equatable {
        case healthDataIsNotAvailable
        case healthDataSharingDenied
        case otherHealthError(HKError)
        case unknownError
    }
    

    init() {
        isHealthDataAvailable = HKHealthStore.isHealthDataAvailable()
        healthStore = HKHealthStore()
        runQuantityType = HKQuantityType(.distanceWalkingRunning)
        authorizationStatus = healthStore.authorizationStatus(for: runQuantityType)
    }
    
    /**
     Request for authorization of HealthKit
     
     This function will update the authorizationStatus property with HealthKit's authorization status.
     If unknown, the system will prompt the user for authorization. Then update the authorizationStatus property
     with the user's response.
     */
    func requestAccessToHealthKitForShoeCycle() async throws {
        if authorizationStatus != .sharingAuthorized {
            do {
                try await healthStore.requestAuthorization(toShare: [runQuantityType], read: [runQuantityType])
                await MainActor.run {
                    authorizationStatus = healthStore.authorizationStatus(for: runQuantityType)
                }
            }
            catch let error as HKError {
                if error.code == .errorAuthorizationDenied {
                    throw DomainError.healthDataSharingDenied
                }
                else {
                    throw DomainError.otherHealthError(error)
                }
            }
            catch {
                throw DomainError.unknownError
            }
        }
        else {
            await MainActor.run {
                authorizationStatus = healthStore.authorizationStatus(for: runQuantityType)
            }
        }
    }
    
    /**
     Save a run to HealthKit
     - Parameters:
        - distance: Distance in miles.
        - date: Date of run.
        - metadata: Entry metadata
     */
    func saveRun(distance: Double, date: Date, metadata: [String : String]) async throws {
        guard healthStore.authorizationStatus(for: runQuantityType) == .sharingAuthorized else {
            throw DomainError.healthDataSharingDenied
        }
        
        let runDistanceQuantity = HKQuantity(unit: .mile(), doubleValue: distance)
        let runSample = HKQuantitySample(type: runQuantityType,
                                         quantity: runDistanceQuantity,
                                         start: date,
                                         end: date,
                                         metadata: metadata)
        do {
            try await healthStore.save(runSample)
        }
        catch let error as HKError {
            throw DomainError.otherHealthError(error)
        }
        catch {
            throw DomainError.unknownError
        }
    }
}
