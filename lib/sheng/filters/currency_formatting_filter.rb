require_relative "base"

module Sheng
  module Filters
    class CurrencyFormattingFilter < Base
      implements :currency

      def filter(value)
        return value unless Sheng::Support.is_numeric?(value)
        value = Sheng::Support.typecast_numeric(value)

        integer, fractional = ("%00.2f" % value).split(".")

        if integer.length > 3
          insert_commas(integer)
        end

        "#{arguments.first}#{integer}.#{fractional}"
      end

      private

      def insert_commas(integer)
        integer.reverse!.gsub!(/(\d{3})(?=\d)/, '\\1,').reverse!
      end
    end
  end
end
