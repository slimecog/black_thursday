require_relative "test_helper"
require_relative "../lib/merchant_repo"
require_relative "../lib/sales_engine"

class MerchantRepoTest < Minitest::Test

  def test_it_exists
    se = SalesEngine.from_csv({
      :items         => "./test/fixtures/items_truncated.csv",
      :merchants     => "./test/fixtures/merchants_truncated.csv",
      :invoices      => "./test/fixtures/invoices_truncated.csv",
      :invoice_items => "./test/fixtures/invoice_items_truncated.csv",
      :transactions  => "./test/fixtures/transactions_truncated.csv",
      :customers     => "./test/fixtures/customers_truncated.csv"
    })

    mr = MerchantRepo.new(se, "./test/fixtures/merchants_truncated.csv")

    assert_instance_of MerchantRepo, mr
    assert_equal 12334105, mr.merchants.first.id
    assert_equal "Shopin1901", mr.merchants.first.name
    assert_equal 16, mr.merchants.count
  end

  def test_all_returns_all_merchants
    se = SalesEngine.from_csv({
      :items         => "./test/fixtures/items_truncated.csv",
      :merchants     => "./test/fixtures/merchants_truncated.csv",
      :invoices      => "./test/fixtures/invoices_truncated.csv",
      :invoice_items => "./test/fixtures/invoice_items_truncated.csv",
      :transactions  => "./test/fixtures/transactions_truncated.csv",
      :customers     => "./test/fixtures/customers_truncated.csv"
    })

    mr = MerchantRepo.new(se, "./test/fixtures/merchants_truncated.csv")

    assert_equal 16, mr.all.count
    assert_instance_of Merchant, mr.merchants.first
  end

  def test_find_by_id_finds_merchant_by_id
    se = SalesEngine.from_csv({
      :items         => "./test/fixtures/items_truncated.csv",
      :merchants     => "./test/fixtures/merchants_truncated.csv",
      :invoices      => "./test/fixtures/invoices_truncated.csv",
      :invoice_items => "./test/fixtures/invoice_items_truncated.csv",
      :transactions  => "./test/fixtures/transactions_truncated.csv",
      :customers     => "./test/fixtures/customers_truncated.csv"
    })

    mr = MerchantRepo.new(se, "./test/fixtures/merchants_truncated.csv")
    expected = mr.find_by_id(12334105)

    assert_equal 12334105, expected.id
    assert_equal "Shopin1901", expected.name

    expected = mr.find_by_id(12334144)

    assert_equal 12334144, expected.id
    assert_equal "Urcase17", expected.name
  end

  def test_find_by_name_finds_merchant_by_name
    se = SalesEngine.from_csv({
      :items         => "./test/fixtures/items_truncated.csv",
      :merchants     => "./test/fixtures/merchants_truncated.csv",
      :invoices      => "./test/fixtures/invoices_truncated.csv",
      :invoice_items => "./test/fixtures/invoice_items_truncated.csv",
      :transactions  => "./test/fixtures/transactions_truncated.csv",
      :customers     => "./test/fixtures/customers_truncated.csv"
    })

    mr = MerchantRepo.new(se, "./test/fixtures/merchants_truncated.csv")
    expected = mr.find_by_name("Shopin1901")

    assert_equal "Shopin1901", expected.name
    assert_equal 12334105, expected.id

    expected = mr.find_by_name("Urcase17")

    assert_equal "Urcase17", expected.name
    assert_equal 12334144, expected.id
  end

  def test_find_all_by_name_finds_all_merchants_by_name
    se = SalesEngine.from_csv({
      :items         => "./test/fixtures/items_truncated.csv",
      :merchants     => "./test/fixtures/merchants_truncated.csv",
      :invoices      => "./test/fixtures/invoices_truncated.csv",
      :invoice_items => "./test/fixtures/invoice_items_truncated.csv",
      :transactions  => "./test/fixtures/transactions_truncated.csv",
      :customers     => "./test/fixtures/customers_truncated.csv"
    })

    mr = MerchantRepo.new(se, "./test/fixtures/merchants_truncated.csv")
    expected = mr.find_all_by_name("shop")

    assert_equal 1, expected.count
    expected.each do |merchant|
      assert_instance_of Merchant, merchant
    end
    assert_equal "Shopin1901", expected.first.name
  end

  def test_find_items_returns_items_sold_by_merchant_id
    se = SalesEngine.from_csv({
      :items         => "./test/fixtures/items_truncated.csv",
      :merchants     => "./test/fixtures/merchants_truncated.csv",
      :invoices      => "./test/fixtures/invoices_truncated.csv",
      :invoice_items => "./test/fixtures/invoice_items_truncated.csv",
      :transactions  => "./test/fixtures/transactions_truncated.csv",
      :customers     => "./test/fixtures/customers_truncated.csv"
    })

    mr = MerchantRepo.new(se, "./test/fixtures/merchants_truncated.csv")
    expected = mr.find_items(12334105)

    expected.each do |item|
      assert_instance_of Item, item
      assert_equal 12334105, item.merchant_id
    end
    assert_equal 3, expected.count
  end

  def test_inspect_shortens_output
    se = SalesEngine.from_csv({
      :items         => "./test/fixtures/items_truncated.csv",
      :merchants     => "./test/fixtures/merchants_truncated.csv",
      :invoices      => "./test/fixtures/invoices_truncated.csv",
      :invoice_items => "./test/fixtures/invoice_items_truncated.csv",
      :transactions  => "./test/fixtures/transactions_truncated.csv",
      :customers     => "./test/fixtures/customers_truncated.csv"
    })

    mr = MerchantRepo.new(se, "./test/fixtures/merchants_truncated.csv")

    assert_equal "#<MerchantRepo 16 rows>", mr.inspect
  end

  def test_find_invoices_by_merchant_id_finds_invoices_by_merchant_id
    se = SalesEngine.from_csv({
      :items         => "./test/fixtures/items_truncated.csv",
      :merchants     => "./test/fixtures/merchants_truncated.csv",
      :invoices      => "./test/fixtures/invoices_truncated.csv",
      :invoice_items => "./test/fixtures/invoice_items_truncated.csv",
      :transactions  => "./test/fixtures/transactions_truncated.csv",
      :customers     => "./test/fixtures/customers_truncated.csv"
    })

    mr = MerchantRepo.new(se, "./test/fixtures/merchants_truncated.csv")

    assert_instance_of Array, mr.find_invoices_by_merchant_id(12334105)
    assert_equal 10, mr.find_invoices_by_merchant_id(12334105).count
    mr.find_invoices_by_merchant_id(12334105).each do |invoice|
      assert_instance_of Invoice, invoice
    end
  end

  def test_find_all_by_id_finds_all_by_id
    se = SalesEngine.from_csv({
      :items         => "./test/fixtures/items_truncated.csv",
      :merchants     => "./test/fixtures/merchants_truncated.csv",
      :invoices      => "./test/fixtures/invoices_truncated.csv",
      :invoice_items => "./test/fixtures/invoice_items_truncated.csv",
      :transactions  => "./test/fixtures/transactions_truncated.csv",
      :customers     => "./test/fixtures/customers_truncated.csv"
    })

    mr = MerchantRepo.new(se, "./test/fixtures/merchants_truncated.csv")

    assert_instance_of Array, mr.find_all_by_id(12334105)
    mr.find_all_by_id(12334105).each do |merchant|
      assert_instance_of Merchant, merchant
      assert_equal 12334105, merchant.id
    end
  end

  def test_find_customer_by_customer_id_finds_customer_by_customer_id
    se = SalesEngine.from_csv({
      :items         => "./test/fixtures/items_truncated.csv",
      :merchants     => "./test/fixtures/merchants_truncated.csv",
      :invoices      => "./test/fixtures/invoices_truncated.csv",
      :invoice_items => "./test/fixtures/invoice_items_truncated.csv",
      :transactions  => "./test/fixtures/transactions_truncated.csv",
      :customers     => "./test/fixtures/customers_truncated.csv"
    })

    mr = MerchantRepo.new(se, "./test/fixtures/merchants_truncated.csv")

    assert_instance_of Customer, mr.find_customer_by_customer_id(1)
    assert_equal 1, mr.find_customer_by_customer_id(1).id
  end
end
