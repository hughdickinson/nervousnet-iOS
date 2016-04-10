//
//  GyroscopeController.swift
//  nervousnet-iOS
//  
//  Created by __DEVNAME__ on 03 Mar 2016.
//  Copyright (c) 2016 ETHZ . All rights reserved.
//
//WARNING - THIS CODE IS AUTOGENERATED BY DEVSKETCH AND CAN BE OVERWRITTEN


import Foundation
import CoreMotion
import CoreData
import UIKit

private let _GYR = GyroscopeController()
class GyroscopeController : NSObject {


    private var auth: Int = 0
    
    private let manager:  CMMotionManager
    
    private let VM = VMController.sharedInstance
    
    var timestamp: UInt64 = 0
    var x: Float = 0.0
    var y: Float = 0.0
    var z: Float = 0.0
    
    override init() {
        self.manager = CMMotionManager()
    }
    
    class var sharedInstance: GyroscopeController {
        return _GYR
    }
    
    func requestAuthorization() {
        print("requesting authorization for gyro")
        
        let val1 = self.VM.defaults.boolForKey("kill")   //objectForKey("kill") as! Bool
        let val2 = self.VM.defaults.boolForKey("switchGyr")    //objectForKey("switchGyr") as! Bool
        
        if !val1 && val2  {
            if self.manager.gyroAvailable {
                self.auth = 1
            }
        }
        else {
            self.auth = 0
        }
    }
    
    func initializeUpdate(freq: Double) {
        
        self.manager.gyroUpdateInterval = freq
        self.manager.startGyroUpdates()
        
    }
    
    // requestAuthorization must be before this is function is called
    func startSensorUpdates() {
        
        if self.auth == 0 {
            return
        }
        
        let queue = NSOperationQueue()
        let currentTimeA :NSDate = NSDate()
        
        self.manager.startGyroUpdatesToQueue(queue, withHandler: {data, error in
            
            self.timestamp = UInt64(currentTimeA.timeIntervalSince1970*1000) // time to timestamp
            guard let data = data else {
                return
            }
            self.x = Float(data.rotationRate.x)
            self.y = Float(data.rotationRate.y)
            self.z = Float(data.rotationRate.z)
            
            //print("groscope")
            //print(self.x)
        
            // store the current data in the CoreData database
            let val = self.VM.defaults.objectForKey("logGyr") as! Bool
            if val {
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                
                let entity = NSEntityDescription.entityForName("Gyroscope", inManagedObjectContext:
                    managedContext)
                let gyr = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                
                gyr.setValue(NSNumber(unsignedLongLong: self.timestamp) , forKey: "timestamp")
                gyr.setValue(self.x, forKey: "x")
                gyr.setValue(self.y, forKey: "y")
                gyr.setValue(self.z, forKey: "z")
            }
        })
    }
    
    func stopSensorUpdates() {
        self.manager.stopGyroUpdates()
        self.auth = 0
    }
}