module ShopApi
  Catalog = {'Iphone 6' =>'https://www.ulmart.ru/goods/957790',
             'Nike Md Runner' => 'https://www.ulmart.ru/goods/3659449'}

  def self.random
    %w(https://www.ulmart.ru/goods/957790 https://www.ulmart.ru/goods/3659449).sample
  end
end