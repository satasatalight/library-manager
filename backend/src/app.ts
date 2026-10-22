import express from 'express';

import example from './endpoints/example.ts';

const app = express();

// Basic middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// routing
interface ExampleBody {
  message: string;
}
app.post('/example', (req, res) => {
  return example((req.body as ExampleBody).message, res);
});

export default app;
