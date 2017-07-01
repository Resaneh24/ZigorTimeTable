using Microsoft.VisualStudio.TestTools.UnitTesting;
using ZgTimeTable;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZgTimeTable.Tests
{
    [TestClass()]
    public class TimeTableTests
    {
        private static readonly DateTime Epoch = new DateTime(1970, 1, 1);

        [TestMethod()]
        public void TimeTableTest()
        {
            TimeTable tt = new TimeTable()
            {
                Sessions = new[]
                {
                    new Session
                    {
                        Start = 1498867200000,
                        End = 1499000400000,
                        Duration = 3600000,
                        Cycle = 7200000
                    },
                    new Session
                    {
                        Start = 1498867200000,
                        End = 1499000400000,
                        Duration = 3600000,
                        Cycle = 0
                    }
                },
                Exceptions = new[]
                {
                    new Session
                    {
                        Start = 1498867200000,
                        End = 1499000400000,
                        Duration = 1800000,
                        Cycle = 0
                    },
                    new Session
                    {
                        Start = 1498867200000,
                        End = 1499000400000,
                        Duration = 900000,
                        Cycle = 3600000
                    }
                }

            };

            Assert.IsFalse(tt.isOpen(GetMilis(new DateTime(2017, 4, 1, 0, 1, 0))),
                "A time before start of sessions is returning true!");

            Assert.IsTrue(tt.isOpen(GetMilis(new DateTime(2017, 7, 1, 0, 30, 1))),
                "A correct time is not returning true near begin!");

            Assert.IsTrue(tt.isOpen(GetMilis(new DateTime(2017, 7, 1, 0, 42, 0))),
                "A correct time is not returning true in between!");

            Assert.IsTrue(tt.isOpen(GetMilis(new DateTime(2017, 7, 1, 2, 59, 59))),
                "A correct time is not returning true in the end!");

            Assert.IsTrue(tt.isOpen(GetMilis(new DateTime(2017, 7, 1, 0, 32, 0))),
                "A correct time is not returning true!");

            Assert.IsFalse(tt.isOpen(GetMilis(new DateTime(2017, 7, 1, 0, 20, 0))),
                "Single time TimeTable Exceptions are not handled correctly!");

            Assert.IsFalse(tt.isOpen(GetMilis(new DateTime(2017, 7, 1, 1, 20, 0))),
                "Single time TimeTable Exceptions are not handled correctly and repeats!");

            Assert.IsFalse(tt.isOpen(GetMilis(new DateTime(2017, 7, 1, 2, 11, 0))),
                "Repeative TimeTable Exceptions are not handled correctly!");

            Assert.IsFalse(tt.isOpen(GetMilis(new DateTime(2017, 7, 1, 1, 2, 0))),
                "A closed time is returning true!");

            Assert.IsFalse(tt.isOpen(GetMilis(new DateTime(2018, 7, 1, 3, 5, 0))),
                "A time after end is returning true!");
        }

        public long GetMilis(DateTime dt) => (long) dt.Subtract(Epoch).TotalMilliseconds;
    }
}