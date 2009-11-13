require 'rubygems'
require 'faster_csv'
require 'iconv'

module TsvExporter
  BOM = "\377\376" #Byte Order Mark

  def to_tsv(attributes, date_format = :short)
    content = FasterCSV.generate(:col_sep => "\t") do |tsv|

      # header
      tsv << attributes
      if self.size > 0

        each do |elem|
          row = []
          couples = elem.attributes.symbolize_keys
          attributes.each do |atr|
            value = get_atr_value(elem, atr, couples)
            row << value
          end
          tsv << row
        end
      end
    end

    content = BOM + Iconv.conv("utf-16le", "utf-8", content)

  end
  
  private
  
  def get_atr_value(elem, atr, couples, format = nil)
    if atr.instance_of?(String) && atr.include?('.')
      value = get_nested_atr_value(elem, atr.split('.').reverse) 
    else
      value = couples[atr]
      value = elem.send(atr.to_sym) if value.blank? && elem.respond_to?(atr) # Required for virtual attributes
      begin
        value = I18n.localize(value, :format => format)
      rescue
        "Is not a Date! :P"
      end
    end
    value
  end
  
  def get_nested_atr_value(elem, hierarchy)
    return nil if hierarchy.size == 0
    atr = hierarchy.pop
    raise ArgumentError, "#{atr} doesn't exist on #{elem.inspect}" unless elem.respond_to?(atr)
    nested_elem = elem.send(atr)
    return "" if nested_elem.nil?
    value = get_nested_atr_value(nested_elem, hierarchy)
    value.nil? ? nested_elem : value
  end
end

