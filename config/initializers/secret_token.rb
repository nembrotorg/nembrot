default = 'fdjgfsdvvccvcaaz465jgeuyrwuywqrewopijnkczvqwj'

Nembrot::Application.config.secret_key_base = Figaro.env.secret_key_base || default
