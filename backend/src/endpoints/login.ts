import type { Response } from 'express';
import jwt from 'jsonwebtoken';
import type { Document, MongoClient, ObjectId, WithId } from 'mongodb';
import { hash } from 'node:crypto';

import { getMongoClient } from '../app.ts';
import config from '../config.ts';

const { sign } = jwt;

interface LoginBody {
  email: string;
  password: string;
}

let mongoClient: MongoClient;

const DB_NAME = 'litlog';
const USERS_TABLE_NAME = 'users';
const JWT_EXPIRE_TIME = '30m'; // How long the token lasts before being considered invalid.

function hashPassword(password: string): string {
  return hash('sha256', password);
}

export default async function login(req: LoginBody, res: Response) {
  // Check if both email and password fields are filled out. Automatically invalid login if false.
  if (!req.email || !req.password) {
    return res.status(401).send({
      status: 'error',
      reason: 'Invalid email or password. Please fill out all fields.',
      token: null,
    });
  }

  // Set up the credentials to check them. The password is hashed here.
  const credentials: LoginBody = {
    email: req.email,
    password: hashPassword(req.password),
  };

  // Get the database ready.
  mongoClient = await getMongoClient();

  // Check if the login attempt is valid.
  const user_document = await validateCredentials(credentials);
  const user_id = user_document?._id;
  // user_id is null if no matching credentials were found.
  if (user_id == null || user_document == null) {
    return res.status(401).send({
      status: 'error',
      reason: 'Invalid email or password.',
      token: null,
    });
  }

  // Check if the email is verified.
  if (user_document.isEmailVerified == false) {
    return res.status(403).send({
      status: 'error',
      reason:
        'You have not verified your email. Please verify before logging in.',
      token: null,
    });
  }

  /*
        By this point, the credentials are known to be valid
        and the email is known to be verified as well.

        The login is valid, so we take care of the rest.
    */
  const token = createJWT(user_id);
  await mongoClient.close();
  return res.status(200).send({
    status: 'success',
    reason: 'Your login attempt was successful.',
    token: token,
  });
}

async function validateCredentials(
  credentials: LoginBody,
): Promise<WithId<Document> | null> {
  try {
    // Search for the user based on the given credentials.
    const credentials_valid = await mongoClient
      .db(DB_NAME)
      .collection(USERS_TABLE_NAME)
      .findOne({
        email: credentials.email,
        password: credentials.password,
      });

    // If we got a result; means credentials were valid.
    if (credentials_valid != null) {
      return credentials_valid;
    }

    // No result; credentials are not valid.
    return null;
  } catch (error) {
    // Some error happened; login is invalid.
    return null;
  }
}

function createJWT(user: ObjectId): string {
  const payload = {
    userId: user,
  };
  const token: string = sign(payload, config.jwt_key, {
    expiresIn: JWT_EXPIRE_TIME,
    algorithm: 'HS256',
  });
  return token;
}
