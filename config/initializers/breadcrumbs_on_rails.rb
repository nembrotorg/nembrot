# OrderedListBuilder is a breadcrumb builder for https://github.com/weppos/breadcrumbs_on_rails
# It has been forked from https://gist.github.com/1933884
#
# OrderedListBuilder accepts the following options:
# * list_class: a class ofr the list element (default: 'breadcrumbs')
# 
# The breadcrumbs are rendered in an ordered list and separators are left to css
#
# (For a discussion of breadcrumb semantics see http://css-tricks.com/markup-for-breadcrumbs/)
#
# You can use it with the :builder option on render_breadcrumbs:
#     <%= render_breadcrumbs :builder => ::OrderedListBuilder %>
#
class OrderedListBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  def render
    @context.content_tag(:ol, class: (@options[:list_class]  || 'breadcrumb')) do
      @elements.collect do |element|
        render_element(element)
      end.join.html_safe
    end
  end

  def render_element(element)
    current = @context.current_page?(compute_path(element))

    @context.content_tag(:li) do
      @context.link_to_unless_current(compute_name(element), compute_path(element), element.options)
    end
  end
end
