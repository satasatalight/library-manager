import assert from 'node:assert';
import { describe, it } from 'node:test';
import request from 'supertest';

import app from '../app.ts';

interface ResponseBody {
  status: string;
  reason: string;
  library: object;
}

describe('Test /library/search endpoint', function () {
  it('Logs in and searches for an expected book', function () {
    // TODO: Implement test
    return request(app)
      .post('/users/register')
      .send({
        email: 'dummy@testing.email',
        first_name: 'Dummy',
        last_name: 'Dummy',
        password: 'DummyAintNoDummy',
      })
      .expect('Content-Type', 'application/json; charset=utf-8')
      .expect(200)
      .then((response) => {
        const { status, reason } = response.body as ResponseBody;
        assert.equal(status, 'success');
        assert.equal(
          reason,
          'Your account has been registered. Please verify your email.',
        );
      });
  });
});