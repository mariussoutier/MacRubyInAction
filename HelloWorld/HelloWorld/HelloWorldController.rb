
class HelloWorldController
    attr_accessor :hello_label, :hello_button

  def awakeFromNib
    @hello = true
  end
    
  def changeLabel(sender)
    if @hello
      @hello_label.stringValue = "Good Bye"
      @hello_button.title = "Hello"
      @hello = false
    else
      @hello_label.stringValue = "Hello World"
      @hello_button.title = "Good Bye"
      @hello = true
    end
  end
end
