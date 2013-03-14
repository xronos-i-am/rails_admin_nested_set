module RailsAdmin
  module Config
    module Actions
      class NestedSet < Base
        RailsAdmin::Config::Actions.register(self)

        # Is the action acting on the root level (Example: /admin/contact)
        register_instance_option :root? do
          false
        end

        register_instance_option :collection? do
          true
        end

        # Is the action on an object scope (Example: /admin/team/1/edit)
        register_instance_option :member? do
          false
        end

        register_instance_option :controller do
          @nested_set_conf = ::RailsAdminNestable::Configuration.new @abstract_model

          Proc.new do |klass|
            if params['id'].present?
              begin
                id        = params[:id].to_s
                parent_id = params[:parent_id].to_s
                prev_id   = params[:prev_id].to_s
                next_id   = params[:next_id].to_s

                if id.empty?
                  return render text: 'Nested set UI error: node id not defined', status: 500
                elsif parent_id.empty? && prev_id.empty? && next_id.empty?
                  return render text: 'Nested set UI error: not defined where to move node', status: 500
                end


                obj = @abstract_model.model.find(id)
                if prev_id.empty? && next_id.empty?
                  obj.move_to_child_of @abstract_model.model.find(parent_id)
                elsif !prev_id.empty?
                  obj.move_to_right_of @abstract_model.model.find(prev_id)
                elsif !next_id.empty?
                  obj.move_to_left_of @abstract_model.model.find(next_id)
                end

                message = "<strong>#{I18n.t('admin.actions.nestable.success')}!</strong>"
              rescue Exception => e
                message = "<strong>#{I18n.t('admin.actions.nestable.error')}</strong>: #{e}"
              end

              render text: message
            else
              @nodes = list_entries(@model_config, :index, nil, nil).order('lft')
              render action: @action.template_name
            end
          end
        end

        register_instance_option :link_icon do
          'icon-move'
        end

        register_instance_option :http_methods do
          [:get, :post]
        end
      end
    end
  end
end
