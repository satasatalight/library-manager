import { JsonWebTokenError, TokenExpiredError, verify } from 'jsonwebtoken';
import { getMongoClient, transporter } from '../app.ts';
import config from '../config.ts';
import type { Response } from 'express';
import type { Collection, MongoClient, ObjectId } from 'mongodb';

export interface SearchBody {
    search_string: string;
    token: string;
}
const DB_NAME = 'litlog';
const USER_BOOKS_TABLE_NAME = 'userBooks';
const LIBRARY_TABLE_NAME = 'library';
interface UserBookEntry {
    book_id: ObjectId;
    user_id: ObjectId;
}
interface BookEntry {
    book_id: ObjectId;
    title: string;
    author: string | null;
    genre: string | null;
    publication_year: number | null;
    description: string | null;
    cover_image: URL | null;
}

async function getBooks(query: string, user_id: ObjectId): Promise<BookEntry[]> {
    let mongoClient: MongoClient = await getMongoClient();
    const userBookRelations: Array<UserBookEntry> = await mongoClient
    .db(DB_NAME)
    .collection<UserBookEntry>(USER_BOOKS_TABLE_NAME)
    .find({ user_id: user_id }).toArray();
    
    const books: Array<BookEntry> = new Array<BookEntry>();
    userBookRelations.forEach(async (entry: UserBookEntry) => {
        const bookEntry: BookEntry | null = await mongoClient.db(DB_NAME)
        .collection<BookEntry>(LIBRARY_TABLE_NAME)
        .findOne({ book_id: entry.book_id });

        if (bookEntry == null) return;
        if (bookEntry.title.includes(query) ||
        (bookEntry.author != null && bookEntry.author.includes(query))) {
            books.push(bookEntry);
        }
    });

    return books;
}

export default async function search(req: SearchBody, res: Response) {
    if (!req.token) {
        return res.status(401).send({
            status: 'error',
            reason: 'Your session is invalid. Please login again.',
            library: null
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


}