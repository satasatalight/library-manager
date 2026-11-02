import { getMongoClient } from '../app.ts';
import type { Response } from 'express';
import type { MongoClient } from 'mongodb';

import type { PendingVerificationEntry } from './register.ts';

interface VerifyBody {
    email: string;
    code: number;
}

let mongoClient: MongoClient;
const DB_NAME = 'litlog';
const USERS_TABLE_NAME = 'users';
const VERIFY_TABLE_NAME = 'pendingVerification';

async function fetchVerifyData(email: string): Promise<PendingVerificationEntry | null> {
    return await mongoClient.db(DB_NAME)
    .collection<PendingVerificationEntry>(VERIFY_TABLE_NAME)
    .findOne({email: email});
}

export default async function verify(req: VerifyBody, res: Response) {
    if (!req.email || !req.code) {
        return res.status(400).send({
            status: "error",
            reason: "Malformed input. Missing email and/or code."
        })
    }

    mongoClient = await getMongoClient();
    let verifyEntry = fetchVerifyData(req.email);
    if (verifyEntry == null) {
        return res.status(404).send({
            status: "error",
            reason: "We could not find your email. Please ensure you have registered your account. If you are still receiving this error, please ensure your email is correct."
        });
    }
}