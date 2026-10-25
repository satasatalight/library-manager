# Branch Naming
This is a monorepo with 3 different projects inside it. As such, make sure your branch naming is super clear as to WHAT your PR is editing. 

Add a suffix to your branch based on what project you are editing. For example, a PR for Frontend should be named ```frontend/[short description of the feature / fix]```. Changes to the general repository are given the suffix ```meta/```.

Do **NOT** make changes to multiple projects in one PR. A frontend PR should only add a feature / fix to the frontend.

# Frontend
The frontend is hosted on GitHub Pages at the default URL (https://satasatalight.github.io/library-manager/). All changes to the ```main``` branch are automatically built and uploaded on there.
## Quick Start:
- Clone this repository
- Install [Node.js](https://nodejs.org/en)
- Open the root of the frontend ```./frontend``` in a terminal 
- Run ```npm i``` to install all dependencies (may take a while)
- Run ```npm run dev``` to view the current website in a browser
## What is the `gh-pages` branch?
You might notice a branch called `gh-pages` on the repo. This is a branch that automatically updates with a built version of the frontend on pushes to the `main` branch. Basically, this is the root folder that GitHub Pages is hosted on. Do **NOT** make any manual commits to this branch.
## Useful Commands:
| Command | Description |
| ------------- | ------------- |
| ```npm run dev``` | Runs your code in a browser and updates live as you make changes |
| ```npm run build``` | Compiles the final website into JavaScript and saves it into ```./build/client``` |
| ```npm run preview``` | Views the compiled website as it would appear when hosted on the GitHub Pages URL |
| ```npm run lint``` | Runs the linter (eslint), which reports bad coding practices |
| ```npm run typecheck``` | Checks the validity of your TypeScript typings |
| ```npm run format``` | Refactors your code to an easy-to-read format (run last before creating a PR) |
## Project structure:
All website files in this project are under ```/app```. You will mainly be editing under ```/components``` and ```/routes```
- ```/routes```: Declares a page in the project. For example: creating a file named "Test.tsx" here would refer to https://satasatalight.github.io/library-manager/Test on the production site. "_index" is a special filename that refers to the root of the project.
    - We are using [React Router's Filename Routing](https://reactrouter.com/how-to/file-route-conventions) for this project. Read the docs if you need to make a more complicated route.
- ```/components```: Declares a reusable component in the project that can imported by larger pages for their logic. This should be where the majority of logic will be implemented.
- ```/sass/styles.scss```: Declares any overrides / custom styles on top of [Bootstrap 5.3](https://getbootstrap.com/docs/5.3/getting-started/introduction/). You probably won't need to edit this.
    - Bootstrap is a "component library", or set of pre-existing CSS classes. The point of the library is to minimize the amount of CSS written in a project, as it's classes cover most styles. As such, we will NOT be writing any manual CSS in this project (unless we implement animations later, probably a stretch goal).
- ```/assets```: Directory for any miscellanous imports. We'll probably only use it store images and icons. Right now it just has the default template files, feel free to delete.
## Useful Library Docs:
- [Bootstrap](https://getbootstrap.com/docs/5.3/getting-started/introduction/) for styling
- [Axios](https://axios.rest/pages/getting-started/examples/typescript.html) for API calls
- [React](https://react.dev/reference/react) for pretty much everything else

# Backend
The backend is hosted using Vercel on https://library-manager-ashy.vercel.app/. All changes to the main branch are automatically uploaded on there.
## Quick Start:
- Clone this repository
- Download the `.env` file provided in the Discord and place it in the root of the backend
- Run ```npm i``` to install all dependencies (may take a while)
- Run `npm run dev` to start the node server locally
## Useful Commands:
| Command | Description |
| ------------- | ------------- |
| ```npm run dev``` | Runs your server locally and updates live as you make changes |
| ```npm test``` | Run all unit tests |
| ```npm run lint``` | Runs the linter (eslint), which reports bad coding practices |
| ```npm run typecheck``` | Checks the validity of your TypeScript typings |
| ```npm run format``` | Refactors your code to an easy-to-read format (run last before creating a PR) |
## Project Structure:
All server files are under `/src`, you will mainly be editing under `/endpoints`, `/tests`, and `app.ts`
- `app.ts`: Import the endpoint function, set the input typing, and set it's routing 
- `/endpoints`: Write the actual logic for an endpoint to be imported into `app.ts`
- `/tests`: Write a unit test for an endpoint
- 'config.ts':
## Note on Vercel:
Vercel is a [stateless](https://amitranjan.vercel.app/system-design/stateful-vs-stateless-servers) server host. Basically that means that all local variables are wiped on the next API call and all important data should be uploaded to the database.

This will probably not be important for the overall implementation (we didn't write any stateful API calls in the last project) but I thought I would mention it in case you see any issues with an endpoint on the production server that you cannot replicate locally.
## Useful Library Docs:
- [Express](https://expressjs.com/en/5x/api/) for getting / sending data
    - Mostly the [Request](https://expressjs.com/en/5x/api/request/) and [Response](https://expressjs.com/en/5x/api/response/) objects
- [node-jsonwebtoken](https://github.com/auth0/node-jsonwebtoken#readme) for handling JWTs
- [mongodb node driver](https://www.mongodb.com/resources/languages/mongodb-and-npm-tutorial) for connecting to the database

# Mobile:
![im workin on it](https://files.catbox.moe/1n1j7t.jpg)