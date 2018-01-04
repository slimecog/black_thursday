require "bigdecimal"
require "csv"
require "time"
require_relative "sales_engine"


  se = SalesEngine.from_csv({
    :items         => "./test/fixtures/items_truncated.csv",
    :merchants     => "./test/fixtures/merchants_truncated.csv",
    :invoices      => "./test/fixtures/invoices_truncated.csv",
    :invoice_items => "./test/fixtures/invoice_items_truncated.csv",
    :transactions  => "./test/fixtures/transactions_truncated.csv",
    :customers     => "./test/fixtures/customers_truncated.csv"
  })



item =  se.items.find_merchant(12334105)
puts item
