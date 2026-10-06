private void check (bool condition, string description)
{
    if (!condition)
        error ("Date dialog regression failed: %s", description);
}

private int main (string[] args)
{
    Gtk.init (ref args);
    var dialog = new MathDateDialog (null);
    dialog.start_entry.text = "2024-02-28";
    dialog.end_entry.text = "2024-03-01";
    check (dialog.result_text == "Difference: 2 days\nLeap days in range: 1 leap day", "actual difference input signals");
    check (dialog.end_entry.sensitive && !dialog.days_entry.sensitive, "difference controls");
    dialog.operation.active_id = "add";
    dialog.days_entry.text = "1";
    check (dialog.result_text == "Result: 2024-02-29", "actual add selection and input signals");
    check (!dialog.end_entry.sensitive && dialog.days_entry.sensitive, "offset controls");
    dialog.operation.active_id = "subtract";
    dialog.start_entry.text = "2024-03-01";
    check (dialog.result_text == "Result: 2024-02-29", "actual subtract selection signals");
    dialog.days_entry.text = "-1";
    check (dialog.result_text.has_prefix ("Enter a whole number"), "invalid offset feedback");
    dialog.days_entry.text = "1";
    dialog.start_entry.text = "0001-01-01";
    check (dialog.result_text.has_prefix ("The result must be"), "range feedback");
    dialog.start_entry.text = "2023-02-29";
    check (dialog.result_text.has_prefix ("Enter a valid date"), "invalid date feedback replaces stale result");
    dialog.operation.active_id = "difference";
    dialog.start_entry.text = "2024-03-01";
    dialog.end_entry.text = "2024-02-28";
    check (dialog.result_text == "Difference: -2 days\nLeap days in range: 1 leap day", "reversed range feedback");
    dialog.destroy ();
    stdout.printf ("PASS: GTK inputs, operation changes, result labels and error recovery\n");
    return 0;
}
