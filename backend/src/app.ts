import express from 'express';
import { MongoClient } from 'mongodb';

import config from './config.ts';
import addBook, { type AddBookBody } from './endpoints/add-book.ts';
import editBook, { type EditBookBody } from './endpoints/edit-book.ts';
import example, { type ExampleBody } from './endpoints/example.ts';
import login, { type LoginBody } from './endpoints/login.ts';
import register, { type RegisterBody } from './endpoints/register.ts';
import resetRequest, { type ResetRequestBody } from './endpoints/reset-request.ts';
import reset, { type ResetBody } from './endpoints/reset.ts';
import verify, { type VerifyBody } from './endpoints/verify.ts';

const app = express();

// Basic middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// MongoDB connection
const DB_URI = config.mongo_uri;
export async function getMongoClient() {
  let mongoClient;

  try {
    mongoClient = new MongoClient(DB_URI);
    await mongoClient.connect();

    return mongoClient;
  } catch (error) {
    console.error('Connection to MongoDB Atlas failed!', error);
    process.exit(1);
  }
}

// routing
app.post('/example', (req, res) => {
  return example((req.body as ExampleBody).message, res);
});

app.post('/users/register', async (req, res) => {
  return await register(req.body as RegisterBody, res);
});

app.post('/users/login', async (req, res) => {
  return await login(req.body as LoginBody, res);
});

app.post('/users/register/verify', async (req, res) => {
  return await verify(req.body as VerifyBody, res);
});

app.post('/users/login/reset_request', async (req, res) => {
  return await resetRequest(req.body as ResetRequestBody, res);
});

app.post('/users/login/reset', async (req, res) => {
  return await reset(req.body as ResetBody, res);
});

app.post('/library/add', async (req, res) => {
  return await addBook(req.body as AddBookBody, res);
});

app.post('/library/edit', async (req, res) => {
  return await editBook(req.body as EditBookBody, res);
});

export default app;
