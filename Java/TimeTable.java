package com.resaneh24.manmamanam.content.common.entity;

import com.resaneh24.manmamanam.content.common.logger.Log;

import java.util.List;

/**
 * 12/6/2016
 *
 * @author Mahdi Taherian
 */

public class TimeTable extends StandardEntity {
    public List<Session> Sessions;
    public List<Session> Exceptions;
    public String HumanReadable;

    public boolean isOpen(long time) {
        return isOpen(this, time);
    }

    public static boolean isOpen(TimeTable timeTable, long time) {
        if (timeTable == null || timeTable.Sessions == null || timeTable.Sessions.isEmpty()) {
            return true;
        }
        Session session = timeTable.findCurrentSession(time);
        return session != null;
    }

    public long nextChange(long time) {
        recursiveCount = 0;
        Session currentSession = findCurrentSession(time);
        if (currentSession != null) {
            long nearestException = findNearest(Exceptions, null, time);

            long remaining = currentSession.remaining(time);
            return Math.min(remaining, nearestException);
        }
        return findNearest(Sessions, Exceptions, time);
    }

    private int recursiveCount = 0;

    private long findNearest(List<Session> Sessions, List<Session> Exceptions, long time) {
        long nearestTime = Long.MAX_VALUE;
        if (Sessions != null) {
            for (Session session : Sessions) {
                long s = session.Start % session.Cycle;
                long t = time % session.Cycle;

//                long end = s + session.Duration;
                long dif = s - t;
                if (dif < 0) {
                    dif += session.Cycle;
                }
                if (dif > 0) {
                    if (Exceptions != null && !Exceptions.isEmpty()) {
                        long future = time + dif;
                        for (Session ex : Exceptions) {
                            if (isInSession(ex, future)) {
                                if (recursiveCount++ > Sessions.size() * Exceptions.size()) {
                                    Log.w("TimeTable", "Problem in recursive calculation.");
                                } else {
                                    dif = Math.min(findNearest(Sessions, Exceptions, time + ex.remaining(future)), dif);
                                }
                            }
                        }
                    }
                } else {
                    throw new RuntimeException("Negative time difference: ");
//                    Log.w("TimeTable", "Negative time difference: " + dif);
//                    long r = session.remaining(time);
//                    dif = r;
                }
                nearestTime = Math.min(nearestTime, dif);
            }
        }
        return nearestTime;
    }

    private static boolean isInSession(Session session, long time) {
        if (time < session.Start || (session.End > 0 && session.End < time)) {
            return false;
        } else {
            return session.remaining(time) > 0;
        }
    }

    public Session findCurrentSession(long time) {
        if (Exceptions != null) {
            for (Session session : Exceptions) {
                if (isInSession(session, time)) {
                    return null;
                }
            }
        }

        for (Session session : Sessions) {
            if (isInSession(session, time)) {
                return session;
            }
        }
        return null;
    }


    public static class Session extends StandardEntity {
        public long Start;
        public long End;
        public long Duration;
        public long Cycle;

        public long remaining(long time) {
            long t = time % Cycle;
            long s = Start % Cycle;
            if (t < s) {
                return -1;
            }
            long e = s + Duration;
            long r = e - t;
            return r > 0 ? r : 0;
        }
    }
}
