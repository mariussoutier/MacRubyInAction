
class BrowserController
  attr_accessor :window, :url_field, :web_view, :indicator
  
  def awakeFromNib
    @web_view.frameLoadDelegate = self
  end
  
  def url_entered(sender)
    url = NSURL.URLWithString(format_url(@url_field.stringValue))
    request = NSURLRequest.requestWithURL(url)
    @web_view.mainFrame.loadRequest(request)
  end
  
  def format_url(url)
    url = "http://#{url}" unless url.include?("http://") || url.include?("https://")
    url
  end
  
  def webView(sender, didStartProvisionalLoadForFrame:frame)
    @indicator.startAnimation(self)
    if frame == sender.mainFrame
      @url_field.stringValue = frame.provisionalDataSource.request.URL.absoluteString
    end
  end
  
  def webView(sender, didFinishLoadForFrame:frame)
    @indicator.stopAnimation(self)
  end
  
  def webView(sender, didReceiveTitle:title, forFrame:frame)
    @window.setTitle(title) if frame == sender.mainFrame
  end
  
  def webView(sender, didFailProvisionalLoadWithError:error, forFrame:frame)
    put "FAIL"
    if frame == sender.mainFrame
      alert = NSAlert.alloc.init
      alert.setMessageText("There was a problem loading URL:")
      alert.setInformativeText(@url_field.stringValue)
      alert.beginSheetModalForWindow(@window, modalDelegate:self, didEndSelector:nil, contexInfo:nil)
      @indicator.stopAnimation(self)
    end
  end
end
