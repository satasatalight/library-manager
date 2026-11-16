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
    .post("/users/login")
    .send({
        email: "authenticated@guy.com",
        password: "theverifiedguy"
    })
    .expect(200)
    .then((response) => {
        const body = response.body as LoginResponseBody;

        return request(app)
        .post("/library/search")
        .send({
            token: body.token,
            search_string: "Endpoint"
        })
        .expect(200)
        .then((response) => {
            const body = response.body as ResponseBody;
            assert.equal(body.status, "success");
            assert.equal(body.reason, "book data obtained");
            assert.equal(body.library.at(0)?.title, "Endpoint Test Book");
        })
    })
  });
});