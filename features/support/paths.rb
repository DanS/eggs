module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the home\s?page/
      '/'


    when /the delivery "(.*)"$/i
      delivery_path(Delivery.find_by_name($1), :farm_id => @farm.id)  
      
    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      "/#{page_name}"   

#    else
#      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
#        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
