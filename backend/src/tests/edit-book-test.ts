import assert from 'node:assert';
import { describe, it } from 'node:test';
import request from 'supertest';

import app from '../app.ts';

interface EditBookResponseBody
{
    status: string;
    reason: string;
}

interface AddBookResponseBody {
  status: string;
  reason: string;
  book_id: string | null;
}

interface LoginResponseBody {
  status: string;
  reason: string;
  token: string | null;
}

describe('Test /library/add POST endpoint', function () {
  it('Attempts to add a new book to a user library', function () {
    request(app)
      .post('/users/login')
      .send({
        email: 'authenticated@guy.com',
        password: 'theverifiedguy',
      })
      .then((response) => {
        const login_body = response.body as LoginResponseBody;

        return request(app)
          .post('/library/add')
          .send({
            title: 'Example Book',
            author: 'Johnny Appleseed',
            genre: 'One of them',
            publication_year: '1970',
            description: 'This is a book that was never written.',
            cover_image: null,
            token: login_body.token
          })
          .expect('Content-Type', 'application/json; charset=utf-8')
          .expect(200)
          .then((response) => {
            const add_body = response.body as AddBookResponseBody;
            
            return request(app)
            .post('/library/edit')
            .send({
                book_id: add_body.book_id,
                title: 'Edited Example Book',
                author: 'Johnny Editseed',
                genre: 'One of the edited ones',
                publication_year: "1970",
                description: 'This is an edited book that was never written.',
                cover_image: null,
                token: login_body.token
            })
            .expect('Content-Type', 'application/json; charset=utf-8')
            .expect(200)
            .then((response) => {
                const { status, reason } = response.body as EditBookResponseBody;
                assert.equal(status, 'success');
                assert.equal(reason, 'Book successfully edited.');
            });
          });
      });
  });
});