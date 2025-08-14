import axios from 'axios'

/**
 * axiosの設定とインターセプターを初期化する
 * @returns クリーンアップ関数
 */
export const initializeAxios = () => {
  const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')

  if (token) {
    axios.defaults.headers.common['X-CSRF-Token'] = token
  }

  axios.defaults.headers.common['Content-Type'] = 'application/json'
  axios.defaults.headers.common['Accept'] = 'application/json'

  const requestInterceptor = axios.interceptors.request.use(
    (config) => {
      console.log('Sending request:', config.method?.toUpperCase(), config.url)
      return config
    },
    (error) => {
      return Promise.reject(error)
    }
  )

  const responseInterceptor = axios.interceptors.response.use(
    (response) => {
      console.log('Response received:', response.status, response.config.url)
      return response
    },
    (error) => {
      // エラーレスポンスのログ
      if (error.response) {
        console.error('Response error:', error.response.status, error.response.data)
      } else if (error.request) {
        console.error('Request error:', error.message)
      } else {
        console.error('Error:', error.message)
      }
      return Promise.reject(error)
    }
  )

  // クリーンアップ関数
  return () => {
    axios.interceptors.request.eject(requestInterceptor)
    axios.interceptors.response.eject(responseInterceptor)
  }
}

/**
 * axiosの設定をリセットする
 */
export const resetAxios = () => {
  axios.defaults.headers.common = {}
  axios.interceptors.request.clear()
  axios.interceptors.response.clear()
}
