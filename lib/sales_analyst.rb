require 'memoist'
require_relative "sales_engine"
require_relative "business_intelligence"
require_relative "merchant_analytics"
require_relative "item_analytics"

class SalesAnalyst
  include BusinessIntelligence
  include MerchantAnalytics
  include ItemAnalytics

  extend Memoist

  attr_reader :sales_engine

  def initialize(sales_engine)
    @sales_engine = sales_engine
  end
end
