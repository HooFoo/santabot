class Morpher

  def initialize(phrase)
    begin
    client = Savon.client do |globals|
      globals.wsdl 'http://morpher.ru/WebService.asmx?WSDL'
      globals.soap_version 2
      globals.soap_header header
    end

    response = client.call(:get_xml, message: {s: phrase}, :attributes => {:xmlns => 'http://morpher.ru/'})
    @data = response.to_array(:get_xml_response, :get_xml_result).first
    rescue Exception => ex
      LOG.error "Morpher error: #{ex.message}"
      @data = {
          И: phrase,
          Р: phrase,
          Д: phrase,
          множественное: {
          }
      }
    end
  end

  def singular(padeg)
    @data[padeg.to_sym]
  end

  def plural(padeg)
    @data[:множественное][padeg.to_sym]
  end

  private

  def header
    {
        'Credentials' => {
            'Username' => 'test',
            'Password' => 'test'
        },
        :attributes! => {'Credentials' => {:xmlns => 'http://morpher.ru/'}}
    }
  end
end