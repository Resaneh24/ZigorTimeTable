//
//  TimeTable.swift
//  Man Mamanam
//
//  Created by Farzan on 12/6/16.
//  Copyright © 2016 SoroushMehr. All rights reserved.
//

import Foundation

class TimeTable: NSObject {
    
    var sessions: [Session]?
    var exceptions: [Session]?
    var humanReadable: String?
    
    func isOpen(time: Int64) -> Bool {
        return isOpen(timeTable: self, currentTime: time)
    }
    
    func isOpen(timeTable: TimeTable?, currentTime: Int64?) -> Bool {
        if timeTable == nil || timeTable?.sessions == nil || (timeTable?.sessions?.isEmpty)! {
            return true
        }
        
        return (timeTable!.findCurrentSession(time: currentTime!) != nil)
    }
    
    func nextChange(time: Int64) -> Int64 {
        let currentSession = findCurrentSession(time: time)
        if currentSession != nil {
            let nearestException = findNearest(exceptions, nil, time)
            let remaining = currentSession?.remaining(time: time)
            
            return min(remaining!, nearestException)
        }
        
        return findNearest(sessions, exceptions, time)
    }
    
    var recursiveCount = 0
    
    func findNearest(_ sessions: [Session]?, _ exceptions: [Session]?, _ time: Int64) -> Int64 {
        var nearestTime = Int64.max
        if sessions != nil {
            for session in sessions! {
                let s = session.startDate!.int64Value % session.cycle!.int64Value
                let t = time % session.cycle!.int64Value
                
                var dif = s - t
                if dif < 0 {
                    dif += session.cycle!.int64Value
                }
                if dif > 0 {
                    if exceptions != nil && !exceptions!.isEmpty {
                        let future = time + dif
                        for exception in exceptions! {
                            if isInSession(exception, future) {
                                recursiveCount += 1
                                if recursiveCount > sessions!.count * exceptions!.count {
                                    debugPrint("TimeTable", "Problem in recursive calculation.")
                                }
                            }
                        }
                    }
                } else {
                    debugPrint("TimeTable", "Negative time difference: ", dif)
                    let r = session.remaining(time: time)
                    dif = r
                }
                
                nearestTime = min(nearestTime, dif)
            }
        }
        
        return nearestTime
    }
    
    func isInSession(_ session: Session, _ currentTime: Int64) -> Bool {
        if currentTime < session.startDate!.int64Value || ( session.endDate!.int64Value > 0 && currentTime > session.endDate!.int64Value ) {
            return false
        }
        return session.remaining(time: currentTime) > 0
    }
    
    func findCurrentSession(time: Int64) -> Session? {
        if exceptions != nil {
            for session in exceptions! {
                if isInSession(session, time) {
                    return nil
                }
            }
        }
        
        for session in sessions! {
            if isInSession(session, time) {
                return session
            }
        }
        
        return nil
    }
}

class Session: NSObject {
    
    var startDate: NSNumber?
    var duration: NSNumber?
    var endDate: NSNumber?
    var cycle: NSNumber?
    
    func remaining(time: Int64) -> Int64 {
        let s = startDate!.int64Value % cycle!.int64Value
        let t = time % cycle!.int64Value
        
        if t < s {
            return -1
        }
        
        let e = s + duration!.int64Value
        let r = e - t
        
        return r > 0 ? r : 0
    }
}
