// api/proxy.js
import fetch from 'node-fetch';

export default async function handler(req, res) {
  const targetUrl = req.query.url;

  // Handle preflight CORS requests
  if (req.method === 'OPTIONS') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.status(200).end();
    return;
  }

  if (!targetUrl) {
    res.status(400).send('Missing url parameter');
    return;
  }

  try {
    const response = await fetch(targetUrl);
    const contentType = response.headers.get('content-type') || 'application/octet-stream';

    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Content-Type', contentType);

    const buffer = await response.buffer();
    res.send(buffer);
  } catch (error) {
    console.error(error);
    res.status(500).send('Error fetching the URL');
  }
}
