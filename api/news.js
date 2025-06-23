export default async function handler(req, res) {
  const response = await fetch(
    'https://newsapi.org/v2/top-headlines?country=us&apiKey=b0b0bf7ec0384190a044541bf1265050'
  );

  if (!response.ok) {
    return res.status(response.status).json({ error: 'Failed to fetch news' });
  }

  const data = await response.json();
  res.status(200).json(data);
}
