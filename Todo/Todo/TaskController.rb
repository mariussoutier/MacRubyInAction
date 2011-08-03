
class TaskController
  attr_accessor :task_table_view, :task_text_field
  
  def awakeFromNib
    @tasks = []
    @task_table_view.dataSource = self
    @task_table_view.delegate = self
  end
  
  def numberOfRowsInTableView(view)
    @tasks.size
  end
  
  def tableView(view, objectValueForTableColumn:column, row:index)
    task = @tasks[index]
    case column.identifier
      when 'status'
        task.status
      when 'title'
        task.title
    end
  end

  def create_task(sender)
    if @task_text_field.stringValue != ""
      task = Task.new
      task.title = @task_text_field.stringValue
      @tasks << task
      @task_text_field.stringValue = ""
      @task_table_view.reloadData
    end
  end
  
  def complete_task(sender)
    if @task_table_view.selectedRow != -1
      @tasks[@task_table_view.selectedRow].complete
      @task_table_view.reloadData
    end
  end
end
