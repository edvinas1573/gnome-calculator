// SPDX-License-Identifier: GPL-3.0-or-later
/* Calendar arithmetic uses GLib.Date, independent of time zones and DST. */
public errordomain DateCalculationError
{
    INVALID_DATE,
    INVALID_DAYS,
    OUT_OF_RANGE
}

public class DateCalculator : Object
{
    public const int MAX_DAYS = 3652058;

    public static Date parse (string text) throws DateCalculationError
    {
        var value = text.strip ();
        if (value.length != 10 || value[4] != '-' || value[7] != '-')
            throw new DateCalculationError.INVALID_DATE ("Use YYYY-MM-DD");
        for (var i = 0; i < value.length; i++)
            if (i != 4 && i != 7 && (value[i] < '0' || value[i] > '9'))
                throw new DateCalculationError.INVALID_DATE ("Use YYYY-MM-DD");

        var year = int.parse (value.substring (0, 4));
        var month = int.parse (value.substring (5, 2));
        var day = int.parse (value.substring (8, 2));
        if (year < 1 || year > 9999 || month < 1 || month > 12 || day < 1 || day > 31 ||
            !Date.valid_dmy ((DateDay) day, (DateMonth) month, (DateYear) year))
            throw new DateCalculationError.INVALID_DATE ("Invalid Gregorian date");
        Date date = Date ();
        date.set_dmy ((DateDay) day, month, (DateYear) year);
        return date;
    }

    public static int parse_days (string text) throws DateCalculationError
    {
        var value = text.strip ();
        if (value.length == 0)
            throw new DateCalculationError.INVALID_DAYS ("Enter a whole number of days");
        for (var i = 0; i < value.length; i++)
            if (value[i] < '0' || value[i] > '9')
                throw new DateCalculationError.INVALID_DAYS ("Enter a non-negative whole number");
        int64 days;
        if (!int64.try_parse (value, out days) || days > MAX_DAYS)
            throw new DateCalculationError.INVALID_DAYS ("Day count is too large");
        return (int) days;
    }

    public static string format (Date date)
    {
        return "%04u-%02u-%02u".printf ((uint) date.get_year (), (uint) date.get_month (), (uint) date.get_day ());
    }

    public static int difference (string start, string end, out int leap_days) throws DateCalculationError
    {
        var first = parse (start);
        var last = parse (end);
        var lower = first.get_julian () < last.get_julian () ? first : last;
        var upper = first.get_julian () < last.get_julian () ? last : first;
        leap_days = 0;
        // Count February 29 in [earlier date, later date), matching elapsed days.
        for (int year = lower.get_year (); year <= upper.get_year (); year++)
        {
            if (!((DateYear) year).is_leap_year ())
                continue;
            Date leap = Date ();
            leap.set_dmy (29, 2, (DateYear) year);
            if (leap.get_julian () >= lower.get_julian () && leap.get_julian () < upper.get_julian ())
                leap_days++;
        }
        return first.days_between (last);
    }

    public static string shift (string start, int days, bool subtract) throws DateCalculationError
    {
        var date = parse (start);
        if (days < 0 || days > MAX_DAYS)
            throw new DateCalculationError.INVALID_DAYS ("Invalid day count");
        var serial = date.get_julian ();
        // Years 0001 through 9999 contain MAX_DAYS + 1 days.
        if ((subtract && days >= serial) || (!subtract && days > MAX_DAYS + 1 - serial))
            throw new DateCalculationError.OUT_OF_RANGE ("Date outside supported range");
        if (subtract)
            date.subtract_days ((uint) days);
        else
            date.add_days ((uint) days);
        return format (date);
    }
}

