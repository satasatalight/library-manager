import assert from 'node:assert';
import { describe, it } from 'node:test';
import request from 'supertest';

import app from '../app.ts';



interface ViewLibraryResponseBody
{
    status: string;
    reason: string;
    library: string | null
}

interface LoginResponseBody {
  status: string;
  reason: string;
  token: string | null;
}

describe('Test /library/view endpoint', function () {
  it('Attempts to retrieve all books in the library of the user', async function () {
    await request(app)
      .post('/users/login')
      .send({
        email: 'authenticated@guy.com',
        password: 'theverifiedguy',
      })
      .then((response) => {
        const body = response.body as LoginResponseBody;

        return request(app)
          .post('/library/view')
          .send({
            token: body.token,
          })
          .expect('Content-Type', 'application/json; charset=utf-8')
          .expect(200)
          .then((response) => {
            const { status, reason, library } =
              response.body as ViewLibraryResponseBody;
            assert.equal(status, 'success');
            assert.ok(['No books found in user library.', 'book data obtained'].includes(reason));
            assert.notEqual(library, null);
          });
      });
  });
});