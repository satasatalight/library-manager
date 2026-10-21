// use 'config' object to retrieve enviornment variables

import dotenv from 'dotenv';

dotenv.config();

interface Config {
    port: number;
}

const config: Config = {
    port: Number(process.env.port)
};

export default config;