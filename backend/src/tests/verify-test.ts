import { ImapFlow } from 'imapflow';
import { simpleParser } from 'mailparser';
import assert from 'node:assert';
import { randomUUID } from 'node:crypto';
import { describe, it } from 'node:test';
import request from 'supertest';

import app from '../app.ts';
import config from '../config.ts';

interface ResponseBody {
  status: string;
  reason: string;
}

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

interface VerificationEmailOptions {
  email: string;
  timeoutMs?: number;
  pollIntervalMs?: number;
}

export async function getVerificationCode({
  email,
  timeoutMs = 15_000,
  pollIntervalMs = 1_000,
}: VerificationEmailOptions): Promise<string> {
  const client = new ImapFlow({
    host: 'imap.ethereal.email',
    port: 993,
    secure: true,
    auth: {
      user: config.email_user,
      pass: config.email_pass,
    },
    logger: false,
  });

  await client.connect();

  try {
    const deadline = Date.now() + timeoutMs;

    while (Date.now() < deadline) {
      const lock = await client.getMailboxLock('INBOX');

      try {
        const uids = await client.search({ to: email }, { uid: true });

        if (Array.isArray(uids)) {
          // Check newest messages first
          for (const uid of [...uids].reverse()) {
            const message = await client.fetchOne(
              uid,
              { source: true },
              { uid: true },
            );

            if (!message || !message.source) {
              continue;
            }

            const parsed = await simpleParser(message.source);

            const match = parsed.text?.match(/the code:\s*(\d{6})/i);

            if (match?.[1]) {
              return match[1];
            }
          }
        }
      } finally {
        lock.release();
      }

      await sleep(pollIntervalMs);
    }

    throw new Error(
      `Verification email not found for ${email} ` + `within ${timeoutMs}ms`,
    );
  } finally {
    await client.logout();
  }
}

describe('Test /users/register/verify POST endpoint', function () {
  it('Send verify request', function () {
    const email = `dummy-${randomUUID()}@testing1.email`;

    return request(app)
      .post('/users/register')
      .send({
        email: email,
        first_name: 'Dummy',
        last_name: 'Dummy',
        password: 'DummyAintNoDummy',
      })
      .expect('Content-Type', 'application/json; charset=utf-8')
      .expect(200)
      .then(async () => {
        const code: number = parseInt(
          await getVerificationCode({ email: email }),
        );

        return request(app)
          .post('/users/register/verify')
          .send({
            email: email,
            code: code,
          })
          .expect('Content-Type', 'application/json; charset=utf-8')
          .expect(200)
          .then((response) => {
            const { status, reason } = response.body as ResponseBody;
            assert.equal(status, 'success');
            assert.equal(
              reason,
              'Your email has been verified. You may now log in using your username and password.',
            );
          });
      });
  });
});
