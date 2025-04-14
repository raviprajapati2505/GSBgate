module Effective
  module Datatables
    class Users < Effective::Datatable
      include ActionView::Helpers::TranslationHelper

      def get_access_licences
        access_licences = Licence.select(:display_name, :display_weight).order(:display_weight).distinct.map { |licence| [licence.display_name, licence.display_name.sub(',', '+')] }.uniq
        access_licences.push(["No licences","No licences"])
        return access_licences
      end

      datatable do
        col :name do |rec|          
          link_to_if(current_user.is_credentials_admin?,
            rec.name,
            dashboard_user_path(rec.id)
          )
        end
        col :username
        col :email

        col :role, as: :integer, search: { as: :select, collection: Proc.new { User.roles.map { |k, v| @roles.include?(v) ? [t(k, scope: 'activerecord.attributes.user.roles'), v] : [] }.reject(&:empty?) } } do |rec|
          t(rec.role, scope: 'activerecord.attributes.user.roles') unless rec.role.nil?
        end

        col :gord_employee, label: 'GORD Employee'

        col :licences_name, col_class: 'multiple-select', sql_column: "ARRAY_TO_STRING(ARRAY(SELECT licences.title FROM licences INNER JOIN access_licences ON access_licences.user_id = users.id WHERE access_licences.licence_id = licences.id), '|||')", label: 'Licences', search: { as: :select, collection: Proc.new { get_access_licences } } do |rec|
          ERB::Util.html_escape(rec.licences_name).split('|||').sort.join(', <br/>') unless rec.licences_name.nil?

        end.search do |collection, terms, column, index|
          terms_array = terms.split(',').map { |ele| ele.gsub('+', ',') || ele }
          collection_set = collection
          results_array = []
          recent_certificates_ids = []
          users_id_with_no_licences = []

          unless (collection.class == Array || terms_array.include?(nil))
            if (terms_array.include?("No licences"))
              terms_array.delete("No licences")

              users_id_with_licences = User.joins(:access_licences).ids.uniq
              users_id_with_no_licences = User.where('id NOT IN (?)', users_id_with_licences).ids.uniq
            end

            unless terms_array.blank?
              results_array = collection_set.where("ARRAY_TO_STRING(ARRAY(SELECT licences.display_name FROM licences INNER JOIN access_licences ON access_licences.user_id = users.id WHERE access_licences.licence_id = licences.id), '|||') ILIKE ANY ( array[:terms_array] )", terms_array: terms_array.map! {|val| "%#{val}%" }).pluck("users.id")
            end

            all_user_ids = users_id_with_no_licences.push(*results_array).uniq
          
            collection.where("users.id IN (?)", all_user_ids) rescue collection
          else
            collection
          end
        end

        col :last_sign_in_at, label: 'Last Sign in at', as: :datetime, visible: false, search: { as: :select, collection: Proc.new { User.pluck_date_field_by_year_month_day(:last_sign_in_at, :desc).compact } } do |rec|
          localize(rec.last_sign_in_at.in_time_zone) unless rec.last_sign_in_at.nil?
        end

        col :sign_in_count, label: 'Sign in Count', as: :integer, visible: false, search: :string

        if User.current.can?(:masquerade, current_user)
          col :id, label: 'Masquerade', search: false, sort: false do |rec|
            btn_link_to(masquerade_users_path(rec.id), icon: 'user-secret', size: 'small', tooltip: 'Masquerade')
          end
        end
        if User.current.can?(:edit, current_user)
          col :active, label: 'Active?', search: { as: :boolean } do |rec|
            value = rec.active? ? 'checked' : ''
            "<input class='user-status' type='checkbox' #{value} data-user-id=#{rec.id}>".html_safe
          end
          col :edit, sql_column: 'users.id', label: 'Edit', search: false, sort: false do |rec|
            btn_link_to(user_path(rec.id), icon: 'edit', size: 'small', tooltip: 'Edit')
          end
        end

        if User.current.can?(:destroy, current_user)
          col :delete, sql_column: 'users.id', label: 'Delete', search: false, sort: false do |rec|
            btn_link_to(user_path(rec.id), method: :delete, data: { confirm: 'All data of this user will be deleted permanently, Are you sure you want to delete this User ?' }, style: 'danger', icon: 'trash', size: 'small', tooltip: 'Delete')
          end
        end
      end

      collection do
        @roles = 
          case attributes.dig(:type)
            when 'individuals'
              [User.roles['default_role']]
            when 'corporates'
              [User.roles['corporate']]
            when 'admins'
              User.roles.values - [User.roles['default_role'], User.roles['corporate']]
            else
              User.roles.values
          end

        User
          .select('users.id',
                  'users.username',
                  'users.name',
                  'users.email',
                  'users.role',
                  'users.active',
                  'users.gord_employee',
                  'users.active',
                  "ARRAY_TO_STRING(ARRAY(SELECT licences.display_name FROM licences INNER JOIN access_licences ON access_licences.user_id = users.id WHERE access_licences.licence_id = licences.id ORDER BY licences.display_weight), '|||') AS licences_name",
                  'users.last_sign_in_at',
                  'users.sign_in_count')
          .where("users.role IN (:roles)", roles: @roles)
          .accessible_by(current_ability)
      end
    end
  end
end