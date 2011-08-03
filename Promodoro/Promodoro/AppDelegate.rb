#
#  AppDelegate.rb
#  Promodoro
#
#  Created by Marius Soutier on 20.07.11.
#

class AppDelegate
  attr_accessor :window, :action_button, :time_left_label, :inspirational_label
  
  def awakeFromNib
    @minutes = 25
  end
  
  def start_timer(sender)
    if @timer.nil?
      @timer = NSTimer.scheduledTimerWithTimeInterval(60, target:self, selector:"update_time_left:",
                                                               userInfo:nil, repeats:true)
      @action_button.title = "Stop timer"
      @inspirational_label.stringValue = "Go create something!"
    else
      reset_timer # TODO Stop != reset
    end
  end
    
  def reset_timer
    @timer.invalidate
    @timer = nil
    @action_button.title = "Start working"
    @inspirational_label.stringValue = ""
    @minutes = 25
    update_timer_text
  end
    
  def update_time_left(timer)
    if @minutes >= 1
      @minutes -= 1
      update_timer_text
    else
      reset_timer
    end
  end
    
  def update_timer_text
    @time_left_label.stringValue = "#{@minutes} minutes remaining"
    
  end
end
