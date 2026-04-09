import Foundation

extension Date {
    public var startOfWeek: Date {
        Calendar.current
            .date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) ?? self
    }

    public var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }

    public var startOfQuarter: Date {
        let month = Calendar.current.component(.month, from: self)
        let quarterStartMonth = ((month - 1) / 3) * 3 + 1
        return Calendar.current.date(from: DateComponents(
            year: Calendar.current.component(.year, from: self),
            month: quarterStartMonth,
            day: 1
        )) ?? self
    }

    public var startOfSemester: Date {
        let month = Calendar.current.component(.month, from: self)
        let semesterStartMonth = month <= 6 ? 1 : 7
        return Calendar.current.date(from: DateComponents(
            year: Calendar.current.component(.year, from: self),
            month: semesterStartMonth,
            day: 1
        )) ?? self
    }

    public var startOfYear: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year], from: self)) ?? self
    }
}
