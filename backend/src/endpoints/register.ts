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

function validateNames(req: RegisterBody): boolean {
  if (!req.first_name.match("[A-Za-z\-]+") || !req.last_name.match("[A-Za-z\-]+")) {
    return false;
  }

  return true;
}

function validatePassword(password: string): boolean {
  if (password.length < 8) {
    return false;
  }

  return true;
}

export default async function register(req: RegisterBody, res: Response) {
    mongoClient = await getMongoClient();

    if (await validateEmail(req.email) == false) {
      return res.status(400).send({
        status: "error",
        reason: "We could not register your account. Your email is either invalid or already exists."
      });
    }
    if (validateNames(req) == false) {
      return res.status(400).send({
        status: "error",
        reason: "We could not register your account. Make sure your names only contain letters and dashes."
      });
    }
    if (validatePassword(req.password) == false) {
      return res.status(400).send({
        status: "error",
        reason: "We could not register your account. Your password must be at least 8 characters long."
      });
    }
    
    await mongoClient.close();
    return res.send('Hello World.\nYou sent: ');
}