framework 'cocoa'

@app = NSApplication.sharedApplication

def setup_window
  win = NSWindow.alloc.initWithContentRect([300, 300, 300, 100],
    styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask,
    backing:NSBackingStoreBuffered, defer:false)
  win.delegate = self
  win.title = "Delegate Test"
  win.display
  win.orderFrontRegardless
end

def windowShouldClose(sender)
  alert = NSAlert.alertWithMessageText("Do you really want to quit?",
    defaultButton:"OK", alternateButton:"Cancel", otherButton:nil, informativeTextWithFormat:"Are you sure you want to exit this cool app?")
  alert.runModal == NSAlertDefaultReturn ? true : false
end

def windowDidClose(notification)
  @app.stop(self)
end

setup_window
@app.run

