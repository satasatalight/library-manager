import { getMongoClient } from '../app.ts';
import type { Request, Response } from 'express';
import type { MongoClient } from 'mongodb';
import { assert } from 'node:console';

interface RegisterBody {
  email: string;
  first_name: string;
  last_name: string;
  password: string;
}

async function validateEmail(email: string) {
    
}

export default async function register(req: RegisterBody, res: Response) {
    let mongoClient: MongoClient;
    mongoClient = await getMongoClient();
    
    await mongoClient.close();
    return res.send('Hello World.\nYou sent: ');
}