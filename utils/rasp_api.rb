module ShopApi
  Catalog = {'Iphone 6' =>'https://www.ulmart.ru/goods/957790',
             'Nike Md Runner' => 'https://www.ulmart.ru/goods/3659449'}

  def self.get_random_item_name
    Catalog.keys.sample
  end

  def self.item_link name
    Catalog[name]
  end
end