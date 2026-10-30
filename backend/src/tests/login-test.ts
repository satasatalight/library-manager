import assert from 'node:assert';
import { describe, it } from 'node:test';
import request from 'supertest';

import app from '../app.ts';

interface ResponseBody {
  status: string;
  reason: string;
  token: string | null;
}

describe('Test /users/login POST endpoint', function () {
  it('Checks if credentials are valid and email is verified, and returns a token if so.', function () {
    return request(app)
      .post('/users/login')
      .send({
        email: 'example@testing.email',
        password: 'examplepassword',
      })
      .expect('Content-Type', 'application/json; charset=utf-8')
      .expect(200)
      .then((response) => {
        const { status, reason, token } = response.body as ResponseBody;
        assert.equal(status, 'success');
        assert.equal(reason, 'Your login attempt was successful.');
        assert.notEqual(token, null);
      });
  });
});
