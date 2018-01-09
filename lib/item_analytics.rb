require "memoist"

module ItemAnalytics
  extend Memoist

  def find_items
    merchant_list.map do |merchant|
      sales_engine.items.find_all_by_merchant_id(merchant).count
    end
  end
  memoize :find_items

  def average_unit_price
    (sales_engine.items.all.reduce(0) { |sum, item|
      sum + item.unit_price } / sales_engine.items.all.count).round(2).to_f
  end
  memoize :average_unit_price

  def unit_price_and_average_sqr_sum
    sales_engine.items.all.reduce(0) { |sum, item|
      sum += (item.unit_price - average_unit_price) ** 2 }
  end
  memoize :unit_price_and_average_sqr_sum

  def unit_price_std_dev_sum_minus_one
    unit_price_and_average_sqr_sum / (sales_engine.items.all.count - 1)
  end
  memoize :unit_price_std_dev_sum_minus_one

  def unit_price_stnd_dev
    Math.sqrt(unit_price_std_dev_sum_minus_one).round(2)
  end
  memoize :unit_price_stnd_dev

  def golden_items_stnd_dev
    average_unit_price + (unit_price_stnd_dev * 2)
  end
  memoize :golden_items_stnd_dev

  def golden_items
    sales_engine.items.items.find_all do |item|
      item.unit_price >= golden_items_stnd_dev
    end
  end
  memoize :golden_items

  def most_frequent_item_on_list(id)
    max = item_ids_of_merchant(id).values.max
    item_ids_of_merchant(id).select { |key, value|
        value == max }.to_a
  end
  memoize :most_frequent_item_on_list

  def item_ids_of_most_sold_items(id)
    most_frequent_item_on_list(id).map do |value_pair|
      value_pair.first
    end
  end
  memoize :item_ids_of_most_sold_items

  def most_sold_item_for_merchant(id)
    item_ids_of_most_sold_items(id).map do |item_id|
      sales_engine.items.find_by_id(item_id)
    end
  end
  memoize :most_sold_item_for_merchant

  def inv_item_freq_of_merchant(id)
    invoice_items_of_merchant(id).reduce(Hash.new(0)) do |result, item|
      result[item] += 1
      result
    end
  end
  memoize :inv_item_freq_of_merchant

  def total_of_invoice_item_items_sold(id)
    inv_item_freq_of_merchant(id).reduce(Hash.new(0)) do |result, (key, value)|
      result[key] = (key.unit_price * key.quantity * value)
      result
    end
  end
  memoize :total_of_invoice_item_items_sold

  def top_invoice_item_revenue(id)
    total_of_invoice_item_items_sold(id).max_by do |_, value|
       value
     end
  end
  memoize :top_invoice_item_revenue
end
