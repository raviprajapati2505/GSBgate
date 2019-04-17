module DatePlucker
  extend ActiveSupport::Concern

  module ClassMethods
    def pluck_date_field_by_year(date_field, sort_order = :asc)
      self.pluck_date_field_by_date_parts(date_field, %w(year), sort_order)
    end

    def pluck_date_field_by_year_month(date_field, sort_order = :asc)
      self.pluck_date_field_by_date_parts(date_field, %w(year month), sort_order)
    end

    def pluck_date_field_by_year_month_day(date_field, sort_order = :asc)
      self.pluck_date_field_by_date_parts(date_field, %w(year month day), sort_order)
    end

    def pluck_date_field_by_year_month_day_hour(date_field, sort_order = :asc)
      self.pluck_date_field_by_date_parts(date_field, %w(year month day hour), sort_order)
    end

    def pluck_date_field_by_year_month_day_hour_minute(date_field, sort_order = :asc)
      self.pluck_date_field_by_date_parts(date_field, %w(year month day hour minute), sort_order)
    end

    def pluck_date_field_by_date_parts(date_field, date_parts, sort_order = :asc)
      date_field_parts_extract = date_parts.map{|part| "extract(#{part} from #{self.table_name}.#{date_field})"}
      date_field_parts_extract_order = date_field_parts_extract.map{|part| "#{part} #{sort_order}"}
      date_field_parts_name = "#{date_field}_by_#{date_parts.join('_')}"
      self.order(Arel.sql(date_field_parts_extract_order.join(', ')))
          .group(Arel.sql(date_field_parts_extract.join(', ')))
          .pluck(Arel.sql(date_field_parts_extract.join(" || '/' || ") + " as #{date_field_parts_name}"))
    end
  end

end
