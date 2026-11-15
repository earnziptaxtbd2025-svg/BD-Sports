// Tiny local server for testing the pages on your computer: node web_public/serve.js
// It applies the same rewrite as production: every /t/... address serves t.html.
const http = require('http');
const fs = require('fs');
const path = require('path');

const root = __dirname;
const port = Number(process.env.PORT) || 8080;
const types = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8', '.json': 'application/json; charset=utf-8',
  '.txt': 'text/plain; charset=utf-8',
};

http.createServer((req, res) => {
  let pathname = decodeURIComponent(new URL(req.url, 'http://x').pathname);
  if (pathname.startsWith('/t/')) pathname = '/t.html';
  if (pathname === '/') pathname = '/index.html';

  const file = path.normalize(path.join(root, pathname));
  const publicFile = file.startsWith(root + path.sep) && !file.includes(`${path.sep}test${path.sep}`)
    && !file.endsWith('serve.js');

  fs.readFile(file, (err, data) => {
    if (err || !publicFile) {
      res.writeHead(404, { 'Content-Type': 'text/html; charset=utf-8' });
      return res.end(fs.existsSync(path.join(root, '404.html'))
        ? fs.readFileSync(path.join(root, '404.html')) : 'Not found');
    }
    res.writeHead(200, { 'Content-Type': types[path.extname(file)] || 'application/octet-stream' });
    res.end(data);
  });
}).listen(port, () => console.log(`Open http://localhost:${port}/t/demo`));
