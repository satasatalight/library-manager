import config from "../config.ts";
import { getMongoClient } from "../app.ts";
import type { Response } from "express"
import type { MongoClient } from "mongodb";
import nodemailer from "nodemailer";
import { randomInt } from "node:crypto";

export interface ResetRequestBody {
    email: string
}
let mongoClient: MongoClient;
const DB_NAME = "litlog";
const USERS_TABLE_NAME = "users";
const VERIFY_TABLE_NAME = "pendingVerification";
const EXPIRY_TIME_DAYS = 7;

async function emailExists(email: string): Promise<boolean> {
    try {
        const collection = mongoClient.db(DB_NAME).collection(USERS_TABLE_NAME);
        return collection.findOne({ email: email }) != null;
    } catch {
        return false;
    }
}
async function storeResetCode(email: string, code: number): Promise<boolean> {
    try {
        const collection = mongoClient.db(DB_NAME).collection(VERIFY_TABLE_NAME);
        collection.updateOne({ email: email }, 
            { $set: { code: code, expiry: Date.now() + (EXPIRY_TIME_DAYS * 24 * 60 * 60 * 1000)}}
        );
    } catch {
        return false;
    }
    return true;
}
async function emailResetCode(email: string, code: number) {
    try {
        const transporter = nodemailer.createTransport({
            service: 'Ethereal',
            secure: false,
            auth: {
            user: config.email_user,
            pass: config.email_pass,
            },
        });

        const info = await transporter.sendMail({
            from: `"LitLog" <${config.email_user}>`,
            to: email,
            subject: 'LitLog: Reset your password',
            html:
            '<p>Use the code to reset your password: <b>' +
            code +
            '</b><br /><br />If you did not request a password change, ignore this email.' +
            '<br /><br />Sincerely, <b>LitLog</b>.</p>',
        });
        console.log('Message sent: %s', info.messageId);
        console.log('Preview: %s', nodemailer.getTestMessageUrl(info));
    } catch {
        return false;
    }
    return true;
}

export default async function resetRequest(req: ResetRequestBody, res: Response) {
    if (!req.email) {
        return res.status(400).send({
            status: "error",
            reason: "Malformed input. Please provide an email."
        });
    }

    mongoClient = await getMongoClient();

    if (await emailExists(req.email) == false) {
        return res.status(404).send({
            status: "error",
            reason: "We could not find your email. Please ensure you have entered a valid email address."
        });
    }

    let code: number = randomInt(100000, 1000000);
    if (await storeResetCode(req.email, code) == false) {
        return res.status(500).send({
            status: "error",
            reason: "Server database temporarily unavailable. Please try again later."
        });
    }

    if (await emailResetCode(req.email, code) == false) {
        return res.status(500).send({
            status: "error",
            reason: "We could not send the reset code to your email. Please try again later."
        });
    }

    return res.status(200).send({
        status: "success",
        reason: "A password reset email has been sent. Please check your email."
    })
}