import assert from 'node:assert';
import { describe, it } from 'node:test';
import request from 'supertest';

import app from '../app.ts';
import type { Book } from '../endpoints/search-book.ts';

interface LoginResponseBody {
  status: string;
  reason: string;
  token: string | null;
}
interface ResponseBody {
  status: string;
  reason: string;
  library: Book[];
}

describe('Test /library/search endpoint', function () {
  it('Logs in and searches for an expected book', async function () {
    // TODO: Implement test
    await request(app)
      .post('/users/login')
      .send({
        email: 'authenticated@guy.com',
        password: 'theverifiedguy',
      })
      .expect(200)
      .then(async (response) => {
        const token = (response.body as LoginResponseBody).token;

        // add example book to search
        await request(app).post('/library/add').send({
          title: 'Endpoint Test Book',
          author: 'Testing Search',
          genre: 'Test',
          publication_year: '1970',
          description: 'This is a book that was never written.',
          cover_image: null,
          token: token,
        });

        // run search test
        const result = await request(app)
          .post('/library/search')
          .send({
            token: token,
            search_string: 'Endpoint',
          })
          .expect(200);

        // verify test success
        const body = result.body as ResponseBody;
        assert.equal(body.status, 'success');
        assert.equal(body.reason, 'book data obtained');
        assert.equal(body.library.at(0)?.title, 'Endpoint Test Book');

        // remove example book from library
        await request(app)
          .post('/library/delete')
          .send({
            book_id: body.library.at(0)?.bookId,
            token: token,
          });

        return result;
      });
  });
});
