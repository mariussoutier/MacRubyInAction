require "json"

class AppDelegate
  attr_accessor :window, :button
  attr_reader :address_book, :picker
  attr_accessor :contact_name, :contact_image, :contact_twitter
  
  def applicationDidFinishLaunching(a_notification)
    @address_book = ABAddressBook.sharedAddressBook
    check_me
  end
  
  def windowWillClose(sender)
    exit
  end
  
  def alert(title="Alert", message="Something went wrong: ")
    NSAlert.alertWithMessageText(title, defaultButton: "OK", alternateButton: nil, otherButton: nil, informativeTextWithFormat: message).runModal
  end
  
  def check_me
    unless @address_book.me
      alert "Address Book Problem", "You need to mark a contact in the Address Book as yours"
    end
    #if @address_book.me.nickname.blank?
    if @address_book.me.nickname.nil? || @address_book.me.nickname == ""
      alert "Address Book Problem", "You need to set a Twitter nickname"
    end
  end
  
  def create_twitter_group
    twitter_group = @address_book.groups.find{|g| g.name == "Twitter"}
    if twitter_group
      twitter_group
    else
      group = ABGroup.alloc.init
      group.name = "Twitter"
      @address_book << group
      @address_book.save
      twitter_group
    end
  end
  
  def import_twitter_contacts(sender)
    make_user_wait
    
    me = @address_book.me
    twitter_group = create_twitter_group
    puts "Importing from Twitter"
    
    Thread.new{
      fetch_paginated_friends(me.nickname) do |followers|
        add_twitter_followers(followers, twitter_group)
      end
      @address_book.save
      puts "Import done"
      display_contacts
    }
  end
  
  def fetch_paginated_friends(account, &block)
    cursor = -1
    until cursor == 0
      # This is the correct endpoint, the book seems to be wrong
      url_string = "https://api.twitter.com/1/statuses/friends/#{account}.json?cursor=#{cursor}"
      url = NSURL.alloc.initWithString(url_string)
      json_friends = NSMutableString.alloc.initWithContentsOfURL(url, encoding:NSUTF8StringEncoding, error:nil)
      friend_results = JSON.parse(json_friends)
      block.call(friend_results["users"])
      cursor = friend_results["next_cursor"]
    end
  end
  
  def add_twitter_followers(followers, group)
    followers.each do |friend|
      if friend["screen_name"]
        puts "Importing #{friend['screen_name']}"
        query = ABPerson.searchElementForProperty(KABNicknameProperty, label:nil, key:nil, value:friend["screen_name"], comparison:KABEqual)
        results = @address_book.recordsMatchingSearchElement(query)
        contact = results.first || ABPerson.alloc.initWithAddressBook(@address_book)
      else
        contact = ABPerson.alloc.initWithAddressBook(@address_book)
      end
      
      first_name, last_name = friend["name"].split(" ")
      contact.firstName = first_name if first_name
      contact.lastName = last_name if last_name
      contact.nickname = friend["screen_name"]
      urls = {"Twitter" => "http://twitter.com/#{friend['screen_name']}"}
      urls[KABHomePageLabel] = friend["url"] unless friend["url"].blank?
      contact.URLs = urls.to_ab_multivalue
      contact.imageData = NSData.dataWithContentsOfURL(friend["profile_image_url"].to_nsurl)
      
      notes = []
      notes << friend["description"] unless friend["description"].blank?
      notes << "Location: #{friend['location']}" unless friend['location'].blank?
      contact.note = notes.join("\n")
      group << contact
    end
  end
  
  def make_user_wait
    @button.hidden = true
    if @spinner
      @spinner.hidden = false
    else
      x = window.frame.size.width / 2 - 32 / 2
      y = window.frame.size.height / 2 - 32 / 2
      @spinner = NSProgressIndicator.alloc.initWithFrame([x, y, 32, 32])
      @spinner.style = NSProgressIndicatorSpinningStyle
      @window.contentView.addSubview(@spinner)
    end
    @spinner.startAnimation(nil)
  end
  
  def display_contacts
    @spinner.stopAnimation(nil)
    @spinner.hidden = true
    frame = [0, 0, @window.frame.size.width, @window.frame.size.height - 120]
    @picker = ABPeoplePickerView.alloc.initWithFrame(frame)
    
    center = NSNotificationCenter.defaultCenter
    center.addObserver(self, selector:"record_changed:", name:ABPeoplePickerNameSelectionDidChangeNotification, object:@picker)
    @picker.allowMultipleSelection = false
    @picker.addProperty KABNicknameProperty
    @contact_image.hidden = false
    @contact_name.hidden = false
    @contact_twitter.hidden = false
    
    @window.contentView.addSubview(@picker)
  end
  
  def record_changed(notification)
    selected = @picker.selectedRecords || []
    if selected.empty?
      @contact_image.image = nil
      @contact_name.stringValue = ""
      @contact_twitter.stringValue = ""
    else
      person = selected.first
      @contact_image.image = NSImage.alloc.initWithData(person.imageData)
      @contact_name.stringValue = "#{person.firstName} #{person.lastName}"
      @contact_twitter.stringValue = person.nickname || ""
    end
  end
end
