//  HealthKitService.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/8/23.
//  
//

import Foundation
import HealthKit

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
    
    func requestAccessToHealthKitForShoeCycle() async throws {
        if authorizationStatus != .sharingAuthorized {
            do {
                try await healthStore.requestAuthorization(toShare: [runQuantityType], read: [runQuantityType])
                await MainActor.run {
                    authorizationStatus = healthStore.authorizationStatus(for: runQuantityType)
                }
            }
            catch let error as HKError {
                print(error)
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
