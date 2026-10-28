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
let mongoClient: MongoClient;
const DB_NAME = "Library-Manager";
const USERS_TABLE_NAME = "users";

async function validateEmail(email: string): Promise<boolean> {
    // Correct email structure
    if (!email.match("/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$/.")) {
      return false;
    }

    // Email not in database
    const collection = await mongoClient.db(DB_NAME).collection(USERS_TABLE_NAME);
    if (collection.findOne({ "email": email }) != null) {
      return false;
    }

    // Email valid!
    return true;
}

export default async function register(req: RegisterBody, res: Response) {
    mongoClient = await getMongoClient();
    
    await mongoClient.close();
    return res.send('Hello World.\nYou sent: ');
}