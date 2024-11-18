import http from 'k6/http';

const url = __ENV.URL;

export const options = {
  scenarios: {
    open_model: {
      executor: 'ramping-arrival-rate',
      preallocatedVUs: 1
    }
  }
};

export default function() {
  http.get(url);
}