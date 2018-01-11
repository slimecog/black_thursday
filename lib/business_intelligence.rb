require "memoist"

module BusinessIntelligence
  extend Memoist

  def find_standard_dev_difference_total
    find_items.map do |item_total|
      (item_total - average_items_per_merchant) ** 2
    end.sum.round(2)
  end
  memoize :find_standard_dev_difference_total

  def total_std_dev_sum_minus_one
    find_standard_dev_difference_total / (merchant_list.count - 1)
  end
  memoize :total_std_dev_sum_minus_one

  def standard_dev_plus_average
    average_items_per_merchant_standard_deviation + average_items_per_merchant
  end
  memoize :standard_dev_plus_average

  def find_invoices
    merchant_list.map do |merchant|
      sales_engine.invoices.find_all_by_merchant_id(merchant).count
    end
  end
  memoize :find_invoices

  def invoice_total_minus_average_squared
    find_invoices.reduce(0) { |sum, total|
      sum += (total - average_invoices_per_merchant) ** 2 }
  end
  memoize :invoice_total_minus_average_squared

  def invoice_diff_total_divided
    invoice_total_minus_average_squared / (find_invoices.length - 1)
  end
  memoize :invoice_diff_total_divided

  def invoice_count_two_stnd_deviations_above_mean
    average_invoices_per_merchant + average_invoices_per_merchant_std_dev * 2
  end
  memoize :invoice_count_two_stnd_deviations_above_mean

  def invoice_count_two_stnd_deviations_below_mean
    average_invoices_per_merchant - average_invoices_per_merchant_std_dev * 2
  end
  memoize :invoice_count_two_stnd_deviations_below_mean

  def merchants_invoice_total_list
    Hash[merchant_list.zip(find_invoices)]
  end
  memoize :merchants_invoice_total_list

  def top_merchants
    sum = invoice_count_two_stnd_deviations_above_mean
    merchants_invoice_total_list.find_all { |key, value|
      key if value >= sum }
  end
  memoize :top_merchants

  def top_merchants_by_invoice_count
    top_merchants.map { |merchant|
      sales_engine.merchants.find_by_id(merchant.first) }
  end
  memoize :top_merchants_by_invoice_count

  def bottom_merchants
    sum = invoice_count_two_stnd_deviations_below_mean
    merchants_invoice_total_list.find_all { |key, value|
      key if value <= sum }
  end
  memoize :bottom_merchants

  def bottom_merchants_by_invoice_count
    bottom_merchants.map { |merchant|
      sales_engine.merchants.find_by_id(merchant.first) }
  end
  memoize :bottom_merchants_by_invoice_count

  def created_days_to_week_days
    sales_engine.invoices.invoices.map do |invoice|
      invoice.created_at.strftime("%A")
    end
  end
  memoize :created_days_to_week_days

  def invoice_totals_by_day
    created_days_to_week_days.each_with_object(Hash.new(0)) do |week_day, hash|
      hash[week_day] += 1
    end
  end
  memoize :invoice_totals_by_day

  def invoices_per_day_average
    invoice_totals_by_day.reduce(0) { |sum, (_, value)|
      sum += value } / invoice_totals_by_day.count
  end
  memoize :invoices_per_day_average

  def invoice_totals_minus_avg_sqrd
    invoice_totals_by_day.reduce(0) { |sum, (_, value)|
    sum += (value - invoices_per_day_average) ** 2 }
  end
  memoize :invoice_totals_minus_avg_sqrd

  def invoice_total_diff_sqrd
    invoice_totals_minus_avg_sqrd / (invoice_totals_by_day.count - 1)
  end
  memoize :invoice_total_diff_sqrd

  def weekday_invoice_stnd_deviation
    Math.sqrt(invoice_total_diff_sqrd).round(2)
  end
  memoize :weekday_invoice_stnd_deviation

  def weekday_invoice_stnd_deviation_plus_avg
    weekday_invoice_stnd_deviation + invoices_per_day_average
  end
  memoize :weekday_invoice_stnd_deviation_plus_avg

  def top_days_by_invoice_count
    invoice_totals_by_day.select do |key, value|
      value >= weekday_invoice_stnd_deviation_plus_avg
    end.keys
  end
  memoize :top_days_by_invoice_count

  def all_invoices_by_status(status)
    sales_engine.invoices.find_all_by_status(status)
  end
  memoize :all_invoices_by_status

  def invoice_status(status)
    (all_invoices_by_status(status).length /
    sales_engine.invoices.all.length.to_f * 100).round(2)
  end
  memoize :invoice_status

  def find_all_invoices_by_date(date)
    sales_engine.invoices.find_all_by_created_date(date)
  end
  memoize :find_all_invoices_by_date

  def find_invoice_items_for_invoice_collection(invoices)
    invoices.reduce([]) do |result, invoice|
      result << invoice.invoice_items
    end.flatten
  end
  memoize :find_invoice_items_for_invoice_collection

  def total_invoice_items_price(invoice_items)
    invoice_items.reduce(0) do |total, invoice_item|
      total += (invoice_item.quantity * invoice_item.unit_price)
    end
  end
  memoize :total_invoice_items_price

  def total_revenue_by_date(date)
    invoices = find_all_invoices_by_date(date)
    invoice_items = find_invoice_items_for_invoice_collection(invoices)
    total_invoice_items_price(invoice_items)
  end
  memoize :total_revenue_by_date

  def valid_invoices
    @sales_engine.invoices.all.find_all do |invoice|
      invoice.is_paid_in_full?
    end
  end
  memoize :valid_invoices

  def invalid_invoices
    sales_engine.invoices.all.find_all do |invoice|
      invoice.is_paid_in_full? == false
    end
  end
  memoize :invalid_invoices

  def valid_invoices_grouped_by_merchant
    valid_invoices.group_by do |invoice|
      invoice.merchant_id
    end
  end
  memoize :valid_invoices_grouped_by_merchant

  def invoice_totals(invoices)
    invoices.reduce(0) do |sum, invoice|
      sum += invoice.total
    end
  end
  memoize :invoice_totals
end
