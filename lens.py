import tempfile
from PIL import ImageGrab, Image
import json
import pytesseract
import time

pytesseract.pytesseract.tesseract_cmd = "D:\\Project\\python\\Bots\\Bot\\tesseract.exe"

def getImageAndText():
    image = ImageGrab.grabclipboard()
    output = {
        'path': '',
        'text': ''
    }
    if image is not None:
        with tempfile.NamedTemporaryFile(mode="wb+", delete=False) as f:

            image.save(f, format='png')
        output['path'] = f.name
        output['text'] = pytesseract.image_to_string(image, lang='eng')

    print(json.dumps(output))

time.sleep(3)
getImageAndText()
