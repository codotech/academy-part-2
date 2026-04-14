import 'dotenv/config';
import express from 'express';
import cors from 'cors';

const app = express();

app.use(cors());
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

// Your routes go here.
// The only hard requirement: GET /api/search?q=<query>
// must return { results: [...] } matching the contract in the frontend.

const PORT = process.env.PORT ?? 3000;
app.listen(PORT, () => {
  console.log(`listening on :${PORT}`);
});
