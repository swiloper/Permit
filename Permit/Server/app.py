from flask import Flask, request, jsonify
import numpy
import base64
import cv2
import string
import random

app = Flask(__name__)

# Set up face detector path.
cascade = "/Users/home/Library/Python/3.9/lib/python/site-packages/cv2/data/"
detector = cv2.CascadeClassifier(cascade + 'haarcascade_frontalface_default.xml')

def decode(base, scanning):
    decoded = base64.b64decode(base)
    data = numpy.frombuffer(decoded, dtype=numpy.uint8)

    if scanning:
        image = cv2.imdecode(data, cv2.COLOR_BGR2GRAY)
        result = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    else:
        result = cv2.imdecode(data, cv2.IMREAD_GRAYSCALE)

    return result

@app.route('/scan', methods=['POST'])
def scan():
    id = request.json['id']
    images = request.json['images']
    portraits = []

    for base in images:
        image = decode(base, True)
        faces = detector.detectMultiScale(image, scaleFactor=1.2, minNeighbors=5)
        for (x, y, w, h) in faces:
            portrait = image[y:y + h, x:x + w]
            resized = cv2.resize(portrait, (100, 100))
            portraits.append(resized)
        
    recognizer = cv2.face.LBPHFaceRecognizer_create()
    recognizer.train(portraits, numpy.array([1] * len(portraits)))
    path = f"database/{id}.yml"
    recognizer.write(path)
    print("Training completed.")
    return jsonify({'isRegisterCompleted': True})

@app.route('/authenticate', methods=['POST'])
def authenticate():
    id = request.json['id']
    base = request.json['image']
    image = decode(base, False)
    faces = detector.detectMultiScale(image, scaleFactor=1.05, minNeighbors=5)
    recognizer = cv2.face.LBPHFaceRecognizer_create()
    path = f"database/{id}.yml"
    recognizer.read(path)

    for (x, y, w, h) in faces:
        face = cv2.resize(image[y:y + h, x:x + w], (100, 100))
        label, distance = recognizer.predict(face)
        max = 425
        confidence = int(100 * (1-distance/max))

        if confidence >= 80:
            response = f"Identified with confidence {confidence}."
            print(response)
            return jsonify({'passcode': ''.join(random.SystemRandom().choice(string.digits) for _ in range(6))})
        else:
            response = f"Person is unknown, confidence {confidence}."
            print(response)
            return jsonify({'passcode': None})

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000)