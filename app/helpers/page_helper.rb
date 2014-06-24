# encoding: utf-8

module PageHelper
  def page_wrapper(wrapper = 'section', css_list = [], &block)
    <<-EOS
    <#{ wrapper } class="theme-#{ @current_channel.theme.slug } #{ controller.controller_name }-#{ controller.action_name } #{ @current_channel_css_modules } #{ css_instructions(css_list) unless css_list.blank? }"  data-theme-wrapper="true" data-channel-name="#{ @current_channel.name }" data-channel-id="#{ @current_channel.id }" data-channel-slug="#{ @current_channel.slug }" data-controller="#{ controller.controller_name }" data-action="#{ controller.action_name }" data-theme="#{ @current_channel.theme.slug }">
      #{ render 'channels/top_menu' if @current_channel.menu_at_top? }
      #{ '<nav>' + (render_breadcrumbs builder: ::OrderedListBuilder) + '</nav>' if @current_channel.breadcrumbs? }
      #{ capture(&block) }
      #{ render 'channels/footer' unless @current_channel.nil? || !@current_channel.menu_at_bottom? || @current_channel == @default_channel }
      #{ render 'shared/map_script', map: @map_all_markers, key: 'MAP_ALL_MARKERS' unless @map_all_markers.blank? }
    </#{ wrapper }>
    EOS
  end
end
