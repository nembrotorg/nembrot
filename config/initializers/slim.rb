# Slim
Slim::Engine.set_options format: ENV['html_format'].to_sym,
                         pretty: ENV['html_pretty'] == 'pretty',
                         sort_attrs: ENV['html_sort_attrs'],
                         tabsize: ENV['html_tabsize'].to_i
