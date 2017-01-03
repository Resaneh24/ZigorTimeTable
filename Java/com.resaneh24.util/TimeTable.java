package com.resaneh24.util;

import android.util.Log;
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
                if (!session.isInPeriod(time)) {
                    continue;
                }

                long s;
                long t;
                if (session.Cycle <= 0) {
                    s = session.Start;
                    t = time;
                } else {
                    s = session.Start % session.Cycle;
                    t = time % session.Cycle;
                }

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
        if (!session.isInPeriod(time)) {
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
            if (!isInPeriod(time)) {
                return -1;
            }
            long s;
            long t;
            if (Cycle <= 0) {
                s = Start;
                t = time;
            } else {
                s = Start % Cycle;
                t = time % Cycle;
            }
            if (t < s) {
                return -1;
            }
            long e = s + Duration;
            long r = e - t;
            return r > 0 ? r : 0;
        }

        public boolean isInPeriod(long time) {
            long e;
            if (Cycle == 0 && End == 0) {
                e = Start + Duration;
            } else if (End == 0) {
                e = Long.MAX_VALUE;
            } else {
                e = End;
            }

            return time >= Start && time < e;
        }
    }
}