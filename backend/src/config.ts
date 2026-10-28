// use 'config' object to retrieve enviornment variables
import dotenv from 'dotenv';

dotenv.config();

interface Config {
  port: number;
  mongo_uri: string;
  jwt_key: string;
}

const config: Config = {
  port: Number(process.env.PORT),
  mongo_uri: String(process.env.MONGODB_URI),
  jwt_key: String(process.env.JWT_KEY),
};

export default config;
