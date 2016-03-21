class OwnersController < AuthenticatedController
  load_and_authorize_resource :owner

  def show
    respond_to do |format|
      format.json { render json: @owner, status: :ok }
    end
  end

  def index
    respond_to do |format|
      format.json {
        if params.has_key?(:q)
          total_count = Owner.where('name like ?', '%' + params[:q] + '%')
                            .count
          if params.has_key?(:page)
            owners = Owner.select('id, name as text, governmental, private_developer, private_owner')
                        .where('name like ?', '%' + params[:q] + '%')
                         .order('governmental', 'private_developer', 'private_owner')
                        .page(params[:page]).per(25)
          else
            owners = Owner.select('id, name as text, governmental, private_developer, private_owner')
                          .where('name like ?', '%' + params[:q] + '%')
                         .order('governmental', 'private_developer', 'private_owner')
                          .page(0).per(25)
          end
        else
          total_count = Owner.count
          if params.has_key?(:page)
            owners = Owner.select('id, name as text, governmental, private_developer, private_owner')
                         .order('governmental', 'private_developer', 'private_owner')
                        .page(params[:page]).per(25)
          else
            owners = Owner.select('id, name as text, governmental, private_developer, private_owner')
                         .order('governmental', 'private_developer', 'private_owner')
                        .page(0).per(25)
          end
        end

        governmental_children = []
        private_developer_children = []
        private_owner_children = []
        other = []
        owners.each do |owner|
          if owner.governmental?
            governmental_children << owner
          elsif owner.private_developer?
            private_developer_children << owner
          elsif owner.private_owner?
            private_owner_children << owner
          else
            other << owner
          end
        end
        items = []
        unless governmental_children.empty?
          items << {text: 'Governmental', children: governmental_children}
        end
        unless private_developer_children.empty?
          items << {text: 'Private developers', children: private_developer_children}
        end
        unless private_owner_children.empty?
          items << {text: 'Private owners', children: private_owner_children}
        end
        items += other

        render json: {total_count: total_count, items: items}, status: :ok
      }
    end
  end
end