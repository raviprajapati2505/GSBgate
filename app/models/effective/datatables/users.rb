module Effective
  module Datatables
    class Users < Effective::Datatable
      include ActionView::Helpers::TranslationHelper

      datatable do
        col :name
        col :username
        col :email
        col :role, as: :integer, search: { as: :select, collection: Proc.new { User.roles.map { |k| [t(k[0], scope: 'activerecord.attributes.user.roles'), k[1]] } } } do |rec|
          t(rec.role, scope: 'activerecord.attributes.user.roles') unless rec.role.nil?
        end
        col :linkme_user, label: 'Linkme.qa User'
        col :cgp_license, label: 'CGP License'
        col :gord_employee, label: 'GORD Employee'
        col :last_sign_in_at, label: 'Last Sign in at', as: :datetime, search: { as: :select, collection: Proc.new { User.pluck_date_field_by_year_month_day(:last_sign_in_at, :desc) } } do |rec|
          localize(rec.last_sign_in_at.in_time_zone) unless rec.last_sign_in_at.nil?
        end
        col :sign_in_count, label: 'Sign in Count', as: :integer, search: :string
        if User.current.can?(:masquerade, User)
          col :id, label: 'Masquerade', search: false, sort: false do |rec|
            btn_link_to(masquerade_users_path(rec.id), icon: 'user-secret', size: 'small')
          end
        end
      end

      collection do
        User.select('users.id',
                    'users.username',
                    'users.name',
                    'users.email',
                    'users.role',
                    'users.linkme_user',
                    'users.cgp_license',
                    'users.gord_employee',
                    'users.last_sign_in_at',
                    'users.sign_in_count').accessible_by(current_ability)
      end
    end
  end
end