from flask import Flask
# from flask_sqlalchemy import SQLAlchemy

# db = SQLAlchemy()

def create_app(env='dev'):
    app = Flask(__name__)

    # app.config['SECRET_KEY'] = ''
    # app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'

    # db.init_app(app)

    @app.route('/')
    def index():
        return "Index"
  
    @app.route('/profile')
    def profile():
        return "Profile"

    if __name__ == '__main__':
        app.run(debug=True)

    return app

# To run the application, you would typically create an instance of the app:
# app = create_app()

 