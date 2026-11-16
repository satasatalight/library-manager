import type { Response } from 'express';
import jwt from 'jsonwebtoken';
import {
  type Document,
  type InsertOneResult,
  MongoClient,
  ObjectId,
} from 'mongodb';

import { getMongoClient } from '../app.ts';
import config from '../config.ts';

const { verify, JsonWebTokenError, TokenExpiredError } = jwt;

export interface DeleteBookBody {
  book_id: ObjectId;
  token: string | null //JWT
}

let mongoClient: MongoClient;

const DB_NAME = 'litlog';
const USER_BOOKS_TABLE_NAME = 'userBooks';
const LIBRARY_TABLE_NAME = 'library';

export default async function deleteBook(req: DeleteBookBody, res: Response)
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

  mongoClient = await getMongoClient();

  const deletion_result: boolean = await removeBookEntries(req.book_id);

  mongoClient.close();

  if(deletion_result == false)
  {
    return res.status(500).send({
        status: 'error',
        reason: 'The book could not be found.'
    });
  }

  return res.status(200).send({
    status: 'success',
    reason: 'Book successfully deleted.'
  });
}

async function removeBookEntries(book_id: ObjectId): Promise<boolean>
{
    let remove_from_library = async (id: ObjectId): Promise<boolean> => {
        try
        {
            const result = await mongoClient
            .db(DB_NAME)
            .collection(LIBRARY_TABLE_NAME)
            .deleteOne({
                _id: id
            });

            if(result.deletedCount == 1)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        catch(error)
        {
            console.log("Error when removing from library table: " + error);
            return false;
        }
        
    };

    let remove_from_user_books = async (id: ObjectId): Promise<boolean> => {
        try
        {
            let result = await mongoClient
            .db(DB_NAME)
            .collection(USER_BOOKS_TABLE_NAME)
            .deleteOne({
                bookId: id
            });

            if(result.deletedCount == 1)
            {
                return true;
            }
            else
            {
                return false;
            }
            
        }
        catch(error)
        {
            console.log("Error when removing from user books table: " + error);
            return true;
        }
    };

    if(await remove_from_library( new ObjectId(book_id) ) == false)
    {
        return false;
    }

    if(await remove_from_user_books( new ObjectId(book_id) ) == false)
    {
        return false;
    }

    return true;
}