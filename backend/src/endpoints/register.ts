import type { Response } from 'express';
import type { MongoClient } from 'mongodb';
import { hash, randomInt } from 'node:crypto';

import { getMongoClient } from '../app.ts';
import nodemailer from 'nodemailer';

interface RegisterBody {
  email: string;
  first_name: string;
  last_name: string;
  password: string;
}
let mongoClient: MongoClient;
const DB_NAME = 'litlog';
const USERS_TABLE_NAME = 'users';
interface DatabaseUserEntry {
  email: string;
  firstName: string;
  lastName: string;
  password: string;
  isEmailVerified: boolean;
}
const VERIFY_TABLE_NAME = 'pendingVerification';
const EXPIRY_TIME_DAYS = 7;
interface PendingVerificationEntry {
  email: string;
  code: number;
  expiry: number;
}

async function validateEmail(email: string): Promise<boolean> {
  // Correct email structure
  if (!email.match('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')) {
    return false;
  }

  // Email not in database
  const collection = mongoClient.db(DB_NAME).collection(USERS_TABLE_NAME);
  if ((await collection.findOne({ email: email })) != null) {
    return false;
  }

  return true;
}
function validateNames(req: RegisterBody): boolean {
  if (
    !req.first_name.match('^[A-Za-z\-]+$') ||
    !req.last_name.match('^[A-Za-z\-]+$')
  ) {
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

function hashPassword(password: string): string {
  return hash('sha256', password);
}

async function storeData(entry: DatabaseUserEntry): Promise<boolean> {
  try {
    await mongoClient.db(DB_NAME).collection(USERS_TABLE_NAME).insertOne(entry);

    // Any email with @testing.email will auto-delete
    if (entry.email.match("^[a-zA-Z0-9._%+-]+@testing\.email$")) {
      await mongoClient.db(DB_NAME).collection(USERS_TABLE_NAME).deleteOne(entry);
      console.log(entry.email + " user entry test successfully removed!");
    }
  } catch (error) {
    return false;
  }

  return true;
}

async function storeValidationData(entry: PendingVerificationEntry): Promise<boolean> {
  try {
    await mongoClient.db(DB_NAME).collection(VERIFY_TABLE_NAME).insertOne(entry);

    // Any email with @testing.email will auto-delete
    if (entry.email.match("^[a-zA-Z0-9._%+-]+@testing\.email$")) {
      await mongoClient.db(DB_NAME).collection(VERIFY_TABLE_NAME).deleteOne(entry);
      console.log(entry.email + " verification entry test successfully removed!");
    }
  } catch (error) {
    return false;
  }
  
  return true;
}

export default async function register(req: RegisterBody, res: Response) {
  if (!req.email || !req.first_name || !req.last_name || !req.password) {
    return res.status(400).send({
      status: 'error',
      reason: 'We could not register your account. Please fill out all fields.',
    });
  }

  mongoClient = await getMongoClient();

  if ((await validateEmail(req.email)) == false) {
    return res.status(400).send({
      status: 'error',
      reason:
        "We could not register your account. Your email is either invalid or already exists. If your email is valid, click 'Forgot Password' to reset for this email.",
    });
  }
  if (validateNames(req) == false) {
    return res.status(400).send({
      status: 'error',
      reason:
        'We could not register your account. Make sure your names only contain letters and dashes.',
    });
  }
  if (validatePassword(req.password) == false) {
    return res.status(400).send({
      status: 'error',
      reason:
        'We could not register your account. Your password must be at least 8 characters long.',
    });
  }

  const entry: DatabaseUserEntry = {
    email: req.email,
    firstName: req.first_name,
    lastName: req.last_name,
    password: hashPassword(req.password),
    isEmailVerified: false,
    // validation_code: randomInt(100000, 1000000), // Random 6-digit code
  };
  if ((await storeData(entry)) == false) {
    return res.status(500).send({
      status: 'error',
      reason:
        'We could not register your account. Our database may be unable to add your information. Please try again later.',
    });
  }

  // TODO: store email + verification code + expiry timestamp in pendingVerification collection
  const verifyEntry: PendingVerificationEntry = {
    email: req.email,
    code: randomInt(100000,1000000),
    expiry: Date.now() + (EXPIRY_TIME_DAYS * 24 * 60 * 60 * 1000)
  }
  if ((await storeValidationData(verifyEntry)) == false) {
    return res.status(500).send({
      status: 'error',
      reason:
        'We could not register your account. Our database may be unable to add your information. Please try again later.',
    });
  }

  // TODO: send email w/ verification code thru nodemailer to user

  console.log('New account registered:');
  console.log(entry);

  await mongoClient.close();
  return res.status(200).send({
    status: 'success',
    reason: 'Your account has been registered. Please verify your email.',
  });
}
