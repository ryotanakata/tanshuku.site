import { useState, useEffect } from 'react'
import axios from 'axios'

type ShortenedUrl = {
  original_url: string
  short_code: string
  short_url: string
  created_at: string
}

export default function App() {
  const [url, setUrl] = useState<string>('')
  const [shortenedUrl, setShortenedUrl] = useState<ShortenedUrl | null>(null)
  const [loading, setLoading] = useState<boolean>(false)
  const [error, setError] = useState<string>('')

  // axiosの設定とインターセプター
  useEffect(() => {
    // CSRFトークンを取得してaxiosのデフォルトヘッダーに設定
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
    if (token) {
      axios.defaults.headers.common['X-CSRF-Token'] = token
    }

    // デフォルトのヘッダー設定
    axios.defaults.headers.common['Content-Type'] = 'application/json'
    axios.defaults.headers.common['Accept'] = 'application/json'

    // リクエストインターセプター
    const requestInterceptor = axios.interceptors.request.use(
      (config) => {
        // リクエスト送信前のログ
        console.log('Sending request:', config.method?.toUpperCase(), config.url)
        return config
      },
      (error) => {
        return Promise.reject(error)
      }
    )

    // レスポンスインターセプター
    const responseInterceptor = axios.interceptors.response.use(
      (response) => {
        // 成功レスポンスのログ
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
  }, [])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      const response = await axios.post('/api/urls', { url })
      setShortenedUrl(response.data)
      setUrl('')
    } catch (err: any) {
      if (err.response) {
        // サーバーからのエラーレスポンス
        setError(err.response.data.error || '短縮URLの作成に失敗しました')
      } else if (err.request) {
        // リクエストは送信されたがレスポンスがない
        setError('サーバーからの応答がありません')
      } else {
        // リクエストの設定時にエラーが発生
        setError('ネットワークエラーが発生しました')
      }
    } finally {
      setLoading(false)
    }
  }

  const copyToClipboard = async (text: string) => {
    try {
      await navigator.clipboard.writeText(text)
      alert('クリップボードにコピーしました！')
    } catch (err) {
      alert('コピーに失敗しました')
    }
  }

  return (
    <div className="container">
      <h1>短縮URLサービス</h1>
      <form onSubmit={handleSubmit}>
        <input
          type="url"
          value={url}
          onChange={(e) => setUrl(e.target.value)}
          placeholder="短縮したいURLを入力してください"
          required
          disabled={loading}
        />
        <button type="submit" disabled={loading}>
          {loading ? '処理中...' : '短縮する'}
        </button>
      </form>

      {error && (
        <div className="error">
          <p>{error}</p>
        </div>
      )}

      {shortenedUrl && (
        <div className="result">
          <h3>短縮完了！</h3>
          <div className="url-info">
            <p><strong>元のURL:</strong> {shortenedUrl.original_url}</p>
            <p><strong>短縮URL:</strong>
              <a href={shortenedUrl.short_url} target="_blank" rel="noopener noreferrer">
                {shortenedUrl.short_url}
              </a>
              <button
                onClick={() => copyToClipboard(shortenedUrl.short_url)}
                className="copy-btn"
              >
                コピー
              </button>
            </p>
            <p><strong>作成日時:</strong> {new Date(shortenedUrl.created_at).toLocaleString('ja-JP')}</p>
          </div>
        </div>
      )}
    </div>
  )
}