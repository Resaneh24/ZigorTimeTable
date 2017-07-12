//
//  TimeTable.swift
//  Man Mamanam
//
//  Created by Farzan on 12/6/16.
//  Copyright © 2016 SoroushMehr. All rights reserved.
//

import Foundation

protocol Copyable {
    init(instance: Self)
}

extension Copyable {
    func clone() -> Self {
        return Self.init(instance: self)
    }
}


class TimeTable: NSObject, Copyable {

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
        let session = timeTable!.findCurrentSession(time: currentTime!)
        return (session != nil)
    }

    func nextChange(_ time: Int64) -> Int64 {
        let currentSession = findCurrentSession(time: time)
        if currentSession != nil {
            let nearestException = findNearest(exceptions, nil, time)
            let remaining = currentSession?.remaining(time)

            return min(remaining!, nearestException)
        } else {
            var currentException: Session? = nil

            for session in exceptions! {
                if isInSession(session, time) {
                    currentException = session
                    break
                }
            }

            if currentException != nil {
                var exRemaining = currentException!.remaining(time)
                for exception in exceptions! {
                    if isInSession(exception, time + exRemaining) {
                        exRemaining += exception.remaining(time + exRemaining)
                    }
                }
                if findCurrentSession(time: time + exRemaining) != nil {
                    return exRemaining
                }
            }
        }

        return findNearest(sessions, exceptions, time)
    }

    func findNearest(_ sessions: [Session]?, _ exceptions: [Session]?, _ time: Int64) -> Int64 {
        var nearestTime = Int64.max
        if sessions != nil {
            for session in sessions! {

                if !session.isInPeriod(time) {
                    continue
                }

                var s: Int64!
                var t: Int64!

                if session.cycle!.int64Value <= 0 {
                    s = session.start!.int64Value
                    t = time
                } else {
                    s = session.start!.int64Value % session.cycle!.int64Value
                    t = time % session.cycle!.int64Value
                }

                var dif = s - t
                if dif <= 0 {
                    dif += session.cycle!.int64Value
                }
                if !session.isInPeriod(time + dif) {
                    continue
                }

                if dif > 0 {
                    if exceptions != nil && !exceptions!.isEmpty {
                        let future = time + dif
                        var exDif = Int64.max
                        var isException = false

                        for ex in exceptions! {
                            if isInSession(ex, future) {
                                isException = true
                                exDif = min(nextChange(future), exDif)
                            }
                        }
                        if isException {
                            dif = exDif + dif
                        } else {
                            dif = min(exDif, dif)
                        }
                    }
                } else {
                    debugPrint("TimeTable", "Negative time difference: ", dif)
                }

                nearestTime = min(nearestTime, dif)
            }
        }

        return nearestTime
    }

    func isInSession(_ session: Session, _ currentTime: Int64) -> Bool {
        if !session.isInPeriod(currentTime) {
            return false
        } else {
            return session.remaining(currentTime) > 0
        }
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


    override init() {
        super.init()
    }

    required init(instance: TimeTable) {
        self.humanReadable = instance.humanReadable
        if let sessionArray = instance.sessions {
            var ses = [Session]()
            for item in sessionArray {
                ses.append(item.clone())
            }
            self.sessions = ses
        }

        if let excepArray = instance.exceptions {
            var exc = [Session]()
            for item in excepArray {
                exc.append(item.clone())
            }
            self.sessions = exc
        }
    }
}

class Session: NSObject, Copyable {

    var start: NSNumber?
    var duration: NSNumber?
    var end: NSNumber?
    var cycle: NSNumber?

    func remaining(_ time: Int64) -> Int64 {
        if !isInPeriod(time) {
            return -1
        }

        var s: Int64!
        var t: Int64!

        if cycle!.int64Value <= 0 {
            s = start!.int64Value
            t = time
        } else {
            s = start!.int64Value % cycle!.int64Value
            t = time % cycle!.int64Value
        }

        if t < s {
            return -1
        }

        let e = s + duration!.int64Value
        let r = e - t

        return r > 0 ? r : 0
    }

    func isFinished(_ time: Int64) -> Bool {
        var e: Int64!
        if cycle == 0 && end == 0 {
            e = start!.int64Value + duration!.int64Value
        } else if end == 0 {
            e = Int64.max
        } else {
            e = end as! Int64
        }

        return time >= e
    }

    func isInPeriod(_ time: Int64) -> Bool {
        return time >= start!.int64Value && !isFinished(time)
    }
    
    override init() {
        super.init()
    }
    
    required init(instance: Session) {
        self.start = instance.start
        self.duration = instance.duration
        self.end = instance.end
        self.cycle = instance.cycle
    }
}
