#!/usr/bin/python3
import sys, json, time
from http.server import HTTPServer, BaseHTTPRequestHandler

arglen = len(sys.argv)
if arglen != 2 and arglen != 3:
    sys.exit("1 or 2 arguments expected: <port> [debug]")

debug_mode = False if arglen == 2 else True


class Server(BaseHTTPRequestHandler):
  def do_HEAD(self):
    return
    
  def do_GET(self):
    self.respond()
    
  def do_POST(self):
    self.respond()
    
  def handle_http(self, status, content_type, content):
    self.send_response(status)
    self.send_header('Content-type', content_type)
    self.end_headers()
    self.wfile.write(content)
    
  def respond(self):
    n_bytes = int(self.headers.get('Content-Length', "0"))
    data = json.loads(str(self.rfile.read(n_bytes), "UTF-8"))
    
    print(time.asctime(), 'Server received %d bytes' % n_bytes)
    sys.stdout.flush()
    if debug_mode:     # debug
        sec = int(time.time())
        with open(str(sec) + ".table.json", "w") as write_file:
            json.dump(data, write_file)

    if "layers" in data:
        for layer in data["layers"]:
            print('%s ' % layer["digest"], *layer["urls"]) # starred expression to unpack a list
            sys.stdout.flush()
    
    body = bytes("", "UTF-8")
    self.handle_http(200, 'text/html', body)
    
    
HOST_NAME = ''                     # 'localhost'
PORT_NUMBER = int(sys.argv[1])     # 8000

httpd = HTTPServer((HOST_NAME, PORT_NUMBER), Server)
print(time.asctime(), 'Server UP - %s:%s' % (HOST_NAME, PORT_NUMBER))
try:
    httpd.serve_forever()
except KeyboardInterrupt:
    pass    # do nothing
httpd.server_close()
print(time.asctime(), 'Server DOWN - %s:%s' % (HOST_NAME, PORT_NUMBER))
