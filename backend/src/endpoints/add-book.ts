import type { Response } from 'express';
import jwt from 'jsonwebtoken';
import type { Document, MongoClient, ObjectId, WithId } from 'mongodb';
import { hash } from 'node:crypto';

import { getMongoClient } from '../app.ts';
import config from '../config.ts';

interface Book
{
    book_id: ObjectId;
    title: string;
    author: string | null;
    genre: string | null;
    publication_year: number | null;
    description: string | null;
    cover_image: URL | null;
}

interface AddBookBody
{
    title: string;
    author: string | null;
    genre: string | null;
    publication_year: number | null;
    description: string | null;
    cover_image: URL | null;
    token: string | null // JWT
}

let mongoClient : MongoClient;

const DB_NAME = 'litlog';
const USERS_TABLE_NAME = 'users';
const USER_BOOKS_TABLE_NAME = 'userBooks';
const LIBRARY_TABLE_NAME = 'library';

export default async function addBook(req: AddBookBody, res: Response)
{
    /*
        Check if the provided JWT is valid. Use the verify method.
        Handle token being invalid, and handle token being expired.

        Also retrieve the "userId" from the JWT. This will be used later.
    */

    
    /*
        Check if the necessary "title" field is filled out.
    */

    
    /*
        The request should be valid at this point, go ahead and create
        the Book object.
    */

    
    /*
        Add the new Book to LIBRARY_TABLE_NAME. Keep the _id attribute.
    */

    
    /*
        Add a new entry to USER_BOOKS_TABLE_NAME. The "bookId" attribute should
        be an ObjectId representing the newly added book, and the "userId" attribute
        should be an ObjectId representing the user who made the request.
    */

    
    /*
        If everything was successful up to this point, return a success and close the
        MongoDB client.
    */
}