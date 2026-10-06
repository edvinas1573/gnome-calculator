# Date calculation

Open the calculator's primary menu and choose **Date Calculation**. The dialog
provides three operations. Results update as inputs change and can be selected
and copied.

1. **Difference between dates** accepts a start and end date. It shows signed
   elapsed days (`end - start`) and the number of February 29 dates in the range.
2. **Add days** accepts a start date and a non-negative whole number of days.
3. **Subtract days** accepts the same inputs and moves backward.

Dates use `YYYY-MM-DD`, from `0001-01-01` through `9999-12-31`. Arithmetic uses
the proleptic Gregorian calendar and GLib.Date's calendar-day representation,
not elapsed seconds; daylight-saving time and local time zones do not change
the answer. Today is only used to initialize the fields.

The difference excludes the later date and includes the earlier one, including
when the inputs are reversed. Thus February 28 to March 1 in 2024 is two days
and one leap day. February 28 to February 29 is one day and zero leap days;
February 29 to March 1 is one day and one leap day. Identical dates give zero.
Century years such as 1900 and 2100 are not leap years; 2000 is.

Empty/invalid dates, fractional/negative day counts, excessively large counts
and results outside the supported date range show validation feedback in place
of the previous result. Fields irrelevant to the selected operation are disabled.
No locale-specific ambiguous date parsing or network access is used by this feature.

## Verification

Build the complete application and enable GTK tests:

```sh
meson setup _build -Dui-tests=true
meson compile -C _build
glib-compile-schemas data
GSETTINGS_SCHEMA_DIR="$PWD/data" GSETTINGS_BACKEND=memory \
  xvfb-run -a dbus-run-session -- \
  meson test -C _build 'Date calculator' 'Date dialog' --print-errorlogs
```

The math test covers fixed answers, leap-day endpoints, leap centuries, reversed
ranges, invalid inputs, the full supported date range, and 6036 month transition
roundtrips. The GTK test constructs the real calculator window, activates its
date-calculation action, then changes actual dialog widgets and checks results,
disabled fields, validation recovery and close handling. The workflow runs the
new tests in UTC, America/New_York and Europe/Vilnius and also runs the original
test suite. Optional `DATE_TEST_SCREENSHOTS` captures rendered dialog examples.

Baseline run 37425243465 compiled the original application but failed its
network-dependent Currency test and the existing GTK accessibility-bus setup.
The workflow installs the accessibility service for subsequent GTK verification.
The Currency test failure is separate from date arithmetic; do not interpret
passing date tests as proof of an entirely passing original suite.
