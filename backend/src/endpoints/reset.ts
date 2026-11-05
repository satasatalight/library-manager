import { getMongoClient } from "../app.ts";
import type { Response } from "express";
import type { MongoClient } from "mongodb";
import { hash } from "node:crypto";
import { type DatabaseUserEntry, type PendingVerificationEntry } from "./register.ts";

export interface ResetBody {
    email: string;
    code: number;
    new_password: string;
}
let mongoClient: MongoClient;
const DB_NAME = "litlog";
const USERS_TABLE_NAME = "users";
const VERIFY_TABLE_NAME = "pendingVerification";
const EXPIRY_TIME_DAYS = 7;

async function getVerificationEntry(email: string): Promise<PendingVerificationEntry | null> {
    try {
        return mongoClient
        .db(DB_NAME)
        .collection<PendingVerificationEntry>(VERIFY_TABLE_NAME)
        .findOne({ email: email });
    } catch {
        return null;
    }
}
function hashPassword(pass: string): string {
    return hash('sha256', pass);
}
async function storeNewPass(email: string, pass: string): Promise<boolean> {
    let hashedPass: string = hashPassword(pass);

    try {
        await mongoClient
        .db(DB_NAME)
        .collection<DatabaseUserEntry>(USERS_TABLE_NAME)
        .updateOne({ email: email }, { $set: { password: hashedPass }});
    } catch {
        return false;
    }
    return true;
}

export default async function reset(req: ResetBody, res: Response) {
    if (!req.code || !req.email || !req.new_password) {
        return res.status(400).send({
            status: "error",
            reason: "Malformed input. Missing JSON variables."
        });
    }

    mongoClient = await getMongoClient();

    const entry: PendingVerificationEntry | null = await getVerificationEntry(req.email);
    if (entry == null) {
        return res.status(404).send({
            status: "error",
            reason: "Could not find a reset code matching this email."
        });
    }

    if (entry.code != req.code || entry.expiry < Date.now()) {
        return res.status(401).send({
            status: "error",
            reason: "This code is invalid. Please try again."
        });
    }

    if (await storeNewPass(req.email, req.new_password) == false) {
        return res.status(500).send({
            status: "error",
            reason: "We were unable to set your new password. Please try again later."
        });
    }

    return res.status(200).send({
        status: "success",
        reason: "Your password has been reset. Please login using the new password."
    });
}