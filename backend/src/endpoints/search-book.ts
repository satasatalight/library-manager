import { getMongoClient, transporter } from '../app.ts';
import config from '../config.ts';
import type { Response } from 'express';

export interface SearchBody {
    search_string: string;
    token: string;
}

export default async function search(req: SearchBody, res: Response) {
    if (!req.token) {
        return res.status(401).send({
            status: 'error',
            reason: 'Your session is invalid. Please login again.',
            library: null
        });
    }

    
}