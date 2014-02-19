# encoding: utf-8

module PageHelper
  def page_wrapper(wrapper = 'section', css_list = [], &block)
    <<-EOS
    <#{ wrapper } class="theme-#{ @current_channel.theme } #{ controller.controller_name }-#{ controller.action_name } #{ css_instructions(css_list) unless css_list.empty? }"  data-theme-wrapper="true" data-channel-name="#{ @current_channel.name }" data-channel-id="#{ @current_channel.id }" data-channel-slug="#{ @current_channel.slug }" data-controller="#{ controller.controller_name }" data-action="#{ controller.action_name }" data-theme="#{ @current_channel.theme.slug }">
      <nav>#{ render_breadcrumbs builder: ::OrderedListBuilder }</nav>
      #{ capture(&block) }
      #{ render 'channels/footer' unless @current_channel == @default_channel }
      #{ include_gon(:init => true) }
    </#{ wrapper }>
    EOS
  end
end
