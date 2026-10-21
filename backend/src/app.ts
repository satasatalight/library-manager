import express from 'express';
import example from './endpoints/example';

const app = express();

app.use(express.json());

app.get('/example', example);

export default app;