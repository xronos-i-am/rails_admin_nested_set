module RailsAdminNestedSet
  class Configuration
    attr_reader :abstract_model, :update_url, :edit_path, :inline_menu

    def initialize( abstract_model, scope_instance = nil, update_route_fragment = :nested_set )
      @abstract_model = abstract_model
      @scope_instance = scope_instance
      @update_route_fragment = update_route_fragment

      @update_url = ->( view ) { update_url_block( view ) }
      @edit_path = ->( view, node ) { edit_path_block( view, node ) }
      @inline_menu = ->( view, node ) { inline_menu_block( view, node ) }
    end

    def options
      @options ||= {
        max_depth: 3,
      }.merge( abstract_model_config.nested_set || {} )
    end

    def object_label( node )
      abstract_model_config.with( object: node ).object_label
    end

    protected

      def scoped?
        !@scope_instance.nil?
      end

      def update_params
        return { model_name: @abstract_model } unless scoped?

        { 
          model_name: RailsAdmin::AbstractModel.new( @scope_instance.class ),
          id: @scope_instance.id
        }
      end   

      def edit_route_fragment
        self.scoped? ? :scoped_edit : :edit
      end

      def edit_params( node )
        url_params = { model_name: @abstract_model, id: node.id }

        return url_params unless scoped?

        url_params.merge( scope_id: @scope_instance.id )
      end

      def abstract_model_config
        @abstract_model_config ||= ::RailsAdmin::Config.model( @abstract_model.model )
      end

      def update_url_block( view )
        view.send( "#{@update_route_fragment}_path", update_params )
      end

      def edit_path_block( view, node )
        view.send( "#{edit_route_fragment}_path", edit_params( node ) )
      end

      def inline_menu_block( view, node )
        return view.menu_for( :member, @abstract_model, node, true ) unless scoped?

        menu_for( view, :member, @abstract_model, node, true )
      end

      def menu_for(view, parent, abstract_model = nil, object = nil, only_icon = false)
        actions = view.actions( parent, abstract_model, object )

        scope_id = view.controller.params[:id]

        actions.map do |action|
          wording = view.wording_for(:menu, action)
          %{
            <li title="#{wording if only_icon}" rel="#{'tooltip' if only_icon}" class="icon #{action.key}_#{parent}_link #{'active' if view.current_action?(action)}">
              <a class="#{action.pjax? ? 'pjax' : ''}" href="#{view.url_for({ :action => action.action_name, :controller => 'rails_admin/main', :model_name => abstract_model.try(:to_param), :id => (object.try(:persisted?) && object.try(:id) || nil), :scope_id => scope_id })}">
                <i class="#{action.link_icon}"></i>
                <span#{only_icon ? " style='display:none'" : ""}>#{wording}</span>
              </a>
            </li>
          }
        end.join.html_safe       
      end

  end
end