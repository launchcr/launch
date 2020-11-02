import Axios from "axios";

const urls = {
  test: `http://localhost:3001`,
  development: 'http://localhost:3001/',
  production: 'https://your-production-url.com/'
}

const api = Axios.create({
  baseURL: urls[process.env.NODE_ENV],
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  }
});

api.interceptors.response.use((response) => response, (err) => {
  // Insert custom logic for universal error handling.
  // You can still `catch` errors on a case by case basis.
  throw err
});

export default api;