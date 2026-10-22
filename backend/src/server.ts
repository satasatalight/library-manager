import logger from 'jet-logger';

import app from './app.ts';
import config from './config.ts';

const SERVER_START_MESSAGE = `Express server started on port: ${config.port}`;

// Start the server
app.listen(config.port, (err) => {
  if (!!err) {
    logger.err(err.message);
  } else {
    logger.info(SERVER_START_MESSAGE);
  }
});
