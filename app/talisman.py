from flask_talisman import Talisman

def init_talisman(app):
    csp = {
        'default-src': [
            '\'self\'',
            'stackpath.bootstrapcdn.com',
            'cdnjs.cloudflare.com',
        ]
    }
    Talisman(app, content_security_policy=csp)
