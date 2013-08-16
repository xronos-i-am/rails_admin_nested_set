module RailsAdminNestedSet
  module Helper
    def rails_admin_nested_set(tree, opts= {})
      tree = tree.to_a.sort_by { |m| m.lft }
      roots = tree.select{|elem| elem.parent_id.nil?}
      id = "ns_#{rand(100_000_000..999_999_999)}"
      content = content_tag(:ol, rails_admin_nested_set_builder(roots, tree), id: id, class: 'dd-list')
      js = "rails_admin_nested_set({id: '#{id}', max_depth: #{max_depth}, update_url: '#{update_url}'});"
      content + content_tag(:script, js.html_safe, type: 'text/javascript')
    end

    def rails_admin_nested_set_builder(nodes, tree)
      nodes.map do |node|
        li_classes = 'dd-item dd3-item'

        content_tag :li, class: li_classes, :'data-id' => node.id do

          output = content_tag :div, 'drag', class: 'dd-handle dd3-handle'
          output+= content_tag :div, class: 'dd3-content' do
            content = link_to @nested_set_conf.object_label( node ), edit_node_path( node )
            content + content_tag(:div, action_links( node ), class: 'pull-right links')
          end

          children = tree.select{|elem| elem.parent_id == node.id}
          if children.any?
            output += content_tag :ol, rails_admin_nested_set_builder(children, tree), class: 'dd-list'
          end

          output
        end
      end.join.html_safe
    end

    def max_depth
      @nested_set_conf.options[:max_depth] || '0'
    end

    def update_url
      @nested_set_conf.update_url[ self ]
    end

    def edit_node_path( node )
      @nested_set_conf.edit_path[ self, node ]
    end

    def action_links( node )
      content_tag :ul, class: 'inline actions' do
        @nested_set_conf.inline_menu[ self, node ]
      end
    end
  end
end
