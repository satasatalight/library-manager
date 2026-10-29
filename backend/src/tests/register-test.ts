import assert from 'node:assert';
import { describe, it } from 'node:test';
import request from 'supertest';

import app from '../app.ts';

describe('Test /users/register POST endpoint', function () {
  it('Registers a user, sends an email, and returns status', function () {
    return request(app)
      .post('/users/register')
      .send({ email: 'dummy@testing.email',
        first_name: 'Dummy',
        last_name: 'Dummy',
        password: 'DummyAintNoDummy'
       })
      .expect('Content-Type', 'application/json')
      .expect(200)
      .then((response) => {
        const { status, reason } = response.body;
        assert.equal(status, 'success');
        assert.equal(reason, 'Your account has been registered. Please verify your email.');
      });
  });
});