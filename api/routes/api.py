import os
from werkzeug.utils import secure_filename
from datetime import datetime
from main import app
from flask import send_file, flash, request, redirect, url_for, jsonify
from models.user import User
from models.location import Location
from models.pushnotification import Pushnotification

UPLOAD_FOLDER = '/home/cbr/python/api/images/'  # path uploading use in server
# UPLOAD_FOLDER = '/images/' # path uploading use in server
ALLOWED_EXTENSIONS = set(['txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif'])
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/')
def index():
    listuser = User().listuser()
    return listuser


@app.route('/uploadfile', methods=['GET', 'POST'])
def uploadfile():
    if request.method == 'POST':
        # check if the post request has the file part
        if 'filepost' not in request.files:
            return redirect(request.url)
        file = request.files['filepost']
        # if user does not select file, browser also
        # submit an empty part without filename
        if file.filename == '':
            return redirect(request.url)
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            ext = filename.split(".")[-1]
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            filename_rename = str(
                datetime.now().strftime('%Y%m%d%H%M%S%f'))+'.'+ext
            os.rename(UPLOAD_FOLDER + filename, UPLOAD_FOLDER+filename_rename)
            return jsonify(filename_rename)
            # return redirect(url_for('showimg', filename=filename))
    else:
        return redirect(request.url)


@app.route('/loadimg/<id>', methods=['GET'])
def loadimg(id):
    photo = Location().loadimg(id)
    return photo


@app.route('/showimg/<filename>', methods=['GET'])
def showimg(filename):
    return send_file('images/'+filename, mimetype='image/jpg')


@app.route('/textsearch', methods=['GET'])
def textsearch():
    photo = Location().textsearch()
    return photo


@app.route('/sendnotification', methods=['GET'])
def sendnotification():
    send_push = Pushnotification.sendnotification()
    return send_push


@app.route('/generatechart', methods=['GET'])
def generatechart():
    chart = Location().generatechart()
    return chart