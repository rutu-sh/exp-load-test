import http from 'k6/http';

const url = __ENV.URL;

export const options = {
  scenarios: {
    closed_model: {
      executor: 'constant-vus',
    }
  }
};

export default function() {
  http.get(url);
}