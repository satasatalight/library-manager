import type { Response } from 'express';
import jwt from 'jsonwebtoken';
import {
  type Document,
  FindCursor,
  MongoClient,
  ObjectId,
  type WithId,
} from 'mongodb';

import { getMongoClient } from '../app.ts';
import config from '../config.ts';

const { verify, JsonWebTokenError, TokenExpiredError } = jwt;

interface Book {
  bookId: ObjectId;
  title: string;
  author: string | null;
  genre: string | null;
  publicationYear: number | null;
  description: string | null;
  coverImageUrl: URL | null;
}

export interface ViewLibraryBody
{
    token: string | null; //JWT
}

let mongoClient : MongoClient;

const DB_NAME = 'litlog';
const USER_BOOKS_TABLE_NAME = 'userBooks';
const LIBRARY_TABLE_NAME = 'library';

export default async function viewLibrary(req: ViewLibraryBody, res: Response)
{
    /*
        Check if the provided JWT is valid. Use the verify method.
        Handle token being invalid, and handle token being expired.

        Also retrieve the "userId" from the JWT. This will be used later.
    */
  // Check if the token is provided.
  if (!req.token) {
    return res.status(401).send({
      status: 'error',
      reason: 'Your session is invalid. Please login again.',
      book_id: null,
    });
  }

  // Check if the token is valid and can be verified.
  let user_id: ObjectId | undefined;
  interface JWTBody {
    userId: ObjectId;
  }

  try {
    const verified_token = verify(req.token, config.jwt_key) as JWTBody;
    user_id = verified_token.userId;
  } catch (error) {
    if (error instanceof TokenExpiredError) // Token expired
    {
      return res.status(401).send({
        status: 'error',
        reason: 'Your token has expired. Please login again.',
        book_id: null,
      });
    } else if (
      error instanceof JsonWebTokenError
    ) // Token improperly formatted.
    {
      return res.status(400).send({
        status: 'error',
        reason: 'Your session may have been tampered with. Please login again.',
        book_id: null,
      });
    } else {
      return res.status(500).send({
        status: 'error',
        reason: 'An unknown error occurred.',
        book_id: null,
      });
    }
  }

  // Initiate the database connection.
  mongoClient = await getMongoClient();

  // Get a list of Book IDs associated with the user.

  const returned_ids = await findUserOwnedBooks(new ObjectId(user_id));

  // An error happened when querying the database.
  if(returned_ids == undefined)
  {
    return res.status(500).send({
        status: 'error',
        reason: 'An unknown error occurred.',
        library: null
    });
  }

  // Use the returned IDs to find those books and their information.
  const returned_books = await findUserOwnedBooksInfo(returned_ids);

  // An error happened when querying the database.
  if(returned_books == undefined)
  {
    return res.status(500).send({
        status: 'error',
        reason: 'An unknown error occurred.',
        library: null
    });
  }

  // The search was successful, but the user has no books.
  if(returned_books.length == 0)
  {
    return res.status(200).send({
        status: 'success',
        reason: 'No books found in user library.',
        library: null
    });
  }

  // A non-zero number of books were found associated with the user.
  return res.status(200).send({
    status: 'success',
    reason: 'book data obtained',
    library: returned_books
  });
}

async function findUserOwnedBooks(user: ObjectId): Promise<ObjectId[] | undefined>
{
    let result: FindCursor<WithId<Document>>;

    try
    {
        result = mongoClient
        .db(DB_NAME)
        .collection(USER_BOOKS_TABLE_NAME)
        .find({
            userId: user
        });
    }
    catch
    {
        return undefined
    }

    const returned_documents: WithId<Document>[] = await result.toArray();
    
    const returned_ids: ObjectId[] = returned_documents.map(document => document.bookId as ObjectId);

    return returned_ids;
}

async function findUserOwnedBooksInfo(books: ObjectId[]): Promise<Book[] | undefined>
{
    let result: FindCursor<WithId<Document>>;

    try
    {
        result = mongoClient
        .db(DB_NAME)
        .collection(LIBRARY_TABLE_NAME)
        .find({
            _id: { $in: books}
        });
    }
    catch
    {
        return undefined;
    }

    const returned_documents = await result.toArray();

    const returned_books: Book[] = returned_documents.map((document) => {
        const book: Book = 
        {
            bookId: document._id,
            title: document.title as string,
            author: document.author as string,
            genre: document.genre as string,
            publicationYear: document.publicationYear as number,
            description: document.description as string,
            coverImageUrl: document.coverImageUrl as URL
        }
        return book;
    });

    return returned_books;
}