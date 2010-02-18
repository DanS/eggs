class Importer

  def initialize(dir = "#{RAILS_ROOT}/db/import")
    @dir = dir
  end

  def pickups
    imports.collect(&:pickups).flatten
  end

  def import!
    imports.collect do |import|
      import.import!
    end
  end

  def imports
    Dir["#{@dir}/*.csv"].collect {|file|  PickupImport.new file}
  end

end

class PickupImport
  attr_reader :file, :rows, :columns, :farm

  def initialize(file)
    @file = file
    @rows = CSV.read file
    @farm = Farm.find_by_name('Soul Food Farm') || raise("Unable to find farm with name 'Soul Food Farm'")
    @columns = read_headers @rows[0]
  end

  def import!
    pickups.each {|pickup| pickup.save!}
    members.each {|member| member.save(false)}
    orders.each {|order| order.save(false)}
  end

  def pickup_date
    file =~ /((\d+)-(\d+))/
    Date.civil 2010, $2.to_i, $3.to_i
  end

  def pickups
    return @pickups if @pickups

    @pickups = location_names.collect do |location|
      pickup = Pickup.new(:name => location, :date => pickup_date, :status => 'archived', :farm => @farm)
      products.each do |product|
        pickup.stock_items << StockItem.new(:product => product)
      end
      pickup
    end
    @pickups
  end

  def normalize_product_header(header)
    header.strip!
    header.gsub! 'REG ', 'REGULAR '
    header.gsub! 'LG ', 'LARGE '
    header.gsub! 'Chicken XXL ', 'Chicken, XXL '
    header.gsub! 'New! ', ''
    header.gsub! ' SALE', ''
    header.gsub! 'pound', 'lb'
    header.gsub! ' ml', 'ml'
    header.gsub! '.5/', ".50/"
    header.gsub! ' .5', " 0.5"
    header.gsub! 'oil ', "oil, "
  end

  def headers
    @rows[0]
  end

  def read_headers(row = @rows[0])
    columns = {
            :timestamp => 0,
            :last_name => 1,
            :first_name => 2,
            :email => 3,
            :phone => 4,
            :location => 7,
            :products => {} }

    row.each_with_index do |header, index|
      next unless header
      if header =~ /(\$)/
        normalize_product_header(header)
        columns[:products][find_or_new_product(header)] = index
      end
    end

    columns
  end

  def location_names
    @rows[1..-1].collect {|row| row[7]}.uniq.reject {|name| name.nil? || name == '0'}
  end

  def find_or_new_product(header)
    if header =~ /^(.+?) ?\((.+)\)/
      name = $1
      description = $2
    else
      name = header
      description = nil
    end
    product = Product.find_by_name_and_farm_id name, @farm
    if !product
      product = Product.new(:name => name, :description => description, :farm => @farm)
      product.save!
    end
    product
  end

  def products
    @products ||= @columns[:products].sort {|a,b| a[1] <=> b[1]}.collect{|pair| pair[0]}
  end

  def members
    return @members if @members

    @members = []
    @rows[1..-1].each do |row|
      first_name = row[2]
      last_name = row[1]
      next unless first_name && last_name
      
      first_name = first_name.titleize
      last_name = last_name.titleize
      next if @members.find {|item| item.first_name == first_name && item.last_name == last_name}

      # Find or create new Member
      member = Member.find_by_first_name_and_last_name first_name, last_name
      if !member
        member = Member.new :first_name => first_name, :last_name => last_name,
                            :email_address => row[3], :phone_number => row[4]
      end
      if !member.subscriptions.detect {|item| item.farm == @farm}
        member.subscriptions << Subscription.new(:farm => @farm)
      end

      @members << member
    end
    @members
  end

  def orders
    @orders ||= @rows[1..-1].collect do |row|
      first_name = row[columns[:first_name]]
      last_name = row[columns[:last_name]]
      next unless first_name && last_name

      first_name = first_name.titleize
      last_name = last_name.titleize
      member = members.find {|item| item.first_name == first_name && item.last_name == last_name}

      # Create Order
      pickup = pickups.find {|item| item.name == row[columns[:location]]}
      begin
        timestamp = DateTime.parse(row[columns[:timestamp]])
      rescue Exception => e
        timestamp = pickup.date # If timestamp is 'manual' or nil use pickup date
      end

      order = Order.new :pickup => pickup, :member => member, :created_at => timestamp
      pickup.stock_items.each do |stock_item|
        order.order_items << OrderItem.new(:stock_item => stock_item, :quantity => row[columns[:products][stock_item.product]] || 0)
      end

      order
    end.reject {|item| item.nil?}
  end

end