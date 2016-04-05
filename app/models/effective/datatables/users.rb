module Effective
  module Datatables
    class Users < Effective::Datatable
      include ActionView::Helpers::TranslationHelper

      attr_accessor :current_ability

      datatable do
        table_column 'username'
        table_column 'name'
        table_column 'email'
        table_column 'role', type: :integer, filter: {type: :select, values: Proc.new { User.roles.map { |k| [t(k[0], scope: 'activerecord.attributes.user.roles'), k[1]] } }} do |rec|
          t(rec.role, scope: 'activerecord.attributes.user.roles') unless rec.role.nil?
        end
        table_column 'linkme_user', label: 'Linkme.qa user'
        table_column 'cgp_license', label: 'CGP license'
        table_column 'gord_employee', label: 'GORD employee'
        table_column 'last_sign_in_at', label: 'Last sign in at', type: :datetime, filter: {type: :select, values: Proc.new { User.pluck_date_field_by_year_month_day(:last_sign_in_at, :desc) }} do |rec|
          localize(rec.last_sign_in_at.in_time_zone) unless rec.last_sign_in_at.nil?
        end
        table_column 'sign_in_count', label: 'Sign in count', type: :number
        if User.current.can?(:masquerade, User)
          table_column 'id', label: 'Masquerade', filter: false, sortable: false do |rec|
            btn_link_to(masquerade_users_path(rec.id), icon: 'user-secret', size: 'small')
          end
        end
      end

      def collection
        coll = User
                   .select('users.id',
                           'users.username',
                           'users.name',
                           'users.email',
                           'users.role',
                           'users.linkme_user',
                           'users.cgp_license',
                           'users.gord_employee',
                           'users.last_sign_in_at',
                           'users.sign_in_count')

        # Ensure we always have an ability, so we will not show unauthorized data
        if current_ability.nil?
          # Rails.logger.debug "NO ABILITY"
          return coll.none
        else
          # use cancan ability to limit the authorized users
          # Rails.logger.debug "ABILITY OK"
          return coll.accessible_by(current_ability)
        end
      end

    end
  end
end