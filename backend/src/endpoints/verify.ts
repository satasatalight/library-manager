import type { Response } from 'express';
import type { MongoClient } from 'mongodb';

import { getMongoClient } from '../app.ts';
import type {
  DatabaseUserEntry,
  PendingVerificationEntry,
} from './register.ts';

interface VerifyBody {
  email: string;
  code: number;
}

let mongoClient: MongoClient;
const DB_NAME = 'litlog';
const USERS_TABLE_NAME = 'users';
const VERIFY_TABLE_NAME = 'pendingVerification';

async function fetchVerifyData(
  email: string,
): Promise<PendingVerificationEntry | null> {
  return await mongoClient
    .db(DB_NAME)
    .collection<PendingVerificationEntry>(VERIFY_TABLE_NAME)
    .findOne({ email: email });
}

function isCodeExpired(expiry: number): boolean {
  return Date.now() > expiry;
}

async function verifyUser(email: string): Promise<boolean> {
  try {
    await mongoClient
      .db(DB_NAME)
      .collection<DatabaseUserEntry>(USERS_TABLE_NAME)
      .updateOne({ email: email }, { $set: { isEmailVerified: true } });
  } catch {
    return false;
  }
  return true;
}

export default async function verify(req: VerifyBody, res: Response) {
  if (!req.email || !req.code) {
    return res.status(400).send({
      status: 'error',
      reason: 'Malformed input. Missing email and/or code.',
    });
  }

  mongoClient = await getMongoClient();
  const verifyEntry: PendingVerificationEntry | null = await fetchVerifyData(
    req.email,
  );
  if (verifyEntry == null) {
    return res.status(404).send({
      status: 'error',
      reason:
        'We could not find your email. Please ensure you have registered your account. If you are still receiving this error, please ensure your email is correct.',
    });
  }

  if (isCodeExpired(verifyEntry.expiry)) {
    return res.status(403).send({
      status: 'error',
      reason: 'Your code has expired.',
    });
  }

  if (req.code != verifyEntry.code) {
    return res.status(403).send({
      status: 'error',
      reason:
        'We could not match your code. Please ensure the code is correct.',
    });
  }

  if (await verifyUser(req.email)) {
    return res.status(200).send({
      status: 'success',
      reason:
        'Your email has been verified. You may now log in using your username and password.',
    });
  } else {
    return res.status(500).send({
      status: 'error',
      reason:
        'We could not update your verification status. The database may be unavailable. Please try again later.',
    });
  }
}
