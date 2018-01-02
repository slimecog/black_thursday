require_relative "merchant_repo"
require_relative "item_repo"
class SalesEngine
  attr_reader :merchants,
              :items

  def self.from_csv(directory)
    SalesEngine.new(directory)
  end

  def initialize(directory)
    @merchants = MerchantRepo.new(self, directory[:merchants])
    @items     = ItemRepo.new(self, directory[:items])
  end


end
