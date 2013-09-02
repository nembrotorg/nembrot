# Slim
Slim::Engine.set_default_options format: Settings.html.format.to_sym,
                                 pretty: Settings.html.pretty,
                                 sort_attrs: Settings.html.sort_attrs,
                                 tab_size: Settings.html.tab_size
