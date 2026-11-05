import type { Response } from "express"

export interface resetRequestBody {
    email: string
}

async function emailExists(email: string): Promise<boolean> {

}
async function storeResetCode(email: string, code: number): Promise<boolean> {

}
async function emailResetCode(email: string, code: number): Promise<boolean> {

}

export default async function resetRequest(req: resetRequestBody, res: Response) {
    
}