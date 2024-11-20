import http from 'k6/http';

const url = __ENV.URL;

export const options = {
  scenarios: {
    open_model: {
      executor: 'constant-arrival-rate',
      rate: 100, // Number of iterations per time unit
      timeUnit: '1s', // Time unit for the rate
      duration: '60s',
      preAllocatedVUs: 100, // Number of VUs to pre-allocate
      maxVUs: 200, // Maximum number of VUs to allow
    }
  }
};

export default function() {
  http.get(url);
}