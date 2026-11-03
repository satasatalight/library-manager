import assert from 'node:assert';
import { describe, it } from 'node:test';
import request from 'supertest';

import app from '../app.ts';

interface ResponseBody {
  status: string;
  reason: string;
  book_id: string | null;
}

describe('Test /library/add POST endpoint', function () {
  it('Attempts to add a new book to a user library', function () {
    return request(app)
      .post('/library/add')
      .send({
        title: 'Example Book',
        author: 'Johnny Appleseed',
        genre: 'One of them',
        publication_year: '1970',
        description: 'This is a book that was never written.',
        cover_image: null,
        token: '[PASTE TOKEN HERE]',
      })
      .expect('Content-Type', 'application/json; charset=utf-8')
      .expect(200)
      .then((response) => {
        const { status, reason, book_id } = response.body as ResponseBody;
        assert.equal(status, 'success');
        assert.equal(reason, 'Book successfully added.');
        assert.notEqual(book_id, null);
      });
  });
});
