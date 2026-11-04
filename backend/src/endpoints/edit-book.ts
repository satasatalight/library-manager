import type { Response } from 'express';
import jwt from 'jsonwebtoken';
import {
  Db,
  type Document,
  type InsertOneResult,
  MongoClient,
  ObjectId,
  type UpdateResult,
  type WithId,
} from 'mongodb';

import { getMongoClient } from '../app.ts';
import config from '../config.ts';

const { verify, JsonWebTokenError, TokenExpiredError } = jwt;

interface Book {
  title: string;
  author: string | null;
  genre: string | null;
  publicationYear: number | null;
  description: string | null;
  coverImageUrl: URL | null;
}

interface EditBookBody {
  book_id: ObjectId;
  title: string;
  author: string | null;
  genre: string | null;
  publication_year: number | null;
  description: string | null;
  cover_image: URL | null;
  token: string | null; // JWT
}

let mongoClient: MongoClient;

const DB_NAME = 'litlog';
const USERS_TABLE_NAME = 'users';
const USER_BOOKS_TABLE_NAME = 'userBooks';
const LIBRARY_TABLE_NAME = 'library';

export default async function editBook(req: EditBookBody, res: Response) {
  /*
    Check if the JWT is valid. Use the verify method.
    Handle token being invalid, and handle token being expired.

    Also, retrieve the "userId" from the JWT. This will be used later.
    */
  // First, check if the token is actually provided.
  if (!req.token) {
    return res.status(400).send({
      status: 'error',
      reason: 'Your session is invalid. Please login again.',
    });
  }

  // Next, check if the token is valid and can be verified.
  let user_id: ObjectId | undefined;
  interface JWTBody {
    userId: ObjectId;
  }

  try {
    const verified_token = verify(req.token, config.jwt_key) as JWTBody;
    user_id = verified_token.userId;
  } catch (error) {
    if (error instanceof TokenExpiredError) // Token was valid, but expired.
    {
      return res.status(401).send({
        status: 'error',
        reason: 'Your token has expired. Please login again',
      });
    } else if (
      error instanceof JsonWebTokenError
    ) // Token improperly formatted or failed to verify
    {
      return res.status(400).send({
        status: 'error',
        reason: 'Your session may have been tampered with. Please login again.',
      });
    } else {
      return res.status(500).send({
        status: 'error',
        reason: 'An unknown error occurred.',
      });
    }
  }

  // Make sure the necessary title field is filled out.
  if (!req.title || req.title === '') {
    return res.status(400).send({
      status: 'error',
      reason: 'The book must have a title.',
    });
  }

  /*
    The request should be valid at this point, so let's go ahead
    and construct a new Book object.
    */
  const BookToEdit: Book = {
    title: req.title,
    author: req.author,
    genre: req.genre,
    publicationYear: req.publication_year,
    description: req.description,
    coverImageUrl: req.cover_image,
  };

  mongoClient = await getMongoClient();
  /*
    An error occurs if the book ID is improperly formatted and we don't catch it.
    */
  let result: UpdateResult<Document> | null;
  try {
    result = await updateBookInformation(new ObjectId(req.book_id), BookToEdit);
  } catch {
    await mongoClient.close();
    return res.status(400).send({
      status: 'error',
      reason: 'The book ID may have been tampered with.',
    });
  }

  await mongoClient.close();

  if (result === null) {
    return res.status(500).send({
      status: 'error',
      reason: 'An expected error happened with the database.',
    });
  }

  if (result.matchedCount == 1 && result.modifiedCount == 1) {
    return res.status(200).send({
      status: 'success',
      reason: 'Book successfully edited.',
    });
  } else if (result.matchedCount == 1 && result.modifiedCount == 0) {
    return res.status(200).send({
      status: 'success',
      reason: 'No new book information was provided.',
    });
  } else {
    return res.status(500).send({
      status: 'error',
      reason: 'We could not find your book.',
    });
  }
}

async function updateBookInformation(
  book_id: ObjectId,
  Book: Book,
): Promise<UpdateResult<Document> | null> {
  let result: UpdateResult<Document>;
  try {
    result = await mongoClient
      .db(DB_NAME)
      .collection(LIBRARY_TABLE_NAME)
      .updateOne({ _id: book_id }, { $set: Book });
  } catch {
    return null;
  }

  return result;
}
