unit gtk2clipboardowner;

// Gives the LCL GTK2 widgetset a clipboard widget that is always realized.
//
// LCL-GTK2 uses the first form whose handle is created as its clipboard widget
// (lcl/interfaces/gtk2/gtk2wsforms.pp, TGtk2WSCustomForm.CreateHandle). In HeidiSQL
// that is the hidden SQL completion popup. Its GTK window is only realized once the
// popup has been shown, and gtk_selection_owner_set() refuses unrealized widgets
// ("assertion 'widget == NULL || gtk_widget_get_realized (widget)' failed"). LCL
// ignores that failure, so every copy to the clipboard silently did nothing until
// the completion popup had appeared once.
//
// A GtkInvisible is what GTK's own GtkClipboard uses for this: it is realized right
// away, never shown and never destroyed, so the clipboard does not depend on which
// form exists or is visible. Remove this unit once LCL realizes its clipboard widget.

{$mode delphi}{$H+}

interface

// Call once after Application.Initialize. Does nothing on other widgetsets.
procedure InstallRealizedClipboardWidget;

implementation

{$IFDEF LCLGtk2}
uses
  InterfaceBase, gtk2, gtk2int;

procedure InstallRealizedClipboardWidget;
var
  Widget: PGtkWidget;
begin
  Widget := gtk_invisible_new;
  gtk_widget_realize(Widget);
  TGtk2WidgetSet(WidgetSet).SetClipboardWidget(Widget);
end;
{$ELSE}
procedure InstallRealizedClipboardWidget;
begin
end;
{$ENDIF}

end.
