
class Task
  attr_accessor :status, :title

  def initialize
    @status = "Open"
  end
    
  def complete
    @status = "Completed"
  end
end
