using System;
using System.Linq;

// ReSharper disable All

namespace ZgTimeTable
{

    public class TimeTable
    {
        public Session[] Sessions;
        public Session[] Exceptions;
        public string HumanReadable;

        public TimeTable()
        {
            
        }

        public TimeTable(Session[] sessions, Session[] Exeptions)
        {
            
        }

        public bool isOpen(long time)
        {
            return isOpen(this, time);
        }

        public static bool isOpen(TimeTable timeTable, long time)
        {
            if (timeTable == null || timeTable.Sessions == null || !timeTable.Sessions.Any())
            {
                return true;
            }
            Session session = timeTable.findCurrentSession(time);
            return session != null;
        }

        public long nextChange(long time)
        {
            Session currentSession = findCurrentSession(time);
            if (currentSession != null)
            {
                long nearestException = findNearest(Exceptions, null, time);

                long remaining = currentSession.remaining(time);
                return Math.Min(remaining, nearestException);
            }
            else
            {
                Session currentExpection = null;
                foreach (Session session in Exceptions)
                {
                    if (isInSession(session, time))
                    {
                        currentExpection = session;
                        break;
                    }
                }
                if (currentExpection != null)
                {
                    long exRemaining = currentExpection.remaining(time);
                    if (findCurrentSession(time + exRemaining) != null)
                        return exRemaining;
                }
            }
            return findNearest(Sessions, Exceptions, time);
        }

        private long findNearest(Session[] Sessions, Session[] Exceptions, long time)
        {
            long nearestTime = long.MaxValue;
            if (Sessions != null)
            {
                foreach (Session session in Sessions)
                {
                    if (!session.isInPeriod(time))
                        continue;

                    long s;
                    long t;
                    if (session.Cycle <= 0)
                    {
                        s = session.Start;
                        t = time;
                    }
                    else
                    {
                        s = session.Start % session.Cycle;
                        t = time % session.Cycle;
                    }

                    long dif = s - t;
                    if (dif < 0)
                    {
                        dif += session.Cycle;
                    }
                    if (!session.isInPeriod(time + dif))
                        continue;

                    if (dif > 0)
                    {
                        if (Exceptions != null && Exceptions.Any())
                        {
                            long future = time + dif;
                            long exDif = long.MaxValue;

                            foreach (Session ex in Exceptions)
                            {
                                if (isInSession(ex, future))
                                {
                                    exDif = Math.Min(nextChange(time + ex.remaining(future)) + dif, exDif);
                                }
                            }
                            dif = Math.Min(exDif, dif);
                        }
                    }
                    else
                    {
                        throw new Exception("Negative time difference: ");
                    }
                    nearestTime = Math.Min(nearestTime, dif);
                }
            }
            return nearestTime;
        }

        private static bool isInSession(Session session, long time)
        {
            if (time < session.Start || (session.End > 0 && session.End < time))
            {
                return false;
            }
            else {
                return session.remaining(time) > 0;
            }
        }

        public Session findCurrentSession(long time)
        {
            if (Exceptions != null)
            {
                foreach (Session session in Exceptions)
                {
                    if (isInSession(session, time))
                    {
                        return null;
                    }
                }
            }

            foreach (Session session in Sessions)
            {
                if (isInSession(session, time))
                {
                    return session;
                }
            }

            return null;
        }
    }

    public class Session
    {
        public long Start;
        public long End;
        public long Duration;
        public long Cycle;

        public long remaining(long time)
        {
            if (isInPeriod(time))
                return -1;
            
            long t;
            long s;
            if(Cycle <= 0)
            {
                s = Start;
                t = time;
            }
            else
            {
                s = Start % Cycle;
                t = time % Cycle;
            }
            if (t < s)
            {
                return -1;
            }
            long e = s + Duration;
            long r = e - t;
            return r > 0 ? r : 0;
        }
        public bool isInPeriod(long time)
        {
            long e;
            if (Cycle == 0 && End == 0)
                e = Start + Duration;
            else if (End == 0)
                e = long.MaxValue;
            else
                e = End;

            return time >= Start && time < e;
        }
    }
}
