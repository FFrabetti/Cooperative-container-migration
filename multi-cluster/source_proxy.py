#!/usr/bin/python3
import sys, time, io
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path
from http.client import HTTPConnection

arglen = len(sys.argv)
if arglen != 4:
    sys.exit("3 arguments expected: <port> <cache_dir> <peer_proxy>")

cache_dir = Path(sys.argv[2])
if not cache_dir.is_dir():
    sys.exit("Cache directory does not exist")

peerProxy = sys.argv[3]

class Server(BaseHTTPRequestHandler):
  def do_HEAD(self):
    return
    
  def do_GET(self):
    self.respond()
    
  def do_POST(self):
    self.respond()
    
  def handle_http(self, status, content_type, content_len, content):
    self.send_response(status)
    self.send_header('Content-Type', content_type)
    self.send_header('Content-Length', content_len)
    self.end_headers()
    if isinstance(content, io.IOBase):
        while True:
            chunk = content.read(io.DEFAULT_BUFFER_SIZE)
            if not chunk:
                break
            else:
                self.wfile.write(chunk)
    else:
        self.wfile.write(content)
        
  def respond(self):
    digest = self.path.split('/')[-1]
    
    cacheFile = cache_dir.joinpath(digest)
    if cacheFile.is_file():
        size = cacheFile.stat().st_size
        with cacheFile.open('rb') as f:
            self.handle_http(200, 'application/octet-stream', size, f)
    else:
        conn = HTTPConnection(peerProxy)
        conn.request("GET", self.path)
        resp = conn.getresponse()
        self.handle_http(resp.status, resp.getheader('Content-Type'), resp.getheader('Content-Length'), resp)
    
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
