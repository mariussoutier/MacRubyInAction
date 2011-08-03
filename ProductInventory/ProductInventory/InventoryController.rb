
class InventoryController
  attr_accessor :window, :products, :products_table

  def awakeFromNib
    @products = []
    seed_products
  end
  
  def seed_products
    20.times do |x|
      product = Product.new
      values = {
        "name" => "Item #{x}",
        "price" => rand(500),
        "sku" => 123 * rand(300) * 3,
        "quantity" => rand(30)
      }
      @products << product.setValuesForKeysWithDictionary(values)
      product.addObserver(self, forKeyPath:"quantity", options:NSKeyValueObservingOptionNew, context:nil)
    end
  end
  
  def numberOfRowsInTableView(view)
    @products.size
  end

  def tableView(view, objectValueForTableColumn:column, row:index)
    @products[index].valueForKey(column.identifier)
  end
  
  def tableView(view, setObjectValue:value, forTableColumn:column, row:index)
    @products[index].setValue(value, forKey:column.identifier)
  end
  
  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    if object.is_a?(Product)
      case keyPath
        when "quantity"
          new_value = change.objectForKey(NSKeyValueChangeNewKey)
          if new_value.to_i == 0
            alert = NSAlert.alloc.init
            alert.setMessageText("Product is currently out of stock.")
            alert.beginSheetModalForWindow(@window, modalDelegate:self, didEndSelector:nil, contextInfo:nil)
          end
      end
    end
  end
end
