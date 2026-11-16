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
interface LoginResponseBody {
  status: string;
  reason: string;
  token: string;
}

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));
export async function getVerificationCode(email: string): Promise<string> {
  const timeoutMs = 15_000;
  const pollIntervalMs = 1_000;

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

            const match = parsed.text?.match(/your password:\s*(\d{6})/i);

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

describe('Test password reset endpoints', function () {
  it('Requests reset, then provides code', function () {
    const email = 'dummy.king@test.king';
    const new_password = randomUUID();

    return request(app)
      .post('/users/login/reset_request')
      .send({
        email: email,
      })
      .expect('Content-Type', 'application/json; charset=utf-8')
      .expect(200)
      .then(async (response) => {
        const { status, reason } = response.body as ResponseBody;
        assert.equal(status, 'success');
        assert.equal(
          reason,
          'A password reset email has been sent. Please check your email.',
        );

        const code: number = parseInt(await getVerificationCode(email));
        return request(app)
          .post('/users/login/reset')
          .send({
            email: email,
            code: code,
            new_password: new_password,
          })
          .expect('Content-Type', 'application/json; charset=utf-8')
          .expect(200)
          .then(async (response) => {
            const { status, reason } = response.body as ResponseBody;
            assert.equal(status, 'success');
            assert.equal(
              reason,
              'Your password has been reset. Please login using the new password.',
            );

            return request(app)
              .post('/users/login')
              .send({
                email: email,
                password: new_password,
              })
              .expect('Content-Type', 'application/json; charset=utf-8')
              .expect(200)
              .then((response) => {
                const { status, reason, token } =
                  response.body as LoginResponseBody;
                assert.equal(status, 'success');
                assert.equal(reason, 'Your login attempt was successful.');
                assert.notEqual(token, null);
              });
          });
      });
  });
});
