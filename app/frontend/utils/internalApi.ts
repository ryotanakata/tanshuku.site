import axios from "axios";
import { INTERNAL_API_ENDPOINTS } from "@/constants/internalApiEndpoints";

const apiClient = axios.create({ baseURL: "/api/" });

apiClient.interceptors.request.use(
  (config) => {
    const token = document.querySelector<HTMLMetaElement>(
      'meta[name="csrf-token"]'
    )?.content;
    if (token) {
      config.headers["X-CSRF-TOKEN"] = token;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    console.error("API Error:", error.response?.data);
    return Promise.reject(error);
  }
);

/**
 * 短縮URLをサーバーに作成するリクエストを送信します。
 * @param url オリジナルURLを含むオブジェクト
 * @returns axiosのレスポンスPromise
 */
const fetchShotendUrl = (url: string) => {
  return apiClient.post(INTERNAL_API_ENDPOINTS.URL, { url });
};

export { fetchShotendUrl };
