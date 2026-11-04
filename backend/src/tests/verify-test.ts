import assert from 'node:assert';
import { describe, it } from 'node:test';
import request from 'supertest';

import app from '../app.ts';

interface ResponseBody {
  status: string;
  reason: string;
}

describe('Test /users/register/verify POST endpoint', function () {
  it('Send verify request', function () {
    return request(app)
      .post('/users/register/verify')
      .send({
        email: 'thomas@testing2.email',
        code: 276352,
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
