export default async function handler(req, res) {
  const apiUrl = 'https://newsapi.org/v2/top-headlines?country=us&apiKey=b0b0bf7ec0384190a044541bf1265050';

  try {
    const apiResponse = await fetch(apiUrl);
    const data = await apiResponse.json();

    res.setHeader('Access-Control-Allow-Origin', '*'); // Optional
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch news' });
  }
}
