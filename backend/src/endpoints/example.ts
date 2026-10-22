import type { Response } from 'express';

export default function example(message: string, res: Response) {
  return res.send('Hello World.\nYou sent: ' + message);
}
