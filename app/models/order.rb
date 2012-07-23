class Order < ActiveRecord::Base
  # TODO: get methods from include OrderMaker

  attr_protected

  has_many :line_items, :dependent => :destroy
  has_one :shipping_address, :dependent => :destroy
  belongs_to :setting

  accepts_nested_attributes_for :shipping_address
  accepts_nested_attributes_for :line_items

  def self.create_order(params,setting)
    options = order_options(params)
    options['shipping_address_attributes'] = get_shipping_attributes(params)
    options['line_items_attributes'] = get_line_items_attributes(params)
    options['setting_id'] = setting.id
    order = create(options)
  end

  def self.order_options(params)
    options = params.slice(*Order.column_names)
    options['shopify_order_id'] = params['id']
    options
  end

  def self.get_shipping_attributes(params)
    options = params['shipping_address'].slice(*ShippingAddress.column_names)
    options.delete('id')
    options
  end

  def self.get_line_items_attributes(params)
    params['line_items'].map do |item|
      options = item.slice(*LineItem.column_names)
      options['line_item_id'] = options.delete('id')
      options
    end
  end

end