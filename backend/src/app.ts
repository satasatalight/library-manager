import express from 'express';
import { MongoClient } from 'mongodb';

import example from './endpoints/example.ts';
import register from './endpoints/register.ts';
import config from './config.ts';

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
        console.log('Connecting to MongoDB Atlas cluster...');
        await mongoClient.connect();
        console.log('Successfully connected to MongoDB Atlas!');

        return mongoClient;
    } catch (error) {
        console.error('Connection to MongoDB Atlas failed!', error);
        process.exit(1);
    }
}

// routing
interface ExampleBody {
  message: string;
}
app.post('/example', (req, res) => {
  return example((req.body as ExampleBody).message, res);
});
app.post('/users/register', async (req, res) => {
  return await register(req.body, res);
})

export default app;
