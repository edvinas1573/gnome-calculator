// SPDX-License-Identifier: GPL-3.0-or-later
private void check (bool condition, string description)
{
    if (!condition)
        error ("Date dialog regression failed: %s", description);
}

private void capture (Gtk.Window window, string name)
{
    var directory = Environment.get_variable ("DATE_TEST_SCREENSHOTS");
    if (directory == null)
        return;
    check (DirUtils.create_with_parents (directory, 0755) == 0, "screenshot directory");
    var loop = new MainLoop ();
    Timeout.add (150, () => { loop.quit (); return Source.REMOVE; });
    loop.run ();
    int width, height;
    window.get_size (out width, out height);
    var image = Gdk.pixbuf_get_from_window (window.get_window (), 0, 0, width, height);
    check (image != null, "rendered GTK screenshot");
    try { image.save (Path.build_filename (directory, name + ".png"), "png"); }
    catch (Error e) { error ("Cannot save screenshot: %s", e.message); }
}

private int main (string[] args)
{
    Gtk.init (ref args);
    Hdy.init ();
    var app = new Gtk.Application ("org.gnome.Calculator.DateTest", ApplicationFlags.NON_UNIQUE);
    try { app.register (); }
    catch (Error e) { error ("Cannot register GTK application: %s", e.message); }
    var window = new MathWindow (app, new MathEquation ());
    window.show_all ();
    check (window.lookup_action ("date-calculation") != null, "real window action registered");
    window.activate_action ("date-calculation", null);
    MathDateDialog? opened = null;
    foreach (var top_level in Gtk.Window.list_toplevels ())
        if (top_level is MathDateDialog)
            opened = (MathDateDialog) top_level;
    check (opened != null, "real window action opens the date dialog");
    var dialog = (!) opened;
    check (dialog.transient_for == window, "dialog belongs to calculator window");
    dialog.start_entry.text = "2024-02-28";
    dialog.end_entry.text = "2024-03-01";
    check (dialog.result_text == "Difference: 2 days\nLeap days in range: 1 leap day", "actual difference input signals");
    check (dialog.end_entry.sensitive && !dialog.days_entry.sensitive, "difference controls");
    capture (dialog, "difference");
    dialog.operation.active_id = "add";
    dialog.days_entry.text = "1";
    check (dialog.result_text == "Result: 2024-02-29", "actual add selection and input signals");
    check (!dialog.end_entry.sensitive && dialog.days_entry.sensitive, "offset controls");
    capture (dialog, "add");
    dialog.operation.active_id = "subtract";
    dialog.start_entry.text = "2024-03-01";
    check (dialog.result_text == "Result: 2024-02-29", "actual subtract selection signals");
    capture (dialog, "subtract");
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
    dialog.response (Gtk.ResponseType.CLOSE);
    window.destroy ();
    stdout.printf ("PASS: real calculator window action, GTK inputs, operation changes, result labels and error recovery\n");
    return 0;
}

