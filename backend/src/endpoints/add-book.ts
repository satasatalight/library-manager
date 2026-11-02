import type { Response } from 'express';
import jwt, { JsonWebTokenError, TokenExpiredError } from 'jsonwebtoken';
import { Db, MongoClient, type Document, type InsertOneResult, type ObjectId, type WithId } from 'mongodb';

import { getMongoClient } from '../app.ts';
import config from '../config.ts';

const { verify } = jwt;

interface NewBook
{
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
    // Check if the token is provided.
    if(!req.token)
    {
        return res.status(401).send({
            status: 'error',
            reason: 'Your session is invalid. Please login again.',
            book_id: null
        });
    }

    // Check if the token is valid and can be verified.
    let user_id: ObjectId | undefined;
    interface JWTBody{ userId: ObjectId; }

    try
    {
        const verified_token = verify(req.token, config.jwt_key) as JWTBody;
        user_id = verified_token.userId;
    }
    catch(error)
    {
        if(error instanceof JsonWebTokenError) // Token improperly formatted.
        {
            return res.status(400).send({
                status: 'error',
                reason: 'Your session may have been tampered with. Please login again.',
                book_id: null
            });
        }
        else if(error instanceof TokenExpiredError) // Token expired
        {
            return res.status(401).send({
                status: 'error',
                reason: 'Your token has expired. Please login again.',
                book_id: null
            });
        }
        else
        {
            return res.status(500).send({
                status: 'error',
                reason: 'An unknown error occurred.',
                book_id: null
            });
        }
    }
    
    /*
        Check if the necessary "title" field is filled out.
    */
    if(!req.title || req.title === "")
    {
        return res.status(400).send({
            status: 'error',
            reason: 'Please give the book a title.',
            book_id: null
        });
    }
    
    /*
        The request should be valid at this point, go ahead and create
        the Book object.
    */
    const NewBook: NewBook =
    {
        title: req.title,
        author: req.author,
        genre: req.genre,
        publication_year: req.publication_year,
        description: req.description,
        cover_image: req.cover_image
    };

    /*
        Add the new Book to LIBRARY_TABLE_NAME. Keep the _id attribute.
    */
    mongoClient = await getMongoClient();
    const book_id: ObjectId | undefined = await createBook(NewBook);
    if(typeof book_id === "undefined")
    {
        return res.status(500).send({
                status: 'error',
                reason: 'An unknown error occurred with the database.',
                book_id: null
            });
    }

    /*
        Add a new entry to USER_BOOKS_TABLE_NAME. The "bookId" attribute should
        be an ObjectId representing the newly added book, and the "userId" attribute
        should be an ObjectId representing the user who made the request.
    */
    const entry_id_for_request: ObjectId | undefined = await giveBookToUser(user_id, book_id);
    if(typeof entry_id_for_request === "undefined")
    {
        return res.status(500).send({
                status: 'error',
                reason: 'An unknown error occurred with the database.',
                book_id: null
            });
    }

    /*
        If everything was successful up to this point, return a success and close the
        MongoDB client.
    */
    await mongoClient.close();
    return res.status(200).send({
        status: 'success',
        reason: 'Book successfully added.',
        book_id: entry_id_for_request
    });
}

async function createBook(entry: NewBook): Promise<ObjectId | undefined>
{
    let result: InsertOneResult<Document>;
    try
    {
        result = await mongoClient
        .db(DB_NAME)
        .collection(LIBRARY_TABLE_NAME)
        .insertOne(entry);
    }
    catch
    {
        return undefined;
    }

    return result.insertedId;
}

async function giveBookToUser(user: ObjectId, book: ObjectId): Promise<ObjectId | undefined>
{
    let result: InsertOneResult<Document>;
    try
    {
        result = await mongoClient
        .db(DB_NAME)
        .collection(USER_BOOKS_TABLE_NAME)
        .insertOne({
            bookId: book,
            userId: user
        });
    }
    catch
    {
        return undefined;
    }

    return result.insertedId;
}