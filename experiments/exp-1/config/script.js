import http from 'k6/http';

const url = __ENV.URL;

export const options = {
  scenarios: {
    open_model: {
      executor: 'constant-arrival-rate',
      vus: 100,
      duration: '60s',
    }
  }
};

export default function() {
  http.get(url);
}