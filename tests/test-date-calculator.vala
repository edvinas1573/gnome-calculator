// SPDX-License-Identifier: GPL-3.0-or-later
private void check (bool condition, string description)
{
    if (!condition)
        error ("Date regression failed: %s", description);
}

private void range (string start, string end, int expected, int expected_leaps) throws Error
{
    int leaps;
    var days = DateCalculator.difference (start, end, out leaps);
    check (days == expected && leaps == expected_leaps, start + " to " + end);
}

private int main (string[] args)
{
    try
    {
        range ("2024-02-28", "2024-03-01", 2, 1);
        range ("2023-02-28", "2023-03-01", 1, 0);
        range ("1900-02-28", "1900-03-01", 1, 0);
        range ("2000-02-28", "2000-03-01", 2, 1);
        range ("2100-02-28", "2100-03-01", 1, 0);
        range ("2024-03-01", "2024-02-28", -2, 1);
        range ("2024-02-29", "2024-02-29", 0, 0);
        range ("2024-02-28", "2024-02-29", 1, 0);
        range ("2024-02-29", "2024-03-01", 1, 1);
        range ("2020-01-01", "2025-01-01", 1827, 2);
        range ("0001-01-01", "9999-12-31", 3652058, 2424);
        range ("2024-03-09", "2024-03-11", 2, 0);
        range ("2024-11-02", "2024-11-04", 2, 0);
        check (DateCalculator.shift ("2024-02-28", 1, false) == "2024-02-29", "add into leap day");
        check (DateCalculator.shift ("2024-03-01", 1, true) == "2024-02-29", "subtract into leap day");
        check (DateCalculator.shift ("2023-12-31", 1, false) == "2024-01-01", "year transition");
        check (DateCalculator.shift ("2000-02-29", 365, false) == "2001-02-28", "whole leap year offset");
        check (DateCalculator.shift ("0001-01-01", 3652058, false) == "9999-12-31", "maximum addition");
        check (DateCalculator.shift ("9999-12-31", 3652058, true) == "0001-01-01", "maximum subtraction");
        check (DateCalculator.shift ("9999-12-31", 0, false) == "9999-12-31", "zero upper bound");
        check (DateCalculator.shift ("0001-01-01", 0, true) == "0001-01-01", "zero lower bound");
        check (DateCalculator.format (DateCalculator.parse (" 2024-02-29 ")) == "2024-02-29", "surrounding whitespace");

        // Exercise all Gregorian leap-century cases and month transitions.
        for (var year = 1899; year <= 2401; year++)
            for (var month = 1; month <= 12; month++)
            {
                var start = "%04d-%02d-01".printf (year, month);
                var shifted = DateCalculator.shift (start, 45, false);
                check (DateCalculator.shift (shifted, 45, true) == start, "month roundtrip");
                int leaps;
                check (DateCalculator.difference (start, shifted, out leaps) == 45, "elapsed days after shift");
            }

        string[] invalid_dates = { "", "2024-2-29", "2023-02-29", "1900-02-29", "2100-02-29", "2024-04-31", "2024-00-01", "2024-13-01", "2024-01-00", "0000-01-01", "10000-01-01", "2024/01/01", "2024-01-01extra", "2024-01-0x", "٢٠٢٤-01-01" };
        foreach (var invalid in invalid_dates)
        {
            bool rejected = false;
            try { DateCalculator.parse (invalid); }
            catch (DateCalculationError e) { rejected = e.code == DateCalculationError.INVALID_DATE; }
            check (rejected, "invalid date: " + invalid);
        }
        string[] invalid_days = { "", "-1", "+1", "1.5", "1e2", "2x", "3652059", "9223372036854775808", "999999999999999999999999999999999999999999" };
        foreach (var invalid in invalid_days)
        {
            bool rejected = false;
            try { DateCalculator.parse_days (invalid); }
            catch (DateCalculationError e) { rejected = e.code == DateCalculationError.INVALID_DAYS; }
            check (rejected, "invalid days: " + invalid);
        }
        check (DateCalculator.parse_days (" 00042 ") == 42, "whole days");
        check (DateCalculator.parse_days ("0") == 0, "zero days");
        foreach (var subtract in new bool[] { false, true })
        {
            bool rejected = false;
            try { DateCalculator.shift (subtract ? "0001-01-01" : "9999-12-31", 1, subtract); }
            catch (DateCalculationError e) { rejected = e.code == DateCalculationError.OUT_OF_RANGE; }
            check (rejected, "result range boundary");
        }
        bool negative_rejected = false;
        try { DateCalculator.shift ("2024-01-01", -1, false); }
        catch (DateCalculationError e) { negative_rejected = e.code == DateCalculationError.INVALID_DAYS; }
        check (negative_rejected, "direct negative day count");
    }
    catch (Error e)
    {
        stderr.printf ("Unexpected error: %s\n", e.message);
        return 1;
    }
    stdout.printf ("PASS: date differences, leap days, add/subtract, boundaries and 6036 month roundtrips\n");
    return 0;
}
