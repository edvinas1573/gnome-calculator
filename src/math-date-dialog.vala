// SPDX-License-Identifier: GPL-3.0-or-later
public class MathDateDialog : Gtk.Dialog
{
    internal Gtk.ComboBoxText operation;
    internal Gtk.Entry start_entry;
    internal Gtk.Entry end_entry;
    internal Gtk.Entry days_entry;
    private Gtk.Label result;
    public string result_text { get { return result.label; } }

    public MathDateDialog (Gtk.Window? parent)
    {
        Object (title: _("Date Calculation"), transient_for: parent, modal: true);
        add_button (_("_Close"), Gtk.ResponseType.CLOSE);
        response.connect (() => destroy ());

        var grid = new Gtk.Grid ();
        grid.margin = 18;
        grid.row_spacing = 12;
        grid.column_spacing = 12;
        get_content_area ().add (grid);
        operation = new Gtk.ComboBoxText ();
        operation.append ("difference", _("Difference between dates"));
        operation.append ("add", _("Add days"));
        operation.append ("subtract", _("Subtract days"));
        operation.active_id = "difference";
        attach_input (grid, _("_Operation"), operation, 0);

        var today = new DateTime.now_local ().format ("%Y-%m-%d");
        start_entry = date_entry (today);
        end_entry = date_entry (today);
        days_entry = new Gtk.Entry ();
        days_entry.text = "0";
        days_entry.input_purpose = Gtk.InputPurpose.DIGITS;
        attach_input (grid, _("_Start date"), start_entry, 1);
        attach_input (grid, _("_End date"), end_entry, 2);
        attach_input (grid, _("_Days"), days_entry, 3);

        var hint = new Gtk.Label (_("Use YYYY-MM-DD, from 0001-01-01 to 9999-12-31.\nLeap days are counted from the earlier date, inclusive, to the later date, exclusive."));
        hint.wrap = true;
        hint.max_width_chars = 48;
        hint.xalign = 0;
        grid.attach (hint, 0, 4, 2, 1);
        result = new Gtk.Label ("");
        result.selectable = true;
        result.wrap = true;
        result.max_width_chars = 48;
        result.xalign = 0;
        grid.attach (result, 0, 5, 2, 1);

        operation.changed.connect (update_result);
        start_entry.changed.connect (update_result);
        end_entry.changed.connect (update_result);
        days_entry.changed.connect (update_result);
        show_all ();
        update_result ();
        start_entry.grab_focus ();
    }

    private Gtk.Entry date_entry (string initial)
    {
        var entry = new Gtk.Entry ();
        entry.placeholder_text = "YYYY-MM-DD";
        entry.width_chars = 12;
        entry.text = initial;
        return entry;
    }

    private void attach_input (Gtk.Grid grid, string text, Gtk.Widget widget, int row)
    {
        var label = new Gtk.Label.with_mnemonic (text);
        label.xalign = 0;
        label.mnemonic_widget = widget;
        widget.hexpand = true;
        grid.attach (label, 0, row, 1, 1);
        grid.attach (widget, 1, row, 1, 1);
    }

    internal void update_result ()
    {
        var difference = operation.active_id == "difference";
        end_entry.sensitive = difference;
        days_entry.sensitive = !difference;
        try
        {
            if (difference)
            {
                int leap_days;
                var days = DateCalculator.difference (start_entry.text, end_entry.text, out leap_days);
                var elapsed = ngettext ("%d day", "%d days", days.abs ()).printf (days);
                var leaps = ngettext ("%d leap day", "%d leap days", leap_days).printf (leap_days);
                result.label = _("Difference: %s\nLeap days in range: %s").printf (elapsed, leaps);
            }
            else
            {
                var days = DateCalculator.parse_days (days_entry.text);
                var date = DateCalculator.shift (start_entry.text, days, operation.active_id == "subtract");
                result.label = _("Result: %s").printf (date);
            }
        }
        catch (DateCalculationError error)
        {
            switch (error.code)
            {
                case DateCalculationError.INVALID_DATE:
                    result.label = _("Enter a valid date in YYYY-MM-DD format.");
                    break;
                case DateCalculationError.INVALID_DAYS:
                    result.label = _("Enter a whole number of days between 0 and 3652058.");
                    break;
                default:
                    result.label = _("The result must be between 0001-01-01 and 9999-12-31.");
                    break;
            }
        }
    }
}

