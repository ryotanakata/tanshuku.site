import axios from "axios";

const apiClient = axios.create();

apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    console.error("API Error:", error.response?.data);
    return Promise.reject(error);
  }
);
