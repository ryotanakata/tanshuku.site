import axios from "axios";
import { EXTERNAL_API_ENDPOINTS } from "@/constants/externalApiEndpoints";

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
