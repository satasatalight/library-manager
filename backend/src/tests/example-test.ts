import assert from 'node:assert';
import { describe, it } from 'node:test';
import request from 'supertest';

import app from '#src/app.ts';

describe('test /example POST endpoint', function () {
  it('sends hello world + the message back', function () {
    return request(app)
      .post('/example')
      .send({ message: 'test' })
      .expect('Content-Type', /text/)
      .expect('Content-Length', '27')
      .expect(200)
      .then((response) => {
        assert.equal(response.text, 'Hello World.\nYou sent: test');
      });
  });
});
