require "memoist"

module MerchantAnalytics
  extend Memoist

  def average_items_per_merchant
    merchants = sales_engine.merchants.all.length
    items = sales_engine.items.all.length
    (items.to_f / merchants.to_f).round(2)
  end
  memoize :average_items_per_merchant

  def merchant_list
    sales_engine.merchants.merchants.map { |merchant| merchant.id }
  end
  memoize :merchant_list

  def average_items_per_merchant_standard_deviation
    (Math.sqrt(total_std_dev_sum_minus_one).round(2))
  end
  memoize :average_items_per_merchant_standard_deviation

  def merchants_by_item_count
    Hash[merchant_list.zip(find_items)]
  end
  memoize :merchants_by_item_count

  def merchants_by_items_in_stock
    merchants_by_item_count.find_all do |_, value|
      value >= standard_dev_plus_average
    end
  end
  memoize :merchants_by_items_in_stock

  def merchants_with_high_item_count
    merchants_by_items_in_stock.map do |merchant|
      sales_engine.merchants.find_by_id(merchant[0])
    end
  end
  memoize :merchants_with_high_item_count

  def all_merchant_items(merchant_id)
    sales_engine.items.find_all_by_merchant_id(merchant_id)
  end
  memoize :all_merchant_items

  def average_item_price_for_merchant(merchant_id)
    list = all_merchant_items(merchant_id)
    list.reduce(0) do |sum, item|
      sum + item.unit_price / list.count
    end.round(2)
  end
  memoize :average_item_price_for_merchant

  def average_average_price_per_merchant
    (merchant_list.reduce(0) { |sum, merchant|
      sum + average_item_price_for_merchant(merchant)
      } / merchant_list.count).round(2)
  end
  memoize :average_average_price_per_merchant

  def average_invoices_per_merchant
    (find_invoices.reduce(0) { |sum, totals|
      sum += totals } / find_invoices.count.to_f).round(2)
  end
  memoize :average_invoices_per_merchant

  def average_invoices_per_merchant_std_dev
    Math.sqrt(invoice_diff_total_divided).round(2)
  end
  memoize :average_invoices_per_merchant_std_dev

  def average_invoices_per_merchant_standard_deviation
    average_invoices_per_merchant_std_dev
  end

  def missing_merchants
    sales_engine.merchants.all.find_all do |merchant|
      merchant.valid_invoices.count == 0
    end
  end
  memoize :missing_merchants

  def total_of_invoices_per_merchant
    valid_invoices_grouped_by_merchant.reduce({}) do |result, pair|
      result.update pair.first => (invoice_totals(pair.last))
    end
  end
  memoize :total_of_invoices_per_merchant

  def fill_missing_merchants
    merchants_by_rev = total_of_invoices_per_merchant
    missing_merchants.each do |merchant|
      merchants_by_rev[merchant.id] = 0
    end
    merchants_by_rev
  end
  memoize :fill_missing_merchants

  def merchants_by_revenue
    fill_missing_merchants.sort_by do |_, value|
      value
    end.reverse
  end
  memoize :merchants_by_revenue

  def merchants_ranked_by_revenue
    merchants_by_revenue.map do |merchant_rev|
      @sales_engine.merchants.find_by_id(merchant_rev.first)
    end
  end
  memoize :merchants_ranked_by_revenue

  def top_revenue_earners(count = 20)
    merchants = merchants_ranked_by_revenue
    merchants.first(count)
  end
  memoize :top_revenue_earners

  def merchants_with_invalid_invoices
    invalid_invoices.map do |invoice|
      invoice.merchant_id
    end.uniq
  end
  memoize :merchants_with_invalid_invoices

  def merchants_with_pending_invoices
    merchants_with_invalid_invoices.map do |merchant_id|
      sales_engine.merchants.find_by_id(merchant_id)
    end
  end
  memoize :merchants_with_pending_invoices

  def merchants_with_only_one_item
    sales_engine.merchants.all.find_all do |merchant|
      merchant.items.count == 1
    end
  end
  memoize :merchants_with_only_one_item

  def merchants_with_only_one_item_registered_in_month(month)
    merchants_with_only_one_item.find_all do |merchant|
      merchant.created_at.strftime("%B") == month
    end
  end
  memoize :merchants_with_only_one_item_registered_in_month

  def revenue_by_merchant(merchant_id)
    invoice_totals(sales_engine.merchants.find_by_id(merchant_id).invoices)
  end
  memoize :revenue_by_merchant

  def valid_invoices_of_merchant(merchant_id)
    valid_invoices.find_all do |invoice|
      invoice.merchant_id == merchant_id
    end.flatten
  end
  memoize :valid_invoices_of_merchant

  def invoice_items_of_merchant(merchant_id)
    valid_invoices_of_merchant(merchant_id).map do |invoice|
      invoice.invoice_items
    end.flatten
  end
  memoize :invoice_items_of_merchant

  def item_ids_of_merchant(merchant_id)
    invoice_items_of_merchant(merchant_id).reduce({}) do |result, invoice_item|
      result[invoice_item.item_id] = invoice_item.quantity
      result
    end
  end
  memoize :item_ids_of_merchant

  def best_item_for_merchant(id)
    @sales_engine.items.find_by_id(top_invoice_item_revenue(id).first.item_id)
  end
  memoize :best_item_for_merchant
end
